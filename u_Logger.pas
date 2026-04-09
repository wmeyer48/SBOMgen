unit u_Logger;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Simple memo-backed logger used throughout SBOMgen.

  SysLog is a global instance initialised at application startup.
  The host form assigns SysLog.Memo before any logging occurs.
  All methods guard against an unassigned Memo and are safe to
  call during startup before the form is fully constructed.
*)

interface

uses
  RzEdit;

type
  /// <summary>
  /// Memo-backed logger. Writes timestamped entries to an injected
  /// TRzMemo. Safe to call before Memo is assigned — entries are
  /// silently discarded if no Memo has been set.
  /// </summary>
  TLogger = class
  private
    FMemo: TRzMemo;
    procedure SetMemo(const AValue: TRzMemo);
  public
    constructor Create;

    /// <summary>Appends AText as a new line in the memo.</summary>
    procedure Add(const AText: string);
    /// <summary>Formats and appends a line using the supplied format string and arguments.</summary>
    procedure AddFormat(const AFormat: string; const AArgs: array of const);
    /// <summary>Clears all content from the memo.</summary>
    procedure Clear;
    /// <summary>Returns the current line count of the memo.</summary>
    function  GetCount: Integer;

    /// <summary>The TRzMemo this logger writes to. Must be assigned before logging begins.</summary>
    property Memo:  TRzMemo read FMemo  write SetMemo;
    /// <summary>Current line count of the memo.</summary>
    property Count: Integer read GetCount;
  end;

// Global logger instance. Initialised in the project source;
// Memo assigned by the host form in its OnCreate handler.
var
  SysLog: TLogger;

implementation

uses
  System.SysUtils;

{ TLogger }

constructor TLogger.Create;
begin
  inherited Create;
end;

procedure TLogger.Add(const AText: string);
begin
  if not Assigned(FMemo) then
    Exit;

  FMemo.Lines.Add(AText);
end;

procedure TLogger.AddFormat(const AFormat: string;
  const AArgs: array of const);
begin
  Add(Format(AFormat, AArgs));
end;

procedure TLogger.Clear;
begin
  if not Assigned(FMemo) then
    Exit;

  FMemo.Clear;
end;

function TLogger.GetCount: Integer;
begin
  if not Assigned(FMemo) then
    Exit(0);

  Result := FMemo.Lines.Count;
end;

procedure TLogger.SetMemo(const AValue: TRzMemo);
begin
  FMemo := AValue;
end;

end.
