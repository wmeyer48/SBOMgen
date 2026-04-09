unit u_SPDXLicenses;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines ISPDXLicenseManager and its implementation. Loads the
  SPDX license list from a JSON file and provides lookup, validation,
  and search services over the resulting catalog. Used to populate
  license drop-downs and validate user-entered SPDX identifiers.
*)

interface

uses
  Spring.Collections;

type
  /// <summary>
  /// Immutable data-transfer object representing a single SPDX license entry.
  /// </summary>
  TSPDXLicense = class
  private
    FLicenseID:     string;
    FName:          string;
    FIsOsiApproved: Boolean;
    FIsDeprecated:  Boolean;
    FSeeAlso:       TArray<string>;
  public
    /// <summary>The SPDX license identifier, e.g. "Apache-2.0".</summary>
    property LicenseID:     string         read FLicenseID     write FLicenseID;
    /// <summary>The full license name.</summary>
    property Name:          string         read FName          write FName;
    /// <summary>True if the license is OSI-approved.</summary>
    property IsOsiApproved: Boolean        read FIsOsiApproved write FIsOsiApproved;
    /// <summary>True if the license identifier has been deprecated by SPDX.</summary>
    property IsDeprecated:  Boolean        read FIsDeprecated  write FIsDeprecated;
    /// <summary>Array of reference URLs for this license.</summary>
    property SeeAlso:       TArray<string> read FSeeAlso       write FSeeAlso;
  end;

  /// <summary>
  /// Provides SPDX license lookup, validation, and search services
  /// over a catalog loaded from the SPDX JSON license list file.
  /// </summary>
  ISPDXLicenseManager = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Loads the SPDX license catalog from the specified JSON file.</summary>
    procedure LoadFromFile(const AFilePath: string);
    /// <summary>Returns the license entry for the specified SPDX identifier, or nil.</summary>
    function GetLicenseByID(const ALicenseID: string): TSPDXLicense;
    /// <summary>Returns a read-only list of all loaded license entries.</summary>
    function GetAllLicenses: IReadOnlyList<TSPDXLicense>;
    /// <summary>
    /// Returns a sorted, read-only list of formatted license strings
    /// suitable for populating a drop-down. Deprecated licenses are excluded.
    /// Each entry is formatted as "LicenseID (Name)".
    /// </summary>
    function GetLicenseList: IReadOnlyList<string>;
    /// <summary>Returns True if the specified SPDX identifier exists in the catalog.</summary>
    function IsValidLicense(const ALicenseID: string): Boolean;
    /// <summary>
    /// Returns a read-only list of all license entries whose ID or name
    /// contains the supplied search term (case-insensitive).
    /// </summary>
    function SearchLicenses(const ASearchTerm: string): IReadOnlyList<TSPDXLicense>;
  end;

  TSPDXLicenseManager = class(TInterfacedObject, ISPDXLicenseManager)
  private
    FLicenses:      IList<TSPDXLicense>;
    FLicenseLookup: IDictionary<string, TSPDXLicense>;
    procedure ParseJSON(const AJSONText: string);
  public
    constructor Create;

    procedure LoadFromFile(const AFilePath: string);
    function  GetLicenseByID(const ALicenseID: string): TSPDXLicense;
    function  GetAllLicenses: IReadOnlyList<TSPDXLicense>;
    function  GetLicenseList: IReadOnlyList<string>;
    function  IsValidLicense(const ALicenseID: string): Boolean;
    function  SearchLicenses(const ASearchTerm: string): IReadOnlyList<TSPDXLicense>;
  end;

implementation

uses
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.IOUtils;

{ TSPDXLicenseManager }

constructor TSPDXLicenseManager.Create;
begin
  inherited Create;
  // FLicenses owns the TSPDXLicense instances.
  // FLicenseLookup is non-owning; lifetime is governed by FLicenses.
  // SPDX identifiers are case-sensitive per spec — no case-insensitive comparer.
  FLicenses      := TCollections.CreateObjectList<TSPDXLicense>(True);
  FLicenseLookup := TCollections.CreateDictionary<string, TSPDXLicense>;
end;

procedure TSPDXLicenseManager.LoadFromFile(const AFilePath: string);
var
  JSONText: string;
begin
  if not FileExists(AFilePath) then
    raise EFileNotFoundException.CreateFmt(
      'SPDX license file not found: %s', [AFilePath]);

  JSONText := TFile.ReadAllText(AFilePath, TEncoding.UTF8);
  ParseJSON(JSONText);
end;

procedure TSPDXLicenseManager.ParseJSON(const AJSONText: string);
var
  RootObj:       TJSONObject;
  LicensesArray: TJSONArray;
  SeeAlsoArray:  TJSONArray;
  LicenseObj:    TJSONObject;
  License:       TSPDXLicense;
  URLs:          IList<string>;
  I, J:          Integer;
begin
  FLicenses.Clear;
  FLicenseLookup.Clear;

  RootObj := TJSONObject.ParseJSONValue(AJSONText) as TJSONObject;
  if not Assigned(RootObj) then
    raise EArgumentException.Create('Invalid SPDX JSON format');

  try
    LicensesArray := RootObj.GetValue<TJSONArray>('licenses');
    if not Assigned(LicensesArray) then
      raise EArgumentException.Create('No licenses array in SPDX JSON');

    for I := 0 to LicensesArray.Count - 1 do
    begin
      LicenseObj := LicensesArray.Items[I] as TJSONObject;

      License             := TSPDXLicense.Create;
      License.LicenseID   := LicenseObj.GetValue<string>('licenseId', '');
      License.Name        := LicenseObj.GetValue<string>('name', '');
      License.IsOsiApproved := LicenseObj.GetValue<Boolean>('isOsiApproved', False);
      License.IsDeprecated  := LicenseObj.GetValue<Boolean>('isDeprecatedLicenseId', False);

      URLs := TCollections.CreateList<string>;
      if LicenseObj.TryGetValue<TJSONArray>('seeAlso', SeeAlsoArray) then
      begin
        for J := 0 to SeeAlsoArray.Count - 1 do
          URLs.Add(SeeAlsoArray.Items[J].Value);
      end;
      License.SeeAlso := URLs.ToArray;

      FLicenses.Add(License);

      if not License.LicenseID.IsEmpty then
        FLicenseLookup.Add(License.LicenseID, License);
    end;
  finally
    RootObj.Free;
  end;
end;

function TSPDXLicenseManager.GetLicenseByID(
  const ALicenseID: string): TSPDXLicense;
begin
  if not FLicenseLookup.TryGetValue(ALicenseID, Result) then
    Result := nil;
end;

function TSPDXLicenseManager.GetAllLicenses: IReadOnlyList<TSPDXLicense>;
begin
  Result := FLicenses as IReadOnlyList<TSPDXLicense>;
end;

function TSPDXLicenseManager.GetLicenseList: IReadOnlyList<string>;
var
  License: TSPDXLicense;
  List:    IList<string>;
begin
  List := TCollections.CreateList<string>;

  for License in FLicenses do
  begin
    if not License.IsDeprecated then
      List.Add(Format('%s (%s)', [License.LicenseID, License.Name]));
  end;

  List.Sort;
  Result := List as IReadOnlyList<string>;
end;

function TSPDXLicenseManager.IsValidLicense(const ALicenseID: string): Boolean;
begin
  Result := FLicenseLookup.ContainsKey(ALicenseID);
end;

function TSPDXLicenseManager.SearchLicenses(
  const ASearchTerm: string): IReadOnlyList<TSPDXLicense>;
var
  License:     TSPDXLicense;
  SearchLower: string;
  Results:     IList<TSPDXLicense>;
begin
  Results     := TCollections.CreateObjectList<TSPDXLicense>(False);
  SearchLower := ASearchTerm.ToLower;

  for License in FLicenses do
  begin
    if License.LicenseID.ToLower.Contains(SearchLower) or
       License.Name.ToLower.Contains(SearchLower) then
      Results.Add(License);
  end;

  Result := Results as IReadOnlyList<TSPDXLicense>;
end;

end.
