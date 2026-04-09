unit u_ModuleAdapter;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Adapts IModuleInfo to IMetadataItem for display in the AppCode
  tab tree view. Also provides ISourceAnalyzer for release
  compliance checks (copyright, SPDX, TODO/FIXME scanning).

  TModuleInfoAdapter — wraps IModuleInfo as IMetadataItem and
    IExtendedModuleInfo. Resolves the actual file path via the
    map parser and gathers file size, modification time, and
    line count at construction time.

  TSourceAnalyzer — scans a source file and returns a list of
    ICodeWarning instances covering copyright, SPDX identifier,
    and TODO/FIXME markers.
*)

interface

uses
  System.Classes,
  Spring.Collections,
  i_MetadataViewer,
  i_SBOMComponentDetection,
  u_MapModules,
  u_UserProfile;

type
  /// <summary>Severity level of a code quality warning.</summary>
  TWarningLevel = (wlInfo, wlWarning, wlError);

  /// <summary>A single code quality warning produced by ISourceAnalyzer.</summary>
  ICodeWarning = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    /// <summary>Returns the severity of this warning.</summary>
    function GetLevel: TWarningLevel;
    /// <summary>Returns the warning message text.</summary>
    function GetMessage: string;
    /// <summary>Returns the source line number this warning relates to.</summary>
    function GetLineNumber: Integer;

    /// <summary>Severity of this warning.</summary>
    property Level:      TWarningLevel read GetLevel;
    /// <summary>Warning message text.</summary>
    property Message:    string        read GetMessage;
    /// <summary>Source line number this warning relates to.</summary>
    property LineNumber: Integer       read GetLineNumber;
  end;

  /// <summary>Scans a source file for release compliance issues.</summary>
  ISourceAnalyzer = interface
    ['{D4E5F6A7-B8C9-0123-DEF1-234567890123}']
    /// <summary>
    /// Analyzes the specified source file and returns a read-only
    /// list of warnings covering copyright, SPDX, and comment markers.
    /// </summary>
    function AnalyzeFile(const AFileName: string): IReadOnlyList<ICodeWarning>;
  end;

  /// <summary>Extended file-level information for a module entry.</summary>
  IExtendedModuleInfo = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the Delphi unit name of this module.</summary>
    function GetUnitName:     string;
    /// <summary>Returns the resolved file path of this module.</summary>
    function GetFilePath:     string;
    /// <summary>Returns the file size in bytes.</summary>
    function GetFileSize:     Int64;
    /// <summary>Returns the last write time of the source file.</summary>
    function GetLastModified: TDateTime;
    /// <summary>Returns the number of lines in the source file.</summary>
    function GetLineCount:    Integer;
    /// <summary>Returns a display string describing the module scope or origin.</summary>
    function GetScope:        string;

    /// <summary>Delphi unit name of this module.</summary>
    property UnitName:     string    read GetUnitName;
    /// <summary>Resolved file path of this module.</summary>
    property FilePath:     string    read GetFilePath;
    /// <summary>File size in bytes.</summary>
    property FileSize:     Int64     read GetFileSize;
    /// <summary>Last write time of the source file.</summary>
    property LastModified: TDateTime read GetLastModified;
    /// <summary>Number of lines in the source file.</summary>
    property LineCount:    Integer   read GetLineCount;
    /// <summary>Display string describing the module scope or origin.</summary>
    property Scope:        string    read GetScope;
  end;

  /// <summary>
  /// Adapts IModuleInfo to IMetadataItem and IExtendedModuleInfo for
  /// display in the AppCode tab tree view.
  /// </summary>
  TModuleInfoAdapter = class(TInterfacedObject, IMetadataItem, IExtendedModuleInfo)
  private
    FActualFilePath: string;
    FModuleInfo:     IModuleInfo;
    FFileSize:       Int64;
    FLastModified:   TDateTime;
    FLineCount:      Integer;
    FUserProfile:    IUserProfile;

    procedure GatherFileInfo;
    function  CountLines(const AFileName: string): Integer;
  public
    constructor Create(
      AModuleInfo:  IModuleInfo;
      AMapParser:   IMapModuleParser;
      AUserProfile: IUserProfile);

    function GetName:        string;
    function GetVersion:     string;
    function GetSupplier:    string;
    function GetSupplierURL: string;
    function GetLicense:     string;
    function GetDescription: string;
    function GetIsModified:  Boolean;

    procedure SetVersion(const AValue:     string);
    procedure SetSupplier(const AValue:    string);
    procedure SetSupplierURL(const AValue: string);
    procedure SetLicense(const AValue:     string);
    procedure SetDescription(const AValue: string);

    function GetUnitName:     string;
    function GetFilePath:     string;
    function GetFileSize:     Int64;
    function GetLastModified: TDateTime;
    function GetLineCount:    Integer;
    function GetScope:        string;
  end;

  /// <summary>Simple source file viewer interface.</summary>
  ISourceFileViewer = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    /// <summary>Loads the specified file into the viewer.</summary>
    procedure LoadFile(const AFileName: string);
    /// <summary>Clears the viewer content.</summary>
    procedure Clear;
    /// <summary>Sets the read-only state of the viewer.</summary>
    procedure SetReadOnly(AValue: Boolean);
  end;

  TCodeWarning = class(TInterfacedObject, ICodeWarning)
  private
    FLevel:      TWarningLevel;
    FMessage:    string;
    FLineNumber: Integer;
  public
    constructor Create(
            ALevel:      TWarningLevel;
      const AMessage:    string;
            ALineNumber: Integer);

    function GetLevel:      TWarningLevel;
    function GetMessage:    string;
    function GetLineNumber: Integer;
  end;

  TSourceAnalyzer = class(TInterfacedObject, ISourceAnalyzer)
  private
    FCurrentYear: Integer;

    procedure CheckCopyright(const ALines: TStringList;
      AWarnings: IList<ICodeWarning>);
    procedure CheckSPDXLicense(const ALines: TStringList;
      AWarnings: IList<ICodeWarning>);
    procedure CheckTODOComments(const ALines: TStringList;
      AWarnings: IList<ICodeWarning>);
    procedure CheckFIXMEComments(const ALines: TStringList;
      AWarnings: IList<ICodeWarning>);
  public
    constructor Create;
    function AnalyzeFile(const AFileName: string): IReadOnlyList<ICodeWarning>;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.Math,
  u_SBOMEnums;

{ Utility }

function FormatFileSize(ABytes: Int64): string;
begin
  if ABytes < 1024 then
    Result := Format('%d bytes', [ABytes])
  else if ABytes < 1024 * 1024 then
    Result := Format('%.1f KB', [ABytes / 1024])
  else
    Result := Format('%.2f MB', [ABytes / (1024 * 1024)]);
end;

{ TModuleInfoAdapter }

constructor TModuleInfoAdapter.Create(
  AModuleInfo:  IModuleInfo;
  AMapParser:   IMapModuleParser;
  AUserProfile: IUserProfile);
begin
  inherited Create;
  FModuleInfo  := AModuleInfo;
  FUserProfile := AUserProfile;

  if Assigned(AMapParser) then
    FActualFilePath := AMapParser.GetModuleFilePath(AModuleInfo.UnitName)
  else
    FActualFilePath := '';

  FFileSize     := 0;
  FLastModified := 0;
  FLineCount    := 0;

  if not FActualFilePath.IsEmpty then
  begin
    GatherFileInfo;
  end;
end;

procedure TModuleInfoAdapter.GatherFileInfo;
begin
  FFileSize     := 0;
  FLastModified := 0;
  FLineCount    := 0;

  if FileExists(FActualFilePath) then
  begin
    try
      FFileSize     := TFile.GetSize(FActualFilePath);
      FLastModified := TFile.GetLastWriteTime(FActualFilePath);
      FLineCount    := CountLines(FActualFilePath);
    except
      on E: Exception do
      begin
        FFileSize     := 0;
        FLastModified := 0;
        FLineCount    := 0;
      end;
    end;
  end;
end;

function TModuleInfoAdapter.CountLines(const AFileName: string): Integer;
var
  Lines: TStringList;
begin
  Result := 0;
  if not FileExists(AFileName) then
    Exit;

  try
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(AFileName);
      Result := Lines.Count;
    finally
      Lines.Free;
    end;
  except
    on E: Exception do
      Result := 0;
  end;
end;

function TModuleInfoAdapter.GetName: string;
begin
  Result := FModuleInfo.UnitName;
end;

function TModuleInfoAdapter.GetVersion: string;
begin
  Result := '';
end;

function TModuleInfoAdapter.GetSupplier: string;
begin
  if Assigned(FUserProfile) and not FUserProfile.Company.IsEmpty then
    Result := FUserProfile.Company
  else
    Result := 'Internal Development';
end;

function TModuleInfoAdapter.GetSupplierURL: string;
begin
  Result := '';
end;

function TModuleInfoAdapter.GetLicense: string;
begin
  Result := 'Proprietary';
end;

function TModuleInfoAdapter.GetDescription: string;
begin
  if FLineCount > 0 then
    Result := Format('%s (%d lines, %s)',
      [ExtractFileName(FActualFilePath), FLineCount,
       FormatFileSize(FFileSize)])
  else
    Result := ExtractFileName(FActualFilePath);
end;

function TModuleInfoAdapter.GetIsModified: Boolean;
begin
  Result := False;
end;

// Read-only setters — IMetadataItem requires them; modules are not editable.
procedure TModuleInfoAdapter.SetVersion(const AValue: string);
begin
  // Read-only
end;

procedure TModuleInfoAdapter.SetSupplier(const AValue: string);
begin
  // Read-only
end;

procedure TModuleInfoAdapter.SetSupplierURL(const AValue: string);
begin
  // Read-only
end;

procedure TModuleInfoAdapter.SetLicense(const AValue: string);
begin
  // Read-only
end;

procedure TModuleInfoAdapter.SetDescription(const AValue: string);
begin
  // Read-only
end;

function TModuleInfoAdapter.GetUnitName: string;
begin
  Result := FModuleInfo.UnitName;
end;

function TModuleInfoAdapter.GetFilePath: string;
begin
  Result := FActualFilePath;
end;

function TModuleInfoAdapter.GetFileSize: Int64;
begin
  Result := FFileSize;
end;

function TModuleInfoAdapter.GetLastModified: TDateTime;
begin
  Result := FLastModified;
end;

function TModuleInfoAdapter.GetLineCount: Integer;
begin
  Result := FLineCount;
end;

function TModuleInfoAdapter.GetScope: string;
begin
  case FModuleInfo.Category of
    ccInternal:      Result := 'Internal';
    ccDelphiRTL:     Result := 'RTL';
    ccDelphiVCL:     Result := 'VCL';
    ccDelphiFireDAC: Result := 'FireDAC';
    ccThirdParty:    Result := 'Third Party';
  else
    Result := 'Unknown';
  end;
end;

{ TCodeWarning }

constructor TCodeWarning.Create(
        ALevel:      TWarningLevel;
  const AMessage:    string;
        ALineNumber: Integer);
begin
  inherited Create;
  FLevel      := ALevel;
  FMessage    := AMessage;
  FLineNumber := ALineNumber;
end;

function TCodeWarning.GetLevel: TWarningLevel;
begin
  Result := FLevel;
end;

function TCodeWarning.GetLineNumber: Integer;
begin
  Result := FLineNumber;
end;

function TCodeWarning.GetMessage: string;
begin
  Result := FMessage;
end;

{ TSourceAnalyzer }

constructor TSourceAnalyzer.Create;
begin
  inherited Create;
  FCurrentYear := CurrentYear;
end;

function TSourceAnalyzer.AnalyzeFile(
  const AFileName: string): IReadOnlyList<ICodeWarning>;
var
  Lines:    TStringList;
  Warnings: IList<ICodeWarning>;
begin
  Warnings := TCollections.CreateList<ICodeWarning>;

  if not FileExists(AFileName) then
  begin
    Warnings.Add(TCodeWarning.Create(wlError, 'File not found', 0));
    Result := Warnings as IReadOnlyList<ICodeWarning>;
    Exit;
  end;

  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(AFileName);
      CheckCopyright(Lines, Warnings);
      CheckSPDXLicense(Lines, Warnings);
      CheckTODOComments(Lines, Warnings);
      CheckFIXMEComments(Lines, Warnings);
    except
      on E: Exception do
        Warnings.Add(TCodeWarning.Create(
          wlError, 'Error reading file: ' + E.Message, 0));
    end;
  finally
    Lines.Free;
  end;

  Result := Warnings as IReadOnlyList<ICodeWarning>;
end;

procedure TSourceAnalyzer.CheckCopyright(
  const ALines: TStringList; AWarnings: IList<ICodeWarning>);
var
  I:             Integer;
  Line:          string;
  FoundCopyright: Boolean;
  CopyrightYear: Integer;
begin
  FoundCopyright := False;
  CopyrightYear  := 0;

  for I := 0 to Min(49, ALines.Count - 1) do
  begin
    Line := ALines[I].ToLower;

    if Line.Contains('copyright') then
    begin
      FoundCopyright := True;

      if TryStrToInt(Copy(ALines[I], Pos('20', ALines[I]), 4),
        CopyrightYear) then
      begin
        if CopyrightYear < FCurrentYear then
          AWarnings.Add(TCodeWarning.Create(
            wlWarning,
            Format('Copyright year %d is outdated (current year: %d)',
              [CopyrightYear, FCurrentYear]),
            I + 1));
      end;

      Break;
    end;
  end;

  if not FoundCopyright then
    AWarnings.Add(TCodeWarning.Create(
      wlWarning, 'No copyright notice found', 1));
end;

procedure TSourceAnalyzer.CheckSPDXLicense(
  const ALines: TStringList; AWarnings: IList<ICodeWarning>);
var
  I:         Integer;
  FoundSPDX: Boolean;
begin
  FoundSPDX := False;

  for I := 0 to Min(49, ALines.Count - 1) do
  begin
    if ALines[I].Contains('SPDX-License-Identifier:') then
    begin
      FoundSPDX := True;
      Break;
    end;
  end;

  if not FoundSPDX then
    AWarnings.Add(TCodeWarning.Create(
      wlInfo,
      'No SPDX-License-Identifier found (recommended for SBOM compliance)',
      1));
end;

procedure TSourceAnalyzer.CheckTODOComments(
  const ALines: TStringList; AWarnings: IList<ICodeWarning>);
var
  I:        Integer;
  Line:     string;
  TodoText: string;
begin
  for I := 0 to ALines.Count - 1 do
  begin
    Line := ALines[I];

    if Line.ToUpper.Contains('TODO') or Line.ToUpper.Contains('TO DO') then
    begin
      TodoText := Trim(Line);
      if TodoText.StartsWith('//') then
        TodoText := Trim(Copy(TodoText, 3, Length(TodoText)));

      AWarnings.Add(TCodeWarning.Create(
        wlInfo, 'TODO: ' + TodoText, I + 1));
    end;
  end;
end;

procedure TSourceAnalyzer.CheckFIXMEComments(
  const ALines: TStringList; AWarnings: IList<ICodeWarning>);
var
  I:         Integer;
  Line:      string;
  FixmeText: string;
begin
  for I := 0 to ALines.Count - 1 do
  begin
    Line := ALines[I];

    if Line.ToUpper.Contains('FIXME') or Line.ToUpper.Contains('FIX ME') then
    begin
      FixmeText := Trim(Line);
      if FixmeText.StartsWith('//') then
        FixmeText := Trim(Copy(FixmeText, 3, Length(FixmeText)));

      AWarnings.Add(TCodeWarning.Create(
        wlWarning, 'FIXME: ' + FixmeText, I + 1));
    end;
  end;
end;

end.
