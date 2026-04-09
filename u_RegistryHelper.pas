unit u_RegistryHelper;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Provides registry access helpers for Delphi-specific data,
  including CatalogRepository package metadata and general-purpose
  key/value enumeration. Used by the component detection and
  environment harvesting subsystems.
*)

interface

uses
  Winapi.Windows,
  Spring.Collections;

type
  /// <summary>
  /// Carries package metadata read from the Delphi CatalogRepository
  /// registry keys for a single installed GetIt package.
  /// </summary>
  IPackageRegistryInfo = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the package name as registered in the CatalogRepository.</summary>
    function GetPackageName: string;
    /// <summary>Returns the package description.</summary>
    function GetDescription: string;
    /// <summary>Returns the SPDX license identifier or expression.</summary>
    function GetLicense: string;
    /// <summary>Returns the human-readable license name.</summary>
    function GetLicenseName: string;
    /// <summary>Returns the license acceptance state.</summary>
    function GetLicenseState: string;
    /// <summary>Returns the package project or home page URL.</summary>
    function GetProjectURL: string;
    /// <summary>Returns the vendor or author name.</summary>
    function GetVendor: string;
    /// <summary>Returns the installed package version string.</summary>
    function GetVersion: string;

    /// <summary>Package name as registered in the CatalogRepository.</summary>
    property PackageName:  string read GetPackageName;
    /// <summary>Package description.</summary>
    property Description:  string read GetDescription;
    /// <summary>SPDX license identifier or expression.</summary>
    property License:      string read GetLicense;
    /// <summary>Human-readable license name.</summary>
    property LicenseName:  string read GetLicenseName;
    /// <summary>License acceptance state.</summary>
    property LicenseState: string read GetLicenseState;
    /// <summary>Package project or home page URL.</summary>
    property ProjectURL:   string read GetProjectURL;
    /// <summary>Vendor or author name.</summary>
    property Vendor:       string read GetVendor;
    /// <summary>Installed package version string.</summary>
    property Version:      string read GetVersion;
  end;

  /// <summary>
  /// Provides registry access helpers for Delphi-specific operations,
  /// including CatalogRepository package enumeration and general-purpose
  /// key and value reading.
  /// </summary>
  IDelphiRegistryHelper = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    /// <summary>
    /// Returns a dictionary of package names to metadata for all GetIt
    /// packages registered under the specified BDS version key.
    /// </summary>
    function GetCatalogPackages(const ABDSVersion: string):
      IDictionary<string, IPackageRegistryInfo>;
    /// <summary>Returns the string value at the specified registry key and value name.</summary>
    function GetRegistryValue(ARootKey: HKEY;
      const AKeyPath, AValueName: string): string;
    /// <summary>Returns a read-only list of all subkey names under the specified registry key.</summary>
    function GetRegistryKeys(ARootKey: HKEY;
      const AKeyPath: string): IReadOnlyList<string>;
    /// <summary>
    /// Returns a dictionary of all string value names and their data
    /// found under the specified registry key.
    /// </summary>
    function GetRegistryValues(ARootKey: HKEY;
      const AKeyPath: string): IDictionary<string, string>;
  end;

  TPackageRegistryInfo = class(TInterfacedObject, IPackageRegistryInfo)
  private
    FPackageName:  string;
    FDescription:  string;
    FLicense:      string;
    FLicenseName:  string;
    FLicenseState: string;
    FProjectURL:   string;
    FVendor:       string;
    FVersion:      string;
  public
    constructor Create(const APackageName: string;
      AValues: IDictionary<string, string>);

    function GetPackageName:  string;
    function GetDescription:  string;
    function GetLicense:      string;
    function GetLicenseName:  string;
    function GetLicenseState: string;
    function GetProjectURL:   string;
    function GetVendor:       string;
    function GetVersion:      string;
  end;

  TDelphiRegistryHelper = class(TInterfacedObject, IDelphiRegistryHelper)
  private
    function ReadPackageInfo(const ABasePath,
      APackageName: string): IPackageRegistryInfo;
  public
    function GetCatalogPackages(const ABDSVersion: string):
      IDictionary<string, IPackageRegistryInfo>;
    function GetRegistryValue(ARootKey: HKEY;
      const AKeyPath, AValueName: string): string;
    function GetRegistryKeys(ARootKey: HKEY;
      const AKeyPath: string): IReadOnlyList<string>;
    function GetRegistryValues(ARootKey: HKEY;
      const AKeyPath: string): IDictionary<string, string>;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.Win.Registry;

const
  CATALOG_PACKAGES_PATH =
    'SOFTWARE\Embarcadero\BDS\%s\CatalogRepository\Packages';

{ TPackageRegistryInfo }

constructor TPackageRegistryInfo.Create(const APackageName: string;
  AValues: IDictionary<string, string>);
begin
  inherited Create;
  FPackageName := APackageName;

  AValues.TryGetValue('Description',  FDescription);
  AValues.TryGetValue('License',      FLicense);
  AValues.TryGetValue('LicenseName',  FLicenseName);
  AValues.TryGetValue('LicenseState', FLicenseState);
  AValues.TryGetValue('ProjectURL',   FProjectURL);
  AValues.TryGetValue('Vendor',       FVendor);
  AValues.TryGetValue('Version',      FVersion);
end;

function TPackageRegistryInfo.GetPackageName: string;
begin
  Result := FPackageName;
end;

function TPackageRegistryInfo.GetDescription: string;
begin
  Result := FDescription;
end;

function TPackageRegistryInfo.GetLicense: string;
begin
  Result := FLicense;
end;

function TPackageRegistryInfo.GetLicenseName: string;
begin
  Result := FLicenseName;
end;

function TPackageRegistryInfo.GetLicenseState: string;
begin
  Result := FLicenseState;
end;

function TPackageRegistryInfo.GetProjectURL: string;
begin
  Result := FProjectURL;
end;

function TPackageRegistryInfo.GetVendor: string;
begin
  Result := FVendor;
end;

function TPackageRegistryInfo.GetVersion: string;
begin
  Result := FVersion;
end;

{ TDelphiRegistryHelper }

function TDelphiRegistryHelper.GetRegistryValue(ARootKey: HKEY;
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

function TDelphiRegistryHelper.GetRegistryKeys(ARootKey: HKEY;
  const AKeyPath: string): IReadOnlyList<string>;
var
  Reg:     TRegistry;
  Keys:    TStringList;
  I:       Integer;
  Results: IList<string>;
begin
  Results := TCollections.CreateList<string>;
  Reg     := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ARootKey;
    if Reg.OpenKeyReadOnly(AKeyPath) then
    begin
      Keys := TStringList.Create;
      try
        Reg.GetKeyNames(Keys);
        for I := 0 to Keys.Count - 1 do
          Results.Add(Keys[I]);
      finally
        Keys.Free;
      end;
    end;
  finally
    Reg.Free;
  end;

  Result := Results as IReadOnlyList<string>;
end;

function TDelphiRegistryHelper.GetRegistryValues(ARootKey: HKEY;
  const AKeyPath: string): IDictionary<string, string>;
var
  Reg:        TRegistry;
  ValueNames: TStringList;
  I:          Integer;
begin
  Result := TCollections.CreateDictionary<string, string>;
  Reg    := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ARootKey;
    if Reg.OpenKeyReadOnly(AKeyPath) then
    begin
      ValueNames := TStringList.Create;
      try
        Reg.GetValueNames(ValueNames);
        for I := 0 to ValueNames.Count - 1 do
        begin
          if Reg.GetDataType(ValueNames[I]) = rdString then
            Result.Add(ValueNames[I], Reg.ReadString(ValueNames[I]));
        end;
      finally
        ValueNames.Free;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

function TDelphiRegistryHelper.ReadPackageInfo(const ABasePath,
  APackageName: string): IPackageRegistryInfo;
var
  PackagePath: string;
  Values:      IDictionary<string, string>;
begin
  PackagePath := ABasePath + '\' + APackageName;
  Values      := GetRegistryValues(HKEY_CURRENT_USER, PackagePath);
  Result      := TPackageRegistryInfo.Create(APackageName, Values);
end;

function TDelphiRegistryHelper.GetCatalogPackages(
  const ABDSVersion: string): IDictionary<string, IPackageRegistryInfo>;
var
  BasePath:     string;
  PackageNames: IReadOnlyList<string>;
  PackageName:  string;
begin
  Result   := TCollections.CreateDictionary<string, IPackageRegistryInfo>;
  BasePath := Format(CATALOG_PACKAGES_PATH, [ABDSVersion]);

  PackageNames := GetRegistryKeys(HKEY_CURRENT_USER, BasePath);

  for PackageName in PackageNames do
    Result.Add(PackageName, ReadPackageInfo(BasePath, PackageName));
end;

end.
