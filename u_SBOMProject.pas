unit u_SBOMProject;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines ISBOMProject and ISBOMProjectService, covering project
  settings persistence, recent project tracking via the registry,
  and SBOM output folder management.
*)

interface

uses
  Spring,
  Spring.Collections;

type
  /// <summary>
  /// Holds all settings for a single SBOMgen project, including source
  /// paths, MAP file location, and generation timestamps.
  /// </summary>
  ISBOMProject = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF0123456789}']
    /// <summary>Returns the Delphi compiler version string for this project.</summary>
    function GetCompilerVersion: string;
    /// <summary>Returns the date and time this project was first created.</summary>
    function GetCreated: Nullable<TDateTime>;
    /// <summary>Returns the fully qualified path to the project DPR file.</summary>
    function GetDPRFile: string;
    /// <summary>Returns the semicolon-delimited list of excluded path prefixes.</summary>
    function GetExcludedPaths: string;
    /// <summary>Returns the date and time the SBOM was last generated for this project.</summary>
    function GetLastGenerated: Nullable<TDateTime>;
    /// <summary>Returns the date and time the project settings were last changed.</summary>
    function GetLastModified: Nullable<TDateTime>;
    /// <summary>Returns the fully qualified path to the MAP file for this project.</summary>
    function GetMapFile: string;
    /// <summary>Returns the root folder for this project's persisted data.</summary>
    function GetProjectFolder: string;
    /// <summary>Returns the display name of this project.</summary>
    function GetProjectName: string;
    /// <summary>Returns the semicolon-delimited list of source root folders.</summary>
    function GetRootFolders: string;

    /// <summary>Sets the Delphi compiler version string.</summary>
    procedure SetCompilerVersion(const AValue: string);
    /// <summary>Sets the fully qualified path to the project DPR file.</summary>
    procedure SetDPRFile(const AValue: string);
    /// <summary>Sets the semicolon-delimited list of excluded path prefixes.</summary>
    procedure SetExcludedPaths(const AValue: string);
    /// <summary>Sets the date and time the SBOM was last generated.</summary>
    procedure SetLastGenerated(const AValue: Nullable<TDateTime>);
    /// <summary>Sets the date and time the project settings were last changed.</summary>
    procedure SetLastModified(const AValue: Nullable<TDateTime>);
    /// <summary>Sets the fully qualified path to the MAP file.</summary>
    procedure SetMapFile(const AValue: string);
    /// <summary>Sets the root folder for this project's persisted data.</summary>
    procedure SetProjectFolder(const AValue: string);
    /// <summary>Sets the display name of this project.</summary>
    procedure SetProjectName(const AValue: string);
    /// <summary>Sets the semicolon-delimited list of source root folders.</summary>
    procedure SetRootFolders(const AValue: string);

    /// <summary>Delphi compiler version string for this project.</summary>
    property CompilerVersion: string    read GetCompilerVersion write SetCompilerVersion;
    /// <summary>
    /// Date and time this project was first created.
    /// HasValue is False if the project has never been saved.
    /// </summary>
    property Created:         Nullable<TDateTime> read GetCreated;
    /// <summary>Fully qualified path to the project DPR file.</summary>
    property DPRFile:         string    read GetDPRFile         write SetDPRFile;
    /// <summary>Semicolon-delimited list of excluded path prefixes.</summary>
    property ExcludedPaths:   string    read GetExcludedPaths   write SetExcludedPaths;
    /// <summary>
    /// Date and time the SBOM was last generated for this project.
    /// HasValue is False if no SBOM has yet been generated.
    /// </summary>
    property LastGenerated: Nullable<TDateTime>  read GetLastGenerated write SetLastGenerated;
    /// <summary>
    /// Date and time the project settings were last changed.
    /// HasValue is False if the project has never been saved.
    /// </summary>
    property LastModified:    Nullable<TDateTime> read GetLastModified write SetLastModified;
    /// <summary>Fully qualified path to the MAP file for this project.</summary>
    property MapFile:         string    read GetMapFile         write SetMapFile;
    /// <summary>Root folder for this project's persisted data.</summary>
    property ProjectFolder:   string    read GetProjectFolder   write SetProjectFolder;
    /// <summary>Display name of this project.</summary>
    property ProjectName:     string    read GetProjectName     write SetProjectName;
    /// <summary>Semicolon-delimited list of source root folders.</summary>
    property RootFolders:     string    read GetRootFolders     write SetRootFolders;
  end;

  /// <summary>
  /// Manages SBOMgen project persistence, recent project tracking,
  /// and SBOM output folder resolution.
  /// </summary>
  ISBOMProjectService = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F01234567890}']
    /// <summary>Creates and returns a new project with the given display name.</summary>
    function  CreateNew(const AProjectName: string): ISBOMProject;
    /// <summary>Loads and returns a project from the specified JSON project file.</summary>
    function  LoadFromFile(const AFileName: string): ISBOMProject;
    /// <summary>Serialises the project to the specified JSON project file.</summary>
    procedure SaveToFile(AProject: ISBOMProject; const AFileName: string);
    /// <summary>Returns the read-only list of recently accessed project names.</summary>
    function  GetRecentProjects: IReadOnlyList<string>;
    /// <summary>Returns the fully qualified path to the SBOM output folder for the project.</summary>
    function  GetSBOMFolder(AProject: ISBOMProject): string;
    /// <summary>Generates and returns a timestamped SBOM output file name for the project.</summary>
    function  GenerateSBOMFileName(AProject: ISBOMProject): string;
  end;

  TSBOMProject = class(TInterfacedObject, ISBOMProject)
  private
    FCompilerVersion: string;
    FCreated:         Nullable<TDateTime>;
    FDPRFile:         string;
    FExcludedPaths:   string;
    FLastGenerated:   Nullable<TDateTime>;
    FLastModified:    Nullable<TDateTime>;
    FMapFile:         string;
    FProjectFolder:   string;
    FProjectName:     string;
    FRootFolders:     string;
  public
    constructor Create(const AProjectName, AProjectFolder: string;
        ACreated, ALastGenerated, ALastModified: Nullable<TDateTime>);

    function GetCompilerVersion: string;
    function GetCreated:         Nullable<TDateTime>;
    function GetDPRFile:         string;
    function GetExcludedPaths:   string;
    function GetLastGenerated:   Nullable<TDateTime>;
    function GetLastModified:    Nullable<TDateTime>;
    function GetMapFile:         string;
    function GetProjectFolder:   string;
    function GetProjectName:     string;
    function GetRootFolders:     string;

    procedure SetCompilerVersion(const AValue: string);
    procedure SetDPRFile(const AValue:         string);
    procedure SetExcludedPaths(const AValue:   string);
    procedure SetLastGenerated(const AValue: Nullable<TDateTime>);
    procedure SetLastModified(const AValue: Nullable<TDateTime>);
    procedure SetMapFile(const AValue:         string);
    procedure SetProjectFolder(const AValue:   string);
    procedure SetProjectName(const AValue:     string);
    procedure SetRootFolders(const AValue:     string);
  end;

  TSBOMProjectService = class(TInterfacedObject, ISBOMProjectService)
  private
    FBasePath: string;
    procedure AddToRecentProjects(const AFileName: string);
    procedure EnsureProjectFolder(const AProjectFolder: string);
  public
    constructor Create;

    function  CreateNew(const AProjectName: string): ISBOMProject;
    function  GenerateSBOMFileName(AProject: ISBOMProject): string;
    function  GetRecentProjects: IReadOnlyList<string>;
    function  GetSBOMFolder(AProject: ISBOMProject): string;
    function  LoadFromFile(const AFileName: string): ISBOMProject;
    procedure SaveToFile(AProject: ISBOMProject; const AFileName: string);
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.IOUtils,
  System.JSON,
  System.DateUtils,
  System.Win.Registry,
  Winapi.Windows,
  u_Logger;

const
  RECENT_PROJECTS_KEY = 'Software\SBOMGenerator';
  MAX_RECENT_PROJECTS = 10;

{ TSBOMProject }

constructor TSBOMProject.Create(const AProjectName, AProjectFolder: string; ACreated, ALastGenerated, ALastModified: Nullable<TDateTime>);
begin
  inherited Create;
  FProjectName   := AProjectName;
  FProjectFolder := AProjectFolder;
  FCreated       := ACreated;
  FLastGenerated := ALastGenerated;
  FLastModified  := ALastModified;
end;

function TSBOMProject.GetCompilerVersion: string;
begin
  Result := FCompilerVersion;
end;

function TSBOMProject.GetCreated: Nullable<TDateTime>;
begin
  Result := FCreated;
end;

function TSBOMProject.GetDPRFile: string;
begin
  Result := FDPRFile;
end;

function TSBOMProject.GetExcludedPaths: string;
begin
  Result := FExcludedPaths;
end;

function TSBOMProject.GetLastGenerated: Nullable<TDateTime>;
begin
  Result := FLastGenerated;
end;

function TSBOMProject.GetLastModified: Nullable<TDateTime>;
begin
  Result := FLastModified;
end;

function TSBOMProject.GetMapFile: string;
begin
  Result := FMapFile;
end;

function TSBOMProject.GetProjectFolder: string;
begin
  Result := FProjectFolder;
end;

function TSBOMProject.GetProjectName: string;
begin
  Result := FProjectName;
end;

function TSBOMProject.GetRootFolders: string;
begin
  Result := FRootFolders;
end;

procedure TSBOMProject.SetCompilerVersion(const AValue: string);
begin
  FCompilerVersion := AValue;
end;

procedure TSBOMProject.SetDPRFile(const AValue: string);
begin
  FDPRFile := AValue;
end;

procedure TSBOMProject.SetExcludedPaths(const AValue: string);
begin
  FExcludedPaths := AValue;
end;

procedure TSBOMProject.SetLastGenerated(const AValue: Nullable<TDateTime>);
begin
  FLastGenerated := AValue;
end;

procedure TSBOMProject.SetLastModified(const AValue: Nullable<TDateTime>);
begin
  FLastModified := AValue;
end;

procedure TSBOMProject.SetMapFile(const AValue: string);
begin
  FMapFile := AValue;
end;

procedure TSBOMProject.SetProjectFolder(const AValue: string);
begin
  FProjectFolder := AValue;
end;

procedure TSBOMProject.SetProjectName(const AValue: string);
begin
  FProjectName := AValue;
end;

procedure TSBOMProject.SetRootFolders(const AValue: string);
begin
  FRootFolders := AValue;
end;

{ TSBOMProjectService }

constructor TSBOMProjectService.Create;
begin
  inherited Create;
  FBasePath := TPath.Combine(TPath.GetDocumentsPath, 'SBOMProjects');

  if not TDirectory.Exists(FBasePath) then
    TDirectory.CreateDirectory(FBasePath);
end;

procedure TSBOMProjectService.AddToRecentProjects(const AFileName: string);
var
  Reg:         TRegistry;
  RecentList:  TStringList;
  I:           Integer;
  ProjectName: string;
begin
  ProjectName := TPath.GetFileNameWithoutExtension(AFileName);

  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKey(RECENT_PROJECTS_KEY, True) then
      Exit;

    RecentList := TStringList.Create;
    try
      if Reg.ValueExists('RecentProjects') then
        RecentList.Text := Reg.ReadString('RecentProjects');

      I := RecentList.IndexOf(ProjectName);
      if I >= 0 then
        RecentList.Delete(I);

      RecentList.Insert(0, ProjectName);

      while RecentList.Count > MAX_RECENT_PROJECTS do
        RecentList.Delete(RecentList.Count - 1);

      Reg.WriteString('RecentProjects', RecentList.Text);
    finally
      RecentList.Free;
    end;
  finally
    Reg.Free;
  end;
end;

function TSBOMProjectService.CreateNew(const AProjectName: string): ISBOMProject;
var
  ProjectFolder: string;
  Created:       Nullable<TDateTime>;
begin
  ProjectFolder := TPath.GetFullPath(TPath.Combine(FBasePath, AProjectName));
  EnsureProjectFolder(ProjectFolder);
  Created := Now;
  Result  := TSBOMProject.Create(AProjectName, ProjectFolder,
    Created,
    Default(Nullable<TDateTime>),
    Default(Nullable<TDateTime>));
end;

procedure TSBOMProjectService.EnsureProjectFolder(const AProjectFolder: string);
var
  SBOMFolder: string;
begin
  if not TDirectory.Exists(AProjectFolder) then
    TDirectory.CreateDirectory(AProjectFolder);

  SBOMFolder := TPath.Combine(AProjectFolder, 'SBOMs');
  if not TDirectory.Exists(SBOMFolder) then
    TDirectory.CreateDirectory(SBOMFolder);
end;

function TSBOMProjectService.GenerateSBOMFileName(AProject: ISBOMProject): string;
var
  Timestamp:  string;
  SBOMFolder: string;
begin
  Timestamp  := FormatDateTime('yyyy-mm-dd_hhnnss', Now);
  SBOMFolder := GetSBOMFolder(AProject);
  Result     := TPath.Combine(SBOMFolder, Timestamp + '.sbom.json');
end;

function TSBOMProjectService.GetRecentProjects: IReadOnlyList<string>;
var
  Folders:     TArray<string>;
  Folder:      string;
  ProjectName: string;
  ProjectFile: string;
  Results:     IList<string>;
begin
  Results := TCollections.CreateList<string>;

  if not TDirectory.Exists(FBasePath) then
  begin
    SysLog.Add('GetRecentProjects: base path not found: ' + FBasePath);
    Result := Results as IReadOnlyList<string>;
    Exit;
  end;

  Folders := TDirectory.GetDirectories(FBasePath);
  for Folder in Folders do
  begin
    ProjectName := TPath.GetFileName(Folder);
    ProjectFile := TPath.Combine(Folder, ProjectName + '.sbomproj');
    if FileExists(ProjectFile) then
      Results.Add(ProjectName);
  end;

  Result := Results as IReadOnlyList<string>;
end;

function TSBOMProjectService.GetSBOMFolder(AProject: ISBOMProject): string;
begin
  Result := TPath.Combine(AProject.ProjectFolder, 'SBOMs');
end;

function TSBOMProjectService.LoadFromFile(const AFileName: string): ISBOMProject;
var
  JSONText:      string;
  JSONObj:       TJSONObject;
  Project:       TSBOMProject;
  CreatedStr:    string;
  ISODateStr:    string;
  ProjectFolder: string;
  LastGenerated: Nullable<TDateTime>;
  Created:       Nullable<TDateTime>;
  LastModifiedStr: string;
  LastModified:    Nullable<TDateTime>;
begin
  if not FileExists(AFileName) then
    raise EFileNotFoundException.CreateFmt(
      'Project file not found: %s', [AFileName]);

  JSONText := TFile.ReadAllText(AFileName, TEncoding.UTF8);
  JSONObj  := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  try
    if JSONObj.TryGetValue<string>('created', CreatedStr) and
       not CreatedStr.IsEmpty then
      Created := ISO8601ToDate(CreatedStr)
    else
      Created := Default(Nullable<TDateTime>);

    if JSONObj.TryGetValue<string>('lastGenerated', ISODateStr) and
       not ISODateStr.IsEmpty then
      LastGenerated := ISO8601ToDate(ISODateStr)
    else
      LastGenerated := Default(Nullable<TDateTime>);

    if JSONObj.TryGetValue<string>('lastModified', LastModifiedStr) and
       not LastModifiedStr.IsEmpty then
      LastModified := ISO8601ToDate(LastModifiedStr)
    else
      LastModified := Default(Nullable<TDateTime>);

    ProjectFolder := ExtractFilePath(AFileName);

    Project := TSBOMProject.Create(
      JSONObj.GetValue<string>('projectName', ''),
      ProjectFolder,
      Created,
      LastGenerated,
      LastModified);

    Project.SetRootFolders(JSONObj.GetValue<string>('rootFolders', ''));
    Project.SetMapFile(JSONObj.GetValue<string>('mapFile', ''));
    Project.SetDPRFile(JSONObj.GetValue<string>('dprFile', ''));
    Project.SetExcludedPaths(JSONObj.GetValue<string>('excludedPaths', ''));
    Project.SetCompilerVersion(JSONObj.GetValue<string>('compilerVersion', ''));

    Result := Project;

    AddToRecentProjects(AFileName);
  finally
    JSONObj.Free;
  end;
end;

procedure TSBOMProjectService.SaveToFile(AProject: ISBOMProject;
  const AFileName: string);
var
  JSONObj:  TJSONObject;
  JSONText: string;
  IsNew:    Boolean;
begin
  // IsNew when project entry doesn't exist
  IsNew := not FileExists(AFileName);

  EnsureProjectFolder(AProject.ProjectFolder);

  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('projectName',     AProject.ProjectName);
    JSONObj.AddPair('rootFolders',     AProject.RootFolders);
    JSONObj.AddPair('mapFile',         AProject.MapFile);
    JSONObj.AddPair('dprFile',         AProject.DPRFile);
    JSONObj.AddPair('excludedPaths',   AProject.ExcludedPaths);
    JSONObj.AddPair('compilerVersion', AProject.CompilerVersion);
    JSONObj.AddPair('lastModified',    DateToISO8601(Now));

    // Only write lastGenerated if an SBOM has actually been generated.
    if AProject.LastGenerated.HasValue then
      JSONObj.AddPair('lastGenerated',
        DateToISO8601(AProject.LastGenerated.Value));

   // Only write created on first save.
    if IsNew then
      JSONObj.AddPair('created', DateToISO8601(Now))
    else if AProject.Created.HasValue then
      JSONObj.AddPair('created',
        DateToISO8601(AProject.Created.Value));

    JSONText := JSONObj.Format(2);
    TFile.WriteAllText(AFileName, JSONText, TEncoding.UTF8);

    AddToRecentProjects(AFileName);
  finally
    JSONObj.Free;
  end;
end;

end.
