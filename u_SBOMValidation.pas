unit u_SBOMValidation;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Validation interfaces and implementations for SBOMgen project
  settings and component metadata. Covers basic field validation
  and MAP-file component detection validation.
*)

interface

uses
  Spring.Collections,
  i_SBOMComponent;

type
  TValidationSeverity = (vsError, vsWarning, vsInfo);

  IValidationIssue = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetSeverity: TValidationSeverity;
    function GetMessage:  string;
    function GetField:    string;
    property Severity: TValidationSeverity read GetSeverity;
    property Message:  string              read GetMessage;
    property Field:    string              read GetField;
  end;

  IValidationResult = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function IsValid:       Boolean;
    function HasErrors:     Boolean;
    function HasWarnings:   Boolean;
    function GetIssues:     IReadOnlyList<IValidationIssue>;
    function GetErrorCount: Integer;
    function GetWarningCount: Integer;
    procedure AddError(const AField, AMessage: string);
    procedure AddWarning(const AField, AMessage: string);
    procedure AddInfo(const AField, AMessage: string);
    property Issues:       IReadOnlyList<IValidationIssue> read GetIssues;
    property ErrorCount:   Integer                         read GetErrorCount;
    property WarningCount: Integer                         read GetWarningCount;
  end;

  IBasicValidator = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    function ValidateBasicSettings(
      const AProjectName, ARootFolders,
            AMapFile, ADPRFile, AExcludedPaths: string;
            ACompilerVersionSelected: Boolean): IValidationResult;
  end;

  TValidationIssue = class(TInterfacedObject, IValidationIssue)
  private
    FSeverity: TValidationSeverity;
    FMessage:  string;
    FField:    string;
  public
    constructor Create(
            ASeverity: TValidationSeverity;
      const AField, AMessage: string);
    function GetSeverity: TValidationSeverity;
    function GetMessage:  string;
    function GetField:    string;
  end;

  TValidationResult = class(TInterfacedObject, IValidationResult)
  private
    FIssues: IList<IValidationIssue>;
  public
    constructor Create;
    function IsValid:         Boolean;
    function HasErrors:       Boolean;
    function HasWarnings:     Boolean;
    function GetIssues:       IReadOnlyList<IValidationIssue>;
    function GetErrorCount:   Integer;
    function GetWarningCount: Integer;
    procedure AddError(const AField, AMessage: string);
    procedure AddWarning(const AField, AMessage: string);
    procedure AddInfo(const AField, AMessage: string);
  end;

  TBasicValidator = class(TInterfacedObject, IBasicValidator)
  public
    function ValidateBasicSettings(
      const AProjectName, ARootFolders,
            AMapFile, ADPRFile, AExcludedPaths: string;
            ACompilerVersionSelected: Boolean): IValidationResult;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

{ TValidationIssue }

constructor TValidationIssue.Create(
        ASeverity: TValidationSeverity;
  const AField, AMessage: string);
begin
  inherited Create;
  FSeverity := ASeverity;
  FField    := AField;
  FMessage  := AMessage;
end;

function TValidationIssue.GetSeverity: TValidationSeverity;
begin
  Result := FSeverity;
end;

function TValidationIssue.GetMessage: string;
begin
  Result := FMessage;
end;

function TValidationIssue.GetField: string;
begin
  Result := FField;
end;

{ TValidationResult }

constructor TValidationResult.Create;
begin
  inherited Create;
  FIssues := TCollections.CreateList<IValidationIssue>;
end;

function TValidationResult.IsValid: Boolean;
begin
  Result := not HasErrors;
end;

function TValidationResult.HasErrors: Boolean;
begin
  Result := GetErrorCount > 0;
end;

function TValidationResult.HasWarnings: Boolean;
begin
  Result := GetWarningCount > 0;
end;

function TValidationResult.GetIssues: IReadOnlyList<IValidationIssue>;
begin
  Result := FIssues as IReadOnlyList<IValidationIssue>;
end;

function TValidationResult.GetErrorCount: Integer;
var
  Issue: IValidationIssue;
begin
  Result := 0;
  for Issue in FIssues do
  begin
    if Issue.Severity = vsError then
      Inc(Result);
  end;
end;

function TValidationResult.GetWarningCount: Integer;
var
  Issue: IValidationIssue;
begin
  Result := 0;
  for Issue in FIssues do
  begin
    if Issue.Severity = vsWarning then
      Inc(Result);
  end;
end;

procedure TValidationResult.AddError(const AField, AMessage: string);
begin
  FIssues.Add(TValidationIssue.Create(vsError, AField, AMessage));
end;

procedure TValidationResult.AddWarning(const AField, AMessage: string);
begin
  FIssues.Add(TValidationIssue.Create(vsWarning, AField, AMessage));
end;

procedure TValidationResult.AddInfo(const AField, AMessage: string);
begin
  FIssues.Add(TValidationIssue.Create(vsInfo, AField, AMessage));
end;

{ TBasicValidator }

function TBasicValidator.ValidateBasicSettings(
  const AProjectName, ARootFolders,
        AMapFile, ADPRFile, AExcludedPaths: string;
        ACompilerVersionSelected: Boolean): IValidationResult;
var
  PathArray: TArray<string>;
  Path:      string;
begin
  Result := TValidationResult.Create;

  if AProjectName.Trim.IsEmpty then
    Result.AddError('Project Name', 'Project name is required');

  if not ACompilerVersionSelected then
    Result.AddError('Compiler Version', 'Please select a Delphi compiler version');

  if ARootFolders.Trim.IsEmpty then
    Result.AddError('Root Folders', 'At least one root folder is required')
  else
  begin
    PathArray := ARootFolders.Split([';']);
    for Path in PathArray do
    begin
      if Path.Trim.IsEmpty then
        Continue;
      if not TDirectory.Exists(Path.Trim) then
        Result.AddError('Root Folders',
          Format('Directory does not exist: %s', [Path.Trim]));
    end;
  end;

  if AMapFile.Trim.IsEmpty then
    Result.AddError('MAP File', 'MAP file is required')
  else if not TFile.Exists(AMapFile) then
    Result.AddError('MAP File', 'MAP file does not exist: ' + AMapFile);

  if ADPRFile.Trim.IsEmpty then
    Result.AddWarning('DPR File',
      'DPR file not specified - DPROJ parsing will be skipped')
  else if not TFile.Exists(ADPRFile) then
    Result.AddError('DPR File', 'DPR file does not exist: ' + ADPRFile);

  if not AExcludedPaths.Trim.IsEmpty then
  begin
    PathArray := AExcludedPaths.Split([';']);
    for Path in PathArray do
    begin
      if Path.Trim.IsEmpty then
        Continue;
      if not TDirectory.Exists(Path.Trim) then
        Result.AddWarning('Excluded Paths',
          Format('Directory does not exist: %s', [Path.Trim]));
    end;
  end;
end;

end.
