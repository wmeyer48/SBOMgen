unit u_MetadataEditController;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Controller for metadata editing operations. Owns the coordination
  between tree selection and editor state, edit mode determination,
  field application logic, and persistence sequencing.

  No VCL dependencies — this unit is testable without a UI.
*)

interface

uses
  Spring.Collections,
  i_MetadataViewer;

type
  /// <summary>
  /// Implements edit coordination for the metadata viewer subsystem.
  /// Wired to a tree view and an editor via Initialize; neither
  /// component holds a reference to the other.
  /// </summary>
  TMetadataEditController = class(TInterfacedObject, IMetadataEditController)
  private
    FTreeView:    IMetadataTreeView;
    FDetailView:  IMetadataDetailView;
    FEditor:      IMetadataEditor;
    FOnApplied:   TMetadataAppliedEvent;
    FInitialized: Boolean;
    FCurrentItem: IMetadataItem;

    procedure ApplySingleItem(const AVersion, ASupplier, ASupplierURL,
        ALicense, ADescription: string);
    procedure ApplyMultipleItems(AItems: IReadOnlyList<IMetadataItem>;
        const AVersion, ASupplier, ASupplierURL, ALicense, ADescription: string);
    procedure ApplyFieldsToItem(AItem: IMetadataItem; ASingleEdit: Boolean;
        const AVersion, ASupplier, ASupplierURL, ALicense, ADescription: string);
  public
    procedure Initialize(
      ATreeView:   IMetadataTreeView;
      ADetailView: IMetadataDetailView;
      AEditor:     IMetadataEditor);
    procedure SetOnApplied(AEvent: TMetadataAppliedEvent);
    procedure SelectionChanged;
    procedure ApplyRequested;
    procedure RevertRequested;
  end;

implementation

uses
  System.SysUtils,
  u_Logger;

{ TMetadataEditController }

procedure TMetadataEditController.Initialize(
  ATreeView:   IMetadataTreeView;
  ADetailView: IMetadataDetailView;
  AEditor:     IMetadataEditor);
begin
  Assert(Assigned(ATreeView),
    'TMetadataEditController.Initialize: ATreeView is nil');
  Assert(Assigned(ADetailView),
    'TMetadataEditController.Initialize: ADetailView is nil');
  Assert(Assigned(AEditor),
    'TMetadataEditController.Initialize: AEditor is nil');

  FTreeView    := ATreeView;
  FDetailView  := ADetailView;
  FEditor      := AEditor;
  FInitialized := True;
end;

procedure TMetadataEditController.SetOnApplied(AEvent: TMetadataAppliedEvent);
begin
  FOnApplied := AEvent;
end;

procedure TMetadataEditController.SelectionChanged;
var
  Count: Integer;
  Item:  IMetadataItem;
begin
  if not FInitialized then
    Exit;

  Count := FTreeView.GetSelectedCount;

  if Count = 0 then
  begin
    FCurrentItem := nil;
    FDetailView.Clear;
    FEditor.Clear;
    Exit;
  end;

  if Count = 1 then
  begin
    Item         := FTreeView.GetSelectedItem;
    FCurrentItem := Item;
    FDetailView.ShowItem(Item);
    FEditor.LoadItem(Item);
    FEditor.ExitMultiEditMode;
  end
  else
  begin
    FCurrentItem := nil;
    FDetailView.Clear;
    FEditor.EnterMultiEditMode(Count);
  end;
end;

procedure TMetadataEditController.ApplyRequested;
var
  SelectedItems: IReadOnlyList<IMetadataItem>;
  Version:       string;
  Supplier:      string;
  SupplierURL:   string;
  License:       string;
  Description:   string;
begin
  if not FInitialized then
    Exit;

  // Snapshot editor values BEFORE GetSelectedItems navigates
  // the dataset, which would trigger SelectionChanged and
  // reload the editor with the pre-edit values.
  Version     := FEditor.GetVersion;
  Supplier    := FEditor.GetSupplier;
  SupplierURL := FEditor.GetSupplierURL;
  License     := FEditor.GetLicense;
  Description := FEditor.GetDescription;

  SelectedItems := FTreeView.GetSelectedItems;

  if SelectedItems.Count = 1 then
    ApplySingleItem(Version, Supplier, SupplierURL, License, Description)
  else if SelectedItems.Count > 1 then
    ApplyMultipleItems(SelectedItems,
      Version, Supplier, SupplierURL, License, Description);
end;

procedure TMetadataEditController.ApplySingleItem(
  const AVersion, ASupplier, ASupplierURL,
        ALicense, ADescription: string);
var
  SingleItemList: IList<IMetadataItem>;
begin
  if not Assigned(FCurrentItem) then
  begin
    SysLog.Add('TMetadataEditController.ApplySingleItem: FCurrentItem is nil');
    Exit;
  end;

  ApplyFieldsToItem(FCurrentItem, True,
    AVersion, ASupplier, ASupplierURL, ALicense, ADescription);

  if Assigned(FOnApplied) then
    FOnApplied(FCurrentItem);

  FEditor.ExitMultiEditMode;
  FEditor.LoadItem(FCurrentItem);

  SingleItemList := TCollections.CreateList<IMetadataItem>;
  SingleItemList.Add(FCurrentItem);
  FTreeView.InvalidateItems(
    SingleItemList as IReadOnlyList<IMetadataItem>);
end;

procedure TMetadataEditController.ApplyMultipleItems(
  AItems: IReadOnlyList<IMetadataItem>;
  const AVersion, ASupplier, ASupplierURL,
        ALicense, ADescription: string);
var
  Item: IMetadataItem;
begin
  for Item in AItems do
  begin
    ApplyFieldsToItem(Item, False,
      AVersion, ASupplier, ASupplierURL, ALicense, ADescription);

    if Assigned(FOnApplied) then
      FOnApplied(Item);
  end;

  FEditor.ExitMultiEditMode;
  FTreeView.InvalidateItems(AItems);

  if AItems.Count > 0 then
    FTreeView.SelectSingleItem(AItems.First);
end;

procedure TMetadataEditController.ApplyFieldsToItem(
  AItem: IMetadataItem; ASingleEdit: Boolean;
  const AVersion, ASupplier, ASupplierURL,
        ALicense, ADescription: string);

  procedure ApplyField(
    const AValue: string;
          ASetProc: TProc<string>);
  begin
    if ASingleEdit then
      ASetProc(AValue.Trim)
    else
    begin
      if not AValue.Trim.IsEmpty then
        ASetProc(AValue.Trim);
    end;
  end;

begin
  ApplyField(AVersion,
    procedure(V: string) begin AItem.Version     := V; end);
  ApplyField(ASupplier,
    procedure(V: string) begin AItem.Supplier    := V; end);
  ApplyField(ASupplierURL,
    procedure(V: string) begin AItem.SupplierURL := V; end);
  ApplyField(ALicense,
    procedure(V: string) begin AItem.License     := V; end);
  ApplyField(ADescription,
    procedure(V: string) begin AItem.Description := V; end);
end;

procedure TMetadataEditController.RevertRequested;
begin
  if not FInitialized then
    Exit;

  if Assigned(FCurrentItem) then
    FEditor.LoadItem(FCurrentItem)
  else
    FEditor.Clear;
end;

end.
