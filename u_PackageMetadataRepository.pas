unit u_PackageMetadataRepository;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines IPackageMetadataRepository and its implementation.
  Maintains a catalog of known package metadata used during SBOM
  generation to resolve supplier, license, and version information
  for detected components. Supports built-in seed data loaded from
  an embedded JSON resource, JSON persistence, and runtime metadata
  updates.

  Unit membership: each catalog entry may declare a list of Delphi
  unit names that belong to it. This allows bundled packages such as
  SVGIconImageList (which ships HtmlViewer and MarkdownViewerComponents
  as source) to be resolved from any of their constituent unit names
  rather than appearing as separate unknown packages.

  Schema versioning: the saved metadata file carries a schemaVersion
  integer. When the built-in catalog is updated, METADATA_SCHEMA_VERSION
  is incremented. On load, if the file version is older, MergeBuiltInDefaults
  replaces un-edited entries with the new built-in versions while
  preserving any entry the user has modified (identified by a non-empty
  user-upd field — see ISBOMComponent.UserUpdated).
*)

interface

uses
  System.Classes,
  Spring.Collections,
  i_SBOMComponent,
  u_SBOMEnums;

type
  IPackageMetadataRepository = interface
    ['{39094FFB-1BF6-42CD-8503-8C27844A4359}']
    /// <summary>Returns the component whose name matches APackageName, or nil if not found.</summary>
    function FindMetadata(const APackageName: string): ISBOMComponent;
    /// <summary>
    /// Returns the component that has registered AUnitName as a member
    /// unit, or nil if no entry claims this unit name.
    /// </summary>
    function FindByUnitName(const AUnitName: string): ISBOMComponent;
    /// <summary>Returns a read-only list of all components in the repository.</summary>
    function GetAllComponents: IReadOnlyList<ISBOMComponent>;
    /// <summary>Returns the count of components currently held in the repository.</summary>
    function GetPackageCount: Integer;
    /// <summary>
    /// Clears the repository and loads the built-in seed package list
    /// from the embedded JSON resource.
    /// Returns the number of entries loaded.
    /// </summary>
    function LoadBuiltInDefaults: Integer;
    /// <summary>
    /// Returns True if the schema version in the loaded metadata file
    /// is older than the current built-in catalog version.
    /// </summary>
    function IsSchemaOutdated: Boolean;
    /// <summary>
    /// Merges the built-in catalog into the current repository.
    /// Entries with a non-empty UserUpdated field are preserved unchanged.
    /// Entries with an empty UserUpdated field are replaced by the
    /// current built-in version. New built-in entries are added.
    /// Returns the number of entries replaced or added.
    /// </summary>
    function MergeBuiltInDefaults: Integer;
    /// <summary>
    /// Returns a list of detected components that are absent from the
    /// repository or have incomplete metadata.
    /// </summary>
    function IdentifyUnknownPackages(
      ADetectedComponents: IReadOnlyList<ISBOMComponent>;
      const AVersion: string): IList<ISBOMComponent>;
    /// <summary>
    /// Loads package metadata from the specified JSON file, replacing
    /// any existing entries. Returns True on success.
    /// </summary>
    function LoadGlobalMetadata(const AFile: string): Boolean;
    /// <summary>
    /// Saves all current repository entries to the specified JSON file.
    /// Returns True on success.
    /// </summary>
    function SaveGlobalMetadata(const AFile: string): Boolean;
    /// <summary>
    /// Updates the metadata for the named package, or adds a new entry
    /// if the package is not already present.
    /// </summary>
    procedure UpdatePackageMetadata(
      const AName, AVersion: string;
            AComponentType: TComponentType;
      const ASupplier, ASupplierURL, ALicense, ADescription: string);
    /// <summary>
    /// Registers AUnitName as a member of the package identified by
    /// APackageName. Used when loading catalog entries that declare
    /// a units array.
    /// </summary>
    procedure RegisterUnitMembership(
      const APackageName: string;
      const AUnitName: string);
    /// <summary>
    /// Marks the named catalog entry as user-owned by recording ADate
    /// in its UserUpdated field. Protects the entry from being replaced
    /// by catalog schema upgrades. ADate should be an ISO 8601 date string.
    /// </summary>
    procedure MarkUserUpdated(const APackageName, ADate: string);
    /// <summary>
    /// Returns all catalog entries that claim AUnitName as a member unit.
    /// Returns an empty list if no entries claim the unit, or a single-
    /// entry list if the unit is unambiguous. Only returns multiple entries
    /// when more than one catalog entry claims the same unit name — this
    /// is the signal that disambiguation is required.
    /// </summary>
    function FindCandidatesForUnit(
      const AUnitName: string): IReadOnlyList<ISBOMComponent>;

    /// <summary>
    /// Returns the component whose name and version both match, or nil.
    /// If AVersion is empty, returns the first name match — preserving
    /// existing behaviour for callers that do not need version precision.
    /// </summary>
    function FindMetadataByVersion(const AName: string;
      const AVersion: string = ''): ISBOMComponent;
    /// <summary>
    /// Registers APrefix as a unit name prefix belonging to APackageName.
    /// Any unit whose name starts with APrefix (case-sensitive) will
    /// resolve to this package when FindByUnitName is called.
    /// </summary>
    procedure RegisterPrefixMembership(
      const APackageName: string;
      const APrefix: string);

    /// <summary>
    /// Returns all prefix strings registered for the named package.
    /// Returns an empty list if no prefixes are registered.
    /// </summary>
    function GetPrefixesForPackage(
      const APackageName: string): IReadOnlyList<string>;

    /// <summary>
    /// Removes all prefix registrations for the named package.
    /// </summary>
    procedure ClearPrefixesForPackage(const APackageName: string);
  end;

  TPackageMetadataRepository = class(TInterfacedObject, IPackageMetadataRepository)
  private
    FComponentList: IList<ISBOMComponent>;
    FSchemaVersion: Integer;
    // Maps unit name (lowercase) → package name for O(1) lookup.
    FUnitIndex: IDictionary<string, IList<string>>;
    // Maps package name → unit name list for serialisation.
    FPackageUnits: IDictionary<string, IList<string>>;
    // Maps unit name prefix → package name (case-sensitive StartsWith match).
    FPrefixIndex: IDictionary<string, string>;
    procedure AddComponent(
      const ABomRef, AName, AVersion: string;
            AType: TComponentType;
      const ASupplier, ASupplierURL, ALicenseID: string;
      const ADescription:  string = '';
      const AUserUpdated:  string = '');
    procedure LoadFromJSON(const AJSONText: string);
    procedure MarkUserUpdated(const APackageName, ADate: string);
    procedure ReadPrefixesArray(PackageObj: TObject; const APackageName: string);
    procedure ReadUnitsArray(PackageObj: TObject;
      const APackageName: string);
  public
    constructor Create;

    function  FindMetadata(const APackageName: string): ISBOMComponent;
    function  FindByUnitName(const AUnitName: string): ISBOMComponent;
    function  GetAllComponents: IReadOnlyList<ISBOMComponent>;
    function  GetPackageCount: Integer;
    function  LoadBuiltInDefaults: Integer;
    function  IsSchemaOutdated: Boolean;
    function  MergeBuiltInDefaults: Integer;
    function  IdentifyUnknownPackages(
      ADetectedComponents: IReadOnlyList<ISBOMComponent>;
      const AVersion: string): IList<ISBOMComponent>;
    function  LoadGlobalMetadata(const AFile: string): Boolean;
    function  SaveGlobalMetadata(const AFile: string): Boolean;
    procedure UpdatePackageMetadata(
      const AName, AVersion: string;
            AComponentType: TComponentType;
      const ASupplier, ASupplierURL, ALicense, ADescription: string);
    procedure RegisterUnitMembership(
      const APackageName: string;
      const AUnitName: string);
    function  FindMetadataByVersion(const AName: string;
      const AVersion: string = ''): ISBOMComponent;
    function  FindCandidatesForUnit(
      const AUnitName: string): IReadOnlyList<ISBOMComponent>;
    procedure RegisterPrefixMembership(const APackageName: string; const APrefix: string);
    function GetPrefixesForPackage(const APackageName: string): IReadOnlyList<string>;
    procedure ClearPrefixesForPackage(const APackageName: string);
  end;

implementation

{$R 'package-metadata-defaults.res' 'package-metadata-defaults.rc'}

// Note: package-metadata-defaults.rc must NOT be added to the project
// via Project → Add to Project. The {$R} directive above is sufficient.
// Adding it to the project causes duplicate resource linker warnings.

uses
  System.Generics.Collections,
  System.IOUtils,
  System.JSON,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  Winapi.Windows,
  u_Logger,
  u_SBOMClasses;

const
  // Increment this value whenever the built-in catalog changes.
  // LoadGlobalMetadata compares the saved schemaVersion against this
  // constant. If the saved value is lower, IsSchemaOutdated returns True
  // and f_Main will call MergeBuiltInDefaults to refresh un-edited entries.
  METADATA_SCHEMA_VERSION = 8;

type
  TComponentTypeHelper = record helper for TComponentType
    function FromString(const AStr: string): TComponentType;
    function ToString: string;
  end;

function TComponentTypeHelper.FromString(const AStr: string): TComponentType;
var
  Value: Integer;
begin
  Value  := GetEnumValue(TypeInfo(TComponentType), AStr);
  Result := ctLibrary;
  if Value >= 0 then
    Result := TComponentType(Value);
end;

function TComponentTypeHelper.ToString: string;
begin
  Result := GetEnumName(TypeInfo(TComponentType), Ord(Self));
end;

{ TPackageMetadataRepository }

constructor TPackageMetadataRepository.Create;
begin
  inherited Create;
  FComponentList := TCollections.CreateList<ISBOMComponent>;
  FSchemaVersion := 0;
  FUnitIndex := TCollections.CreateDictionary<string, IList<string>>(
    TStringComparer.OrdinalIgnoreCase);
  FPackageUnits  := TCollections.CreateDictionary<string, IList<string>>(
    TStringComparer.OrdinalIgnoreCase);
  FPrefixIndex := TCollections.CreateDictionary<string, string>;
end;

procedure TPackageMetadataRepository.AddComponent(
  const ABomRef, AName, AVersion: string;
        AType: TComponentType;
  const ASupplier, ASupplierURL, ALicenseID: string;
  const ADescription:  string;
  const AUserUpdated:  string);
var
  Component: TSBOMComponent;
begin
  Component := TSBOMComponent.Create(
    ABomRef, AName, AVersion, AType,
    ASupplier, ASupplierURL, ALicenseID, ADescription);

  if not AUserUpdated.IsEmpty then
    Component.SetUserUpdated(AUserUpdated);

  FComponentList.Add(Component);
end;

procedure TPackageMetadataRepository.ClearPrefixesForPackage(const APackageName: string);
var
  ToRemove: IList<string>;
  Prefix:   string;
begin
  ToRemove := TCollections.CreateList<string>;
  for Prefix in FPrefixIndex.Keys do
  begin
    if SameText(FPrefixIndex[Prefix], APackageName) then
      ToRemove.Add(Prefix);
  end;
  for Prefix in ToRemove do
    FPrefixIndex.Remove(Prefix);
end;

procedure TPackageMetadataRepository.RegisterUnitMembership(
  const APackageName: string;
  const AUnitName: string);
var
  PackageNames: IList<string>;
  Units:        IList<string>;
begin
  if AUnitName.IsEmpty or APackageName.IsEmpty then
    Exit;

  // Add package name to the unit's candidate list.
  if not FUnitIndex.TryGetValue(AUnitName, PackageNames) then
  begin
    PackageNames := TCollections.CreateList<string>;
    FUnitIndex[AUnitName] := PackageNames;
  end;

  if not PackageNames.Contains(APackageName) then
    PackageNames.Add(APackageName);

  // Maintain the reverse map for serialisation.
  if not FPackageUnits.TryGetValue(APackageName, Units) then
  begin
    Units := TCollections.CreateList<string>;
    FPackageUnits[APackageName] := Units;
  end;

  if not Units.Contains(AUnitName) then
    Units.Add(AUnitName);
end;

procedure TPackageMetadataRepository.MarkUserUpdated(const APackageName, ADate: string);
var
  I: Integer;
begin
  for I := 0 to FComponentList.Count - 1 do
  begin
    if SameText(FComponentList[I].Name, APackageName) then
    begin
      FComponentList[I].SetUserUpdated(ADate);
      Exit;
    end;
  end;
end;

procedure TPackageMetadataRepository.ReadUnitsArray(PackageObj: TObject;
  const APackageName: string);
var
  JSONObj:    TJSONObject;
  UnitsArray: TJSONArray;
  J:          Integer;
  UnitName:   string;
begin
  JSONObj    := PackageObj as TJSONObject;
  UnitsArray := JSONObj.GetValue('units') as TJSONArray;

  if not Assigned(UnitsArray) then
    Exit;

  for J := 0 to UnitsArray.Count - 1 do
  begin
    UnitName := UnitsArray.Items[J].Value;
    if not UnitName.IsEmpty then
      RegisterUnitMembership(APackageName, UnitName);
  end;
end;

procedure TPackageMetadataRepository.LoadFromJSON(const AJSONText: string);
var
  JSONObj:       TJSONObject;
  PackagesArray: TJSONArray;
  I:             Integer;
  PackageObj:    TJSONObject;
  Name:          string;
  Version:       string;
  Supplier:      string;
  SupplierURL:   string;
  License:       string;
  Description:   string;
  TypeStr:       string;
  UserUpdated:   string;
  ComponentType: TComponentType;
begin
  JSONObj := TJSONObject.ParseJSONValue(AJSONText) as TJSONObject;
  if not Assigned(JSONObj) then
  begin
    SysLog.Add('Error: Invalid JSON in package metadata');
    Exit;
  end;

  try
    // Read schema version — defaults to 0 if absent (pre-versioning files).
    FSchemaVersion := JSONObj.GetValue<Integer>('schemaVersion', 0);

    PackagesArray := JSONObj.GetValue<TJSONArray>('packages');
    if not Assigned(PackagesArray) then
    begin
      SysLog.Add('Error: No packages array in metadata');
      Exit;
    end;

    for I := 0 to PackagesArray.Count - 1 do
    begin
      PackageObj := PackagesArray.Items[I] as TJSONObject;

      Name := PackageObj.GetValue<string>('name', '');
      if Name.IsEmpty then
        Continue;

      Version     := PackageObj.GetValue<string>('version',     '1.0.0');
      Supplier    := PackageObj.GetValue<string>('supplier',    'Unknown');
      SupplierURL := PackageObj.GetValue<string>('supplierURL', '');
      License     := PackageObj.GetValue<string>('license',     'NOASSERTION');
      Description := PackageObj.GetValue<string>('description', '');
      TypeStr     := PackageObj.GetValue<string>('type',        'ctLibrary');
      UserUpdated := PackageObj.GetValue<string>('user-upd',    '');

      if TypeStr.IsEmpty then
        ComponentType := ctLibrary
      else
        ComponentType := ComponentType.FromString(TypeStr);

      AddComponent('', Name, Version, ComponentType,
        Supplier, SupplierURL, License, Description, UserUpdated);

      ReadUnitsArray(PackageObj, Name);
      ReadPrefixesArray(PackageObj, Name);
    end;

    SysLog.Add(Format('Loaded %d packages from metadata',
      [PackagesArray.Count]));
  finally
    JSONObj.Free;
  end;
end;

procedure TPackageMetadataRepository.ReadPrefixesArray(PackageObj: TObject; const APackageName: string);
var
  JSONObj:       TJSONObject;
  PrefixesArray: TJSONArray;
  J:             Integer;
  Prefix:        string;
begin
  JSONObj       := PackageObj as TJSONObject;
  PrefixesArray := JSONObj.GetValue('prefixes') as TJSONArray;

  if not Assigned(PrefixesArray) then
    Exit;

  for J := 0 to PrefixesArray.Count - 1 do
  begin
    Prefix := PrefixesArray.Items[J].Value;
    if not Prefix.IsEmpty then
      RegisterPrefixMembership(APackageName, Prefix);
  end;
end;

function TPackageMetadataRepository.FindMetadata(
  const APackageName: string): ISBOMComponent;
var
  Component: ISBOMComponent;
begin
  Result := nil;
  for Component in FComponentList do
  begin
    if SameText(Component.Name, APackageName) then
      Exit(Component);
  end;
end;

function TPackageMetadataRepository.FindMetadataByVersion(const AName,
  AVersion: string): ISBOMComponent;
var
  Component: ISBOMComponent;
begin
  Result := nil;
  for Component in FComponentList do
  begin
    if not SameText(Component.Name, AName) then
      Continue;

    // If no version specified, return first name match.
    if AVersion.IsEmpty then
      Exit(Component);

    if SameText(Component.Version, AVersion) then
      Exit(Component);
  end;
end;

function TPackageMetadataRepository.FindByUnitName(
  const AUnitName: string): ISBOMComponent;
var
  PackageNames: IList<string>;
  Prefix:       string;
  PackageName:  string;
begin
  Result := nil;
  if AUnitName.IsEmpty then
    Exit;

  // 1. Exact unit name match.
  if FUnitIndex.TryGetValue(AUnitName, PackageNames) and
     (PackageNames.Count > 0) then
  begin
    Result := FindMetadata(PackageNames.First);
    Exit;
  end;

  // 2. Case-sensitive prefix match.
  for Prefix in FPrefixIndex.Keys do
  begin
    if AUnitName.StartsWith(Prefix) then
    begin
      PackageName := FPrefixIndex[Prefix];
      Result      := FindMetadata(PackageName);
      Exit;
    end;
  end;
end;

function TPackageMetadataRepository.FindCandidatesForUnit(
  const AUnitName: string): IReadOnlyList<ISBOMComponent>;
var
  PackageNames: IList<string>;
  Results:      IList<ISBOMComponent>;
  PackageName:  string;
  Component:    ISBOMComponent;
begin
  Results := TCollections.CreateList<ISBOMComponent>;

  if not AUnitName.IsEmpty and
     FUnitIndex.TryGetValue(AUnitName, PackageNames) then
  begin
    for PackageName in PackageNames do
    begin
      Component := FindMetadata(PackageName);
      if Assigned(Component) then
        Results.Add(Component);
    end;
  end;

  Result := Results as IReadOnlyList<ISBOMComponent>;
end;

function TPackageMetadataRepository.GetAllComponents: IReadOnlyList<ISBOMComponent>;
begin
  Result := FComponentList as IReadOnlyList<ISBOMComponent>;
end;

function TPackageMetadataRepository.GetPackageCount: Integer;
begin
  Result := FComponentList.Count;
end;

function TPackageMetadataRepository.GetPrefixesForPackage(const APackageName: string): IReadOnlyList<string>;
var
  Results: IList<string>;
  Prefix:  string;
begin
  Results := TCollections.CreateList<string>;
  for Prefix in FPrefixIndex.Keys do
  begin
    if SameText(FPrefixIndex[Prefix], APackageName) then
      Results.Add(Prefix);
  end;
  Result := Results as IReadOnlyList<string>;
end;

function TPackageMetadataRepository.LoadBuiltInDefaults: Integer;
var
  Stream:   TResourceStream;
  Bytes:    TBytes;
  JSONText: string;
begin
  FComponentList.Clear;
  FUnitIndex.Clear;
  FPackageUnits.Clear;
  FPrefixIndex.Clear;

  Stream := TResourceStream.Create(HInstance,
    'PACKAGE_METADATA_DEFAULTS', RT_RCDATA);
  try
    SetLength(Bytes, Stream.Size);
    Stream.ReadBuffer(Bytes[0], Stream.Size);
    JSONText := TEncoding.UTF8.GetString(Bytes);
  finally
    Stream.Free;
  end;

  LoadFromJSON(JSONText);

  // Built-in defaults carry the current schema version.
  FSchemaVersion := METADATA_SCHEMA_VERSION;

  Result := FComponentList.Count;
end;

function TPackageMetadataRepository.IsSchemaOutdated: Boolean;
begin
  Result := FSchemaVersion < METADATA_SCHEMA_VERSION;
end;

function TPackageMetadataRepository.MergeBuiltInDefaults: Integer;
var
  Stream:        TResourceStream;
  Bytes:         TBytes;
  JSONText:      string;
  BuiltIn:       TPackageMetadataRepository;
  BuiltInComp:   ISBOMComponent;
  ExistingComp:  ISBOMComponent;
  I:             Integer;
  Found:         Boolean;
  Prefix: string;
  Units:         IList<string>;
  UnitName:      string;
begin
  Result := 0;

  // Load built-in catalog into a temporary repository instance.
  Stream := TResourceStream.Create(HInstance,
    'PACKAGE_METADATA_DEFAULTS', RT_RCDATA);
  BuiltIn := TPackageMetadataRepository.Create;
  try
    SetLength(Bytes, Stream.Size);
    Stream.ReadBuffer(Bytes[0], Stream.Size);
    JSONText := TEncoding.UTF8.GetString(Bytes);
    BuiltIn.LoadFromJSON(JSONText);
    BuiltIn.FSchemaVersion := METADATA_SCHEMA_VERSION;
  finally
    Stream.Free;
  end;

  try
    for BuiltInComp in BuiltIn.FComponentList do
    begin
      Found := False;

      for I := 0 to FComponentList.Count - 1 do
      begin
        if SameText(FComponentList[I].Name, BuiltInComp.Name) then
        begin
          Found := True;

          // User-modified entry — preserve it unchanged.
          if not FComponentList[I].UserUpdated.IsEmpty then
            Break;

          // Un-edited entry — replace with current built-in version.
          FComponentList[I] := TSBOMComponent.Create(
            '',
            BuiltInComp.Name,
            BuiltInComp.Version,
            BuiltInComp.ComponentType,
            BuiltInComp.Supplier,
            BuiltInComp.SupplierURL,
            BuiltInComp.LicenseID,
            BuiltInComp.Description);

          // Re-register unit memberships for this entry.
          if BuiltIn.FPackageUnits.TryGetValue(BuiltInComp.Name, Units) then
          begin
            for UnitName in Units do
              RegisterUnitMembership(BuiltInComp.Name, UnitName);
          end;

          // Re-register prefix memberships for this entry.
          for Prefix in BuiltIn.FPrefixIndex.Keys do
          begin
            if SameText(BuiltIn.FPrefixIndex[Prefix], BuiltInComp.Name) then
              RegisterPrefixMembership(BuiltInComp.Name, Prefix);
          end;

          Inc(Result);
          Break;
        end;
      end;

      // New built-in entry not present in loaded catalog — add it.
      if not Found then
      begin
        AddComponent('',
          BuiltInComp.Name,
          BuiltInComp.Version,
          BuiltInComp.ComponentType,
          BuiltInComp.Supplier,
          BuiltInComp.SupplierURL,
          BuiltInComp.LicenseID,
          BuiltInComp.Description,
          '');

        if BuiltIn.FPackageUnits.TryGetValue(BuiltInComp.Name, Units) then
        begin
          for UnitName in Units do
            RegisterUnitMembership(BuiltInComp.Name, UnitName);
        end;

        Inc(Result);
      end;
    end;

    // Update schema version to current after merge.
    FSchemaVersion := METADATA_SCHEMA_VERSION;

    SysLog.Add(Format(
      'Merged built-in catalog: %d entries replaced or added',
      [Result]));
  finally
    BuiltIn.Free;
  end;
end;

function TPackageMetadataRepository.IdentifyUnknownPackages(
  ADetectedComponents: IReadOnlyList<ISBOMComponent>;
  const AVersion: string): IList<ISBOMComponent>;
var
  Detected: ISBOMComponent;
  Known:    ISBOMComponent;
  Found:    Boolean;
begin
  Result := TCollections.CreateList<ISBOMComponent>;

  for Detected in ADetectedComponents do
  begin
    // The Delphi IDE framework component is always fully attributed
    // and does not have a catalog entry — exclude it from the check.
    if Detected.BomRef.StartsWith('pkg:delphi/') then
      Continue;

    Found := False;
    for Known in FComponentList do
    begin
      if SameText(Detected.Name, Known.Name) then
      begin
        Found := True;
        Break;
      end;
    end;

    if not Found
       or Detected.Supplier.IsEmpty
       or SameText(Detected.Supplier, 'Unknown')
       or Detected.LicenseID.IsEmpty
       or SameText(Detected.LicenseID, 'NOASSERTION') then
      Result.Add(Detected);
  end;

  SysLog.Add(Format(
    'Identified %d packages needing metadata out of %d detected',
    [Result.Count, ADetectedComponents.Count]));
end;

function TPackageMetadataRepository.LoadGlobalMetadata(
  const AFile: string): Boolean;
var
  JSONText: string;
begin
  Result := False;

  if not FileExists(AFile) then
  begin
    SysLog.Add('Global metadata file not found: ' + AFile);
    Exit;
  end;

  try
    FComponentList.Clear;
    FUnitIndex.Clear;
    FPackageUnits.Clear;
    FPrefixIndex.Clear;
    FSchemaVersion := 0;

    JSONText := TFile.ReadAllText(AFile, TEncoding.UTF8);
    LoadFromJSON(JSONText);
    Result := True;

  except
    on E: Exception do
    begin
      SysLog.Add('Error loading global metadata: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TPackageMetadataRepository.RegisterPrefixMembership(const APackageName: string; const APrefix: string);
begin
  if APrefix.IsEmpty or APackageName.IsEmpty then
    Exit;
  if not FPrefixIndex.ContainsKey(APrefix) then
    FPrefixIndex.Add(APrefix, APackageName);
end;

function TPackageMetadataRepository.SaveGlobalMetadata(
  const AFile: string): Boolean;
var
  JSONObj:       TJSONObject;
  PackagesArray: TJSONArray;
  PackageObj:    TJSONObject;
  UnitsArray:    TJSONArray;
  Component:     ISBOMComponent;
  Prefix: string;
  PrefixesArray: TJSONArray;
  Units:         IList<string>;
  UnitName:      string;
begin
  try
    JSONObj := TJSONObject.Create;
    try
      // Write schema version so future loads can detect catalog updates.
      JSONObj.AddPair('schemaVersion',
        TJSONNumber.Create(METADATA_SCHEMA_VERSION));

      PackagesArray := TJSONArray.Create;

      for Component in FComponentList do
      begin
        PackageObj := TJSONObject.Create;
        PackageObj.AddPair('name',        Component.Name);
        PackageObj.AddPair('version',     Component.Version);
        PackageObj.AddPair('supplier',    Component.Supplier);
        PackageObj.AddPair('supplierURL', Component.SupplierURL);
        PackageObj.AddPair('license',     Component.LicenseID);
        PackageObj.AddPair('description', Component.Description);
        PackageObj.AddPair('type',        Component.ComponentType.ToString);

        // Only write user-upd when non-empty — its presence is the signal.
        if not Component.UserUpdated.IsEmpty then
          PackageObj.AddPair('user-upd', Component.UserUpdated);

        if FPackageUnits.TryGetValue(Component.Name, Units) and
           (Units.Count > 0) then
        begin
          UnitsArray := TJSONArray.Create;
          for UnitName in Units do
            UnitsArray.Add(UnitName);
          PackageObj.AddPair('units', UnitsArray);
        end;

        // Write prefixes array if this package has registered prefixes.
        PrefixesArray := TJSONArray.Create;
        for Prefix in FPrefixIndex.Keys do
        begin
          if SameText(FPrefixIndex[Prefix], Component.Name) then
            PrefixesArray.Add(Prefix);
        end;
        if PrefixesArray.Count > 0 then
          PackageObj.AddPair('prefixes', PrefixesArray)
        else
          PrefixesArray.Free;

        PackagesArray.AddElement(PackageObj);
      end;

      JSONObj.AddPair('packages', PackagesArray);
      TFile.WriteAllText(AFile, JSONObj.Format(2), TEncoding.UTF8);

      SysLog.Add(Format('Saved %d packages to global metadata',
        [FComponentList.Count]));
      Result := True;

    finally
      JSONObj.Free;
    end;

  except
    on E: Exception do
    begin
      SysLog.Add('Error saving global metadata: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TPackageMetadataRepository.UpdatePackageMetadata(
  const AName, AVersion: string;
        AComponentType: TComponentType;
  const ASupplier, ASupplierURL, ALicense, ADescription: string);
var
  I:           Integer;
  UserUpdated: string;
  NewComp:     TSBOMComponent;
begin
  for I := 0 to FComponentList.Count - 1 do
  begin
    if SameText(FComponentList[I].Name, AName) then
    begin
      // Preserve UserUpdated when replacing an existing entry.
      UserUpdated := FComponentList[I].UserUpdated;

      NewComp := TSBOMComponent.Create(
        Format('pkg:generic/%s@%s',
          [AName.ToLower.Replace(' ', '-'), AVersion]),
        AName, AVersion, AComponentType,
        ASupplier, ASupplierURL, ALicense, ADescription);

      if not UserUpdated.IsEmpty then
        NewComp.SetUserUpdated(UserUpdated);

      FComponentList[I] := NewComp;
      SysLog.Add(Format('Updated repository metadata for: %s', [AName]));
      Exit;
    end;
  end;

  FComponentList.Add(TSBOMComponent.Create(
    Format('pkg:generic/%s@%s',
      [AName.ToLower.Replace(' ', '-'), AVersion]),
    AName, AVersion, AComponentType,
    ASupplier, ASupplierURL, ALicense, ADescription));
  SysLog.Add(Format('Added new repository metadata for: %s', [AName]));
end;

end.
