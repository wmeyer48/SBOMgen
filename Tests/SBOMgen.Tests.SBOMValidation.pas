unit SBOMgen.Tests.SBOMValidation;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  DUnitX tests for u_SBOMValidation.
  Covers TValidationResult issue accumulation and predicates,
  and TBasicValidator field validation logic.
  TComponentValidator is excluded — it requires IComponentDetector
  and IComponentCatalog stubs and belongs in integration tests.
*)

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TValidationResultTests = class
  public
    // ── Initial state ─────────────────────────────────────────────────────

    [Test]
    procedure NewResultIsValid;

    [Test]
    procedure NewResultHasNoErrors;

    [Test]
    procedure NewResultHasNoWarnings;

    [Test]
    procedure NewResultIssueCountIsZero;

    // ── AddError ──────────────────────────────────────────────────────────

    [Test]
    procedure AddErrorMakesResultInvalid;

    [Test]
    procedure AddErrorIncrementsErrorCount;

    [Test]
    procedure AddErrorSetsCorrectFieldAndMessage;

    [Test]
    procedure AddErrorSetsCorrectSeverity;

    [Test]
    procedure MultipleErrorsAreAccumulated;

    // ── AddWarning ────────────────────────────────────────────────────────

    [Test]
    procedure AddWarningDoesNotMakeResultInvalid;

    [Test]
    procedure AddWarningIncrementsWarningCount;

    [Test]
    procedure AddWarningSetsCorrectSeverity;

    // ── AddInfo ───────────────────────────────────────────────────────────

    [Test]
    procedure AddInfoDoesNotMakeResultInvalid;

    [Test]
    procedure AddInfoDoesNotIncrementErrorOrWarningCount;

    // ── Mixed issues ──────────────────────────────────────────────────────

    [Test]
    procedure ErrorAndWarningBothAccumulated;

    [Test]
    procedure HasWarningsIsFalseWhenOnlyErrors;

    [Test]
    procedure HasErrorsIsFalseWhenOnlyWarnings;
  end;

  [TestFixture]
  TBasicValidatorTests = class
  private
    FTempDir:  string;
    FTempFile: string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ── Project name ──────────────────────────────────────────────────────

    [Test]
    procedure EmptyProjectNameProducesError;

    [Test]
    procedure WhitespaceProjectNameProducesError;

    // ── Compiler version ──────────────────────────────────────────────────

    [Test]
    procedure NoCompilerVersionProducesError;

    // ── Root folders ──────────────────────────────────────────────────────

    [Test]
    procedure EmptyRootFoldersProducesError;

    [Test]
    procedure NonExistentRootFolderProducesError;

    [Test]
    procedure ExistingRootFolderProducesNoError;

    [Test]
    procedure MultipleRootFoldersOneInvalidProducesError;

    // ── MAP file ──────────────────────────────────────────────────────────

    [Test]
    procedure EmptyMapFileProducesError;

    [Test]
    procedure NonExistentMapFileProducesError;

    [Test]
    procedure ExistingMapFileProducesNoError;

    // ── DPR file ──────────────────────────────────────────────────────────

    [Test]
    procedure EmptyDPRFileProducesWarningNotError;

    [Test]
    procedure NonExistentDPRFileProducesError;

    [Test]
    procedure ExistingDPRFileProducesNoError;

    // ── Excluded paths ────────────────────────────────────────────────────

    [Test]
    procedure EmptyExcludedPathsProducesNoIssues;

    [Test]
    procedure NonExistentExcludedPathProducesWarningNotError;

    [Test]
    procedure ExistingExcludedPathProducesNoIssue;

    // ── All valid ─────────────────────────────────────────────────────────

    [Test]
    procedure AllValidSettingsProducesNoErrors;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,
  Spring.Collections,
  u_SBOMValidation;

{ TValidationResultTests }

procedure TValidationResultTests.NewResultIsValid;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  Assert.IsTrue(R.IsValid);
end;

procedure TValidationResultTests.NewResultHasNoErrors;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  Assert.IsFalse(R.HasErrors);
end;

procedure TValidationResultTests.NewResultHasNoWarnings;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  Assert.IsFalse(R.HasWarnings);
end;

procedure TValidationResultTests.NewResultIssueCountIsZero;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  Assert.AreEqual(0, R.Issues.Count);
end;

procedure TValidationResultTests.AddErrorMakesResultInvalid;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddError('Field', 'Something is wrong');
  Assert.IsFalse(R.IsValid);
end;

procedure TValidationResultTests.AddErrorIncrementsErrorCount;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddError('Field', 'Error 1');
  R.AddError('Field', 'Error 2');
  Assert.AreEqual(2, R.ErrorCount);
end;

procedure TValidationResultTests.AddErrorSetsCorrectFieldAndMessage;
var
  R:     IValidationResult;
  Issue: IValidationIssue;
begin
  R := TValidationResult.Create;
  R.AddError('MyField', 'My message');
  Issue := R.Issues[0];
  Assert.AreEqual('MyField',    Issue.Field);
  Assert.AreEqual('My message', Issue.Message);
end;

procedure TValidationResultTests.AddErrorSetsCorrectSeverity;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddError('Field', 'Message');
  Assert.AreEqual(vsError, R.Issues[0].Severity);
end;

procedure TValidationResultTests.MultipleErrorsAreAccumulated;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddError('F1', 'E1');
  R.AddError('F2', 'E2');
  R.AddError('F3', 'E3');
  Assert.AreEqual(3, R.Issues.Count);
  Assert.AreEqual(3, R.ErrorCount);
end;

procedure TValidationResultTests.AddWarningDoesNotMakeResultInvalid;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddWarning('Field', 'A warning');
  Assert.IsTrue(R.IsValid);
end;

procedure TValidationResultTests.AddWarningIncrementsWarningCount;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddWarning('Field', 'Warning 1');
  R.AddWarning('Field', 'Warning 2');
  Assert.AreEqual(2, R.WarningCount);
end;

procedure TValidationResultTests.AddWarningSetsCorrectSeverity;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddWarning('Field', 'Message');
  Assert.AreEqual(vsWarning, R.Issues[0].Severity);
end;

procedure TValidationResultTests.AddInfoDoesNotMakeResultInvalid;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddInfo('Field', 'Info');
  Assert.IsTrue(R.IsValid);
end;

procedure TValidationResultTests.AddInfoDoesNotIncrementErrorOrWarningCount;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddInfo('Field', 'Info');
  Assert.AreEqual(0, R.ErrorCount);
  Assert.AreEqual(0, R.WarningCount);
end;

procedure TValidationResultTests.ErrorAndWarningBothAccumulated;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddError('F1', 'E1');
  R.AddWarning('F2', 'W1');
  Assert.AreEqual(1, R.ErrorCount);
  Assert.AreEqual(1, R.WarningCount);
  Assert.AreEqual(2, R.Issues.Count);
end;

procedure TValidationResultTests.HasWarningsIsFalseWhenOnlyErrors;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddError('Field', 'Error');
  Assert.IsFalse(R.HasWarnings);
end;

procedure TValidationResultTests.HasErrorsIsFalseWhenOnlyWarnings;
var
  R: IValidationResult;
begin
  R := TValidationResult.Create;
  R.AddWarning('Field', 'Warning');
  Assert.IsFalse(R.HasErrors);
end;

{ TBasicValidatorTests }

procedure TBasicValidatorTests.Setup;
begin
  FTempDir  := TPath.Combine(TPath.GetTempPath, 'SBOMgenTests_' +
    IntToStr(GetCurrentProcessId));
  TDirectory.CreateDirectory(FTempDir);
  FTempFile := TPath.Combine(FTempDir, 'test.map');
  TFile.WriteAllText(FTempFile, 'MAP file content');
end;

procedure TBasicValidatorTests.TearDown;
begin
  if TDirectory.Exists(FTempDir) then
    TDirectory.Delete(FTempDir, True);
end;

procedure TBasicValidatorTests.EmptyProjectNameProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('', FTempDir, FTempFile, '', '', True);
  Assert.IsTrue(R.HasErrors);
  Assert.AreEqual('Project Name', R.Issues[0].Field);
end;

procedure TBasicValidatorTests.WhitespaceProjectNameProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('   ', FTempDir, FTempFile, '', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.NoCompilerVersionProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '', '', False);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.EmptyRootFoldersProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', '', FTempFile, '', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.NonExistentRootFolderProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject',
    'C:\NoSuchFolder_SBOMgenTest', FTempFile, '', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.ExistingRootFolderProducesNoError;
var
  Count: Integer;
  V:      IBasicValidator;
  R:      IValidationResult;
  Issues: IReadOnlyList<IValidationIssue>;
  Issue:  IValidationIssue;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '', '', True);
  // Filter for Root Folders errors only
  Count := 0;
  for Issue in R.Issues do
  begin
    if (Issue.Field = 'Root Folders') and (Issue.Severity = vsError) then
      Inc(Count);
  end;
  Assert.AreEqual(0, Count, 'Expected no Root Folders errors');
end;

procedure TBasicValidatorTests.MultipleRootFoldersOneInvalidProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject',
    FTempDir + ';C:\NoSuchFolder_SBOMgenTest',
    FTempFile, '', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.EmptyMapFileProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, '', '', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.NonExistentMapFileProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir,
    'C:\NoSuchFile_SBOMgenTest.map', '', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.ExistingMapFileProducesNoError;
var
  Count: Integer;
  V:      IBasicValidator;
  R:      IValidationResult;
  Issue:  IValidationIssue;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '', '', True);
  Count := 0;
  for Issue in R.Issues do
  begin
    if (Issue.Field = 'MAP File') and (Issue.Severity = vsError) then
      Inc(Count);
  end;
  Assert.AreEqual(0, Count, 'Expected no Map file errors');
end;

procedure TBasicValidatorTests.EmptyDPRFileProducesWarningNotError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '', '', True);
  Assert.IsFalse(R.HasErrors);
  Assert.IsTrue(R.HasWarnings);
  Assert.AreEqual('DPR File', R.Issues[0].Field);
end;

procedure TBasicValidatorTests.NonExistentDPRFileProducesError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile,
    'C:\NoSuchFile_SBOMgenTest.dpr', '', True);
  Assert.IsTrue(R.HasErrors);
end;

procedure TBasicValidatorTests.ExistingDPRFileProducesNoError;
var
  Count: Integer;
  V:     IBasicValidator;
  R:     IValidationResult;
  DPR:   string;
  Issue: IValidationIssue;
begin
  DPR := TPath.Combine(FTempDir, 'test.dpr');
  TFile.WriteAllText(DPR, 'program Test;');
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, DPR, '', True);
  Count := 0;
  for Issue in R.Issues do
  begin
    if (Issue.Field = 'DPR File') and (Issue.Severity = vsError) then
      Inc(Count);
  end;
  Assert.AreEqual(0, Count, 'Expected no DPR file errors');
end;

procedure TBasicValidatorTests.EmptyExcludedPathsProducesNoIssues;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '', '', True);
  // Only the DPR warning should be present
  Assert.AreEqual(1, R.Issues.Count);
  Assert.AreEqual('DPR File', R.Issues[0].Field);
end;

procedure TBasicValidatorTests.NonExistentExcludedPathProducesWarningNotError;
var
  V: IBasicValidator;
  R: IValidationResult;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '',
    'C:\NoSuchExcluded_SBOMgenTest', True);
  Assert.IsFalse(R.HasErrors);
  Assert.IsTrue(R.HasWarnings);
end;

procedure TBasicValidatorTests.ExistingExcludedPathProducesNoIssue;
var
  Count: Integer;
  V:     IBasicValidator;
  R:     IValidationResult;
  Issue: IValidationIssue;
begin
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile, '', FTempDir, True);
  Count := 0;
  for Issue in R.Issues do
  begin
    if Issue.Field = 'Excluded Paths' then
      Inc(Count);
  end;
  Assert.AreEqual(0, Count, 'Expected no Excluded Paths errors');
end;

procedure TBasicValidatorTests.AllValidSettingsProducesNoErrors;
var
  V:   IBasicValidator;
  R:   IValidationResult;
  DPR: string;
begin
  DPR := TPath.Combine(FTempDir, 'test.dpr');
  TFile.WriteAllText(DPR, 'program Test;');
  V := TBasicValidator.Create;
  R := V.ValidateBasicSettings('MyProject', FTempDir, FTempFile,
    DPR, FTempDir, True);
  Assert.IsFalse(R.HasErrors);
end;

initialization
  TDUnitX.RegisterTestFixture(TValidationResultTests);
  TDUnitX.RegisterTestFixture(TBasicValidatorTests);

end.
