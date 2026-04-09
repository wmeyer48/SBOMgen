unit u_MetadataEditor;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Behavioural implementation of IMetadataEditor.
  Owns no controls — all controls are injected from the host form,
  which retains ownership and layout responsibility via its DFM.

  License population is decoupled from any specific data source.
  The host form calls PopulateLicenseItems, passing an
  IReadOnlyList<string> built from whatever source is available —
  FireDAC dataset, container service, or static list. The editor
  has no knowledge of SPDX or any license registry.

  Control types used:
    TLabeledEdit — edit fields on both tabs; label and value travel
                   together, placement is atomic, ReadOnly prevents
                   inadvertent editing.
    TComboBox    — license selection; standard VCL sufficient,
                   no Raize-specific behaviour required.
    TMemo        — description field; standard VCL sufficient.
*)

interface

uses
  Spring.Collections,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  i_MetadataViewer;

type
  /// <summary>
  /// Implements IMetadataEditor against controls injected from the
  /// host form. Owns only behavioural concerns — control population,
  /// field value access, button state management, and delegation of
  /// Apply and Revert to IMetadataEditController.
  /// </summary>
  TMetadataEditor = class(TInterfacedObject, IMetadataEditor)
  private
    // Stored as Pointer to avoid a reference cycle between the editor
    // and the controller, which holds an IMetadataEditor reference.
    // Cast back to IMetadataEditController only at the call sites in
    // OnApplyClick and OnRevertClick.
    FController:      Pointer;
    FInitialized:     Boolean;
    FLoading:         Boolean;

    FLblMode:         TLabel;
    FEdtVersion:      TLabeledEdit;
    FEdtSupplier:     TLabeledEdit;
    FEdtSupplierURL:  TLabeledEdit;
    FCmbLicense:      TComboBox;
    FMemoDescription: TMemo;
    FBtnApply:        TButton;
    FBtnRevert:       TButton;

    function  FindLicenseIndex(const ALicenseID: string): Integer;
    procedure SetButtonState(AHasPendingChanges: Boolean);

    procedure OnEditControlChange(Sender: TObject);
    procedure OnApplyClick(Sender: TObject);
    procedure OnRevertClick(Sender: TObject);

  public
    constructor Create(
      ALblMode:         TLabel;
      AEdtVersion:      TLabeledEdit;
      AEdtSupplier:     TLabeledEdit;
      AEdtSupplierURL:  TLabeledEdit;
      ACmbLicense:      TComboBox;
      AMemoDescription: TMemo;
      ABtnApply:        TButton;
      ABtnRevert:       TButton);

    /// <summary>
    /// Completes initialization by storing the controller, wiring
    /// event handlers, and setting initial button state. Must be
    /// called after construction and before the page is shown.
    /// PopulateLicenseItems should be called immediately after.
    /// </summary>
    procedure Initialize(AController: IMetadataEditController);

    procedure PopulateLicenseItems(AItems: IReadOnlyList<string>);
    procedure LoadItem(AItem: IMetadataItem);
    procedure EnterMultiEditMode(ACount: Integer);
    procedure ExitMultiEditMode;
    procedure Clear;
    function  GetVersion:        string;
    function  GetSupplier:       string;
    function  GetSupplierURL:    string;
    function  GetLicense:        string;
    function  GetDescription:    string;
    function  HasPendingChanges: Boolean;
  end;

implementation

uses
  System.SysUtils,
  System.Classes;

{ TMetadataEditor }

constructor TMetadataEditor.Create(
  ALblMode:         TLabel;
  AEdtVersion:      TLabeledEdit;
  AEdtSupplier:     TLabeledEdit;
  AEdtSupplierURL:  TLabeledEdit;
  ACmbLicense:      TComboBox;
  AMemoDescription: TMemo;
  ABtnApply:        TButton;
  ABtnRevert:       TButton);
begin
  inherited Create;

  Assert(Assigned(ALblMode),
    'TMetadataEditor.Create: ALblMode is nil');
  Assert(Assigned(AEdtVersion),
    'TMetadataEditor.Create: AEdtVersion is nil');
  Assert(Assigned(AEdtSupplier),
    'TMetadataEditor.Create: AEdtSupplier is nil');
  Assert(Assigned(AEdtSupplierURL),
    'TMetadataEditor.Create: AEdtSupplierURL is nil');
  Assert(Assigned(ACmbLicense),
    'TMetadataEditor.Create: ACmbLicense is nil');
  Assert(Assigned(AMemoDescription),
    'TMetadataEditor.Create: AMemoDescription is nil');
  Assert(Assigned(ABtnApply),
    'TMetadataEditor.Create: ABtnApply is nil');
  Assert(Assigned(ABtnRevert),
    'TMetadataEditor.Create: ABtnRevert is nil');

  FLblMode         := ALblMode;
  FEdtVersion      := AEdtVersion;
  FEdtSupplier     := AEdtSupplier;
  FEdtSupplierURL  := AEdtSupplierURL;
  FCmbLicense      := ACmbLicense;
  FMemoDescription := AMemoDescription;
  FBtnApply        := ABtnApply;
  FBtnRevert       := ABtnRevert;
end;

procedure TMetadataEditor.Initialize(AController: IMetadataEditController);
begin
  Assert(Assigned(AController),
    'TMetadataEditor.Initialize: AController is nil');

  FController := Pointer(AController);

  // Wire change handlers here — not in the DFM and not in the
  // constructor. Avoids events firing before initialization is
  // complete, and keeps wiring co-located with the guard setup.
  FEdtVersion.OnChange      := OnEditControlChange;
  FEdtSupplier.OnChange     := OnEditControlChange;
  FEdtSupplierURL.OnChange  := OnEditControlChange;
  FCmbLicense.OnChange      := OnEditControlChange;
  FMemoDescription.OnChange := OnEditControlChange;
  FBtnApply.OnClick         := OnApplyClick;
  FBtnRevert.OnClick        := OnRevertClick;

  FLblMode.Visible := False;
  SetButtonState(False);

  FInitialized := True;
end;

procedure TMetadataEditor.PopulateLicenseItems(
  AItems: IReadOnlyList<string>);
var
  Item: string;
begin
  Assert(Assigned(AItems),
    'TMetadataEditor.PopulateLicenseItems: AItems is nil');

  FCmbLicense.Items.BeginUpdate;
  try
    FCmbLicense.Items.Clear;
    for Item in AItems do
      FCmbLicense.Items.Add(Item);
  finally
    FCmbLicense.Items.EndUpdate;
  end;
end;

function TMetadataEditor.FindLicenseIndex(
  const ALicenseID: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FCmbLicense.Items.Count - 1 do
  begin
    if FCmbLicense.Items[I].StartsWith(ALicenseID + ' ') or
       FCmbLicense.Items[I].Equals(ALicenseID) then
      Exit(I);
  end;
end;

procedure TMetadataEditor.SetButtonState(AHasPendingChanges: Boolean);
begin
  FBtnApply.Enabled  := AHasPendingChanges;
  FBtnRevert.Enabled := AHasPendingChanges;
end;

procedure TMetadataEditor.LoadItem(AItem: IMetadataItem);
var
  Index: Integer;
begin
  FLoading := True;
  try
    if not Assigned(AItem) then
    begin
      Clear;
      Exit;
    end;

    FEdtVersion.Text      := AItem.Version;
    FEdtSupplier.Text     := AItem.Supplier;
    FEdtSupplierURL.Text  := AItem.SupplierURL;
    FMemoDescription.Text := AItem.Description;

    Index                 := FindLicenseIndex(AItem.License);
    FCmbLicense.ItemIndex := Index;

    SetButtonState(False);
  finally
    FLoading := False;
  end;
end;

procedure TMetadataEditor.EnterMultiEditMode(ACount: Integer);
begin
  FLoading := True;
  try
    FLblMode.Caption := Format(
      'Editing %d packages — fill fields to update', [ACount]);
    FLblMode.Visible := True;

    FEdtVersion.Text      := '';
    FEdtSupplier.Text     := '';
    FEdtSupplierURL.Text  := '';
    FCmbLicense.ItemIndex := -1;
    FMemoDescription.Text := '';

    // Apply is available immediately in multi-edit — the user
    // may wish to update only one field across all selected items.
    SetButtonState(True);
    FBtnApply.Caption := Format('Apply to %d Packages', [ACount]);
  finally
    FLoading := False;
  end;
end;

procedure TMetadataEditor.ExitMultiEditMode;
begin
  FLblMode.Visible  := False;
  FBtnApply.Caption := 'Apply';
end;

procedure TMetadataEditor.Clear;
begin
  FLoading := True;
  try
    FEdtVersion.Text      := '';
    FEdtSupplier.Text     := '';
    FEdtSupplierURL.Text  := '';
    FCmbLicense.ItemIndex := -1;
    FMemoDescription.Text := '';
    FLblMode.Visible      := False;
    FBtnApply.Caption     := 'Apply';
    SetButtonState(False);
  finally
    FLoading := False;
  end;
end;

function TMetadataEditor.GetVersion: string;
begin
  Result := Trim(FEdtVersion.Text);
end;

function TMetadataEditor.GetSupplier: string;
begin
  Result := Trim(FEdtSupplier.Text);
end;

function TMetadataEditor.GetSupplierURL: string;
begin
  Result := Trim(FEdtSupplierURL.Text);
end;

function TMetadataEditor.GetLicense: string;
begin
  Result := Trim(FCmbLicense.Text);
end;

function TMetadataEditor.GetDescription: string;
begin
  Result := Trim(FMemoDescription.Text);
end;

function TMetadataEditor.HasPendingChanges: Boolean;
begin
  Result := FBtnApply.Enabled;
end;

procedure TMetadataEditor.OnEditControlChange(Sender: TObject);
begin
  if not FInitialized or FLoading then
    Exit;

  SetButtonState(True);
end;

procedure TMetadataEditor.OnApplyClick(Sender: TObject);
begin
  if not FInitialized then
    Exit;

  IMetadataEditController(FController).ApplyRequested;
end;

procedure TMetadataEditor.OnRevertClick(Sender: TObject);
begin
  if not FInitialized then
    Exit;

  IMetadataEditController(FController).RevertRequested;
end;

end.
