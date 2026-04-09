unit f_PrefixEditor;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Prefix editor dialog for the SBOMgen metadata catalog.
  Presents the current prefix list for a named package and
  allows the user to add or delete entries.

  Usage:
    var F := TfrmPrefixEditor.Create(nil);
    try
      F.Caption := 'Edit Prefixes — ' + PackageName;
      F.LoadPrefixes(CurrentPrefixes);
      if F.ShowModal = mrOK then
        NewPrefixes := F.GetPrefixes;
    finally
      F.Free;
    end;
*)

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Spring.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Mask,
  Vcl.StdCtrls,
  RzPanel,
  RzLstBox,
  RzEdit,
  RzButton;

type
  TfrmPrefixEditor = class(TForm)
    lbPrefixes:         TRzListBox;
    lblExistingPrefixes: TLabel;
    RzPanel1:           TRzPanel;
    btnCancel:          TRzButton;
    btnOK:              TRzButton;
    edtPrefix:          TRzEdit;
    btnAdd:             TRzButton;
    btnDelete:          TRzButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtPrefixChange(Sender: TObject);
    procedure lbPrefixesClick(Sender: TObject);
    procedure edtPrefixKeyPress(Sender: TObject; var Key: Char);
  private
    procedure UpdateButtonStates;
  public
    procedure LoadPrefixes(const APrefixes: IReadOnlyList<string>);
    function  GetPrefixes: IList<string>;
  end;

implementation

{$R *.dfm}

{ TfrmPrefixEditor }

procedure TfrmPrefixEditor.LoadPrefixes(
  const APrefixes: IReadOnlyList<string>);
var
  Prefix: string;
begin
  lbPrefixes.Items.Clear;
  if Assigned(APrefixes) then
  begin
    for Prefix in APrefixes do
      lbPrefixes.Items.Add(Prefix);
  end;
  edtPrefix.Clear;
  UpdateButtonStates;
end;

function TfrmPrefixEditor.GetPrefixes: IList<string>;
var
  I: Integer;
begin
  Result := TCollections.CreateList<string>;
  for I := 0 to lbPrefixes.Items.Count - 1 do
    Result.Add(lbPrefixes.Items[I]);
end;

procedure TfrmPrefixEditor.btnAddClick(Sender: TObject);
var
  Prefix: string;
begin
  Prefix := Trim(edtPrefix.Text);
  if Prefix.IsEmpty then
    Exit;
  if lbPrefixes.Items.IndexOf(Prefix) >= 0 then
    Exit;
  lbPrefixes.Items.Add(Prefix);
  edtPrefix.Clear;
  edtPrefix.SetFocus;
  UpdateButtonStates;
end;

procedure TfrmPrefixEditor.btnDeleteClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPrefixes.ItemIndex;
  if Idx < 0 then
    Exit;
  lbPrefixes.Items.Delete(Idx);
  edtPrefix.Clear;
  UpdateButtonStates;
end;

procedure TfrmPrefixEditor.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TfrmPrefixEditor.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmPrefixEditor.edtPrefixChange(Sender: TObject);
begin
  btnAdd.Enabled := not Trim(edtPrefix.Text).IsEmpty;
end;

procedure TfrmPrefixEditor.lbPrefixesClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPrefixes.ItemIndex;
  if Idx >= 0 then
    edtPrefix.Text := lbPrefixes.Items[Idx];
  UpdateButtonStates;
end;

procedure TfrmPrefixEditor.edtPrefixKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnAddClick(Sender);
  end;
end;

procedure TfrmPrefixEditor.UpdateButtonStates;
begin
  btnAdd.Enabled    := not Trim(edtPrefix.Text).IsEmpty;
  btnDelete.Enabled := lbPrefixes.ItemIndex >= 0;
end;

end.
