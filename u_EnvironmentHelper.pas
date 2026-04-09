unit u_EnvironmentHelper;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Provides Windows environment variable access and path expansion.
  Used by the package resolver and environment harvesting subsystems
  to expand IDE path variables such as $(BDS) and $(BDSCOMMONDIR).
*)

interface

uses
  Spring.Collections;

type
  /// <summary>
  /// Provides access to Windows environment variables and
  /// expands paths containing environment variable references.
  /// </summary>
  IEnvironmentHelper = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>
    /// Returns a dictionary of all environment variable names
    /// and their current values. Hidden variables (those whose
    /// names begin with '=') are excluded.
    /// </summary>
    function GetAllVariables: IDictionary<string, string>;
    /// <summary>Returns the current value of the named environment variable.</summary>
    function GetVariable(const AName: string): string;
    /// <summary>
    /// Expands environment variable references in APath and returns
    /// the result. References must use the %VAR% syntax.
    /// </summary>
    /// <remarks>
    /// Uses the Windows ExpandEnvironmentStrings API with a MAX_PATH
    /// buffer. Paths longer than MAX_PATH (260 characters) after
    /// expansion will be silently truncated.
    /// </remarks>
    function ExpandPath(const APath: string): string;
  end;

  TEnvironmentHelper = class(TInterfacedObject, IEnvironmentHelper)
  public
    function GetAllVariables: IDictionary<string, string>;
    function GetVariable(const AName: string): string;
    function ExpandPath(const APath: string): string;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

{ TEnvironmentHelper }

function TEnvironmentHelper.GetAllVariables: IDictionary<string, string>;
var
  EnvStrings: PChar;
  CurrentPos: PChar;
  VarStr:     string;
  EqualPos:   Integer;
  VarName:    string;
  VarValue:   string;
begin
  Result := TCollections.CreateDictionary<string, string>;

  EnvStrings := GetEnvironmentStrings;
  try
    CurrentPos := EnvStrings;

    while CurrentPos^ <> #0 do
    begin
      VarStr := CurrentPos;

      // Skip hidden variables (names starting with '=')
      if (Length(VarStr) > 0) and (VarStr[1] <> '=') then
      begin
        EqualPos := Pos('=', VarStr);
        if EqualPos > 0 then
        begin
          VarName  := Copy(VarStr, 1, EqualPos - 1);
          VarValue := Copy(VarStr, EqualPos + 1, Length(VarStr));
          Result.Add(VarName, VarValue);
        end;
      end;

      // Advance to the next null-terminated string
      Inc(CurrentPos, Length(VarStr) + 1);
    end;
  finally
    FreeEnvironmentStrings(EnvStrings);
  end;
end;

function TEnvironmentHelper.GetVariable(const AName: string): string;
begin
  Result := System.SysUtils.GetEnvironmentVariable(AName);
end;

function TEnvironmentHelper.ExpandPath(const APath: string): string;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
  Size:   DWORD;
begin
  Size := ExpandEnvironmentStrings(PChar(APath), @Buffer[0], MAX_PATH);
  if Size > 0 then
  begin
    Result := Buffer;
  end
  else
  begin
    Result := APath;
  end;
end;

end.
