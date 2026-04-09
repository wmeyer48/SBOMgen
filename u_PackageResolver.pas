unit u_PackageResolver;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines IPackageResolver and its implementation. Builds module-to-
  package maps by scanning Delphi source paths and the GetIt
  CatalogRepository, then resolves individual module names to their
  containing package for use during SBOM component detection.
*)

interface

uses
  Spring.Collections,
  u_DelphiEnvironment,
  u_DelphiVersionDetector_2,
  u_RegistryHelper;

type
  /// <summary>
  /// Resolves Delphi unit names to their containing package names,
  /// and provides BPL file paths for hash computation.
  /// </summary>
  IPackageResolver = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    /// <summary>
    /// Scans Delphi library paths for the specified version and platform,
    /// building the internal Delphi module-to-package map.
    /// </summary>
    procedure BuildDelphiModuleMap(
      const ABDSVersion: IDelphiVersionInfo;
            APlatform: string);
    /// <summary>
    /// Scans the GetIt CatalogRepository and known BPL registry entries
    /// for the specified version and platform, building the third-party
    /// module-to-package map.
    /// </summary>
    procedure BuildThirdPartyModuleMap(
      const ABDSVersion: IDelphiVersionInfo;
            APlatform: string);
    /// <summary>
    /// Returns the package name for the specified module, or an empty
    /// string if the module is not in either map.
    /// </summary>
    function ResolveModuleToPackage(const AModuleName: string): string;
    /// <summary>Returns a summary string of module map counts for diagnostics.</summary>
    function GetStats: string;
    /// <summary>
    /// Returns the BPL file path for the specified package name, or an
    /// empty string if no BPL path was found during map construction.
    /// </summary>
    function GetBPLPathForPackage(const APackageName: string): string;
  end;

  TPackageResolver = class(TInterfacedObject, IPackageResolver)
  private
    FDelphiModules:     IDictionary<string, string>;
    FThirdPartyModules: IDictionary<string, string>;
    FRegistryHelper:    IDelphiRegistryHelper;
    FRegistryHarvester: IDelphiRegistryHarvester;
    FKnownPackages:     IDictionary<string, string>;

    function  ExpandBPLPath(const APath: string): string;
    function  ExtractPackageNameFromBPL(const ABPLPath: string): string;
    function  ExtractPackageNameFromFolder(const AFolderPath: string): string;
    function  InferPackageNameFromPath(const APath: string): string;
    procedure ScanDelphiSourcePath(const APath, APackageName: string);
    procedure ScanThirdPartySourceFolder(
      const ASourcePath, APackageFolder: string);
  public
    constructor Create(
      ARegistryHelper:    IDelphiRegistryHelper;
      ARegistryHarvester: IDelphiRegistryHarvester);

    procedure BuildDelphiModuleMap(
      const AVersionInfo: IDelphiVersionInfo;
            APlatform: string);
    procedure BuildThirdPartyModuleMap(
      const AVersionInfo: IDelphiVersionInfo;
            APlatform: string);
    function  GetBPLPathForPackage(const APackageName: string): string;
    function  ResolveModuleToPackage(const AModuleName: string): string;
    function  GetStats: string;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  u_Logger;

{ TPackageResolver }

constructor TPackageResolver.Create(
  ARegistryHelper:    IDelphiRegistryHelper;
  ARegistryHarvester: IDelphiRegistryHarvester);
begin
  inherited Create;
  FRegistryHelper    := ARegistryHelper;
  FRegistryHarvester := ARegistryHarvester;
  FDelphiModules     := TCollections.CreateDictionary<string, string>(
    TStringComparer.OrdinalIgnoreCase);
  FThirdPartyModules := TCollections.CreateDictionary<string, string>(
    TStringComparer.OrdinalIgnoreCase);
  FKnownPackages     := TCollections.CreateDictionary<string, string>(
    TStringComparer.OrdinalIgnoreCase);
end;

procedure TPackageResolver.BuildDelphiModuleMap(
  const AVersionInfo: IDelphiVersionInfo;
        APlatform: string);
var
  CleanPath: string;
  LibraryPaths: IDictionary<string, string>;
  PathKey:      string;
  PathValue:    string;
  Paths:        TArray<string>;
  Path:         string;
begin
  FDelphiModules.Clear;

  LibraryPaths := FRegistryHarvester.GetLibraryPaths(AVersionInfo, APlatform);

  SysLog.Add(Format('Processing %d library path types for %s',
    [LibraryPaths.Count, APlatform]));

  for PathKey in LibraryPaths.Keys do
  begin
    PathValue := LibraryPaths[PathKey];
    Paths     := PathValue.Split([';']);

    for Path in Paths do
    begin
      if Path.Trim.IsEmpty then
        Continue;

      // Registry path values may be stored with surrounding
      // double quotes — strip them before use.
      CleanPath := Path.Trim.Trim(['"']);

      if CleanPath.IsEmpty then
        Continue;

      if CleanPath.ToLower.Contains('\source\rtl') then
        ScanDelphiSourcePath(CleanPath, 'Delphi RTL')
      else if CleanPath.ToLower.Contains('\source\vcl') then
        ScanDelphiSourcePath(CleanPath, 'VCL')
      else if CleanPath.ToLower.Contains('\source\fmx') then
        ScanDelphiSourcePath(CleanPath, 'FireMonkey')
      else if CleanPath.ToLower.Contains('\source\data') then
        ScanDelphiSourcePath(CleanPath, 'Data Access')
      else if CleanPath.ToLower.Contains('\source\firedac') then
        ScanDelphiSourcePath(CleanPath, 'FireDAC')
      else if CleanPath.ToLower.Contains('\source\xml') then
        ScanDelphiSourcePath(CleanPath, 'XML')
      else if CleanPath.ToLower.Contains('\source\soap') then
        ScanDelphiSourcePath(CleanPath, 'SOAP')
      else if CleanPath.ToLower.Contains('\source\indy') then
        ScanDelphiSourcePath(CleanPath, 'Indy');
    end;
  end;

  SysLog.Add(Format('Built Delphi module map: %d modules',
    [FDelphiModules.Count]));
end;

procedure TPackageResolver.ScanDelphiSourcePath(
  const APath, APackageName: string);
var
  Files:      TArray<string>;
  FilePath:   string;
  ModuleName: string;
begin
  if not TDirectory.Exists(APath) then
  begin
    SysLog.Add(Format('Path not found: %s', [APath]));
    Exit;
  end;

  try
    Files := TDirectory.GetFiles(APath, '*.pas',
      TSearchOption.soAllDirectories);

    for FilePath in Files do
    begin
      ModuleName := TPath.GetFileNameWithoutExtension(FilePath);
      if not FDelphiModules.ContainsKey(ModuleName) then
        FDelphiModules.Add(ModuleName, APackageName);
    end;

    SysLog.Add(Format('Scanned %s: found %d units',
      [APackageName, Length(Files)]));
  except
    on E: Exception do
      SysLog.Add(Format('Error scanning %s: %s', [APath, E.Message]));
  end;
end;

function TPackageResolver.ExpandBPLPath(const APath: string): string;
begin
  Result := APath;
  Result := Result.Replace('$(BDS)',
    GetEnvironmentVariable('BDS'), [rfIgnoreCase]);
  Result := Result.Replace('$(BDSCOMMONDIR)',
    GetEnvironmentVariable('BDSCOMMONDIR'), [rfIgnoreCase]);

  if Result.Contains('$(') then
    Result := '';
end;

function TPackageResolver.ExtractPackageNameFromBPL(
  const ABPLPath: string): string;
var
  FileName: string;
  I:        Integer;
begin
  FileName := TPath.GetFileNameWithoutExtension(ABPLPath);

  if FileName.StartsWith('dcl', True) then
    FileName := FileName.Substring(3);

  Result := FileName;
  for I := Result.Length downto 1 do
  begin
    if not CharInSet(Result[I], ['0'..'9']) then
    begin
      Result := Copy(Result, 1, I);
      Break;
    end;
  end;

  if Result.EndsWith('DD', True) then
    Result := Copy(Result, 1, Result.Length - 2);

  if Result.IsEmpty then
    Result := FileName;
end;

procedure TPackageResolver.BuildThirdPartyModuleMap(
  const AVersionInfo: IDelphiVersionInfo;
        APlatform: string);
var
  CatalogPath:    string;
  PackageFolders: TArray<string>;
  PackageFolder:  string;
  SourcePath:     string;
  KnownPackages:  IList<IKnownPackage>;
  Package:        IKnownPackage;
  PackageName:    string;
  ExpandedPath:   string;
begin
  FThirdPartyModules.Clear;
  FKnownPackages.Clear;

  KnownPackages := FRegistryHarvester.GetKnownPackages(AVersionInfo, APlatform) as IList<IKnownPackage>;

  SysLog.Add(Format('Loading %d known packages for BPL paths',
    [KnownPackages.Count]));

  for Package in KnownPackages do
  begin
    PackageName  := ExtractPackageNameFromBPL(Package.PackageName);
    ExpandedPath := ExpandBPLPath(Package.BPLPath);

    if not PackageName.IsEmpty and not ExpandedPath.IsEmpty then
    begin
      if not FKnownPackages.ContainsKey(PackageName) then
        FKnownPackages.Add(PackageName, ExpandedPath);
    end;
  end;

  SysLog.Add(Format('Stored %d BPL paths', [FKnownPackages.Count]));

  CatalogPath := AVersionInfo.CatalogRepositoryPath;

  if not TDirectory.Exists(CatalogPath) then
  begin
    SysLog.Add('CatalogRepository not found: ' + CatalogPath);
    Exit;
  end;

  SysLog.Add('Scanning CatalogRepository: ' + CatalogPath);

  PackageFolders := TDirectory.GetDirectories(CatalogPath);

  for PackageFolder in PackageFolders do
  begin
    SourcePath := TPath.Combine(PackageFolder, 'Source');
    if TDirectory.Exists(SourcePath) then
      ScanThirdPartySourceFolder(SourcePath, PackageFolder);
  end;

  SysLog.Add(Format('Built third-party module map: %d modules from %d packages',
    [FThirdPartyModules.Count, Length(PackageFolders)]));
end;

procedure TPackageResolver.ScanThirdPartySourceFolder(
  const ASourcePath, APackageFolder: string);
var
  Files:       TArray<string>;
  FilePath:    string;
  ModuleName:  string;
  PackageName: string;
begin
  try
    PackageName := ExtractPackageNameFromFolder(APackageFolder);

    Files := TDirectory.GetFiles(ASourcePath, '*.pas',
      TSearchOption.soAllDirectories);

    for FilePath in Files do
    begin
      ModuleName := TPath.GetFileNameWithoutExtension(FilePath);
      if not FThirdPartyModules.ContainsKey(ModuleName) then
        FThirdPartyModules.Add(ModuleName, PackageName);
    end;

    if Length(Files) > 0 then
      SysLog.Add(Format('  %s: %d units', [PackageName, Length(Files)]));
  except
    on E: Exception do
      SysLog.Add(Format('Error scanning %s: %s', [ASourcePath, E.Message]));
  end;
end;

function TPackageResolver.ExtractPackageNameFromFolder(
  const AFolderPath: string): string;
var
  FolderName: string;
  DashPos:    Integer;
begin
  FolderName := TPath.GetFileName(AFolderPath);

  DashPos := Pos('-', FolderName);
  if DashPos > 0 then
    Result := Copy(FolderName, 1, DashPos - 1)
  else
    Result := FolderName;

  Result := Result.ToLower;

  if Result.Contains('konopka') or Result.Contains('ksvc') or
     Result.Contains('raize') then
    Result := 'KSVC'
  else if Result.Contains('spring') then
    Result := 'Spring4D'
  else if Result.Contains('virtualtree') or Result.Contains('vst') then
    Result := 'VirtualTrees'
  else if Result.Contains('synedit') then
    Result := 'SynEdit'
  else if Result.Contains('svgicon') or Result.Contains('svg') then
    Result := 'SVGIconImageList'
  else if Result.Contains('img32') or Result.Contains('image32') then
    Result := 'Image32'
  else if Result.Contains('clipper') then
    Result := 'Clipper'
  else
    Result := FolderName;
end;

function TPackageResolver.GetBPLPathForPackage(
  const APackageName: string): string;
begin
  Result := '';

  if not Assigned(FKnownPackages) then
    Exit;

  FKnownPackages.TryGetValue(APackageName, Result);
end;

function TPackageResolver.InferPackageNameFromPath(const APath: string): string;
begin
  if APath.ToLower.Contains('raize') or APath.ToLower.Contains('ksvc') then
    Result := 'KSVC'
  else if APath.ToLower.Contains('spring') then
    Result := 'Spring4D'
  else if APath.ToLower.Contains('virtualtree') or APath.ToLower.Contains('vst') then
    Result := 'VirtualTreeView'
  else if APath.ToLower.Contains('synedit') then
    Result := 'SynEdit'
  else
  begin
    Result := TPath.GetFileName(TDirectory.GetParent(APath));
    if Result.IsEmpty then
      Result := TPath.GetFileName(APath);
  end;
end;

function TPackageResolver.ResolveModuleToPackage(
  const AModuleName: string): string;
var
  ModuleLower: string;
begin
  if FDelphiModules.TryGetValue(AModuleName, Result) then
    Exit;

  if FThirdPartyModules.TryGetValue(AModuleName, Result) then
    Exit;

  ModuleLower := AModuleName.ToLower;

  if ModuleLower.StartsWith('svg') then
    Exit('SVGIconImageList')
  else if ModuleLower.StartsWith('img32') or
          ModuleLower.StartsWith('image32') then
    Exit('Image32')
  else if ModuleLower.StartsWith('clipper') then
    Exit('Clipper');

  Result := '';
end;

function TPackageResolver.GetStats: string;
begin
  Result := Format('Package Resolver: %d Delphi modules, %d third-party modules',
    [FDelphiModules.Count, FThirdPartyModules.Count]);
end;

end.
