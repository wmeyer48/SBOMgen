unit f_ValidationResults;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Displays validation issues from an IValidationResult in a modal
  list. Errors and warnings are prefixed for quick scanning.
  The Copy button places all issues on the clipboard as plain text.
*)

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  RzButton,
  RzPanel,
  u_SBOMValidation;

type
  TfrmValidationResults = class(TForm)
    lstIssues: TListBox;
    lblTitle:  TLabel;
    RzPanel1:  TRzPanel;
    btnOK:     TRzButton;
    btnCopy:   TRzButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
  private
    procedure LoadIssues(AResult: IValidationResult);
  public
    /// <summary>
    /// Creates a validation results form, populates it from AResult,
    /// shows it modally, and returns the modal result.
    /// </summary>
    class function ShowValidation(
      AResult: IValidationResult): TModalResult;
  end;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Clipbrd;

procedure TfrmValidationResults.FormCreate(Sender: TObject);
begin
  lstIssues.Clear;
end;

procedure TfrmValidationResults.LoadIssues(AResult: IValidationResult);
var
  Issue:  IValidationIssue;
  Prefix: string;
begin
  lstIssues.Clear;

  if AResult.HasErrors then
    lblTitle.Caption := Format(
      '%d Error(s) Found — Cannot Generate SBOM', [AResult.ErrorCount])
  else if AResult.HasWarnings then
    lblTitle.Caption := Format(
      '%d Warning(s) Found', [AResult.WarningCount])
  else
    lblTitle.Caption := 'Validation Passed';

  for Issue in AResult.Issues do
  begin
    case Issue.Severity of
      vsError:   Prefix := '[ERROR] ';
      vsWarning: Prefix := '[WARN]  ';
      vsInfo:    Prefix := '[INFO]  ';
    end;

    if not Issue.Field.IsEmpty then
      lstIssues.Items.Add(
        Format('%s%s: %s', [Prefix, Issue.Field, Issue.Message]))
    else
      lstIssues.Items.Add(Prefix + Issue.Message);
  end;
end;

procedure TfrmValidationResults.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText := lstIssues.Items.Text;
end;

class function TfrmValidationResults.ShowValidation(
  AResult: IValidationResult): TModalResult;
var
  Form: TfrmValidationResults;
begin
  Form := TfrmValidationResults.Create(nil);
  try
    Form.LoadIssues(AResult);
    Result := Form.ShowModal;
  finally
    Form.Free;
  end;
end;

end.
