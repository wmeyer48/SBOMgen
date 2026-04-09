unit u_DelphiEnvironment;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines the Delphi environment interfaces and implementations used
  during SBOM component detection. Covers registry harvesting for
  library paths and known packages, DPROJ file parsing, and the
  structured environment model that aggregates both.
*)

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Xml.XMLIntf,
  Spring.Collections,
  u_DelphiVersionDetector_2;

type
  /// <summary>
  /// Represents a single registered Delphi package entry, carrying
  /// the BPL path, DCP path, and description from the registry.
  /// </summary>
  IKnownPackage = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the package name derived from the BPL file name.</summary>
    function GetPackageName: string;
    /// <summary>Returns the registry description string for this package.</summary>
    function GetDescription: string;
    /// <summary>Returns the fully qualified BPL file path.</summary>
    function GetBPLPath: string;
    /// <summary>Returns the fully qualified DCP file path, derived from the BPL path.</summary>
    function GetDCPPath: string;

    /// <summary>Package name derived from the BPL file name.</summary>
    property PackageName: string read GetPackageName;
    /// <summary>Registry description string for this package.</summary>
    property Description: string read GetDescription;
    /// <summary>Fully qualified BPL file path.</summary>
    property BPLPath: string read GetBPLPath;
    /// <summary>Fully qualified DCP file path.</summary>
    property DCPPath: string read GetDCPPath;
  end;

  /// <summary>
  /// Aggregates library paths, browsing paths, debug DCU paths,
  /// package output paths, and known package lists for a single
  /// Delphi installation.
  /// </summary>
  IDelphiEnvironment = interface
    ['{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}']
    /// <summary>Returns the version information for this Delphi installation.</summary>
    function GetVersionInfo: IDelphiVersionInfo;
    /// <summary>Returns the library search paths for the specified platform.</summary>
    function GetLibrarySearchPaths(APlatform: TDelphiPlatform): IReadOnlyList<string>;
    /// <summary>Returns the browsing paths for the specified platform.</summary>
    function GetBrowsingPaths(APlatform: TDelphiPlatform): IReadOnlyList<string>;
    /// <summary>Returns the debug DCU paths for the specified platform.</summary>
    function GetDebugDCUPaths(APlatform: TDelphiPlatform): IReadOnlyList<string>;
    /// <summary>Returns the package DCP output path for the specified platform.</summary>
    function GetPackageDCPOutput(APlatform: TDelphiPlatform): string;
    /// <summary>Returns the package DPL output path for the specified platform.</summary>
    function GetPackageDPLOutput(APlatform: TDelphiPlatform): string;
    /// <summary>Returns the read-only list of known runtime package paths.</summary>
    function GetKnownPackages: IReadOnlyList<string>;
    /// <summary>Returns the read-only list of known IDE package paths.</summary>
    function GetKnownIDEPackages: IReadOnlyList<string>;

    /// <summary>Version information for this Delphi installation.</summary>
    property VersionInfo: IDelphiVersionInfo read GetVersionInfo;
  end;

  /// <summary>
  /// Parses a Delphi DPROJ file to extract search paths, conditional
  /// defines, output paths, platform, and build configuration.
  /// </summary>
  IDPROJParser = interface
    ['{B2C3D4E5-F6A7-8901-2345-6789ABCDEF01}']
    /// <summary>Parses the specified DPROJ file. Returns True on success.</summary>
    function ParseFile(const AFileName: string): Boolean;
    /// <summary>Returns the unit search paths extracted from the DPROJ.</summary>
    function GetSearchPaths: IReadOnlyList<string>;
    /// <summary>Returns the conditional defines extracted from the DPROJ.</summary>
    function GetConditionalDefines: IReadOnlyList<string>;
    /// <summary>Returns the DCP output path from the DPROJ.</summary>
    function GetDCPOutput: string;
    /// <summary>Returns the DPL output path from the DPROJ.</summary>
    function GetDPLOutput: string;
    /// <summary>Returns the target platform string from the DPROJ.</summary>
    function GetPlatform: string;
    /// <summary>Returns the build configuration from the DPROJ, e.g. Debug or Release.</summary>
    function GetConfig: string;
  end;

  /// <summary>
  /// Harvests Delphi environment data from the Windows registry,
  /// covering library paths, known packages, and the full environment model.
  /// </summary>
  IDelphiRegistryHarvester = interface
    ['{C3D4E5F6-A7B8-9012-3456-789ABCDEF012}']
    /// <summary>
    /// Reads all environment data for the specified Delphi version
    /// from the registry and returns a populated IDelphiEnvironment.
    /// </summary>
    function HarvestEnvironment(AVersionInfo: IDelphiVersionInfo): IDelphiEnvironment;
    /// <summary>
    /// Returns the list of known packages registered for the specified
    /// version and platform.
    /// </summary>
    function GetKnownPackages(AVersionInfo: IDelphiVersionInfo;
      APlatform: string): IReadOnlyList<IKnownPackage>;
    /// <summary>
    /// Returns a dictionary of library path type names to their
    /// semicolon-delimited, variable-expanded path values for the
    /// specified version and platform.
    /// </summary>
    function GetLibraryPaths(AVersionInfo: IDelphiVersionInfo;
      const APlatform: string): IDictionary<string, string>;
  end;

  TDelphiEnvironment = class(TInterfacedObject, IDelphiEnvironment)
  private
    FVersionInfo:         IDelphiVersionInfo;
    FLibrarySearchPaths:  IDictionary<TDelphiPlatform, IList<string>>;
    FBrowsingPaths:       IDictionary<TDelphiPlatform, IList<string>>;
    FDebugDCUPaths:       IDictionary<TDelphiPlatform, IList<string>>;
    FPackageDCPOutput:    IDictionary<TDelphiPlatform, string>;
    FPackageDPLOutput:    IDictionary<TDelphiPlatform, string>;
    FKnownPackages:       IList<string>;
    FKnownIDEPackages:    IList<string>;
  public
    constructor Create(AVersionInfo: IDelphiVersionInfo);

    function GetVersionInfo: IDelphiVersionInfo;
    function GetLibrarySearchPaths(APlatform: TDelphiPlatform): IReadOnlyList<string>;
    function GetBrowsingPaths(APlatform: TDelphiPlatform):      IReadOnlyList<string>;
    function GetDebugDCUPaths(APlatform: TDelphiPlatform):      IReadOnlyList<string>;
    function GetPackageDCPOutput(APlatform: TDelphiPlatform):   string;
    function GetPackageDPLOutput(APlatform: TDelphiPlatform):   string;
    function GetKnownPackages:    IReadOnlyList<string>;
    function GetKnownIDEPackages: IReadOnlyList<string>;

    procedure SetLibrarySearchPaths(APlatform: TDelphiPlatform; APaths: IList<string>);
    procedure SetBrowsingPaths(APlatform: TDelphiPlatform;      APaths: IList<string>);
    procedure SetDebugDCUPaths(APlatform: TDelphiPlatform;      APaths: IList<string>);
    procedure SetPackageDCPOutput(APlatform: TDelphiPlatform; const APath: string);
    procedure SetPackageDPLOutput(APlatform: TDelphiPlatform; const APath: string);
    procedure SetKnownPackages(APackages:    IList<string>);
    procedure SetKnownIDEPackages(APackages: IList<string>);
  end;

  TDPROJParser = class(TInterfacedObject, IDPROJParser)
  private
    FSearchPaths:        IList<string>;
    FConditionalDefines: IList<string>;
    FDCPOutput:          string;
    FDPLOutput:          string;
    FPlatform:           string;
    FConfig:             string;

    procedure ParsePropertyGroup(ANode: IXMLNode);
    procedure ParseItemGroup(ANode: IXMLNode);
  public
    constructor Create;

    function ParseFile(const AFileName: string): Boolean;
    function GetSearchPaths:       IReadOnlyList<string>;
    function GetConditionalDefines: IReadOnlyList<string>;
    function GetDCPOutput: string;
    function GetDPLOutput: string;
    function GetPlatform:  string;
    function GetConfig:    string;
  end;

  TDelphiRegistryHarvester = class(TInterfacedObject, IDelphiRegistryHarvester)
  private
    function GetRegistryValue(ARootKey: HKEY;
      const AKeyPath, AValueName: string): string;
    function SplitPaths(const APathString: string): IList<string>;
    function GetLibraryKey(AVersionInfo: IDelphiVersionInfo;
      APlatform: TDelphiPlatform): string;
  public
    function GetKnownPackages(AVersionInfo: IDelphiVersionInfo;
      APlatform: string): IReadOnlyList<IKnownPackage>;
    function GetLibraryPaths(AVersionInfo: IDelphiVersionInfo;
      const APlatform: string): IDictionary<string, string>;
    function HarvestEnvironment(
      AVersionInfo: IDelphiVersionInfo): IDelphiEnvironment;
  end;

  TKnownPackage = class(TInterfacedObject, IKnownPackage)
  private
    FBPLPath:     string;
    FDescription: string;
    FDCPPath:     string;
  public
    constructor Create(const ABPLPath, ADescription: string);

    function GetPackageName: string;
    function GetDescription: string;
    function GetBPLPath:     string;
    function GetDCPPath:     string;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.Win.Registry,
  Xml.XMLDoc,
  u_Logger;

const
  PATH_SEARCH         = 'Search Path';
  PATH_PACKAGE_SEARCH = 'Package Search Path';
  PATH_BROWSING       = 'Browsing Path';
  PATH_DCP_OUTPUT     = 'Package DCP Output';
  PATH_DEBUG_DCU      = 'Debug DCU Path';

  LIBRARY_PATH_KEYS: array[0..4] of string = (
    PATH_SEARCH,
    PATH_PACKAGE_SEARCH,
    PATH_BROWSING,
    PATH_DCP_OUTPUT,
    PATH_DEBUG_DCU
  );

  KNOWN_PACKAGES_WIN32     = 'Known Packages';
  KNOWN_PACKAGES_X64       = 'Known Packages x64';
  KNOWN_IDE_PACKAGES_WIN32 = 'Known IDE Packages';
  KNOWN_IDE_PACKAGES_X64   = 'Known IDE Packages x64';

{ Utility }

function ExpandIDEVariable(const S: string;
  const ABDSPath, ABDSCommonDir, ABDSLib,
        ABDSUserDir, ABDSCatalogRepo,
        ABDSCatalogRepoAllUsers,
        APlatform: string;
  out Expanded: string): Boolean;
var
  WorkStr: string;
  Buffer:  array[0..MAX_PATH] of Char;
  Len:     DWORD;
begin
  Result   := False;
  Expanded := S;
  WorkStr  := S;

  // Substitute Delphi IDE macros — these are not Windows environment
  // variables and must be replaced explicitly before calling
  // ExpandEnvironmentStrings. Both $(VAR) and %VAR% forms are handled
  // since different Delphi versions and installations use both.
  // Longer names must be substituted before shorter prefix matches.
  if not ABDSCatalogRepoAllUsers.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(BDSCatalogRepositoryAllUsers)',
      ABDSCatalogRepoAllUsers, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%BDSCatalogRepositoryAllUsers%',
      ABDSCatalogRepoAllUsers, [rfReplaceAll, rfIgnoreCase]);
  end;

  if not ABDSCatalogRepo.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(BDSCatalogRepository)',
      ABDSCatalogRepo, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%BDSCatalogRepository%',
      ABDSCatalogRepo, [rfReplaceAll, rfIgnoreCase]);
  end;

  if not ABDSCommonDir.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(BDSCOMMONDIR)',
      ABDSCommonDir, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%BDSCOMMONDIR%',
      ABDSCommonDir, [rfReplaceAll, rfIgnoreCase]);
  end;

  if not ABDSUserDir.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(BDSUSERDIR)',
      ABDSUserDir, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%BDSUSERDIR%',
      ABDSUserDir, [rfReplaceAll, rfIgnoreCase]);
  end;

  if not ABDSLib.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(BDSLIB)',
      ABDSLib, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%BDSLIB%',
      ABDSLib, [rfReplaceAll, rfIgnoreCase]);
  end;

  if not ABDSPath.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(BDS)',
      ABDSPath, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%BDS%',
      ABDSPath, [rfReplaceAll, rfIgnoreCase]);
  end;

  if not APlatform.IsEmpty then
  begin
    WorkStr := StringReplace(WorkStr, '$(Platform)',
      APlatform, [rfReplaceAll, rfIgnoreCase]);
    WorkStr := StringReplace(WorkStr, '%Platform%',
      APlatform, [rfReplaceAll, rfIgnoreCase]);
  end;

  // Convert any remaining $(VAR) MSBuild syntax to %VAR% so that
  // ExpandEnvironmentStrings can handle standard Windows env vars
  // such as $(HOMEDRIVE), $(LOCALAPPDATA), $(APPDATA) etc.
  if WorkStr.Contains('$(') then
  begin
    WorkStr := StringReplace(WorkStr, '$(', '%', [rfReplaceAll]);
    WorkStr := StringReplace(WorkStr, ')',  '%', [rfReplaceAll]);
  end;

  // Expand any remaining Windows environment variables.
  Len := ExpandEnvironmentStrings(PChar(WorkStr), @Buffer[0], MAX_PATH);

  if Len > 0 then
  begin
    Expanded := Buffer;
    Result   := True;
  end
  else
  begin
    SysLog.Add(Format('Warning: Could not expand variable: %s', [S]));
    Expanded := S;
    Result   := False;
  end;
end;

{ TDelphiEnvironment }

constructor TDelphiEnvironment.Create(AVersionInfo: IDelphiVersionInfo);
begin
  inherited Create;
  FVersionInfo         := AVersionInfo;
  FLibrarySearchPaths  := TCollections.CreateDictionary<TDelphiPlatform, IList<string>>;
  FBrowsingPaths       := TCollections.CreateDictionary<TDelphiPlatform, IList<string>>;
  FDebugDCUPaths       := TCollections.CreateDictionary<TDelphiPlatform, IList<string>>;
  FPackageDCPOutput    := TCollections.CreateDictionary<TDelphiPlatform, string>;
  FPackageDPLOutput    := TCollections.CreateDictionary<TDelphiPlatform, string>;
  FKnownPackages       := TCollections.CreateList<string>;
  FKnownIDEPackages    := TCollections.CreateList<string>;
end;

function TDelphiEnvironment.GetVersionInfo: IDelphiVersionInfo;
begin
  Result := FVersionInfo;
end;

function TDelphiEnvironment.GetLibrarySearchPaths(
  APlatform: TDelphiPlatform): IReadOnlyList<string>;
var
  List: IList<string>;
begin
  if not FLibrarySearchPaths.TryGetValue(APlatform, List) then
    List := TCollections.CreateList<string>;
  Result := List as IReadOnlyList<string>;
end;

function TDelphiEnvironment.GetBrowsingPaths(
  APlatform: TDelphiPlatform): IReadOnlyList<string>;
var
  List: IList<string>;
begin
  if not FBrowsingPaths.TryGetValue(APlatform, List) then
    List := TCollections.CreateList<string>;
  Result := List as IReadOnlyList<string>;
end;

function TDelphiEnvironment.GetDebugDCUPaths(
  APlatform: TDelphiPlatform): IReadOnlyList<string>;
var
  List: IList<string>;
begin
  if not FDebugDCUPaths.TryGetValue(APlatform, List) then
    List := TCollections.CreateList<string>;
  Result := List as IReadOnlyList<string>;
end;

function TDelphiEnvironment.GetPackageDCPOutput(APlatform: TDelphiPlatform): string;
begin
  if not FPackageDCPOutput.TryGetValue(APlatform, Result) then
    Result := '';
end;

function TDelphiEnvironment.GetPackageDPLOutput(APlatform: TDelphiPlatform): string;
begin
  if not FPackageDPLOutput.TryGetValue(APlatform, Result) then
    Result := '';
end;

function TDelphiEnvironment.GetKnownPackages: IReadOnlyList<string>;
begin
  Result := FKnownPackages as IReadOnlyList<string>;
end;

function TDelphiEnvironment.GetKnownIDEPackages: IReadOnlyList<string>;
begin
  Result := FKnownIDEPackages as IReadOnlyList<string>;
end;

procedure TDelphiEnvironment.SetLibrarySearchPaths(APlatform: TDelphiPlatform;
  APaths: IList<string>);
begin
  FLibrarySearchPaths[APlatform] := APaths;
end;

procedure TDelphiEnvironment.SetBrowsingPaths(APlatform: TDelphiPlatform;
  APaths: IList<string>);
begin
  FBrowsingPaths[APlatform] := APaths;
end;

procedure TDelphiEnvironment.SetDebugDCUPaths(APlatform: TDelphiPlatform;
  APaths: IList<string>);
begin
  FDebugDCUPaths[APlatform] := APaths;
end;

procedure TDelphiEnvironment.SetPackageDCPOutput(APlatform: TDelphiPlatform;
  const APath: string);
begin
  FPackageDCPOutput[APlatform] := APath;
end;

procedure TDelphiEnvironment.SetPackageDPLOutput(APlatform: TDelphiPlatform;
  const APath: string);
begin
  FPackageDPLOutput[APlatform] := APath;
end;

procedure TDelphiEnvironment.SetKnownPackages(APackages: IList<string>);
begin
  FKnownPackages := APackages;
end;

procedure TDelphiEnvironment.SetKnownIDEPackages(APackages: IList<string>);
begin
  FKnownIDEPackages := APackages;
end;

{ TDPROJParser }

constructor TDPROJParser.Create;
begin
  inherited Create;
  FSearchPaths        := TCollections.CreateList<string>;
  FConditionalDefines := TCollections.CreateList<string>;
  FDCPOutput          := '';
  FDPLOutput          := '';
  FPlatform           := 'Win32';
  FConfig             := 'Debug';
end;

function TDPROJParser.ParseFile(const AFileName: string): Boolean;
var
  XMLDoc:   IXMLDocument;
  RootNode: IXMLNode;
  Node:     IXMLNode;
  I:        Integer;
begin
  Result := False;

  if not FileExists(AFileName) then
    Exit;

  try
    XMLDoc := TXMLDocument.Create(nil);
    try
      XMLDoc.LoadFromFile(AFileName);
      XMLDoc.Active := True;

      RootNode := XMLDoc.DocumentElement;
      if not Assigned(RootNode) then
        Exit;

      for I := 0 to RootNode.ChildNodes.Count - 1 do
      begin
        Node := RootNode.ChildNodes[I];
        if SameText(Node.NodeName, 'PropertyGroup') then
          ParsePropertyGroup(Node);
      end;

      for I := 0 to RootNode.ChildNodes.Count - 1 do
      begin
        Node := RootNode.ChildNodes[I];
        if SameText(Node.NodeName, 'ItemGroup') then
          ParseItemGroup(Node);
      end;

      Result := True;
    finally
      XMLDoc := nil;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

procedure TDPROJParser.ParsePropertyGroup(ANode: IXMLNode);
var
  I:         Integer;
  ChildNode: IXMLNode;
  NodeName:  string;
  NodeValue: string;
  Paths:     TArray<string>;
  Path:      string;
begin
  for I := 0 to ANode.ChildNodes.Count - 1 do
  begin
    ChildNode := ANode.ChildNodes[I];
    NodeName  := ChildNode.NodeName;
    NodeValue := ChildNode.Text;

    if SameText(NodeName, 'DCC_UnitSearchPath') then
    begin
      Paths := NodeValue.Split([';']);
      for Path in Paths do
      begin
        if not Path.Trim.IsEmpty then
          FSearchPaths.Add(Path.Trim);
      end;
    end
    else if SameText(NodeName, 'DCC_Define') then
    begin
      Paths := NodeValue.Split([';']);
      for Path in Paths do
      begin
        if not Path.Trim.IsEmpty then
          FConditionalDefines.Add(Path.Trim);
      end;
    end
    else if SameText(NodeName, 'DCC_DcpOutput') then
      FDCPOutput := NodeValue
    else if SameText(NodeName, 'DCC_BplOutput') then
      FDPLOutput := NodeValue
    else if SameText(NodeName, 'Platform') then
      FPlatform := NodeValue
    else if SameText(NodeName, 'Config') then
      FConfig := NodeValue;
  end;
end;

procedure TDPROJParser.ParseItemGroup(ANode: IXMLNode);
begin
  // ItemGroup parsing is not currently required by SBOMgen.
  // Retained as an extension point for future DPROJ analysis.
end;

function TDPROJParser.GetSearchPaths: IReadOnlyList<string>;
begin
  Result := FSearchPaths as IReadOnlyList<string>;
end;

function TDPROJParser.GetConditionalDefines: IReadOnlyList<string>;
begin
  Result := FConditionalDefines as IReadOnlyList<string>;
end;

function TDPROJParser.GetDCPOutput: string;
begin
  Result := FDCPOutput;
end;

function TDPROJParser.GetDPLOutput: string;
begin
  Result := FDPLOutput;
end;

function TDPROJParser.GetPlatform: string;
begin
  Result := FPlatform;
end;

function TDPROJParser.GetConfig: string;
begin
  Result := FConfig;
end;

{ TDelphiRegistryHarvester }

function TDelphiRegistryHarvester.GetRegistryValue(ARootKey: HKEY;
  const AKeyPath, AValueName: string): string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg    := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ARootKey;
    if Reg.OpenKeyReadOnly(AKeyPath) then
    begin
      if Reg.ValueExists(AValueName) then
        Result := Reg.ReadString(AValueName);
    end;
  finally
    Reg.Free;
  end;
end;

function TDelphiRegistryHarvester.SplitPaths(
  const APathString: string): IList<string>;
var
  Paths: TArray<string>;
  Path:  string;
begin
  Result := TCollections.CreateList<string>;
  Paths  := APathString.Split([';']);
  for Path in Paths do
  begin
    if not Path.Trim.IsEmpty then
      Result.Add(Path.Trim);
  end;
end;

function TDelphiRegistryHarvester.GetLibraryKey(
  AVersionInfo: IDelphiVersionInfo;
  APlatform: TDelphiPlatform): string;
const
  PlatformSuffixes: array[TDelphiPlatform] of string = ('\Win32', '\Win64');
begin
  if AVersionInfo.Version < dvDelphiXE2 then
    Result := 'Software' + AVersionInfo.RegistryPath + '\Library'
  else
    Result := 'Software' + AVersionInfo.RegistryPath + '\Library'
      + PlatformSuffixes[APlatform];
end;

function TDelphiRegistryHarvester.HarvestEnvironment(
  AVersionInfo: IDelphiVersionInfo): IDelphiEnvironment;
var
  Env:          TDelphiEnvironment;
  Platform:     TDelphiPlatform;
  LibraryKey:   string;
  PathString:   string;
  RootKeys:     array[0..1] of HKEY;
  RootKey:      HKEY;
  PackagesKey:  string;
  Reg:          TRegistry;
  PackageNames: TStringList;
  KnownList:    IList<string>;
  I:            Integer;
begin
  Env := TDelphiEnvironment.Create(AVersionInfo);

  RootKeys[0] := HKEY_CURRENT_USER;
  RootKeys[1] := HKEY_LOCAL_MACHINE;

  for Platform := Low(TDelphiPlatform) to High(TDelphiPlatform) do
  begin
    if (Platform = dpWin64) and not AVersionInfo.Supports64Bit then
      Continue;

    LibraryKey := GetLibraryKey(AVersionInfo, Platform);

    for RootKey in RootKeys do
    begin
      PathString := GetRegistryValue(RootKey, LibraryKey, 'Search Path');
      if not PathString.IsEmpty then
      begin
        Env.SetLibrarySearchPaths(Platform, SplitPaths(PathString));
        Break;
      end;
    end;

    for RootKey in RootKeys do
    begin
      PathString := GetRegistryValue(RootKey, LibraryKey, 'Browsing Path');
      if not PathString.IsEmpty then
      begin
        Env.SetBrowsingPaths(Platform, SplitPaths(PathString));
        Break;
      end;
    end;

    for RootKey in RootKeys do
    begin
      PathString := GetRegistryValue(RootKey, LibraryKey, 'Debug DCU Path');
      if not PathString.IsEmpty then
      begin
        Env.SetDebugDCUPaths(Platform, SplitPaths(PathString));
        Break;
      end;
    end;

    for RootKey in RootKeys do
    begin
      PathString := GetRegistryValue(RootKey, LibraryKey, 'Package DCP Output');
      if not PathString.IsEmpty then
      begin
        Env.SetPackageDCPOutput(Platform, PathString);
        Break;
      end;
    end;

    for RootKey in RootKeys do
    begin
      PathString := GetRegistryValue(RootKey, LibraryKey, 'Package DPL Output');
      if not PathString.IsEmpty then
      begin
        Env.SetPackageDPLOutput(Platform, PathString);
        Break;
      end;
    end;
  end;

  PackagesKey := 'Software' + AVersionInfo.RegistryPath + '\Known Packages';
  for RootKey in RootKeys do
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := RootKey;
      if Reg.OpenKeyReadOnly(PackagesKey) then
      begin
        KnownList    := TCollections.CreateList<string>;
        PackageNames := TStringList.Create;
        try
          Reg.GetValueNames(PackageNames);
          for I := 0 to PackageNames.Count - 1 do
            KnownList.Add(PackageNames[I]);
        finally
          PackageNames.Free;
        end;
        Env.SetKnownPackages(KnownList);
        Break;
      end;
    finally
      Reg.Free;
    end;
  end;

  PackagesKey := 'Software' + AVersionInfo.RegistryPath + '\Known IDE Packages';
  for RootKey in RootKeys do
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := RootKey;
      if Reg.OpenKeyReadOnly(PackagesKey) then
      begin
        KnownList    := TCollections.CreateList<string>;
        PackageNames := TStringList.Create;
        try
          Reg.GetValueNames(PackageNames);
          for I := 0 to PackageNames.Count - 1 do
            KnownList.Add(PackageNames[I]);
        finally
          PackageNames.Free;
        end;
        Env.SetKnownIDEPackages(KnownList);
        Break;
      end;
    finally
      Reg.Free;
    end;
  end;

  Result := Env;
end;

function TDelphiRegistryHarvester.GetKnownPackages(
  AVersionInfo: IDelphiVersionInfo;
  APlatform: string): IReadOnlyList<IKnownPackage>;
var
  Reg:         TRegistry;
  BasePath:    string;
  PackageKeys: TArray<string>;
  KeyName:     string;
  FullKeyPath: string;
  ValueNames:  TStringList;
  BPLPath:     string;
  Description: string;
  Results:     IList<IKnownPackage>;
begin
  Results := TCollections.CreateList<IKnownPackage>;

  BasePath := 'Software' + AVersionInfo.RegistryPath + '\';

  if APlatform = 'Win32' then
    PackageKeys := [KNOWN_PACKAGES_WIN32, KNOWN_IDE_PACKAGES_WIN32]
  else
    PackageKeys := [KNOWN_PACKAGES_X64, KNOWN_IDE_PACKAGES_X64];

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    ValueNames := TStringList.Create;
    try
      for KeyName in PackageKeys do
      begin
        FullKeyPath := BasePath + KeyName;

        if not Reg.OpenKeyReadOnly(FullKeyPath) then
        begin
          SysLog.Add(Format('Note: Registry key not found: %s',
            [FullKeyPath]));
          Continue;
        end;

        ValueNames.Clear;
        Reg.GetValueNames(ValueNames);

        for BPLPath in ValueNames do
        begin
          Description := Reg.ReadString(BPLPath);
          Results.Add(TKnownPackage.Create(BPLPath, Description));
        end;

        SysLog.Add(Format('Found %d packages in %s',
          [ValueNames.Count, KeyName]));

        Reg.CloseKey;
      end;
    finally
      ValueNames.Free;
    end;
  finally
    Reg.Free;
  end;

  SysLog.Add(Format('Total known packages for %s: %d',
    [APlatform, Results.Count]));

  Result := Results as IReadOnlyList<IKnownPackage>;
end;

function TDelphiRegistryHarvester.GetLibraryPaths(
  AVersionInfo: IDelphiVersionInfo;
  const APlatform: string): IDictionary<string, string>;
var
  Reg:                     TRegistry;
  KeyPath:                 string;
  PathKey:                 string;
  RawValue:                string;
  Segments:                TArray<string>;
  Segment:                 string;
  ProcessedSegments:       TStringList;
  ExpandedSegment:         string;
  I:                       Integer;
  BDSVersion:              string;
  BDSPath:                 string;
  BDSCommonDir:            string;
  BDSLib:                  string;
  BDSUserDir:              string;
  BDSCatalogRepo:          string;
  BDSCatalogRepoAllUsers:  string;
  EnvKeyPath:              string;
begin
  Result  := TCollections.CreateDictionary<string, string>;
  KeyPath := Format('Software\%s\Library\%s\',
    [AVersionInfo.RegistryPath, APlatform]);

  // Derive BDS macro values from registry and version info.
  // Extract version suffix e.g. "23.0" from "\Embarcadero\BDS\23.0".
  BDSVersion := Copy(AVersionInfo.RegistryPath,
    LastDelimiter('\', AVersionInfo.RegistryPath) + 1, MaxInt);
  SysLog.Add('BDSVersion extracted: [' + BDSVersion + ']');

  BDSPath    := AVersionInfo.RootDirectory;
  BDSLib     := TPath.Combine(BDSPath, 'lib');

  // Read IDE macro values from the Environment Variables registry subkey
  // where present (Delphi XE2 and later). Fall back to constructed paths
  // for older versions that do not write this subkey.
  EnvKeyPath := 'Software' + AVersionInfo.RegistryPath +
    '\Environment Variables';

  BDSCommonDir := GetRegistryValue(HKEY_CURRENT_USER,
    EnvKeyPath, 'BDSCOMMONDIR');
  if BDSCommonDir.IsEmpty then
    BDSCommonDir := AVersionInfo.CommonStudioDir;

  BDSCatalogRepoAllUsers := GetRegistryValue(HKEY_CURRENT_USER,
    EnvKeyPath, 'BDSCatalogRepositoryAllUsers');
  if BDSCatalogRepoAllUsers.IsEmpty then
    BDSCatalogRepoAllUsers := AVersionInfo.CatalogRepositoryAllUsersPath;

  BDSUserDir     := AVersionInfo.UserStudioDir;
  BDSCatalogRepo := AVersionInfo.CatalogRepositoryPath;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKeyReadOnly(KeyPath) then
    begin
      ProcessedSegments           := TStringList.Create;
      ProcessedSegments.Delimiter := ';';
      try
        for I := Low(LIBRARY_PATH_KEYS) to High(LIBRARY_PATH_KEYS) do
        begin
          PathKey := LIBRARY_PATH_KEYS[I];

          if not Reg.ValueExists(PathKey) then
            Continue;

          RawValue := Reg.ReadString(PathKey);

          if RawValue.Trim.IsEmpty then
            Continue;

          ProcessedSegments.Clear;
          Segments := RawValue.Split([';']);

          for Segment in Segments do
          begin
            if Segment.Trim.IsEmpty then
              Continue;

            // Expand both $(VAR) and %VAR% forms. The check includes
            // % to catch %BDS%, %BDSLIB% etc. used by some installations.
            if Segment.Contains('$(') or Segment.Contains('%') then
            begin
              if ExpandIDEVariable(Segment,
                   BDSPath, BDSCommonDir, BDSLib,
                   BDSUserDir, BDSCatalogRepo,
                   BDSCatalogRepoAllUsers, APlatform,
                   ExpandedSegment) then
                ProcessedSegments.Add(ExpandedSegment)
              else
                ProcessedSegments.Add(Segment);
            end
            else
              ProcessedSegments.Add(Segment);
          end;

          if ProcessedSegments.Count > 0 then
            Result.Add(PathKey, ProcessedSegments.DelimitedText);
        end;
      finally
        ProcessedSegments.Free;
      end;
    end
    else
      SysLog.Add(Format('Note: Registry key not found: HKCU\%s', [KeyPath]));
  finally
    Reg.Free;
  end;

  SysLog.Add(Format('Loaded %d library path entries for %s',
    [Result.Count, APlatform]));
end;

{ TKnownPackage }

constructor TKnownPackage.Create(const ABPLPath, ADescription: string);
begin
  inherited Create;
  FBPLPath     := ABPLPath;
  FDescription := ADescription;
  FDCPPath     := ChangeFileExt(ABPLPath, '.dcp');
end;

function TKnownPackage.GetBPLPath: string;
begin
  Result := FBPLPath;
end;

function TKnownPackage.GetDCPPath: string;
begin
  Result := FDCPPath;
end;

function TKnownPackage.GetDescription: string;
begin
  Result := FDescription;
end;

function TKnownPackage.GetPackageName: string;
begin
  Result := TPath.GetFileNameWithoutExtension(FBPLPath);
end;

end.
