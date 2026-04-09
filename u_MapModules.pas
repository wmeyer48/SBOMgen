unit u_MapModules;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Parses Delphi MAP files to extract module names, and builds a
  case-insensitive dictionary mapping unit names to their source
  file paths by scanning a set of root folders. Used by the
  component detection subsystem to resolve module origins.
*)

interface

uses
  Spring.Collections;

type
  /// <summary>
  /// Parses a Delphi MAP file to extract module names, and maintains
  /// a case-insensitive unit-name-to-file-path dictionary built by
  /// scanning source root folders.
  /// </summary>
  IMapModuleParser = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>
    /// Parses the specified MAP file and returns a read-only list
    /// of unique module names found in the modules section.
    /// </summary>
    function ParseMapFile(const AMapFile: string): IReadOnlyList<string>;
    /// <summary>
    /// Scans the supplied root folders recursively for .pas files
    /// and builds the internal unit-name-to-file-path dictionary.
    /// </summary>
    procedure BuildModuleFileDictionary(
      const ARootFolders: IReadOnlyList<string>);
    /// <summary>
    /// Returns the source file path for the named module, or an
    /// empty string if the module was not found in the dictionary.
    /// </summary>
    function GetModuleFilePath(const AModuleName: string): string;
    /// <summary>Returns the number of entries in the file path dictionary.</summary>
    function GetDictionaryCount: Integer;
  end;

  TMapModuleParser = class(TInterfacedObject, IMapModuleParser)
  private
    FModuleFiles: IDictionary<string, string>;
    function ExtractModuleName(const AFileName: string): string;
  public
    constructor Create;

    function ParseMapFile(const AMapFile: string): IReadOnlyList<string>;
    procedure BuildModuleFileDictionary(
      const ARootFolders: IReadOnlyList<string>);
    function GetModuleFilePath(const AModuleName: string): string;
    function GetDictionaryCount: Integer;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.IOUtils;

{ TMapModuleParser }

constructor TMapModuleParser.Create;
begin
  inherited Create;
  FModuleFiles := TCollections.CreateDictionary<string, string>(
    TStringComparer.OrdinalIgnoreCase);
end;

function TMapModuleParser.ParseMapFile(
  const AMapFile: string): IReadOnlyList<string>;
var
  Lines:            TStringList;
  I:                Integer;
  Line:             string;
  ModuleName:       string;
  StartPos:         Integer;
  EndPos:           Integer;
  InModulesSection: Boolean;
  SeenModules:      ISet<string>;
  Results:          IList<string>;
begin
  Results     := TCollections.CreateList<string>;
  SeenModules := TCollections.CreateSet<string>;

  if not FileExists(AMapFile) then
  begin
    Result := Results as IReadOnlyList<string>;
    Exit;
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AMapFile);
    InModulesSection := False;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];

      if InModulesSection and Line.Trim.IsEmpty then
        Break;

      if not Line.Contains('M=') then
        Continue;

      InModulesSection := True;

      StartPos := Pos('M=', Line) + 2;
      EndPos   := PosEx(' ', Line, StartPos);
      if EndPos = 0 then
        EndPos := Length(Line) + 1;

      ModuleName := Trim(Copy(Line, StartPos, EndPos - StartPos));

      if not ModuleName.IsEmpty and not SeenModules.Contains(ModuleName) then
      begin
        SeenModules.Add(ModuleName);
        Results.Add(ModuleName);
      end;
    end;
  finally
    Lines.Free;
  end;

  Result := Results as IReadOnlyList<string>;
end;

function TMapModuleParser.ExtractModuleName(const AFileName: string): string;
begin
  Result := TPath.GetFileNameWithoutExtension(AFileName);
end;

procedure TMapModuleParser.BuildModuleFileDictionary(
  const ARootFolders: IReadOnlyList<string>);
var
  RootFolder: string;
  Files:      TArray<string>;
  FilePath:   string;
  ModuleName: string;
begin
  FModuleFiles.Clear;

  for RootFolder in ARootFolders do
  begin
    if RootFolder.Trim.IsEmpty or not TDirectory.Exists(RootFolder) then
      Continue;

    Files := TDirectory.GetFiles(RootFolder, '*.pas',
      TSearchOption.soAllDirectories);

    for FilePath in Files do
    begin
      ModuleName := ExtractModuleName(FilePath);
      if not FModuleFiles.ContainsKey(ModuleName) then
        FModuleFiles.Add(ModuleName, FilePath);
    end;
  end;
end;

function TMapModuleParser.GetModuleFilePath(const AModuleName: string): string;
begin
  if not FModuleFiles.TryGetValue(AModuleName, Result) then
    Result := '';
end;

function TMapModuleParser.GetDictionaryCount: Integer;
begin
  Result := FModuleFiles.Count;
end;

end.
