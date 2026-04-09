unit f_DeleteProject;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Modal confirmation form for deleting a project and its associated
  SBOM files. The user selects which SBOM files to remove and
  optionally the project file itself. Deletion is permanent.
*)

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.CheckLst,
  Spring.Collections;

type
  TfrmDeleteProject = class(TForm)
    chkListSBOMs:      TCheckListBox;
    btnDelete:         TButton;
    btnCancel:         TButton;
    chkDeleteProject:  TCheckBox;
    lblWarning:        TLabel;
    lblSBOMFiles:      TLabel;
    procedure btnDeleteClick(Sender: TObject);
    procedure chkListSBOMsClickCheck(Sender: TObject);
    procedure chkDeleteProjectClick(Sender: TObject);
  private
    FProjectFolder: string;
    FProjectFile:   string;
    procedure UpdateDeleteButton;
  public
    /// <summary>
    /// Creates and shows the delete confirmation form for the specified
    /// project. Returns True if the user confirmed and deletion proceeded.
    /// </summary>
    class function Execute(
      const AProjectFolder: string;
      const AProjectFile:   string;
      const ASBOMFiles:     IReadOnlyList<string>): Boolean;
  end;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  System.StrUtils,
  System.UITypes,
  Vcl.Dialogs,
  u_Logger;

procedure TfrmDeleteProject.btnDeleteClick(Sender: TObject);
var
  I:             Integer;
  SBOMFile:      string;
  OverridesFile: string;
  DeletedCount:  Integer;
begin
  if MessageDlg(
    'Are you sure you want to delete the selected items? ' +
    'This cannot be undone.',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
  begin
    ModalResult := mrCancel;
    Exit;
  end;

  DeletedCount := 0;

  for I := 0 to chkListSBOMs.Items.Count - 1 do
  begin
    if chkListSBOMs.Checked[I] then
    begin
      SBOMFile := TPath.Combine(FProjectFolder, 'SBOMs',
                                chkListSBOMs.Items[I]);
      if FileExists(SBOMFile) then
      begin
        TFile.Delete(SBOMFile);
        Inc(DeletedCount);
      end;
    end;
  end;

  if chkDeleteProject.Checked then
  begin
    if FileExists(FProjectFile) then
      TFile.Delete(FProjectFile);

    OverridesFile := TPath.Combine(FProjectFolder, 'catalog-overrides.json');
    if FileExists(OverridesFile) then
      TFile.Delete(OverridesFile);
  end;

  SysLog.Add(Format('Deleted %d SBOM file(s)%s',
    [DeletedCount,
     IfThen(chkDeleteProject.Checked, ' and project file', '')]));

  ModalResult := mrOk;
end;

procedure TfrmDeleteProject.chkListSBOMsClickCheck(Sender: TObject);
begin
  UpdateDeleteButton;
end;

procedure TfrmDeleteProject.chkDeleteProjectClick(Sender: TObject);
begin
  UpdateDeleteButton;
end;

procedure TfrmDeleteProject.UpdateDeleteButton;
var
  I:          Integer;
  HasChecked: Boolean;
begin
  HasChecked := chkDeleteProject.Checked;

  if not HasChecked then
  begin
    for I := 0 to chkListSBOMs.Items.Count - 1 do
    begin
      if chkListSBOMs.Checked[I] then
      begin
        HasChecked := True;
        Break;
      end;
    end;
  end;

  btnDelete.Enabled := HasChecked;
end;

class function TfrmDeleteProject.Execute(
  const AProjectFolder: string;
  const AProjectFile:   string;
  const ASBOMFiles:     IReadOnlyList<string>): Boolean;
var
  Form:     TfrmDeleteProject;
  SBOMFile: string;
begin
  Form := TfrmDeleteProject.Create(nil);
  try
    Form.FProjectFolder := AProjectFolder;
    Form.FProjectFile   := AProjectFile;

    for SBOMFile in ASBOMFiles do
      Form.chkListSBOMs.Items.Add(ExtractFileName(SBOMFile));

    Form.UpdateDeleteButton;

    Result := Form.ShowModal = mrOk;
  finally
    Form.Free;
  end;
end;

end.
