unit u_FileFinders;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  File location utilities used by the help system and resource
  loading subsystems. Provides upward directory tree search and
  multi-path file resolution.
*)

interface

uses
  System.SysUtils;

/// <summary>
/// Searches upward from AStartPath through successive parent
/// directories until the relative path ARelativePath is found
/// or the filesystem root is reached.
/// </summary>
/// <remarks>
/// Solves the common Delphi debug/release path mismatch: in debug
/// builds the executable sits in Win64\Debug rather than the project
/// root, so resource files found by relative path at deployment time
/// are not found at the same relative offset in debug. Walking up
/// the tree finds the file correctly in both configurations.
/// </remarks>
/// <param name="AStartPath">The directory to begin searching from, typically ExtractFilePath(Application.ExeName).</param>
/// <param name="ARelativePath">The relative file path to locate, e.g. TPath.Combine('Help', 'guide.md').</param>
/// <example>
///   ExePath  := ExtractFilePath(Application.ExeName);
///   HelpFile := FindFileUpTree(ExePath, TPath.Combine('Help', 'sbom-generator-guide.md'));
/// </example>
function FindFileUpTree(const AStartPath, ARelativePath: string): string;

/// <summary>
/// Searches each semicolon-delimited path in ACurrentPaths for a
/// file named AFile and returns the first fully qualified path found,
/// or an empty string if the file is not located in any of the paths.
/// </summary>
function TryGetFileByName(const AFile, ACurrentPaths: string): string;

implementation

uses
  System.IOUtils;

function FindFileUpTree(const AStartPath, ARelativePath: string): string;
var
  Dir:       string;
  Candidate: string;
  Prev:      string;
begin
  Result := '';
  Dir    := AStartPath;

  repeat
    Candidate := TPath.Combine(Dir, ARelativePath);
    if FileExists(Candidate) then
    begin
      Result := Candidate;
      Exit;
    end;
    Prev := Dir;
    Dir  := TPath.GetDirectoryName(Dir);
  until (Dir = '') or (Dir = Prev);
end;

function TryGetFileByName(const AFile, ACurrentPaths: string): string;
var
  Arr:      TArray<string>;
  Path:     string;
  FullPath: string;
begin
  Result := '';

  if ACurrentPaths.IsEmpty then
    Exit;

  Arr := ACurrentPaths.Split([';']);
  for Path in Arr do
  begin
    if Path = '' then
      Continue;

    FullPath := TPath.GetFullPath(TPath.Combine(Path, AFile));

    if TFile.Exists(FullPath) then
    begin
      Result := FullPath;
      Exit;
    end;
  end;
end;

end.
