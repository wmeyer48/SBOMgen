unit u_CLIRunner;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines ICLIRunner and its implementation. Provides a thin,
  interface-based wrapper around Windows CreateProcess for
  invoking external command-line tools and capturing their output.

  TCLIRunner holds no state — every Run call is independent. It is
  registered as a singleton in the DI container not because shared
  state requires it, but because there is no benefit to creating
  multiple instances. A single instance satisfies all callers for
  the lifetime of the application.
*)

interface

type
  /// <summary>
  /// Executes an external command-line tool and captures its combined
  /// stdout and stderr output. Returns the process exit code.
  /// A return value of -1 indicates that the process could not be
  /// started — check AOutput for any diagnostic message.
  /// </summary>
  ICLIRunner = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567891}']
    /// <summary>
    /// Runs AExePath with AParams, captures all output into AOutput,
    /// and returns the process exit code. Blocks until the process
    /// completes.
    /// </summary>
    function Run(
      const AExePath: string;
      const AParams:  string;
      out   AOutput:  string): Integer;
  end;

  TCLIRunner = class(TInterfacedObject, ICLIRunner)
  public
    function Run(
      const AExePath: string;
      const AParams:  string;
      out   AOutput:  string): Integer;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

{ TCLIRunner }

function TCLIRunner.Run(
  const AExePath: string;
  const AParams:  string;
  out   AOutput:  string): Integer;
var
  StartInfo:  TStartupInfo;
  ProcInfo:   TProcessInformation;
  SecAttr:    TSecurityAttributes;
  ReadPipe:   THandle;
  WritePipe:  THandle;
  Buffer:     array[0..4095] of AnsiChar;
  BytesRead:  DWORD;
  Output:     TStringBuilder;
  CmdLine:    string;
begin
  AOutput := '';
  Result  := -1;

  SecAttr.nLength              := SizeOf(TSecurityAttributes);
  SecAttr.bInheritHandle       := True;
  SecAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(ReadPipe, WritePipe, @SecAttr, 0) then
    Exit;

  try
    // Prevent the read end from being inherited by the child process —
    // required so ReadFile returns when the child closes its write end.
    SetHandleInformation(ReadPipe, HANDLE_FLAG_INHERIT, 0);

    ZeroMemory(@StartInfo, SizeOf(TStartupInfo));
    StartInfo.cb          := SizeOf(TStartupInfo);
    StartInfo.dwFlags     := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    StartInfo.wShowWindow := SW_HIDE;
    StartInfo.hStdOutput  := WritePipe;
    StartInfo.hStdError   := WritePipe;

    CmdLine := Format('"%s" %s', [AExePath, AParams]);

    ZeroMemory(@ProcInfo, SizeOf(TProcessInformation));

    if not CreateProcess(nil, PChar(CmdLine), nil, nil, True,
                         CREATE_NO_WINDOW, nil, nil,
                         StartInfo, ProcInfo) then
      Exit;

    // Close the write end in the parent process. If we keep it open,
    // ReadFile will block forever waiting for output that never comes —
    // the child process cannot signal EOF while the parent also holds
    // the write end open.
    CloseHandle(WritePipe);
    WritePipe := 0;

    Output := TStringBuilder.Create;
    try
      repeat
        ZeroMemory(@Buffer, SizeOf(Buffer));
        if not ReadFile(ReadPipe, Buffer, SizeOf(Buffer) - 1,
                        BytesRead, nil) then
          Break;
        if BytesRead > 0 then
          Output.Append(string(PAnsiChar(@Buffer)));
      until BytesRead = 0;

      WaitForSingleObject(ProcInfo.hProcess, INFINITE);
      GetExitCodeProcess(ProcInfo.hProcess, DWORD(Result));
      AOutput := Output.ToString;
    finally
      Output.Free;
    end;

    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);

  finally
    if ReadPipe <> 0 then
      CloseHandle(ReadPipe);
    if WritePipe <> 0 then
      CloseHandle(WritePipe);
  end;
end;

end.
