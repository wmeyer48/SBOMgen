unit u_DelphiVersionDetector_2;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines the Delphi version detection subsystem. Covers the
  immutable version metadata model (IDelphiVersionInfo), the
  static version repository (IDelphiVersionRepository), and
  the registry-based installation detector
  (IDelphiInstallationDetector). Supports Delphi 5 through
  Delphi 13 Florence.
*)

interface

uses
  Winapi.Windows,
  Spring.Collections;

type
  /// <summary>
  /// Enumeration of supported Delphi versions from Delphi 5
  /// through Delphi 13 Florence.
  /// </summary>
  TDelphiVersion = (
    dvDelphi5,     dvDelphi6,    dvDelphi7,    dvDelphi8,
    dvDelphi2005,  dvDelphi2006, dvDelphi2007, dvDelphi2009,
    dvDelphi2010,  dvDelphiXE,   dvDelphiXE2,  dvDelphiXE3,
    dvDelphiXE4,   dvDelphiXE5,  dvDelphiXE6,  dvDelphiXE7,
    dvDelphiXE8,   dvDelphi10_0, dvDelphi10_1, dvDelphi10_2,
    dvDelphi10_3,  dvDelphi10_4, dvDelphi11,   dvDelphi12,
    dvDelphi13
  );

  /// <summary>Target platform for library path and package resolution.</summary>
  TDelphiPlatform = (dpWin32, dpWin64);

  /// <summary>
  /// Immutable metadata record for a single Delphi version.
  /// All properties are set at construction time.
  /// </summary>
  IDelphiVersionInfo = interface
    ['{B8E5F7A1-4D2C-4E9B-9A7E-1C5D6E8F9A0B}']
    /// <summary>Returns the BDS version number, e.g. 23.0 for Delphi 12 Athens.</summary>
    function GetBDSVersion: Double;
    /// <summary>Returns the BDS version as a locale-invariant string, e.g. "11.0".</summary>
    function GetBDSVersionString: string;
    /// <summary>Returns the compiler version string, e.g. "360".</summary>
    function GetCompilerVersion: string;
    /// <summary>Returns the registry path where this installation was detected.</summary>
    function GetDetectedInRegistry: string;
    /// <summary>Returns the package version suffix used in BPL names.</summary>
    function GetPackageVersion: string;
    /// <summary>Returns the full product name, e.g. "Delphi 10.3 Rio".</summary>
    function GetProductName: string;
    /// <summary>Returns the full product version string from the registry, e.g. "29.0.55362.2017".</summary>
    function GetProductVersion: string;
    /// <summary>Returns the registry path suffix below HKCU\Software.</summary>
    function GetRegistryPath: string;
    /// <summary>Returns the calendar year this version was released.</summary>
    function GetReleaseYear: Integer;
    /// <summary>Returns the root installation directory, resolved at detection time.</summary>
    function GetRootDirectory: string;
    /// <summary>Returns the short name, e.g. "XE2" or "10.3 Rio".</summary>
    function GetShortName: string;
    /// <summary>Returns True if this version supports 64-bit compilation.</summary>
    function GetSupports64Bit: Boolean;
    /// <summary>Returns the TDelphiVersion enum value for this version.</summary>
    function GetVersion: TDelphiVersion;
    /// <summary>Per-user Studio data folder, e.g. Documents\Embarcadero\Studio\23.0</summary>
    function GetUserStudioDir: string;
    /// <summary>Machine-wide Studio data folder, e.g. Public\Documents\Embarcadero\Studio\23.0</summary>
    function GetCommonStudioDir: string;
    /// <summary>Per-user CatalogRepository path.</summary>
    function GetCatalogRepositoryPath: string;
    /// <summary>Machine-wide CatalogRepository path.</summary>
    function GetCatalogRepositoryAllUsersPath: string;
   /// <summary>BDS version number, e.g. 23.0 for Delphi 12 Athens.</summary>
    property BDSVersion:          Double         read GetBDSVersion;
    /// <summary>BDS version as a locale-invariant string, e.g. "11.0".</summary>
    property BDSVersionString: string read GetBDSVersionString;
    property CatalogRepositoryPath: string read GetCatalogRepositoryPath;
    property CatalogRepositoryAllUsersPath: string read GetCatalogRepositoryAllUsersPath;
    property CommonStudioDir: string read GetCommonStudioDir;
    /// <summary>Compiler version string, e.g. "360".</summary>
    property CompilerVersion:     string         read GetCompilerVersion;
    /// <summary>Registry path where this installation was detected.</summary>
    property DetectedInRegistry:  string         read GetDetectedInRegistry;
    /// <summary>Package version suffix used in BPL names.</summary>
    property PackageVersion:      string         read GetPackageVersion;
    /// <summary>Full product name, e.g. "Delphi 10.3 Rio".</summary>
    property ProductName:         string         read GetProductName;
    /// <summary>Full product version string from the registry, e.g. "29.0.55362.2017".</summary>
    property ProductVersion: string read GetProductVersion;
    /// <summary>Registry path suffix below HKCU\Software.</summary>
    property RegistryPath:        string         read GetRegistryPath;
    /// <summary>Calendar year this version was released.</summary>
    property ReleaseYear:         Integer        read GetReleaseYear;
    /// <summary>Root installation directory, resolved at detection time.</summary>
    property RootDirectory:       string         read GetRootDirectory;
    /// <summary>Short name, e.g. "XE2" or "10.3 Rio".</summary>
    property ShortName:           string         read GetShortName;
    /// <summary>True if this version supports 64-bit compilation.</summary>
    property Supports64Bit:       Boolean        read GetSupports64Bit;
    property UserStudioDir: string read GetUserStudioDir;
    /// <summary>TDelphiVersion enum value for this version.</summary>
    property Version:             TDelphiVersion read GetVersion;
  end;

  /// <summary>Static catalog of all known Delphi version metadata records.</summary>
  IDelphiVersionRepository = interface
    ['{C9F6A8B2-5E3D-4F0C-8B8F-2D6E7F9A1C0D}']
    /// <summary>Returns the metadata record for the specified version.</summary>
    function GetVersionInfo(AVersion: TDelphiVersion): IDelphiVersionInfo;
    /// <summary>Returns the TDelphiVersion matching the specified product name.</summary>
    function GetVersionByProductName(const AProductName: string): TDelphiVersion;
    /// <summary>Returns a read-only list of all version enum values in the catalog.</summary>
    function GetAllVersions: IReadOnlyList<TDelphiVersion>;
  end;

  /// <summary>Detects installed Delphi versions by querying the Windows registry.</summary>
  IDelphiInstallationDetector = interface
    ['{D0A7B9C3-6F4E-5A1D-9C9A-3E7F8A0B2D1E}']
    /// <summary>Returns a read-only list of all Delphi versions detected on this machine.</summary>
    function GetInstalledVersions: IReadOnlyList<IDelphiVersionInfo>;
    /// <summary>Returns True if the specified version is detected in the registry.</summary>
    function IsVersionInstalled(AVersion: TDelphiVersion): Boolean;
    /// <summary>Returns the root installation path for the specified version, or empty string.</summary>
    function GetInstallationPath(AVersion: TDelphiVersion): string;
    /// <summary>Returns a diagnostic string describing all registry paths checked for a version.</summary>
    function GetDetectionDiagnostics(AVersion: TDelphiVersion): string;
  end;

  TDelphiVersionInfo = class(TInterfacedObject, IDelphiVersionInfo)
  private
    FBDSVersion:         Double;
    FBDSVersionString:   string;
    FCompilerVersion:    string;
    FDetectedInRegistry: string;
    FPackageVersion:     string;
    FProductName:        string;
    FProductVersion:     string;
    FRegistryPath:       string;
    FReleaseYear:        Integer;
    FRootDirectory:      string;
    FShortName:          string;
    FSupports64Bit:      Boolean;
    FVersion:            TDelphiVersion;
  public
    constructor Create(
            AVersion:         TDelphiVersion;
      const AShortName:       string;
      const AProductName:     string;
            ABDSVersion:      Double;
      const APackageVersion:  string;
      const ACompilerVersion: string;
      const ARegistryPath:    string;
            AReleaseYear:     Integer;
            ASupports64Bit:   Boolean);
    function GetBDSVersion:         Double;
    function GetBDSVersionString: string;
    function GetCompilerVersion:    string;
    function GetDetectedInRegistry: string;
    function GetPackageVersion:     string;
    function GetProductName:        string;
    function GetProductVersion: string;
    function GetRegistryPath:       string;
    function GetReleaseYear:        Integer;
    function GetRootDirectory:      string;
    function GetShortName:          string;
    function GetSupports64Bit:      Boolean;
    function GetVersion:            TDelphiVersion;
    function GetUserStudioDir: string;
    function GetCommonStudioDir: string;
    function GetCatalogRepositoryPath: string;
    function GetCatalogRepositoryAllUsersPath: string;
    procedure SetDetectedInRegistry(const AValue: string);
    procedure SetProductVersion(const AValue: string);
    procedure SetRootDirectory(const AValue: string);
  end;

  TDelphiVersionRepository = class(TInterfacedObject, IDelphiVersionRepository)
  private
    FVersionData:      IDictionary<TDelphiVersion, IDelphiVersionInfo>;
    FProductNameIndex: IDictionary<string, TDelphiVersion>;
    procedure InitializeVersionData;
    procedure AddVersion(
            AVersion:         TDelphiVersion;
      const AShortName:       string;
      const AProductName:     string;
            ABDSVersion:      Double;
      const APackageVersion:  string;
      const ACompilerVersion: string;
      const ARegistryPath:    string;
            AReleaseYear:     Integer;
            ASupports64Bit:   Boolean = False);
  public
    constructor Create;

    function GetVersionInfo(AVersion: TDelphiVersion): IDelphiVersionInfo;
    function GetVersionByProductName(const AProductName: string): TDelphiVersion;
    function GetAllVersions: IReadOnlyList<TDelphiVersion>;
  end;

  TRegistryDelphiDetector = class(TInterfacedObject, IDelphiInstallationDetector)
  private
    FRepository:     IDelphiVersionRepository;
    FRegistryRoots:  IList<string>;
    function CheckRegistryPath(
      const ABasePath, AVersionPath: string;
      out   AInstallPath: string;
            ARootKey: HKEY = HKEY_CURRENT_USER): Boolean;
    function GetFileProductVersion(const AFileName: string): string;
  public
    constructor Create(ARepository: IDelphiVersionRepository);

    function GetInstalledVersions:  IReadOnlyList<IDelphiVersionInfo>;
    function IsVersionInstalled(AVersion: TDelphiVersion): Boolean;
    function GetInstallationPath(AVersion: TDelphiVersion): string;
    function GetDetectionDiagnostics(AVersion: TDelphiVersion): string;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Win.Registry,
  u_Logger;

{ TDelphiVersionInfo }

constructor TDelphiVersionInfo.Create(
        AVersion:         TDelphiVersion;
  const AShortName:       string;
  const AProductName:     string;
        ABDSVersion:      Double;
  const APackageVersion:  string;
  const ACompilerVersion: string;
  const ARegistryPath:    string;
        AReleaseYear:     Integer;
        ASupports64Bit:   Boolean);
begin
  inherited Create;
  FVersion            := AVersion;
  FShortName          := AShortName;
  FProductName        := AProductName;
  FBDSVersion         := ABDSVersion;
  if ABDSVersion < 0 then
    FBDSVersionString := ''
  else
    FBDSVersionString := FormatFloat('0.0', ABDSVersion,
      TFormatSettings.Invariant);
  FPackageVersion     := APackageVersion;
  FCompilerVersion    := ACompilerVersion;
  FRegistryPath       := ARegistryPath;
  FReleaseYear        := AReleaseYear;
  FSupports64Bit      := ASupports64Bit;
  FRootDirectory      := '';
  FDetectedInRegistry := '';
  FProductVersion     := '';
end;

function TDelphiVersionInfo.GetBDSVersion: Double;
begin
  Result := FBDSVersion;
end;

function TDelphiVersionInfo.GetBDSVersionString: string;
begin
  Result := FBDSVersionString;
end;

function TDelphiVersionInfo.GetCatalogRepositoryAllUsersPath: string;
begin
  Result := TPath.Combine(GetCommonStudioDir, 'CatalogRepository');
end;

function TDelphiVersionInfo.GetCatalogRepositoryPath: string;
begin
  Result := TPath.Combine(GetUserStudioDir, 'CatalogRepository');
end;

function TDelphiVersionInfo.GetCommonStudioDir: string;
begin
  Result := GetEnvironmentVariable('PUBLIC') +
    '\Documents\Embarcadero\Studio\' + FBDSVersionString;
end;

function TDelphiVersionInfo.GetCompilerVersion: string;
begin
  Result := FCompilerVersion;
end;

function TDelphiVersionInfo.GetDetectedInRegistry: string;
begin
  Result := FDetectedInRegistry;
end;

function TDelphiVersionInfo.GetPackageVersion: string;
begin
  Result := FPackageVersion;
end;

function TDelphiVersionInfo.GetProductName: string;
begin
  Result := FProductName;
end;

function TDelphiVersionInfo.GetProductVersion: string;
begin
  Result := FProductVersion;
end;

function TDelphiVersionInfo.GetRegistryPath: string;
begin
  Result := FRegistryPath;
end;

function TDelphiVersionInfo.GetReleaseYear: Integer;
begin
  Result := FReleaseYear;
end;

function TDelphiVersionInfo.GetRootDirectory: string;
begin
  Result := FRootDirectory;
end;

function TDelphiVersionInfo.GetShortName: string;
begin
  Result := FShortName;
end;

function TDelphiVersionInfo.GetSupports64Bit: Boolean;
begin
  Result := FSupports64Bit;
end;

function TDelphiVersionInfo.GetUserStudioDir: string;
begin
  Result := TPath.Combine(
    TPath.GetDocumentsPath,
    TPath.Combine('Embarcadero\Studio', FBDSVersionString));
end;

function TDelphiVersionInfo.GetVersion: TDelphiVersion;
begin
  Result := FVersion;
end;

procedure TDelphiVersionInfo.SetDetectedInRegistry(const AValue: string);
begin
  FDetectedInRegistry := AValue;
end;

procedure TDelphiVersionInfo.SetProductVersion(const AValue: string);
begin
  FProductVersion := AValue;
end;

procedure TDelphiVersionInfo.SetRootDirectory(const AValue: string);
begin
  FRootDirectory := AValue;
end;

{ TDelphiVersionRepository }

constructor TDelphiVersionRepository.Create;
begin
  inherited Create;
  FVersionData      := TCollections.CreateDictionary<TDelphiVersion, IDelphiVersionInfo>;
  FProductNameIndex := TCollections.CreateDictionary<string, TDelphiVersion>;
  InitializeVersionData;
end;

procedure TDelphiVersionRepository.AddVersion(
        AVersion:         TDelphiVersion;
  const AShortName:       string;
  const AProductName:     string;
        ABDSVersion:      Double;
  const APackageVersion:  string;
  const ACompilerVersion: string;
  const ARegistryPath:    string;
        AReleaseYear:     Integer;
        ASupports64Bit:   Boolean);
var
  Info: IDelphiVersionInfo;
begin
  // NOTE that the ACompilerVersion parameter contains the integer portion of the VERxxx
  // symbol. In use, it is appended as a string to 'VER' and provides the appropriate symbol.
  Info := TDelphiVersionInfo.Create(
    AVersion, AShortName, AProductName,
    ABDSVersion, APackageVersion, ACompilerVersion,
    ARegistryPath, AReleaseYear, ASupports64Bit);
  FVersionData[AVersion]        := Info;
  FProductNameIndex[AProductName] := AVersion;
end;

procedure TDelphiVersionRepository.InitializeVersionData;
begin
  // Delphi 5-7 — no BDS, no CompilerVersion constant
  AddVersion(dvDelphi5, '5',    'Delphi 5',    -1,   '50',  '130', '\Borland\Delphi\5.0',    1999, False);
  AddVersion(dvDelphi6, '6',    'Delphi 6',    -1,   '60',  '140', '\Borland\Delphi\6.0',    2001, False);
  AddVersion(dvDelphi7, '7',    'Delphi 7',    -1,   '70',  '150', '\Borland\Delphi\7.0',    2002, False);

  // BDS era — Borland
  AddVersion(dvDelphi8,    '8',    'Delphi 8',    2.0,  '80',  '160', '\Borland\BDS\2.0',       2003, False);
  AddVersion(dvDelphi2005, '2005', 'Delphi 2005', 3.0,  '90',  '170', '\Borland\BDS\3.0',       2004, False);
  AddVersion(dvDelphi2006, '2006', 'Delphi 2006', 4.0,  '100', '180', '\Borland\BDS\4.0',       2005, False);

  // Delphi 2007 — CodeGear, defines VER180 and VER185
  AddVersion(dvDelphi2007, '2007', 'Delphi 2007', 5.0,  '110', '185', '\Borland\BDS\5.0',       2007, False);

  // CodeGear era
  AddVersion(dvDelphi2009, '2009', 'Delphi 2009', 6.0,  '120', '200', '\CodeGear\BDS\6.0',      2008, False);
  AddVersion(dvDelphi2010, '2010', 'Delphi 2010', 7.0,  '140', '210', '\CodeGear\BDS\7.0',      2009, False);

  // Embarcadero XE series
  AddVersion(dvDelphiXE,  'XE',  'Delphi XE',  8.0,  '150', '220', '\Embarcadero\BDS\8.0',   2010, True);
  AddVersion(dvDelphiXE2, 'XE2', 'Delphi XE2', 9.0,  '160', '230', '\Embarcadero\BDS\9.0',   2011, True);
  AddVersion(dvDelphiXE3, 'XE3', 'Delphi XE3', 10.0, '170', '240', '\Embarcadero\BDS\10.0',  2012, True);
  AddVersion(dvDelphiXE4, 'XE4', 'Delphi XE4', 11.0, '180', '250', '\Embarcadero\BDS\11.0',  2013, True);
  AddVersion(dvDelphiXE5, 'XE5', 'Delphi XE5', 12.0, '190', '260', '\Embarcadero\BDS\12.0',  2013, True);
  AddVersion(dvDelphiXE6, 'XE6', 'Delphi XE6', 14.0, '200', '270', '\Embarcadero\BDS\14.0',  2014, True);
  AddVersion(dvDelphiXE7, 'XE7', 'Delphi XE7', 15.0, '210', '280', '\Embarcadero\BDS\15.0',  2014, True);
  AddVersion(dvDelphiXE8, 'XE8', 'Delphi XE8', 16.0, '220', '290', '\Embarcadero\BDS\16.0',  2015, True);

  // Delphi 10.x series
  AddVersion(dvDelphi10_0, '10 Seattle',  'Delphi 10 Seattle',  17.0, '230', '300', '\Embarcadero\BDS\17.0', 2015, True);
  AddVersion(dvDelphi10_1, '10.1 Berlin', 'Delphi 10.1 Berlin', 18.0, '240', '310', '\Embarcadero\BDS\18.0', 2016, True);
  AddVersion(dvDelphi10_2, '10.2 Tokyo',  'Delphi 10.2 Tokyo',  19.0, '250', '320', '\Embarcadero\BDS\19.0', 2017, True);
  AddVersion(dvDelphi10_3, '10.3 Rio',    'Delphi 10.3 Rio',    20.0, '260', '330', '\Embarcadero\BDS\20.0', 2018, True);
  AddVersion(dvDelphi10_4, '10.4 Sydney', 'Delphi 10.4 Sydney', 21.0, '270', '340', '\Embarcadero\BDS\21.0', 2020, True);

  // Delphi 11+
  AddVersion(dvDelphi11, '11 Alexandria', 'Delphi 11 Alexandria', 22.0, '280', '350', '\Embarcadero\BDS\22.0', 2021, True);
  AddVersion(dvDelphi12, '12 Athens',     'Delphi 12 Athens',     23.0, '290', '360', '\Embarcadero\BDS\23.0', 2023, True);
  AddVersion(dvDelphi13, '13 Florence',   'Delphi 13 Florence',   37.0, '370', '370', '\Embarcadero\BDS\37.0', 2025, True);
end;

function TDelphiVersionRepository.GetVersionInfo(
  AVersion: TDelphiVersion): IDelphiVersionInfo;
begin
  if not FVersionData.TryGetValue(AVersion, Result) then
    raise EArgumentException.CreateFmt(
      'Version %d not found in repository', [Ord(AVersion)]);
end;

function TDelphiVersionRepository.GetVersionByProductName(
  const AProductName: string): TDelphiVersion;
begin
  if not FProductNameIndex.TryGetValue(AProductName, Result) then
    raise EArgumentException.CreateFmt(
      'Product name "%s" not found', [AProductName]);
end;

function TDelphiVersionRepository.GetAllVersions: IReadOnlyList<TDelphiVersion>;
begin
  Result := TCollections.CreateList<TDelphiVersion>(FVersionData.Keys)
    as IReadOnlyList<TDelphiVersion>;
end;

{ TRegistryDelphiDetector }

constructor TRegistryDelphiDetector.Create(
  ARepository: IDelphiVersionRepository);
begin
  inherited Create;
  FRepository    := ARepository;
  FRegistryRoots := TCollections.CreateList<string>;
  FRegistryRoots.Add('\Software');
  FRegistryRoots.Add('\Software\Wow6432Node');
end;

function TRegistryDelphiDetector.CheckRegistryPath(
  const ABasePath, AVersionPath: string;
  out   AInstallPath: string;
        ARootKey: HKEY): Boolean;
var
  Reg:     TRegistry;
  FullPath: string;
  AppPath: string;
  RootDir: string;
begin
  Result       := False;
  AInstallPath := '';

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ARootKey;
    FullPath    := ABasePath + AVersionPath;

    if not Reg.KeyExists(FullPath) then
      Exit;

    if not Reg.OpenKeyReadOnly(FullPath) then
      Exit;

    if Reg.ValueExists('App') then
    begin
      AppPath := Reg.ReadString('App');
      if FileExists(AppPath) then
      begin
        AInstallPath := ExtractFilePath(AppPath);
        AInstallPath := ExcludeTrailingPathDelimiter(AInstallPath);
        if SameText(ExtractFileName(AInstallPath), 'bin') then
          AInstallPath := ExtractFilePath(AInstallPath);
        AInstallPath := ExcludeTrailingPathDelimiter(AInstallPath);
        Result := True;
        Exit;
      end;
    end;

    if Reg.ValueExists('RootDir') then
    begin
      RootDir := Reg.ReadString('RootDir');
      if DirectoryExists(RootDir) then
      begin
        AInstallPath := ExcludeTrailingPathDelimiter(RootDir);
        Result       := True;
        Exit;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

function TRegistryDelphiDetector.GetFileProductVersion(const AFileName: string): string;
var
  Size:    DWORD;
  Handle:  DWORD;
  Buffer:  TBytes;
  PInfo:   PVSFixedFileInfo;
  InfoLen: UINT;
begin
  Result := '';

  if not FileExists(AFileName) then
    Exit;

  Size := GetFileVersionInfoSize(PChar(AFileName), Handle);
  if Size = 0 then
    Exit;

  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(AFileName), Handle, Size,
    Pointer(Buffer)) then
    Exit;

  if not VerQueryValue(Pointer(Buffer), '\', Pointer(PInfo), InfoLen) then
    Exit;

  Result := Format('%d.%d.%d.%d', [
    HiWord(PInfo.dwFileVersionMS),
    LoWord(PInfo.dwFileVersionMS),
    HiWord(PInfo.dwFileVersionLS),
    LoWord(PInfo.dwFileVersionLS)]);
end;

function TRegistryDelphiDetector.GetInstalledVersions: IReadOnlyList<IDelphiVersionInfo>;
var
  AllVersions:    IReadOnlyList<TDelphiVersion>;
  Ver:            TDelphiVersion;
  Info:           IDelphiVersionInfo;
  InstallPath:    string;
  RegistryUsed:   string;
  ModifiableInfo: TDelphiVersionInfo;
  Results:        IList<IDelphiVersionInfo>;
  Reg:            TRegistry;
  FullPath:       string;
  AppPath:        string;
begin
  Results     := TCollections.CreateList<IDelphiVersionInfo>;
  AllVersions := FRepository.GetAllVersions;

  for Ver in AllVersions do
  begin
    InstallPath := GetInstallationPath(Ver);
    if InstallPath <> '' then
    begin
      Info := FRepository.GetVersionInfo(Ver);

      ModifiableInfo := TDelphiVersionInfo.Create(
        Info.Version, Info.ShortName, Info.ProductName,
        Info.BDSVersion, Info.PackageVersion, Info.CompilerVersion,
        Info.RegistryPath, Info.ReleaseYear, Info.Supports64Bit);
      ModifiableInfo.SetRootDirectory(InstallPath);

      for RegistryUsed in FRegistryRoots do
      begin
        if CheckRegistryPath(RegistryUsed, Info.RegistryPath,
                             InstallPath) then
        begin
          ModifiableInfo.SetDetectedInRegistry(
            RegistryUsed + Info.RegistryPath);
          Break;
        end;
      end;

      // Read precise build version from bds.exe file version resource.
      // This distinguishes point releases e.g. Delphi 12.0 from 12.3.
      Reg := TRegistry.Create(KEY_READ);
      try
        Reg.RootKey := HKEY_CURRENT_USER;
        FullPath    := 'Software' + Info.RegistryPath;
        if Reg.OpenKeyReadOnly(FullPath) then
        begin
          AppPath := Reg.ReadString('App');
          if not AppPath.IsEmpty then
            ModifiableInfo.SetProductVersion(
              GetFileProductVersion(AppPath));
          Reg.CloseKey;
        end;
      finally
        Reg.Free;
      end;

      Results.Add(ModifiableInfo);
    end;
  end;

  Result := Results as IReadOnlyList<IDelphiVersionInfo>;
end;

function TRegistryDelphiDetector.IsVersionInstalled(
  AVersion: TDelphiVersion): Boolean;
begin
  Result := GetInstallationPath(AVersion) <> '';
end;

function TRegistryDelphiDetector.GetInstallationPath(
  AVersion: TDelphiVersion): string;
var
  Info:     IDelphiVersionInfo;
  Root:     string;
  RootKeys: array[0..1] of HKEY;
  RootKey:  HKEY;
begin
  Result   := '';
  Info     := FRepository.GetVersionInfo(AVersion);

  RootKeys[0] := HKEY_CURRENT_USER;
  RootKeys[1] := HKEY_LOCAL_MACHINE;

  for RootKey in RootKeys do
  begin
    for Root in FRegistryRoots do
    begin
      if CheckRegistryPath(Root, Info.RegistryPath, Result, RootKey) then
        Exit;
    end;
  end;
end;

function TRegistryDelphiDetector.GetDetectionDiagnostics(
  AVersion: TDelphiVersion): string;
var
  Info:         IDelphiVersionInfo;
  Root:         string;
  FullPath:     string;
  AppPath:      string;
  RootDir:      string;
  Reg:          TRegistry;
  SB:           TStringBuilder;
  RootKeys:     array[0..1] of HKEY;
  RootKeyNames: array[0..1] of string;
  RootKey:      HKEY;
  RKIdx:        Integer;
  ValueNames:   TStringList;
  I:            Integer;
  ValueStr:     string;
begin
  SB := TStringBuilder.Create;
  try
    Info := FRepository.GetVersionInfo(AVersion);
    SB.AppendLine('Checking: ' + Info.ProductName);
    SB.AppendLine('Registry Path: ' + Info.RegistryPath);
    SB.AppendLine('');

    RootKeys[0]     := HKEY_CURRENT_USER;
    RootKeys[1]     := HKEY_LOCAL_MACHINE;
    RootKeyNames[0] := 'HKCU';
    RootKeyNames[1] := 'HKLM';

    for RKIdx := 0 to 1 do
    begin
      RootKey := RootKeys[RKIdx];
      Reg     := TRegistry.Create(KEY_READ);
      try
        Reg.RootKey := RootKey;

        for Root in FRegistryRoots do
        begin
          FullPath := Root + Info.RegistryPath;
          SB.AppendLine('Testing: ' + RootKeyNames[RKIdx] + '\' + FullPath);

          if Reg.KeyExists(FullPath) then
          begin
            SB.AppendLine('  Key EXISTS');
            if Reg.OpenKeyReadOnly(FullPath) then
            begin
              SB.AppendLine('  Key OPENED');

              ValueNames := TStringList.Create;
              try
                Reg.GetValueNames(ValueNames);
                SB.AppendLine('  Value count: ' + IntToStr(ValueNames.Count));

                for I := 0 to ValueNames.Count - 1 do
                begin
                  ValueStr := '';
                  if Reg.ValueExists(ValueNames[I]) then
                  begin
                    if Reg.GetDataType(ValueNames[I]) = TRegDataType.rdString then
                      ValueStr := Reg.ReadString(ValueNames[I]);
                  end;

                  if ValueStr.Contains(':\') then
                    SB.AppendLine('  Value[' + IntToStr(I) + ']: '
                      + ValueNames[I] + ' = ' + ValueStr);
                end;

                if ValueNames.Count = 0 then
                  SB.AppendLine('  (No values in this key)');
              finally
                ValueNames.Free;
              end;

              AppPath := Reg.ReadString('App');
              RootDir := Reg.ReadString('RootDir');

              if AppPath <> '' then
                SB.AppendLine('  App exists: '
                  + BoolToStr(FileExists(AppPath), True));
              if RootDir <> '' then
                SB.AppendLine('  RootDir exists: '
                  + BoolToStr(DirectoryExists(RootDir), True));
            end
            else
              SB.AppendLine('  Key FAILED to open');
          end
          else
            SB.AppendLine('  Key DOES NOT EXIST');

          SB.AppendLine('');
        end;
      finally
        Reg.Free;
      end;
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.
