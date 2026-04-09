unit u_SBOMComponentDetectionImpl;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Concrete implementations of the component detection interfaces
  defined in i_SBOMComponentDetection. Covers module classification,
  Delphi version resolution, and the top-level detection orchestrator.
*)

interface

uses
  Spring.Collections,
  i_AmbiguousUnit,
  i_SBOMComponent,
  i_SBOMComponentDetection,
  u_DelphiVersionDetector_2,
  u_MapModules,
  u_PackageMetadataRepository,
  u_PackageResolver,
  u_SBOMEnums;

type
  TModuleInfo = class(TInterfacedObject, IModuleInfo)
  private
    FUnitName:    string;
    FFilePath:    string;
    FScope:       TComponentScope;
    FCategory:    TComponentCategory;
    FPackageName: string;
  public
    constructor Create(const AUnitName, AFilePath: string);

    function GetUnitName:    string;
    function GetFilePath:    string;
    function GetScope:       TComponentScope;
    function GetCategory:    TComponentCategory;
    function GetPackageName: string;

    procedure SetScope(AScope: TComponentScope);
    procedure SetCategory(ACategory: TComponentCategory);
    procedure SetPackageName(const AName: string);
  end;

  TDelphiVersion = class(TInterfacedObject, IDelphiVersion)
  private
    FBuildVersion: string;
    FMajorVersion: Integer;
    FProductName:  string;
    FStudioPath:   string;
  public
    constructor Create(
      const AStudioPath, AProductName: string;
            AMajorVersion: Integer;
      const ABuildVersion: string);

    function GetBomRef:       string;
    function GetBuildVersion: string;
    function GetMajorVersion: Integer;
    function GetProductName:  string;
    function GetStudioPath:   string;
  end;

  TComponentDetector = class(TInterfacedObject, IComponentDetector)
  private
    FAmbiguousUnits:       IList<IAmbiguousUnit>;
    FDelphiVersion:        IDelphiVersion;
    FDelphiVersionInfo:    IDelphiVersionInfo;
    FInternalModules:      IList<IModuleInfo>;
    FInternalPathPrefixes: IList<string>;
    FMapParser:            IMapModuleParser;
    FMetadataRepo:         IPackageMetadataRepository;
    FPackageResolver:      IPackageResolver;

    function  ComputeFileHash(const AFilePath: string): string;
    procedure GroupModulesByPackage(
      const AModules: IList<IModuleInfo>;
      out   APackages: IDictionary<string, IList<IModuleInfo>>);
    function  CreateComponentFromPackage(
      const APackageName: string;
      const AModules: IList<IModuleInfo>): ISBOMComponent;
    function  CreateModuleInfoFromName(
      const AModuleName: string): IModuleInfo;
    function  IsInternalModule(const AModuleName: string): Boolean;
    function  ExtractPackageNameFromModule(
      const AModuleName: string): string;
    procedure BuildAmbiguousUnits(const AModules: IList<IModuleInfo>);
  public
    constructor Create(
      AMapParser:       IMapModuleParser;
      APackageResolver: IPackageResolver;
      AMetadataRepo:    IPackageMetadataRepository);

    function  DetectComponents(const AMapFile: string;
      AVersionInfo: IDelphiVersionInfo): IList<ISBOMComponent>;
    function  GetDelphiVersion: IDelphiVersion;
    function  GetInternalModules: IReadOnlyList<IModuleInfo>;
    function  GetAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>;
    procedure SetInternalPathPrefixes(
      const APrefixes: IReadOnlyList<string>);
  end;

implementation

uses
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  flcHash,
  u_AmbiguousUnit,
  u_Logger,
  u_SBOMClasses;

{ TModuleInfo }

constructor TModuleInfo.Create(const AUnitName, AFilePath: string);
begin
  inherited Create;
  FUnitName := AUnitName;
  FFilePath := AFilePath;
end;

function TModuleInfo.GetUnitName: string;
begin
  Result := FUnitName;
end;

function TModuleInfo.GetFilePath: string;
begin
  Result := FFilePath;
end;

function TModuleInfo.GetScope: TComponentScope;
begin
  Result := FScope;
end;

function TModuleInfo.GetCategory: TComponentCategory;
begin
  Result := FCategory;
end;

function TModuleInfo.GetPackageName: string;
begin
  Result := FPackageName;
end;

procedure TModuleInfo.SetScope(AScope: TComponentScope);
begin
  FScope := AScope;
end;

procedure TModuleInfo.SetCategory(ACategory: TComponentCategory);
begin
  FCategory := ACategory;
end;

procedure TModuleInfo.SetPackageName(const AName: string);
begin
  FPackageName := AName;
end;

{ TDelphiVersion }

constructor TDelphiVersion.Create(
  const AStudioPath, AProductName: string;
        AMajorVersion: Integer;
  const ABuildVersion: string);
begin
  inherited Create;
  FStudioPath   := AStudioPath;
  FProductName  := AProductName;
  FMajorVersion := AMajorVersion;
  FBuildVersion := ABuildVersion;
end;

function TDelphiVersion.GetBomRef: string;
begin
  if not FBuildVersion.IsEmpty then
    Result := Format('pkg:delphi/rad-studio@%s', [FBuildVersion])
  else
    Result := Format('pkg:delphi/rad-studio@%s', [FStudioPath]);
end;

function TDelphiVersion.GetBuildVersion: string;
begin
  Result := FBuildVersion;
end;

function TDelphiVersion.GetMajorVersion: Integer;
begin
  Result := FMajorVersion;
end;

function TDelphiVersion.GetProductName: string;
begin
  Result := FProductName;
end;

function TDelphiVersion.GetStudioPath: string;
begin
  Result := FStudioPath;
end;

{ TComponentDetector }

constructor TComponentDetector.Create(
  AMapParser:       IMapModuleParser;
  APackageResolver: IPackageResolver;
  AMetadataRepo:    IPackageMetadataRepository);
begin
  inherited Create;
  FMapParser            := AMapParser;
  FPackageResolver      := APackageResolver;
  FMetadataRepo         := AMetadataRepo;
  FInternalModules      := TCollections.CreateList<IModuleInfo>;
  FInternalPathPrefixes := TCollections.CreateList<string>;
  FAmbiguousUnits       := TCollections.CreateList<IAmbiguousUnit>;
end;

procedure TComponentDetector.SetInternalPathPrefixes(
  const APrefixes: IReadOnlyList<string>);
var
  Prefix: string;
begin
  FInternalPathPrefixes.Clear;
  for Prefix in APrefixes do
    FInternalPathPrefixes.Add(Prefix);
end;

function TComponentDetector.IsInternalModule(
  const AModuleName: string): Boolean;
var
  Prefix:   string;
  FilePath: string;
begin
  if AModuleName.StartsWith('u_', True) or
     AModuleName.StartsWith('f_', True) or
     AModuleName.StartsWith('SBOM', True) then
    Exit(True);

  if Assigned(FMapParser) then
  begin
    FilePath := FMapParser.GetModuleFilePath(AModuleName);

    if not FilePath.IsEmpty then
    begin
      for Prefix in FInternalPathPrefixes do
      begin
        if FilePath.ToLower.StartsWith(Prefix.ToLower) then
          Exit(True);
      end;
    end;
  end;

  Result := False;
end;

function TComponentDetector.ExtractPackageNameFromModule(
  const AModuleName: string): string;
var
  DotPos:          Integer;
  FirstPart:       string;
  ResolvedPackage: string;
  ByUnit:          ISBOMComponent;
begin
  if AModuleName.IsEmpty then
  begin
    SysLog.Add('WARNING: Empty module name');
    Exit('Unknown');
  end;

  // 1. Path-based package resolver (BPL/DCU registry mapping)
  if Assigned(FPackageResolver) then
  begin
    ResolvedPackage := FPackageResolver.ResolveModuleToPackage(AModuleName);
    if not ResolvedPackage.IsEmpty then
      Exit(ResolvedPackage);
  end;

  // 2. Explicit unit membership or prefix declared in catalog
  if Assigned(FMetadataRepo) then
  begin
    ByUnit := FMetadataRepo.FindByUnitName(AModuleName);
    if Assigned(ByUnit) then
      Exit(ByUnit.Name);
  end;

  // 3. Namespace prefix fallback
  DotPos := Pos('.', AModuleName);
  if DotPos > 0 then
    FirstPart := Copy(AModuleName, 1, DotPos - 1)
  else
    FirstPart := AModuleName;

  if SameText(FirstPart, 'System') then
    Result := 'Delphi RTL'
  else if SameText(FirstPart, 'Vcl') then
    Result := 'VCL'
  else if SameText(FirstPart, 'Data') then
    Result := 'Data Access'
  else if SameText(FirstPart, 'Xml') then
    Result := 'XML'
  else if SameText(FirstPart, 'Winapi') or
          SameText(FirstPart, 'Windows') then
    Result := 'Windows API'
  else if SameText(FirstPart, 'FireDAC') then
    Result := 'FireDAC'
  else if SameText(FirstPart, 'Spring') then
    Result := 'Spring4D'
  else
    Result := FirstPart;
end;

procedure TComponentDetector.GroupModulesByPackage(
  const AModules: IList<IModuleInfo>;
  out   APackages: IDictionary<string, IList<IModuleInfo>>);
var
  Module:         IModuleInfo;
  PackageName:    string;
  PackageModules: IList<IModuleInfo>;
begin
  APackages := TCollections.CreateDictionary<string, IList<IModuleInfo>>;

  for Module in AModules do
  begin
    PackageName := ExtractPackageNameFromModule(Module.UnitName);

    if not APackages.TryGetValue(PackageName, PackageModules) then
    begin
      PackageModules := TCollections.CreateList<IModuleInfo>;
      APackages.Add(PackageName, PackageModules);
    end;

    PackageModules.Add(Module);
  end;

  SysLog.Add(Format('Grouped %d modules into %d packages',
    [AModules.Count, APackages.Count]));
end;

procedure TComponentDetector.BuildAmbiguousUnits(
  const AModules: IList<IModuleInfo>);
var
  Module:     IModuleInfo;
  Candidates: IReadOnlyList<ISBOMComponent>;
  AmbUnit:    TAmbiguousUnit;
  Seen:       IDictionary<string, Boolean>;
begin
  FAmbiguousUnits.Clear;
  Seen := TCollections.CreateDictionary<string, Boolean>(
    TStringComparer.OrdinalIgnoreCase);

  for Module in AModules do
  begin
    if Seen.ContainsKey(Module.UnitName) then
      Continue;

    Seen[Module.UnitName] := True;

    Candidates := FMetadataRepo.FindCandidatesForUnit(Module.UnitName);

    if Candidates.Count > 1 then
    begin
      AmbUnit := TAmbiguousUnit.Create(Module.UnitName);
      for var Candidate in Candidates do
        AmbUnit.AddCandidate(Candidate);
      FAmbiguousUnits.Add(AmbUnit);
    end;
  end;

  if FAmbiguousUnits.Count > 0 then
    SysLog.Add(Format('Disambiguation required: %d ambiguous unit%s found',
      [FAmbiguousUnits.Count,
       IfThen(FAmbiguousUnits.Count = 1, '', 's')]));
end;

function TComponentDetector.ComputeFileHash(const AFilePath: string): string;
var
  FileStream: TFileStream;
  Buffer:     TBytes;
  Hash:       flcHash.T256BitDigest;
begin
  Result := '';

  if not FileExists(AFilePath) then
    Exit;

  try
    FileStream := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyWrite);
    try
      if FileStream.Size > 0 then
      begin
        SetLength(Buffer, FileStream.Size);
        FileStream.ReadBuffer(Buffer[0], FileStream.Size);
        Hash   := flcHash.CalcSHA256(Buffer[0], Length(Buffer));
        Result := string(flcHash.DigestToHexA(Hash, SizeOf(Hash)));
      end;
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      SysLog.Add(Format('Error computing hash for %s: %s',
        [AFilePath, E.Message]));
  end;
end;

function TComponentDetector.CreateModuleInfoFromName(
  const AModuleName: string): IModuleInfo;
begin
  Result := TModuleInfo.Create(AModuleName, '');
end;

function TComponentDetector.CreateComponentFromPackage(
  const APackageName: string;
  const AModules: IList<IModuleInfo>): ISBOMComponent;
var
  MetadataComponent: ISBOMComponent;
  PackageName:       string;
  Version:           string;
  Supplier:          string;
  SupplierURL:       string;
  LicenseID:         string;
  Description:       string;
  BPLPath:           string;
  FileHash:          string;
begin
  SysLog.Add(Format('Creating component for: %s', [APackageName]));

  MetadataComponent := FMetadataRepo.FindMetadata(APackageName);

  if Assigned(MetadataComponent) then
  begin
    PackageName := APackageName;
    Version     := MetadataComponent.Version;
    Supplier    := MetadataComponent.Supplier;
    SupplierURL := MetadataComponent.SupplierURL;
    LicenseID   := MetadataComponent.LicenseID;
    Description := MetadataComponent.Description;

    if Version = '-luc-' then
    begin
      if Assigned(FDelphiVersion) then
        Version := FDelphiVersion.BuildVersion
      else
        Version := '1.0.0';
    end;
  end
  else
  begin
    PackageName := APackageName;
    Version     := '1.0.0';
    Supplier    := 'Unknown';
    SupplierURL := '';
    LicenseID   := 'NOASSERTION';
    Description := Format('Auto-detected package: %s', [PackageName]);
  end;

  Result := TSBOMComponent.Create(
    Format('pkg:generic/%s@%s',
      [PackageName.ToLower.Replace(' ', '-'), Version]),
    PackageName,
    Version,
    ctLibrary,
    Supplier,
    SupplierURL,
    LicenseID,
    Description);

  BPLPath := FPackageResolver.GetBPLPathForPackage(APackageName);
  if not BPLPath.IsEmpty then
  begin
    FileHash := ComputeFileHash(BPLPath);
    if not FileHash.IsEmpty then
      Result.AddHash('SHA-256:' + FileHash);
  end;

  SysLog.Add(Format('Created: %s v%s (%s)',
    [Result.Name, Result.Version, Supplier]));
end;

function TComponentDetector.DetectComponents(const AMapFile: string;
  AVersionInfo: IDelphiVersionInfo): IList<ISBOMComponent>;
var
  ModuleNames:     IList<string>;
  ModuleName:      string;
  Module:          IModuleInfo;
  ExternalModules: IList<IModuleInfo>;
  Packages:        IDictionary<string, IList<IModuleInfo>>;
  PackageName:     string;
  PackageModules:  IList<IModuleInfo>;
  Component:       ISBOMComponent;
  InternalCount:   Integer;
  ExternalCount:   Integer;
begin
  FDelphiVersionInfo := AVersionInfo;

  // Derive IDelphiVersion directly from the supplied version info.
  // FVersionResolver.ResolveFromPath was path-based and never called —
  // FDelphiVersion is now constructed directly from AVersionInfo.
  FDelphiVersion := TDelphiVersion.Create(
    AVersionInfo.BDSVersionString,
    AVersionInfo.ProductName,
    Round(AVersionInfo.BDSVersion),
    AVersionInfo.ProductVersion);

  SysLog.Add(Format('Resolved Delphi version: %s build %s',
    [FDelphiVersion.ProductName, FDelphiVersion.BuildVersion]));

  Result          := TCollections.CreateList<ISBOMComponent>;
  FInternalModules.Clear;
  ExternalModules := TCollections.CreateList<IModuleInfo>;

  ModuleNames := FMapParser.ParseMapFile(AMapFile) as IList<string>;

  SysLog.Add(Format('MAP file contains %d modules', [ModuleNames.Count]));
  SysLog.Add(Format('File dictionary contains %d files',
    [FMapParser.GetDictionaryCount]));

  InternalCount := 0;
  ExternalCount := 0;

  for ModuleName in ModuleNames do
  begin
    Module := CreateModuleInfoFromName(ModuleName);

    if IsInternalModule(ModuleName) then
    begin
      FInternalModules.Add(Module);
      Inc(InternalCount);
    end
    else
    begin
      ExternalModules.Add(Module);
      Inc(ExternalCount);
    end;
  end;

  SysLog.Add(Format('Categorized: Internal=%d, External=%d',
    [InternalCount, ExternalCount]));

  GroupModulesByPackage(ExternalModules, Packages);

  SysLog.Add(Format('Grouped into %d packages', [Packages.Count]));

  BuildAmbiguousUnits(ExternalModules);

  for PackageName in Packages.Keys do
  begin
    PackageModules := Packages[PackageName];
    Component      := CreateComponentFromPackage(PackageName, PackageModules);
    if Assigned(Component) then
      Result.Add(Component);
  end;

  if Assigned(FDelphiVersion) then
  begin
    Component := TSBOMComponent.Create(
      FDelphiVersion.BomRef,
      FDelphiVersion.ProductName,
      FDelphiVersion.BuildVersion,
      ctFramework,
      'Embarcadero Technologies',
      'https://www.embarcadero.com',
      'LicenseRef-Embarcadero-Proprietary',
      AVersionInfo.ProductName);
    Result.Add(Component);
  end;

  SysLog.Add(Format('Created %d components', [Result.Count]));
end;

function TComponentDetector.GetDelphiVersion: IDelphiVersion;
begin
  Result := FDelphiVersion;
end;

function TComponentDetector.GetInternalModules: IReadOnlyList<IModuleInfo>;
begin
  Result := FInternalModules as IReadOnlyList<IModuleInfo>;
end;

function TComponentDetector.GetAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>;
begin
  Result := FAmbiguousUnits as IReadOnlyList<IAmbiguousUnit>;
end;

end.
