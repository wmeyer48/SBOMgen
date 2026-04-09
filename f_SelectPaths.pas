unit f_SelectPaths;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Modal path selection form. Presents a list of semicolon-delimited
  folder paths that the user can add, remove, and reorder.
  Returns the final list via GetSelectedPaths.
*)

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Mask,
  Vcl.StdCtrls,
  RzButton,
  RzLabel,
  RzLstBox,
  RzPanel,
  RzShellDialogs,
  System.ImageList,
  Vcl.BaseImageCollection,
  Vcl.ImageCollection,
  Vcl.ImgList,
  Vcl.VirtualImageList,
  SVGIconImageListBase,
  SVGIconImageList;

type
  TfSelectPaths = class(TForm)
    pnlTop:            TRzPanel;
    RzPanel2:          TRzPanel;
    pnlBottom:         TRzPanel;
    lbPaths:           TRzListBox;
    pnlSelect:         TRzPanel;
    edtPath:           TLabeledEdit;
    lblListOfPaths:    TRzLabel;
    pnlRight:          TRzPanel;
    btnSelectPath:     TRzButton;
    btnOK:             TRzButton;
    btnCancel:         TRzButton;
    RzPanel1:          TRzPanel;
    btnAdd:            TRzButton;
    btnDelete:         TRzButton;
    btnMoveUp:         TRzBitBtn;
    btnMoveDown:       TRzBitBtn;
    SVGIconImageList1: TSVGIconImageList;
    dlgSelFolder:      TRzSelectFolderDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnSelectPathClick(Sender: TObject);
  end;

/// <summary>
/// Creates and shows the path selection form modally, pre-populated
/// with ACurrentPaths. Returns the updated semicolon-delimited path
/// list on OK, or ACurrentPaths unchanged on Cancel.
/// </summary>
function GetSelectedPaths(const ATitle, ACurrentPaths: string): string;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  System.StrUtils,
  Vcl.Dialogs;

function GetSelectedPaths(const ATitle, ACurrentPaths: string): string;
var
  Form: TfSelectPaths;
begin
  Form := TfSelectPaths.Create(nil);
  try
    Form.Caption := ATitle;
    Form.lbPaths.Items.DelimitedText :=
      IfThen(ACurrentPaths = 'C:\', '', ACurrentPaths);

    if Form.ShowModal = mrOK then
      Result := Form.lbPaths.Items.DelimitedText
    else
      Result := ACurrentPaths;
  finally
    Form.Free;
  end;
end;

procedure TfSelectPaths.FormCreate(Sender: TObject);
begin
  lbPaths.Items.StrictDelimiter := True;
  lbPaths.Items.Delimiter       := ';';
end;

procedure TfSelectPaths.btnAddClick(Sender: TObject);
begin
  if not string(edtPath.Text).IsEmpty then
  begin
    if DirectoryExists(edtPath.Text) then
      lbPaths.Items.Add(edtPath.Text)
    else
      ShowMessage('Path not found.');
  end;
end;

procedure TfSelectPaths.btnDeleteClick(Sender: TObject);
var
  Idx: Integer;
begin
  if (not string(edtPath.Text).IsEmpty) and
     (lbPaths.ItemIndex >= 0) and
     (lbPaths.ItemIndex < lbPaths.Count) then
  begin
    Idx := lbPaths.ItemIndex;
    lbPaths.Items.Delete(Idx);
    if Idx < lbPaths.Count then
      lbPaths.ItemIndex := Idx;
  end;
end;

procedure TfSelectPaths.btnMoveDownClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPaths.ItemIndex;
  if Idx < (lbPaths.Count - 1) then
  begin
    lbPaths.Items.Move(Idx, Idx + 1);
    lbPaths.ItemIndex := Idx + 1;
  end;
end;

procedure TfSelectPaths.btnMoveUpClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPaths.ItemIndex;
  if Idx > 0 then
  begin
    lbPaths.Items.Move(Idx, Idx - 1);
    lbPaths.ItemIndex := Idx - 1;
  end;
end;

procedure TfSelectPaths.btnSelectPathClick(Sender: TObject);
begin
  dlgSelFolder.Title := 'Select a folder';
  if not lbPaths.SelectedItem.IsEmpty then
    dlgSelFolder.SelectedPathName := lbPaths.SelectedItem;

  if dlgSelFolder.Execute then
  begin
    if not string(dlgSelFolder.SelectedPathName).IsEmpty then
      edtPath.Text := dlgSelFolder.SelectedPathName;
  end;
end;

end.
