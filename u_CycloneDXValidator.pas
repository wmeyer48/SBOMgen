unit u_CycloneDXValidator;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines ICycloneDXValidator and its implementation. Orchestrates
  CycloneDX CLI validation of a generated SBOM file against the
  official CycloneDX 1.6 schema.

  Distinct from u_SBOMValidation, which validates project settings
  and component metadata before detection. This unit is concerned
  solely with post-generation schema conformance checking via the
  external CycloneDX CLI tool.

  TCycloneDXValidator depends on ICLIRunner for process execution
  and has no UI dependencies — all results are returned to the
  caller for display. Registered as a singleton in the DI container
  since it holds no state.
*)

interface

uses
  u_CLIRunner;

type
  /// <summary>
  /// Validates a CycloneDX SBOM file against the official 1.6 schema
  /// using the CycloneDX CLI tool. Returns the process exit code and
  /// captures all tool output for the caller to log or display.
  /// </summary>
  ICycloneDXValidator = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678902}']
    /// <summary>
    /// Runs the CycloneDX CLI validator against ASBOMFile using the
    /// executable at ACLIToolPath. Captures output into AOutput and
    /// returns the exit code. Zero indicates a clean validation pass.
    /// </summary>
    function Validate(
      const ASBOMFile:    string;
      const ACLIToolPath: string;
      out   AOutput:      string): Integer;
  end;

  TCycloneDXValidator = class(TInterfacedObject, ICycloneDXValidator)
  private
    FCLIRunner: ICLIRunner;
  public
    constructor Create(ACLIRunner: ICLIRunner);

    function Validate(
      const ASBOMFile:    string;
      const ACLIToolPath: string;
      out   AOutput:      string): Integer;
  end;

implementation

uses
  System.SysUtils;

{ TCycloneDXValidator }

constructor TCycloneDXValidator.Create(ACLIRunner: ICLIRunner);
begin
  inherited Create;
  FCLIRunner := ACLIRunner;
end;

function TCycloneDXValidator.Validate(
  const ASBOMFile:    string;
  const ACLIToolPath: string;
  out   AOutput:      string): Integer;
var
  Params: string;
begin
  AOutput := '';

  Params := Format(
    'validate --input-file "%s" --input-format json ' +
    '--input-version v1_6 --fail-on-errors',
    [ASBOMFile]);

  Result := FCLIRunner.Run(ACLIToolPath, Params, AOutput);
end;

end.
