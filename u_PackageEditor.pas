unit u_PackageEditor;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines IEditablePackageInfo and IPackageEditManager, providing
  an editable wrapper over ISBOMComponent for in-session metadata
  overrides. Supports revert, JSON persistence of overrides, and
  write-back to the component list.
*)

interface

uses
  Spring.Collections,
  i_MetadataViewer,
  i_SBOMComponent;

type
  /// <summary>
  /// Extends IMetadataItem with a revert operation, allowing
  /// all editable fields to be restored to their values at
  /// load time. RevertChanges also clears the IsModified flag.
  /// </summary>
  IEditablePackageInfo = interface(IMetadataItem)
    ['{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}']
    /// <summary>Restores all fields to their original values and clears IsModified.</summary>
    procedure RevertChanges;
  end;

  /// <summary>
  /// Manages the collection of editable package entries for a
  /// detection session. Supports loading from components, querying,
  /// override persistence, and write-back.
  /// </summary>
  IPackageEditManager = interface
    ['{B2C3D4E5-F6A7-8901-2345-678901ABCDEF}']
    /// <summary>Populates the manager from the supplied read-only component list.</summary>
    procedure LoadFromComponents(AComponents: IReadOnlyList<ISBOMComponent>);
    /// <summary>Returns a read-only snapshot of all editable package entries.</summary>
    function GetPackages: IReadOnlyList<IEditablePackageInfo>;
    /// <summary>Returns the editable entry for the named package, or nil if not found.</summary>
    function GetPackageByName(const AName: string): IEditablePackageInfo;
    /// <summary>Returns True if any entry has been modified since loading.</summary>
    function HasModifications: Boolean;
    /// <summary>Writes all modified entries to a catalog-overrides.json file in AProjectFolder.</summary>
    procedure SaveOverrides(const AProjectFolder: string);
    /// <summary>Reads and applies override values from catalog-overrides.json in AProjectFolder.</summary>
    procedure LoadOverrides(const AProjectFolder: string);
    /// <summary>Replaces modified components in AComponents with updated instances.</summary>
    procedure ApplyToComponents(AComponents: IList<ISBOMComponent>);
  end;

  TEditablePackageInfo = class(TInterfacedObject, IEditablePackageInfo, IMetadataItem)
  private
    FPackageName:    string;
    FVersion:        string;
    FSupplier:       string;
    FSupplierURL:    string;
    FLicenseID:      string;
    FDescription:    string;
    FIsModified:     Boolean;
    FOrigVersion:    string;
    FOrigSupplier:   string;
    FOrigSupplierURL: string;
    FOrigLicenseID:  string;
    FOrigDescription: string;
  public
    constructor Create(AComponent: ISBOMComponent);

    function GetName:        string;
    function GetVersion:     string;
    function GetSupplier:    string;
    function GetSupplierURL: string;
    function GetLicense:     string;
    function GetDescription: string;
    function GetIsModified:  Boolean;

    procedure SetVersion(const AValue:     string);
    procedure SetSupplier(const AValue:    string);
    procedure SetSupplierURL(const AValue: string);
    procedure SetLicense(const AValue:     string);
    procedure SetDescription(const AValue: string);

    procedure RevertChanges;
  end;

  TPackageEditManager = class(TInterfacedObject, IPackageEditManager)
  private
    FPackages: IDictionary<string, IEditablePackageInfo>;
  public
    constructor Create;

    procedure LoadFromComponents(AComponents: IReadOnlyList<ISBOMComponent>);
    function  GetPackages: IReadOnlyList<IEditablePackageInfo>;
    function  GetPackageByName(const AName: string): IEditablePackageInfo;
    function  HasModifications: Boolean;
    procedure SaveOverrides(const AProjectFolder: string);
    procedure LoadOverrides(const AProjectFolder: string);
    procedure ApplyToComponents(AComponents: IList<ISBOMComponent>);
  end;

implementation

uses
  System.Generics.Collections,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.SysUtils,
  u_Logger,
  u_SBOMClasses;

{ TEditablePackageInfo }

constructor TEditablePackageInfo.Create(AComponent: ISBOMComponent);
begin
  inherited Create;
  FPackageName     := AComponent.Name;
  FVersion         := AComponent.Version;
  FSupplier        := AComponent.Supplier;
  FSupplierURL     := AComponent.SupplierURL;
  FLicenseID       := AComponent.LicenseID;
  FDescription     := AComponent.Description;

  FOrigVersion     := FVersion;
  FOrigSupplier    := FSupplier;
  FOrigSupplierURL := FSupplierURL;
  FOrigLicenseID   := FLicenseID;
  FOrigDescription := FDescription;

  FIsModified      := False;
end;

function TEditablePackageInfo.GetName: string;
begin
  Result := FPackageName;
end;

function TEditablePackageInfo.GetVersion: string;
begin
  Result := FVersion;
end;

function TEditablePackageInfo.GetSupplier: string;
begin
  Result := FSupplier;
end;

function TEditablePackageInfo.GetSupplierURL: string;
begin
  Result := FSupplierURL;
end;

function TEditablePackageInfo.GetLicense: string;
begin
  Result := FLicenseID;
end;

function TEditablePackageInfo.GetDescription: string;
begin
  Result := FDescription;
end;

function TEditablePackageInfo.GetIsModified: Boolean;
begin
  Result := FIsModified;
end;

procedure TEditablePackageInfo.SetVersion(const AValue: string);
begin
  if FVersion <> AValue then
  begin
    FVersion    := AValue;
    FIsModified := True;
  end;
end;

procedure TEditablePackageInfo.SetSupplier(const AValue: string);
begin
  if FSupplier <> AValue then
  begin
    FSupplier   := AValue;
    FIsModified := True;
  end;
end;

procedure TEditablePackageInfo.SetSupplierURL(const AValue: string);
begin
  if FSupplierURL <> AValue then
  begin
    FSupplierURL := AValue;
    FIsModified  := True;
  end;
end;

procedure TEditablePackageInfo.SetLicense(const AValue: string);
begin
  if FLicenseID <> AValue then
  begin
    FLicenseID  := AValue;
    FIsModified := True;
  end;
end;

procedure TEditablePackageInfo.SetDescription(const AValue: string);
begin
  if FDescription <> AValue then
  begin
    FDescription := AValue;
    FIsModified  := True;
  end;
end;

procedure TEditablePackageInfo.RevertChanges;
begin
  FVersion     := FOrigVersion;
  FSupplier    := FOrigSupplier;
  FSupplierURL := FOrigSupplierURL;
  FLicenseID   := FOrigLicenseID;
  FDescription := FOrigDescription;
  FIsModified  := False;
end;

{ TPackageEditManager }

constructor TPackageEditManager.Create;
begin
  inherited Create;
  FPackages := TCollections.CreateDictionary<string, IEditablePackageInfo>;
end;

procedure TPackageEditManager.LoadFromComponents(
  AComponents: IReadOnlyList<ISBOMComponent>);
var
  Component:    ISBOMComponent;
  EditableInfo: IEditablePackageInfo;
begin
  FPackages.Clear;

  for Component in AComponents do
  begin
    if FPackages.ContainsKey(Component.Name) then
    begin
      SysLog.Add(Format('Warning: Duplicate component name "%s", skipping',
        [Component.Name]));
      Continue;
    end;

    EditableInfo := TEditablePackageInfo.Create(Component);
    FPackages.Add(Component.Name, EditableInfo);
  end;

  SysLog.Add(Format('Loaded %d packages for editing', [FPackages.Count]));
end;

function TPackageEditManager.GetPackages: IReadOnlyList<IEditablePackageInfo>;
begin
  Result := TCollections.CreateList<IEditablePackageInfo>(FPackages.Values) as IReadOnlyList<IEditablePackageInfo>;
end;

function TPackageEditManager.GetPackageByName(
  const AName: string): IEditablePackageInfo;
begin
  if not FPackages.TryGetValue(AName, Result) then
    Result := nil;
end;

function TPackageEditManager.HasModifications: Boolean;
var
  Package: IEditablePackageInfo;
begin
  Result := False;
  for Package in FPackages.Values do
  begin
    if Package.IsModified then
      Exit(True);
  end;
end;

procedure TPackageEditManager.SaveOverrides(const AProjectFolder: string);
var
  JSONObj:       TJSONObject;
  PackagesArray: TJSONArray;
  PackageObj:    TJSONObject;
  Package:       IEditablePackageInfo;
  OverridesFile: string;
begin
  if not HasModifications then
    Exit;

  JSONObj := TJSONObject.Create;
  try
    PackagesArray := TJSONArray.Create;

    for Package in FPackages.Values do
    begin
      if Package.IsModified then
      begin
        PackageObj := TJSONObject.Create;
        PackageObj.AddPair('name',         Package.Name);
        PackageObj.AddPair('version',      Package.Version);
        PackageObj.AddPair('supplier',     Package.Supplier);
        PackageObj.AddPair('supplier_url', Package.SupplierURL);
        PackageObj.AddPair('license',      Package.License);
        PackageObj.AddPair('description',  Package.Description);
        PackagesArray.AddElement(PackageObj);
      end;
    end;

    JSONObj.AddPair('overrides', PackagesArray);

    OverridesFile := TPath.Combine(AProjectFolder, 'catalog-overrides.json');
    TFile.WriteAllText(OverridesFile, JSONObj.Format(2), TEncoding.UTF8);
  finally
    JSONObj.Free;
  end;
end;

procedure TPackageEditManager.LoadOverrides(const AProjectFolder: string);
var
  OverridesFile: string;
  JSONText:      string;
  JSONObj:       TJSONObject;
  PackageObj:    TJSONObject;
  PackagesArray: TJSONArray;
  I:             Integer;
  PackageName:   string;
  Package:       IEditablePackageInfo;
begin
  OverridesFile := TPath.Combine(AProjectFolder, 'catalog-overrides.json');

  if not FileExists(OverridesFile) then
    Exit;

  JSONText := TFile.ReadAllText(OverridesFile, TEncoding.UTF8);
  JSONObj  := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  try
    PackagesArray := JSONObj.GetValue<TJSONArray>('overrides');

    for I := 0 to PackagesArray.Count - 1 do
    begin
      PackageObj  := PackagesArray.Items[I] as TJSONObject;
      PackageName := PackageObj.GetValue<string>('name');

      if FPackages.TryGetValue(PackageName, Package) then
      begin
        Package.Version     := PackageObj.GetValue<string>('version',      Package.Version);
        Package.Supplier    := PackageObj.GetValue<string>('supplier',     Package.Supplier);
        Package.SupplierURL := PackageObj.GetValue<string>('supplier_url', Package.SupplierURL);
        Package.License     := PackageObj.GetValue<string>('license',      Package.License);
        Package.Description := PackageObj.GetValue<string>('description',  Package.Description);
      end;
    end;
  finally
    JSONObj.Free;
  end;
end;

procedure TPackageEditManager.ApplyToComponents(
  AComponents: IList<ISBOMComponent>);
var
  Component: ISBOMComponent;
  Package:   IEditablePackageInfo;
  I:         Integer;
begin
  for I := 0 to AComponents.Count - 1 do
  begin
    Component := AComponents[I];
    if FPackages.TryGetValue(Component.Name, Package) then
    begin
      if Package.IsModified then
        AComponents[I] := TSBOMComponent.Create(
          Component.BomRef,
          Component.Name,
          Package.Version,
          Component.ComponentType,
          Package.Supplier,
          Package.SupplierURL,
          Package.License,
          Package.Description);
    end;
  end;
end;

end.
