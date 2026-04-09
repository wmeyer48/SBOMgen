unit u_MetadataViewer;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Implementations of IMetadataTreeView and IMetadataDetailView.

  TMetadataTreeView   — VST-based tree, purely presentational.
                        Raises OnSelectionChanged; has no knowledge
                        of the editor or controller.

  TMetadataDetailView — read-only display using TLabeledEdit controls.
                        Accepts control references from the host form,
                        which owns layout via its DFM. TLabeledEdit is
                        preferred over TLabel pairs — label and value
                        are a single unit, placement is atomic, and
                        ReadOnly prevents inadvertent editing.
*)

interface

uses
  System.Classes,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
  VirtualTrees,
  VirtualTrees.BaseTree,
  VirtualTrees.Types,
  Spring.Collections,
  i_MetadataViewer;

type
  /// <summary>
  /// Node data record for VST — holds a reference to the metadata item
  /// displayed by this node. Reference counting is handled by the
  /// interface; OnFreeNode simply nils the reference.
  /// </summary>
  PMetadataNodeData = ^TMetadataNodeData;
  TMetadataNodeData = record
    Item: IMetadataItem;
  end;

  /// <summary>
  /// VST-based implementation of IMetadataTreeView.
  /// Owns the VST event wiring and node lifecycle.
  /// Selection changes are surfaced via OnSelectionChanged —
  /// the controller is responsible for responding to them.
  /// </summary>
  TMetadataTreeView = class(TInterfacedObject, IMetadataTreeView)
  private
    FVST:                TVirtualStringTree;
    FItems:              IReadOnlyList<IMetadataItem>;
    FOnSelectionChanged: TNotifyEvent;
    FShowIncompleteOnly: Boolean;

    procedure ApplyFilter;
    function  ItemIsIncomplete(AItem: IMetadataItem): Boolean;

    procedure VSTGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure VSTFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VSTChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VSTCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
    procedure VSTPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
  public
    constructor Create(AVST: TVirtualStringTree);

    procedure LoadItems(AItems: IReadOnlyList<IMetadataItem>);
    procedure SetOnSelectionChanged(AHandler: TNotifyEvent);
    procedure SetShowIncompleteOnly(AValue: Boolean);
    procedure Refresh;
    procedure InvalidateItems(AItems: IReadOnlyList<IMetadataItem>);
    procedure SelectSingleItem(AItem: IMetadataItem);
    function  GetSelectedItem:  IMetadataItem;
    function  GetSelectedItems: IReadOnlyList<IMetadataItem>;
    function  GetSelectedCount: Integer;
  end;

  /// <summary>
  /// Read-only display implementation of IMetadataDetailView.
  /// The host form owns and positions all TLabeledEdit controls in
  /// its DFM. This class receives references to those controls and
  /// populates their Text property — it has no layout responsibility.
  ///
  /// TLabeledEdit is preferred over separate TLabel/TEdit pairs:
  /// the label and value travel together, placement is atomic in
  /// the designer, and ReadOnly := True prevents inadvertent editing.
  /// </summary>
  TMetadataDetailView = class(TInterfacedObject, IMetadataDetailView)
  private
    FEdtName:        TLabeledEdit;
    FEdtVersion:     TLabeledEdit;
    FEdtSupplier:    TLabeledEdit;
    FEdtSupplierURL: TLabeledEdit;
    FEdtLicense:     TLabeledEdit;
    FEdtDescription: TLabeledEdit;
  public
    constructor Create(
      AEdtName:        TLabeledEdit;
      AEdtVersion:     TLabeledEdit;
      AEdtSupplier:    TLabeledEdit;
      AEdtSupplierURL: TLabeledEdit;
      AEdtLicense:     TLabeledEdit;
      AEdtDescription: TLabeledEdit);

    procedure ShowItem(AItem: IMetadataItem);
    procedure Clear;
  end;

  /// <summary>
  /// Factory for the metadata viewer subsystem. Assembles the tree
  /// view and detail view; the editor is constructed separately
  /// by the host form since it requires injected controls.
  /// </summary>
  TMetadataViewerFactory = class
  public
    class function CreateTreeView(
      AVST: TVirtualStringTree): IMetadataTreeView;

    class function CreateDetailView(
      AEdtName:        TLabeledEdit;
      AEdtVersion:     TLabeledEdit;
      AEdtSupplier:    TLabeledEdit;
      AEdtSupplierURL: TLabeledEdit;
      AEdtLicense:     TLabeledEdit;
      AEdtDescription: TLabeledEdit): IMetadataDetailView;

    class function CreateController: IMetadataEditController;
  end;

implementation

uses
  System.SysUtils,
  System.UITypes,
  u_MetadataEditController,
  u_Logger;

{ TMetadataTreeView }

constructor TMetadataTreeView.Create(AVST: TVirtualStringTree);
var
  Col: TVirtualTreeColumn;
begin
  inherited Create;
  FVST                := AVST;
  FShowIncompleteOnly := False;

  FVST.NodeDataSize := SizeOf(TMetadataNodeData);

  FVST.TreeOptions.SelectionOptions := FVST.TreeOptions.SelectionOptions
    + [toFullRowSelect, toMultiSelect];

  FVST.Header.Options := FVST.Header.Options
    + [hoVisible, hoColumnResize];

  if FVST.Header.Columns.Count = 0 then
  begin
    Col          := FVST.Header.Columns.Add;
    Col.Position := 0;
    Col.Width    := 200;
    Col.Text     := 'Package Name';

    Col          := FVST.Header.Columns.Add;
    Col.Position := 1;
    Col.Width    := 100;
    Col.Text     := 'Version';

    Col          := FVST.Header.Columns.Add;
    Col.Position := 2;
    Col.Width    := 150;
    Col.Text     := 'Supplier';
  end;

  FVST.OnGetText      := VSTGetText;
  FVST.OnFreeNode     := VSTFreeNode;
  FVST.OnChange       := VSTChange;
  FVST.OnCompareNodes := VSTCompareNodes;
  FVST.OnPaintText    := VSTPaintText;
end;

procedure TMetadataTreeView.LoadItems(AItems: IReadOnlyList<IMetadataItem>);
begin
  FItems := AItems;
  ApplyFilter;
end;

procedure TMetadataTreeView.SetOnSelectionChanged(AHandler: TNotifyEvent);
begin
  FOnSelectionChanged := AHandler;
end;

procedure TMetadataTreeView.SetShowIncompleteOnly(AValue: Boolean);
begin
  if FShowIncompleteOnly <> AValue then
  begin
    FShowIncompleteOnly := AValue;
    ApplyFilter;
  end;
end;

procedure TMetadataTreeView.Refresh;
begin
  FVST.Invalidate;
end;

procedure TMetadataTreeView.InvalidateItems(
  AItems: IReadOnlyList<IMetadataItem>);
var
  Node:     PVirtualNode;
  NodeData: PMetadataNodeData;
  Item:     IMetadataItem;
begin
  for Item in AItems do
  begin
    Node := FVST.GetFirst;
    while Assigned(Node) do
    begin
      NodeData := FVST.GetNodeData(Node);
      if Assigned(NodeData) and (NodeData^.Item = Item) then
      begin
        FVST.InvalidateNode(Node);
        Break;
      end;
      Node := FVST.GetNext(Node);
    end;
  end;
end;

procedure TMetadataTreeView.SelectSingleItem(AItem: IMetadataItem);
var
  Node:     PVirtualNode;
  NodeData: PMetadataNodeData;
begin
  FVST.ClearSelection;
  Node := FVST.GetFirst;
  while Assigned(Node) do
  begin
    NodeData := FVST.GetNodeData(Node);
    if Assigned(NodeData) and (NodeData^.Item = AItem) then
    begin
      FVST.Selected[Node] := True;
      FVST.FocusedNode    := Node;
      Break;
    end;
    Node := FVST.GetNext(Node);
  end;
end;

function TMetadataTreeView.GetSelectedItem: IMetadataItem;
var
  Node:     PVirtualNode;
  NodeData: PMetadataNodeData;
begin
  Result := nil;
  Node   := FVST.GetFirstSelected;
  if Assigned(Node) then
  begin
    NodeData := FVST.GetNodeData(Node);
    if Assigned(NodeData) then
      Result := NodeData^.Item;
  end;
end;

function TMetadataTreeView.GetSelectedItems: IReadOnlyList<IMetadataItem>;
var
  Node:     PVirtualNode;
  NodeData: PMetadataNodeData;
  Items:    IList<IMetadataItem>;
begin
  Items := TCollections.CreateList<IMetadataItem>;
  Node  := FVST.GetFirstSelected;
  while Assigned(Node) do
  begin
    NodeData := FVST.GetNodeData(Node);
    if Assigned(NodeData) and Assigned(NodeData^.Item) then
      Items.Add(NodeData^.Item);
    Node := FVST.GetNextSelected(Node);
  end;
  Result := Items as IReadOnlyList<IMetadataItem>;
end;

function TMetadataTreeView.GetSelectedCount: Integer;
begin
  Result := FVST.SelectedCount;
end;

function TMetadataTreeView.ItemIsIncomplete(AItem: IMetadataItem): Boolean;
begin
  Result :=
    AItem.Supplier.IsEmpty           or
    AItem.Supplier.Equals('Unknown') or
    AItem.License.IsEmpty            or
    AItem.License.Equals('NOASSERTION');
end;

procedure TMetadataTreeView.ApplyFilter;
var
  Item:     IMetadataItem;
  Node:     PVirtualNode;
  NodeData: PMetadataNodeData;
begin
  FVST.BeginUpdate;
  try
    FVST.Clear;
    for Item in FItems do
    begin
      if FShowIncompleteOnly and not ItemIsIncomplete(Item) then
        Continue;

      Node           := FVST.AddChild(nil);
      NodeData       := FVST.GetNodeData(Node);
      NodeData^.Item := Item;
    end;
  finally
    FVST.EndUpdate;
  end;
end;

procedure TMetadataTreeView.VSTGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  NodeData: PMetadataNodeData;
begin
  NodeData := Sender.GetNodeData(Node);
  if not Assigned(NodeData) or not Assigned(NodeData^.Item) then
    Exit;

  case Column of
    0: CellText := NodeData^.Item.Name;
    1: CellText := NodeData^.Item.Version;
    2: CellText := NodeData^.Item.Supplier;
  end;
end;

procedure TMetadataTreeView.VSTFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  NodeData: PMetadataNodeData;
begin
  NodeData := Sender.GetNodeData(Node);
  if Assigned(NodeData) then
  begin
    NodeData^.Item := nil;
  end;
end;

procedure TMetadataTreeView.VSTChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  if Assigned(FOnSelectionChanged) then
  begin
    FOnSelectionChanged(Sender);
  end;
end;

procedure TMetadataTreeView.VSTCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode;
  Column: TColumnIndex; var Result: Integer);
var
  Data1, Data2: PMetadataNodeData;
begin
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);

  if Assigned(Data1) and Assigned(Data2) and
     Assigned(Data1^.Item) and Assigned(Data2^.Item) then
    Result := CompareText(Data1^.Item.Name, Data2^.Item.Name)
  else
    Result := 0;
end;

procedure TMetadataTreeView.VSTPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType);
var
  NodeData: PMetadataNodeData;
begin
  NodeData := Sender.GetNodeData(Node);
  if Assigned(NodeData) and Assigned(NodeData^.Item) then
  begin
    if NodeData^.Item.IsModified then
      TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold]
    else
      TargetCanvas.Font.Style := TargetCanvas.Font.Style - [fsBold];
  end;
end;

{ TMetadataDetailView }

constructor TMetadataDetailView.Create(
  AEdtName:        TLabeledEdit;
  AEdtVersion:     TLabeledEdit;
  AEdtSupplier:    TLabeledEdit;
  AEdtSupplierURL: TLabeledEdit;
  AEdtLicense:     TLabeledEdit;
  AEdtDescription: TLabeledEdit);
begin
  inherited Create;

  Assert(Assigned(AEdtName),
    'TMetadataDetailView.Create: AEdtName is nil');
  Assert(Assigned(AEdtVersion),
    'TMetadataDetailView.Create: AEdtVersion is nil');
  Assert(Assigned(AEdtSupplier),
    'TMetadataDetailView.Create: AEdtSupplier is nil');
  Assert(Assigned(AEdtSupplierURL),
    'TMetadataDetailView.Create: AEdtSupplierURL is nil');
  Assert(Assigned(AEdtLicense),
    'TMetadataDetailView.Create: AEdtLicense is nil');
  Assert(Assigned(AEdtDescription),
    'TMetadataDetailView.Create: AEdtDescription is nil');

  FEdtName        := AEdtName;
  FEdtVersion     := AEdtVersion;
  FEdtSupplier    := AEdtSupplier;
  FEdtSupplierURL := AEdtSupplierURL;
  FEdtLicense     := AEdtLicense;
  FEdtDescription := AEdtDescription;
end;

procedure TMetadataDetailView.ShowItem(AItem: IMetadataItem);
begin
  if not Assigned(AItem) then
  begin
    Clear;
    Exit;
  end;

  FEdtName.Text        := AItem.Name;
  FEdtVersion.Text     := AItem.Version;
  FEdtSupplier.Text    := AItem.Supplier;
  FEdtSupplierURL.Text := AItem.SupplierURL;
  FEdtLicense.Text     := AItem.License;
  FEdtDescription.Text := AItem.Description;
end;

procedure TMetadataDetailView.Clear;
begin
  FEdtName.Text        := '';
  FEdtVersion.Text     := '';
  FEdtSupplier.Text    := '';
  FEdtSupplierURL.Text := '';
  FEdtLicense.Text     := '';
  FEdtDescription.Text := '';
end;

{ TMetadataViewerFactory }

class function TMetadataViewerFactory.CreateTreeView(
  AVST: TVirtualStringTree): IMetadataTreeView;
begin
  Result := TMetadataTreeView.Create(AVST);
end;

class function TMetadataViewerFactory.CreateDetailView(
  AEdtName:        TLabeledEdit;
  AEdtVersion:     TLabeledEdit;
  AEdtSupplier:    TLabeledEdit;
  AEdtSupplierURL: TLabeledEdit;
  AEdtLicense:     TLabeledEdit;
  AEdtDescription: TLabeledEdit): IMetadataDetailView;
begin
  Result := TMetadataDetailView.Create(
    AEdtName, AEdtVersion, AEdtSupplier,
    AEdtSupplierURL, AEdtLicense, AEdtDescription);
end;

class function TMetadataViewerFactory.CreateController: IMetadataEditController;
begin
  Result := TMetadataEditController.Create;
end;

end.
