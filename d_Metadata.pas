unit d_Metadata;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.
*)

(*
  Rationale:
  In the first iteration, a Virtual TreeView was used for the packages grid.
  It proved unsuitable for multi-record editing and violated Separation of Concerns.

  This data module hosts two FDMemTables:
    fdmMetadata      — editable package metadata; becomes the SBOM content.
    fdmSPDXLicenses  — read-only SPDX license reference data.

  The form uses an unbound TDBGrid (read-only, multi-select) for navigation
  and selection, and plain unbound edit controls for editing. No DB-aware
  edit controls are used, avoiding the single-vs-multi-record binding conflict.

  Premises:
  1. Dirty status is not tracked at the record level. All records are written
     back to the repository on Save.
  2. The total package count is small; performance is not a concern.

  Edit rules:
  - Display only (never edited): BomRef, Name, ComponentType, Hashes.
  - Editable (single and multi-record): Supplier, Version, SupplierURL, LicenseID,
    Description.
  - In ApplyEdits, an empty string means "skip this field". This is safe
    because a blank value is never a legitimate target in package metadata.

  Revert:
  PopulatePackages stores the supplied list. RevertPackages re-populates
  from that stored list, discarding all edits made since last load.

  Filtering:
  ShowIncompleteOnly / ShowAllPackages toggle a dataset filter for records
  with missing or placeholder supplier / license values.
*)

interface

uses
  System.Classes,
  Spring.Collections,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  i_PackageDataset,
  i_SBOMComponent,
  u_PackageMetadataRepository,
  u_SBOMEnums,
  u_SPDXLicenses;

type
  TdMetadata = class(TDataModule, IPackageDataset)
    fdmMetadata:                    TFDMemTable;
    fdmSPDXLicenses:                TFDMemTable;
    fdmMetadataBomRef:              TStringField;
    fdmMetadataName:                TStringField;
    fdmMetadataVersion:             TStringField;
    fdmMetadataComponentType:       TStringField;
    fdmMetadataSupplier:            TStringField;
    fdmMetadataSupplierURL:         TStringField;
    fdmMetadataLicenseID:           TStringField;
    fdmMetadataDescription:         TMemoField;
    fdmMetadataHashes:              TMemoField;
    fdmSPDXLicensesLicenseID:       TStringField;
    fdmSPDXLicensesName:            TStringField;
    fdmSPDXLicensesIsOsiApproved:   TBooleanField;
    fdmSPDXLicensesIsDeprecated:    TBooleanField;
    fdmSPDXLicensesSeeAlso:         TMemoField;
    procedure DataModuleCreate(Sender: TObject);
  private
    FOriginalList: IReadOnlyList<ISBOMComponent>;
    function ComponentTypeFromString(const AStr: string): TComponentType;
    function HashesToString(AHashes: IReadOnlyList<string>): string;
  public
    /// <summary>
    /// Populates fdmMetadata from the supplied component list.
    /// Stores the list so RevertPackages can restore it.
    /// </summary>
    procedure PopulatePackages(APkgList: IReadOnlyList<ISBOMComponent>);

    /// <summary>
    /// Populates fdmSPDXLicenses from the SPDX license manager.
    /// This dataset is read-only; the form uses it to populate
    /// the license combo box.
    /// </summary>
    procedure PopulateSPDX(ALicenseMgr: ISPDXLicenseManager);

    /// <summary>
    /// Applies edits to the records identified by ABookmarks.
    /// Any parameter that is an empty string is skipped for that field,
    /// allowing partial bulk updates.
    /// For a single-record edit, pass a one-element bookmark array.
    /// </summary>
    procedure ApplyEdits(ABookmarks: TArray<TBookmark>;
      const ASupplier, ASupplierURL, ALicenseID, ADescription: string);

    /// <summary>
    /// Writes all dataset rows back to the repository.
    /// Temporarily removes any active filter so all records are processed,
    /// then restores the filter state on exit.
    /// </summary>
    procedure UpdatePackages(APackageRepo: IPackageMetadataRepository);

    /// <summary>Discards all edits by repopulating from the stored original list.</summary>
    procedure RevertPackages;

    /// <summary>
    /// Filters fdmMetadata to show only records with a missing or
    /// placeholder supplier or license value.
    /// </summary>
    procedure ShowIncompleteOnly;

    /// <summary>Removes the incomplete filter and shows all package records.</summary>
    procedure ShowAllPackages;

    procedure LoadSPDXLicenses(const AExePath: string);

    // IPackageDataset
    procedure ApplyItemValues(
      const ABookmark:    TBookmark;
      const AVersion:     string;
      const ASupplier:    string;
      const ASupplierURL: string;
      const ALicenseID:   string;
      const ADescription: string);
    procedure DisableControls;
    procedure EnableControls;
    procedure FreeBookmark(const ABookmark: TBookmark);
    function  GetCurrentBookmark: TBookmark;
    procedure GotoBookmark(const ABookmark: TBookmark);
    function  IsEmpty: Boolean;
    function  ReadFieldAsString(const AFieldName: string): string;
  end;

var
  dMetadata: TdMetadata;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  System.IOUtils,
  System.TypInfo,
  u_DataSetUtils,
  u_FileFinders,
  u_Logger;

procedure TdMetadata.DataModuleCreate(Sender: TObject);
begin
  fdmMetadata.CreateDataSet;
  fdmSPDXLicenses.CreateDataSet;
end;

{ TdMetadata — private helpers }

function TdMetadata.ComponentTypeFromString(const AStr: string): TComponentType;
var
  Value: Integer;
begin
  Value := GetEnumValue(TypeInfo(TComponentType), AStr);
  if Value < 0 then
    Result := ctLibrary
  else
    Result := TComponentType(Value);
end;

function TdMetadata.HashesToString(AHashes: IReadOnlyList<string>): string;
var
  Hash: string;
  Parts: TArray<string>;
  I: Integer;
begin
  SetLength(Parts, AHashes.Count);
  I := 0;
  for Hash in AHashes do
  begin
    Parts[I] := Hash;
    Inc(I);
  end;
  Result := string.Join(',', Parts);
end;

{ TdMetadata — public interface }

procedure TdMetadata.PopulatePackages(
  APkgList: IReadOnlyList<ISBOMComponent>);
var
  Comp: ISBOMComponent;
begin
  FOriginalList := APkgList;

  fdmMetadata.EmptyDataSet;
  for Comp in APkgList do
  begin
    fdmMetadata.Append;
    fdmMetadataBomRef.AsString        := Comp.BomRef;
    fdmMetadataName.AsString          := Comp.Name;
    fdmMetadataVersion.AsString       := Comp.Version;
    fdmMetadataComponentType.AsString := GetEnumName(TypeInfo(TComponentType),
      Ord(Comp.ComponentType));
    fdmMetadataSupplier.AsString      := Comp.Supplier;
    fdmMetadataSupplierURL.AsString   := Comp.SupplierURL;
    fdmMetadataLicenseID.AsString     := Comp.LicenseID;
    fdmMetadataDescription.AsString   := Comp.Description;
    fdmMetadataHashes.AsString        := HashesToString(Comp.Hashes);
    fdmMetadata.Post;
  end;

  AutoSizeColumnsByChar(fdmMetadata);
end;

procedure TdMetadata.PopulateSPDX(ALicenseMgr: ISPDXLicenseManager);
var
  Licenses: IReadOnlyList<TSPDXLicense>;
  License:  TSPDXLicense;
begin
  Licenses := ALicenseMgr.GetAllLicenses;
  fdmSPDXLicenses.EmptyDataSet;
  for License in Licenses do
  begin
    fdmSPDXLicenses.Append;
    fdmSPDXLicensesLicenseID.AsString      := License.LicenseID;
    fdmSPDXLicensesName.AsString           := License.Name;
    fdmSPDXLicensesIsOsiApproved.AsBoolean := License.IsOsiApproved;
    fdmSPDXLicensesIsDeprecated.AsBoolean  := License.IsDeprecated;
    fdmSPDXLicensesSeeAlso.AsString        := string.Join(',', License.SeeAlso);
    fdmSPDXLicenses.Post;
  end;
end;

procedure TdMetadata.ApplyEdits(ABookmarks: TArray<TBookmark>;
  const ASupplier, ASupplierURL, ALicenseID, ADescription: string);
var
  Bm:         TBookmark;
  SingleEdit: Boolean;
begin
  if Length(ABookmarks) = 0 then
    Exit;

  SingleEdit := Length(ABookmarks) = 1;

  // In multi-edit, all fields empty means nothing to do.
  // In single-edit, empty is a legitimate value — always proceed.
  if not SingleEdit and
     ASupplier.IsEmpty and ASupplierURL.IsEmpty and
     ALicenseID.IsEmpty and ADescription.IsEmpty then
    Exit;

  fdmMetadata.DisableControls;
  try
    for Bm in ABookmarks do
    begin
      fdmMetadata.GotoBookmark(Bm);
      fdmMetadata.Edit;

      // Multi-edit: empty = skip.  Single-edit: empty = clear.
      if SingleEdit or not ASupplier.IsEmpty then
        fdmMetadataSupplier.AsString := ASupplier;
      if SingleEdit or not ASupplierURL.IsEmpty then
        fdmMetadataSupplierURL.AsString := ASupplierURL;
      if SingleEdit or not ALicenseID.IsEmpty then
        fdmMetadataLicenseID.AsString := ALicenseID;
      if SingleEdit or not ADescription.IsEmpty then
        fdmMetadataDescription.AsString := ADescription;

      fdmMetadata.Post;
    end;
  finally
    fdmMetadata.EnableControls;
  end;
end;

procedure TdMetadata.LoadSPDXLicenses(const AExePath: string);
var
  Manager:  ISPDXLicenseManager;
  FilePath: string;
begin
  FilePath := FindFileUpTree(AExePath,
    TPath.Combine('Data', 'spdx-licenses.json'));

  if FilePath.IsEmpty then
  begin
    SysLog.Add('Warning: SPDX license file not found - license combo will be empty');
    Exit;
  end;

  Manager := TSPDXLicenseManager.Create;
  Manager.LoadFromFile(FilePath);
  PopulateSPDX(Manager);
end;

procedure TdMetadata.UpdatePackages(APackageRepo: IPackageMetadataRepository);
var
  Bm:          TBookmark;
  WasFiltered: Boolean;
begin
  WasFiltered          := fdmMetadata.Filtered;
  fdmMetadata.Filtered := False;

  Bm := fdmMetadata.GetBookmark;
  try
    fdmMetadata.First;
    while not fdmMetadata.Eof do
    begin
      APackageRepo.UpdatePackageMetadata(
        fdmMetadataName.AsString,
        fdmMetadataVersion.AsString,
        ComponentTypeFromString(fdmMetadataComponentType.AsString),
        fdmMetadataSupplier.AsString,
        fdmMetadataSupplierURL.AsString,
        fdmMetadataLicenseID.AsString,
        fdmMetadataDescription.AsString);
      fdmMetadata.Next;
    end;
  finally
    fdmMetadata.GotoBookmark(Bm);
    fdmMetadata.FreeBookmark(Bm);
    fdmMetadata.Filtered := WasFiltered;
  end;
end;

procedure TdMetadata.RevertPackages;
begin
  if Assigned(FOriginalList) then
    PopulatePackages(FOriginalList);
end;

procedure TdMetadata.ShowIncompleteOnly;
begin
  fdmMetadata.Filter :=
    '(Supplier = ''Unknown'') OR (Supplier = '''') OR ' +
    '(LicenseID = ''NOASSERTION'') OR (LicenseID = '''')';
  fdmMetadata.Filtered := True;
end;

procedure TdMetadata.ShowAllPackages;
begin
  fdmMetadata.Filtered := False;
end;

{ TdMetadata — IPackageDataset }

function TdMetadata.GetCurrentBookmark: TBookmark;
begin
  Result := fdmMetadata.GetBookmark;
end;

procedure TdMetadata.GotoBookmark(const ABookmark: TBookmark);
begin
  fdmMetadata.GotoBookmark(ABookmark);
end;

function TdMetadata.ReadFieldAsString(const AFieldName: string): string;
begin
  Result := fdmMetadata.FieldByName(AFieldName).AsString;
end;

procedure TdMetadata.ApplyItemValues(
  const ABookmark:    TBookmark;
  const AVersion:     string;
  const ASupplier:    string;
  const ASupplierURL: string;
  const ALicenseID:   string;
  const ADescription: string);
begin
  fdmMetadata.GotoBookmark(ABookmark);
  fdmMetadata.Edit;
  fdmMetadataVersion.AsString     := AVersion;
  fdmMetadataSupplier.AsString    := ASupplier;
  fdmMetadataSupplierURL.AsString := ASupplierURL;
  fdmMetadataLicenseID.AsString   := ALicenseID;
  fdmMetadataDescription.AsString := ADescription;
  fdmMetadata.Post;
end;

procedure TdMetadata.DisableControls;
begin
  fdmMetadata.DisableControls;
end;

procedure TdMetadata.EnableControls;
begin
  fdmMetadata.EnableControls;
end;

procedure TdMetadata.FreeBookmark(const ABookmark: TBookmark);
begin
  fdmMetadata.FreeBookmark(ABookmark);
end;

function TdMetadata.IsEmpty: Boolean;
begin
  Result := fdmMetadata.IsEmpty;
end;

end.
