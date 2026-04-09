unit u_UserProfile;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines IUserProfile and IUserProfileService, covering user
  registration data (name, company, address, phone) and its
  JSON persistence to the Windows AppData\Roaming folder.
*)

interface

type
  /// <summary>
  /// Carries user registration information used to populate SBOM
  /// author and supplier fields.
  /// </summary>
  IUserProfile = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the city.</summary>
    function GetCity: string;
    /// <summary>Returns the path to the CycloneDX CLI executable.</summary>
    function GetCLIToolPath: string;
    /// <summary>Returns the user's company or organisation name.</summary>
    function GetCompany: string;
    /// <summary>Returns the phone number.</summary>
    function GetPhone: string;
    /// <summary>Returns the postal or ZIP code.</summary>
    function GetPostal: string;
    /// <summary>Returns the state or province.</summary>
    function GetStateProv: string;
    /// <summary>Returns the street address line.</summary>
    function GetStreet: string;
    /// <summary>Returns the user's full name.</summary>
    function GetUserName: string;

    /// <summary>Sets the city.</summary>
    procedure SetCity(const AValue: string);
    /// <summary>Sets the path to the CycloneDX CLI executable.</summary>
    procedure SetCLIToolPath(const AValue: string);
    /// <summary>Sets the company or organisation name.</summary>
    procedure SetCompany(const AValue: string);
    /// <summary>Sets the phone number.</summary>
    procedure SetPhone(const AValue: string);
    /// <summary>Sets the postal or ZIP code.</summary>
    procedure SetPostal(const AValue: string);
    /// <summary>Sets the state or province.</summary>
    procedure SetStateProv(const AValue: string);
    /// <summary>Sets the street address line.</summary>
    procedure SetStreet(const AValue: string);
    /// <summary>Sets the user's full name.</summary>
    procedure SetUserName(const AValue: string);

    /// <summary>City.</summary>
    property City:      string read GetCity      write SetCity;
    /// <summary>Path to the CycloneDX CLI executable for SBOM validation.</summary>
    property CLIToolPath: string read GetCLIToolPath write SetCLIToolPath;
    /// <summary>Company or organisation name.</summary>
    property Company:   string read GetCompany   write SetCompany;
    /// <summary>Phone number.</summary>
    property Phone:     string read GetPhone     write SetPhone;
    /// <summary>Postal or ZIP code.</summary>
    property Postal:    string read GetPostal    write SetPostal;
    /// <summary>State or province.</summary>
    property StateProv: string read GetStateProv write SetStateProv;
    /// <summary>Street address line.</summary>
    property Street:    string read GetStreet    write SetStreet;
    /// <summary>User's full name.</summary>
    property UserName:  string read GetUserName  write SetUserName;
  end;

  /// <summary>
  /// Manages loading and saving of the user profile as a JSON file
  /// in the Windows AppData\Roaming folder.
  /// </summary>
  IUserProfileService = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    /// <summary>
    /// Loads and returns the user profile from disk. Returns an empty
    /// profile if no file exists or the file cannot be read.
    /// </summary>
    function LoadProfile: IUserProfile;
    /// <summary>Saves the supplied profile to disk as JSON.</summary>
    procedure SaveProfile(AProfile: IUserProfile);
    /// <summary>Returns the fully qualified path to the profile JSON file.</summary>
    function GetProfilePath: string;
  end;

  TUserProfile = class(TInterfacedObject, IUserProfile)
  private
    FCity:        string;
    FCLIToolPath: string;
    FCompany:     string;
    FPhone:       string;
    FPostal:      string;
    FStateProv:   string;
    FStreet:      string;
    FUserName:    string;
  public
    function GetCity:        string;
    function GetCLIToolPath: string;
    function GetCompany:     string;
    function GetPhone:       string;
    function GetPostal:      string;
    function GetStateProv:   string;
    function GetStreet:      string;
    function GetUserName:    string;

    procedure SetCity(const AValue:      string);
    procedure SetCLIToolPath(const AValue: string);
    procedure SetCompany(const AValue:   string);
    procedure SetPhone(const AValue:     string);
    procedure SetPostal(const AValue:    string);
    procedure SetStateProv(const AValue: string);
    procedure SetStreet(const AValue:    string);
    procedure SetUserName(const AValue:  string);
  end;

  TUserProfileService = class(TInterfacedObject, IUserProfileService)
  private
    FProfilePath: string;
    function GetAppDataPath: string;
  public
    constructor Create;

    function  LoadProfile: IUserProfile;
    procedure SaveProfile(AProfile: IUserProfile);
    function  GetProfilePath: string;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  Winapi.ShlObj,
  Winapi.Windows;

function TUserProfile.GetCity: string;
begin
  Result := FCity;
end;

function TUserProfile.GetCLIToolPath: string;
begin
  Result := FCLIToolPath;
end;

function TUserProfile.GetCompany: string;
begin
  Result := FCompany;
end;

function TUserProfile.GetPhone: string;
begin
  Result := FPhone;
end;

function TUserProfile.GetPostal: string;
begin
  Result := FPostal;
end;

function TUserProfile.GetStateProv: string;
begin
  Result := FStateProv;
end;

function TUserProfile.GetStreet: string;
begin
  Result := FStreet;
end;

{ TUserProfile }

function TUserProfile.GetUserName: string;
begin
  Result := FUserName;
end;

procedure TUserProfile.SetCity(const AValue: string);
begin
  FCity := AValue;
end;

procedure TUserProfile.SetCLIToolPath(const AValue: string);
begin
  FCLIToolPath := AValue;
end;

procedure TUserProfile.SetCompany(const AValue: string);
begin
  FCompany := AValue;
end;

procedure TUserProfile.SetPhone(const AValue: string);
begin
  FPhone := AValue;
end;

procedure TUserProfile.SetPostal(const AValue: string);
begin
  FPostal := AValue;
end;

procedure TUserProfile.SetStateProv(const AValue: string);
begin
  FStateProv := AValue;
end;

procedure TUserProfile.SetStreet(const AValue: string);
begin
  FStreet := AValue;
end;

procedure TUserProfile.SetUserName(const AValue: string);
begin
  FUserName := AValue;
end;

{ TUserProfileService }

constructor TUserProfileService.Create;
begin
  inherited Create;
  FProfilePath := TPath.Combine(GetAppDataPath, 'user-profile.json');
end;

function TUserProfileService.GetAppDataPath: string;
var
  AppDataPath: array[0..MAX_PATH] of Char;
begin
  // SHGetFolderPath with CSIDL_APPDATA is deprecated since Windows Vista
  // but remains functional on all supported Windows versions. The preferred
  // modern API is SHGetKnownFolderPath(FOLDERID_RoamingAppData).
  if SHGetFolderPath(0, CSIDL_APPDATA, 0, 0, @AppDataPath) = S_OK then
  begin
    Result := AppDataPath;
    Result := TPath.Combine(Result, 'SBOMGenerator');

    if not TDirectory.Exists(Result) then
      TDirectory.CreateDirectory(Result);
  end
  else
  begin
    Result := TPath.Combine(TPath.GetDocumentsPath, 'SBOMGenerator');
  end;
end;

function TUserProfileService.GetProfilePath: string;
begin
  Result := FProfilePath;
end;

function TUserProfileService.LoadProfile: IUserProfile;
var
  Profile:  TUserProfile;
  JSONText: string;
  JSONObj:  TJSONObject;
begin
  Profile := TUserProfile.Create;

  if FileExists(FProfilePath) then
  begin
    try
      JSONText := TFile.ReadAllText(FProfilePath, TEncoding.UTF8);
      JSONObj  := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;

      if Assigned(JSONObj) then
      begin
        try
          Profile.SetUserName(JSONObj.GetValue<string>('userName',  ''));
          Profile.SetCompany(JSONObj.GetValue<string>('company',    ''));
          Profile.SetStreet(JSONObj.GetValue<string>('street',      ''));
          Profile.SetCity(JSONObj.GetValue<string>('city',          ''));
          Profile.SetStateProv(JSONObj.GetValue<string>('stateProv',''));
          Profile.SetPostal(JSONObj.GetValue<string>('postal',      ''));
          Profile.SetPhone(JSONObj.GetValue<string>('phone',        ''));
          Profile.SetCLIToolPath(JSONObj.GetValue<string>('cliToolPath', ''));
        finally
          JSONObj.Free;
        end;
      end;
    except
      on E: Exception do
      begin
        // File exists but could not be parsed — return the empty profile.
      end;
    end;
  end;

  Result := Profile;
end;

procedure TUserProfileService.SaveProfile(AProfile: IUserProfile);
var
  JSONObj:  TJSONObject;
  JSONText: string;
begin
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('userName',  AProfile.UserName);
    JSONObj.AddPair('company',   AProfile.Company);
    JSONObj.AddPair('street',    AProfile.Street);
    JSONObj.AddPair('city',      AProfile.City);
    JSONObj.AddPair('stateProv', AProfile.StateProv);
    JSONObj.AddPair('postal',    AProfile.Postal);
    JSONObj.AddPair('phone',     AProfile.Phone);
    JSONObj.AddPair('cliToolPath', AProfile.CLIToolPath);

    JSONText := JSONObj.Format(2);
    TFile.WriteAllText(FProfilePath, JSONText, TEncoding.UTF8);
  finally
    JSONObj.Free;
  end;
end;

end.
