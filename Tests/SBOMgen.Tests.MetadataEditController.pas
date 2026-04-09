unit SBOMgen.Tests.MetadataEditController;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  DUnitX tests for u_MetadataEditController.TMetadataEditController.
  All VCL dependencies are replaced by in-process stub implementations
  of IMetadataTreeView, IMetadataDetailView, IMetadataEditor, and
  IMetadataItem declared in this unit.
*)

interface

uses
  System.Classes,
  DUnitX.TestFramework;

type
  [TestFixture]
  TMetadataEditControllerTests = class
  public
    // ── SelectionChanged ──────────────────────────────────────────────────

    [Test]
    procedure SelectionChangedWithZeroItemsClearsDetailAndEditor;

    [Test]
    procedure SelectionChangedWithOneItemShowsInDetailAndLoadsEditor;

    [Test]
    procedure SelectionChangedWithMultipleItemsEntersMultiEditMode;

    [Test]
    procedure SelectionChangedWithMultipleItemsClearsDetail;

    // ── ApplyRequested — single item ──────────────────────────────────────

    [Test]
    procedure ApplyRequestedSingleItemUpdatesSupplier;

    [Test]
    procedure ApplyRequestedSingleItemUpdatesLicense;

    [Test]
    procedure ApplyRequestedSingleItemFiresOnApplied;

    [Test]
    procedure ApplyRequestedSingleItemExitsMultiEditMode;

    // ── ApplyRequested — multiple items ───────────────────────────────────

    [Test]
    procedure ApplyRequestedMultipleItemsUpdatesAllSuppliers;

    [Test]
    procedure ApplyRequestedMultipleItemsFiresOnAppliedForEach;

    [Test]
    procedure ApplyRequestedMultipleItemsSkipsEmptyFieldsInMultiEdit;

    // ── RevertRequested ───────────────────────────────────────────────────

    [Test]
    procedure RevertRequestedWithCurrentItemReloadsEditor;

    [Test]
    procedure RevertRequestedWithoutCurrentItemClearsEditor;

    // ── Initialize guards ─────────────────────────────────────────────────

    [Test]
    procedure SelectionChangedBeforeInitializeDoesNothing;

    [Test]
    procedure ApplyRequestedBeforeInitializeDoesNothing;
  end;

implementation

uses
  System.SysUtils,
  Spring.Collections,
  i_MetadataViewer,
  u_MetadataEditController;




// ── Stub: IMetadataItem ─────────────────────────────────────────────────

type
  TApplyCapture = class
    AppliedItem: IMetadataItem;
    ApplyCount:  Integer;
    procedure OnApplied(AItem: IMetadataItem);
  end;

  TStubMetadataItem = class(TInterfacedObject, IMetadataItem)
  private
    FName:        string;
    FVersion:     string;
    FSupplier:    string;
    FSupplierURL: string;
    FLicense:     string;
    FDescription: string;
  public
    constructor Create(const AName: string);

    function  GetName:        string;
    function  GetVersion:     string;
    function  GetSupplier:    string;
    function  GetSupplierURL: string;
    function  GetLicense:     string;
    function  GetDescription: string;
    function  GetIsModified:  Boolean;
    procedure SetVersion(const AValue:     string);
    procedure SetSupplier(const AValue:    string);
    procedure SetSupplierURL(const AValue: string);
    procedure SetLicense(const AValue:     string);
    procedure SetDescription(const AValue: string);
  end;

// ── Stub: IMetadataDetailView ───────────────────────────────────────────

  TStubDetailView = class(TInterfacedObject, IMetadataDetailView)
  public
    ShowItemCallCount: Integer;
    ClearCallCount:    Integer;
    LastItemShown:     IMetadataItem;
    procedure ShowItem(AItem: IMetadataItem);
    procedure Clear;
  end;

// ── Stub: IMetadataEditor ───────────────────────────────────────────────

  TStubEditor = class(TInterfacedObject, IMetadataEditor)
  public
    LoadItemCallCount:        Integer;
    EnterMultiEditCallCount:  Integer;
    ExitMultiEditCallCount:   Integer;
    ClearCallCount:           Integer;
    LastMultiEditCount:       Integer;
    LastItemLoaded:           IMetadataItem;
    // Configurable return values for Get* methods
    StubVersion:     string;
    StubSupplier:    string;
    StubSupplierURL: string;
    StubLicense:     string;
    StubDescription: string;

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

// ── Stub: IMetadataTreeView ─────────────────────────────────────────────

  TStubTreeView = class(TInterfacedObject, IMetadataTreeView)
  public
    InvalidateCallCount:   Integer;
    SelectSingleCallCount: Integer;
    // Configurable selection state
    StubSelectedCount: Integer;
    StubSelectedItem:  IMetadataItem;
    StubSelectedItems: IReadOnlyList<IMetadataItem>;

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

{ TStubMetadataItem }

constructor TStubMetadataItem.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

function TStubMetadataItem.GetName:        string; begin Result := FName;        end;
function TStubMetadataItem.GetVersion:     string; begin Result := FVersion;     end;
function TStubMetadataItem.GetSupplier:    string; begin Result := FSupplier;    end;
function TStubMetadataItem.GetSupplierURL: string; begin Result := FSupplierURL; end;
function TStubMetadataItem.GetLicense:     string; begin Result := FLicense;     end;
function TStubMetadataItem.GetDescription: string; begin Result := FDescription; end;
function TStubMetadataItem.GetIsModified:  Boolean; begin Result := False;       end;

procedure TStubMetadataItem.SetVersion(const AValue:     string); begin FVersion     := AValue; end;
procedure TStubMetadataItem.SetSupplier(const AValue:    string); begin FSupplier    := AValue; end;
procedure TStubMetadataItem.SetSupplierURL(const AValue: string); begin FSupplierURL := AValue; end;
procedure TStubMetadataItem.SetLicense(const AValue:     string); begin FLicense     := AValue; end;
procedure TStubMetadataItem.SetDescription(const AValue: string); begin FDescription := AValue; end;

{ TStubDetailView }

procedure TStubDetailView.ShowItem(AItem: IMetadataItem);
begin
  Inc(ShowItemCallCount);
  LastItemShown := AItem;
end;

procedure TStubDetailView.Clear;
begin
  Inc(ClearCallCount);
end;

{ TStubEditor }

procedure TStubEditor.PopulateLicenseItems(AItems: IReadOnlyList<string>); begin end;

procedure TStubEditor.LoadItem(AItem: IMetadataItem);
begin
  Inc(LoadItemCallCount);
  LastItemLoaded := AItem;
end;

procedure TStubEditor.EnterMultiEditMode(ACount: Integer);
begin
  Inc(EnterMultiEditCallCount);
  LastMultiEditCount := ACount;
end;

procedure TStubEditor.ExitMultiEditMode;
begin
  Inc(ExitMultiEditCallCount);
end;

procedure TStubEditor.Clear;
begin
  Inc(ClearCallCount);
end;

function TStubEditor.GetVersion:        string; begin Result := StubVersion;     end;
function TStubEditor.GetSupplier:       string; begin Result := StubSupplier;    end;
function TStubEditor.GetSupplierURL:    string; begin Result := StubSupplierURL; end;
function TStubEditor.GetLicense:        string; begin Result := StubLicense;     end;
function TStubEditor.GetDescription:    string; begin Result := StubDescription; end;
function TStubEditor.HasPendingChanges: Boolean; begin Result := False;          end;

{ TStubTreeView }

procedure TStubTreeView.LoadItems(AItems: IReadOnlyList<IMetadataItem>); begin end;
procedure TStubTreeView.SetOnSelectionChanged(AHandler: TNotifyEvent);   begin end;
procedure TStubTreeView.SetShowIncompleteOnly(AValue: Boolean);           begin end;
procedure TStubTreeView.Refresh;                                          begin end;

procedure TStubTreeView.InvalidateItems(AItems: IReadOnlyList<IMetadataItem>);
begin
  Inc(InvalidateCallCount);
end;

procedure TStubTreeView.SelectSingleItem(AItem: IMetadataItem);
begin
  Inc(SelectSingleCallCount);
end;

function TStubTreeView.GetSelectedItem:  IMetadataItem;              begin Result := StubSelectedItem;  end;
function TStubTreeView.GetSelectedItems: IReadOnlyList<IMetadataItem>; begin Result := StubSelectedItems; end;
function TStubTreeView.GetSelectedCount: Integer;                     begin Result := StubSelectedCount;  end;

// ── Helpers ─────────────────────────────────────────────────────────────

function MakeController(
  out ATreeView:   TStubTreeView;
  out ADetailView: TStubDetailView;
  out AEditor:     TStubEditor): IMetadataEditController;
var
  Controller: TMetadataEditController;
begin
  ATreeView   := TStubTreeView.Create;
  ADetailView := TStubDetailView.Create;
  AEditor     := TStubEditor.Create;

  Controller  := TMetadataEditController.Create;
  Controller.Initialize(ATreeView, ADetailView, AEditor);
  Result := Controller;
end;

function MakeItem(const AName: string): IMetadataItem;
begin
  Result := TStubMetadataItem.Create(AName);
end;

function MakeSingleSelection(AItem: IMetadataItem;
  out TreeView: TStubTreeView;
  out Detail:   TStubDetailView;
  out Editor:   TStubEditor): IMetadataEditController;
var
  Items: IList<IMetadataItem>;
begin
  Result := MakeController(TreeView, Detail, Editor);
  TreeView.StubSelectedCount := 1;
  TreeView.StubSelectedItem  := AItem;
  Items := TCollections.CreateList<IMetadataItem>;
  Items.Add(AItem);
  TreeView.StubSelectedItems :=
    Items as IReadOnlyList<IMetadataItem>;
end;

function MakeMultiSelection(AItems: IReadOnlyList<IMetadataItem>;
  out TreeView: TStubTreeView;
  out Detail:   TStubDetailView;
  out Editor:   TStubEditor): IMetadataEditController;
begin
  Result := MakeController(TreeView, Detail, Editor);
  TreeView.StubSelectedCount := AItems.Count;
  TreeView.StubSelectedItem  := nil;
  TreeView.StubSelectedItems := AItems;
end;

{ TMetadataEditControllerTests }

procedure TMetadataEditControllerTests.SelectionChangedWithZeroItemsClearsDetailAndEditor;
var
  Controller:  IMetadataEditController;
  TreeView:    TStubTreeView;
  Detail:      TStubDetailView;
  Editor:      TStubEditor;
begin
  Controller := MakeController(TreeView, Detail, Editor);
  TreeView.StubSelectedCount := 0;
  TreeView.StubSelectedItems :=
    TCollections.CreateList<IMetadataItem> as IReadOnlyList<IMetadataItem>;

  Controller.SelectionChanged;

  Assert.AreEqual(1, Detail.ClearCallCount);
  Assert.AreEqual(1, Editor.ClearCallCount);
end;

procedure TMetadataEditControllerTests.SelectionChangedWithOneItemShowsInDetailAndLoadsEditor;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Item:       IMetadataItem;
begin
  Item       := MakeItem('LibA');
  Controller := MakeSingleSelection(Item, TreeView, Detail, Editor);

  Controller.SelectionChanged;

  Assert.AreEqual(1, Detail.ShowItemCallCount);
  Assert.AreEqual(1, Editor.LoadItemCallCount);
  Assert.AreSame(Item, Detail.LastItemShown);
end;

procedure TMetadataEditControllerTests.SelectionChangedWithMultipleItemsEntersMultiEditMode;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Items:      IList<IMetadataItem>;
begin
  Items := TCollections.CreateList<IMetadataItem>;
  Items.Add(MakeItem('LibA'));
  Items.Add(MakeItem('LibB'));
  Controller := MakeMultiSelection(
    Items as IReadOnlyList<IMetadataItem>, TreeView, Detail, Editor);

  Controller.SelectionChanged;

  Assert.AreEqual(1,  Editor.EnterMultiEditCallCount);
  Assert.AreEqual(2,  Editor.LastMultiEditCount);
end;

procedure TMetadataEditControllerTests.SelectionChangedWithMultipleItemsClearsDetail;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Items:      IList<IMetadataItem>;
begin
  Items := TCollections.CreateList<IMetadataItem>;
  Items.Add(MakeItem('LibA'));
  Items.Add(MakeItem('LibB'));
  Controller := MakeMultiSelection(
    Items as IReadOnlyList<IMetadataItem>, TreeView, Detail, Editor);

  Controller.SelectionChanged;

  Assert.AreEqual(1, Detail.ClearCallCount);
end;

procedure TMetadataEditControllerTests.ApplyRequestedSingleItemUpdatesSupplier;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Item:       IMetadataItem;
begin
  Item              := MakeItem('LibA');
  Controller        := MakeSingleSelection(Item, TreeView, Detail, Editor);
  Editor.StubSupplier := 'Acme Corp';

  Controller.SelectionChanged;
  Controller.ApplyRequested;

  Assert.AreEqual('Acme Corp', Item.Supplier);
end;

procedure TMetadataEditControllerTests.ApplyRequestedSingleItemUpdatesLicense;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Item:       IMetadataItem;
begin
  Item             := MakeItem('LibA');
  Controller       := MakeSingleSelection(Item, TreeView, Detail, Editor);
  Editor.StubLicense := 'MIT';

  Controller.SelectionChanged;
  Controller.ApplyRequested;

  Assert.AreEqual('MIT', Item.License);
end;

procedure TMetadataEditControllerTests.ApplyRequestedSingleItemFiresOnApplied;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Item:       IMetadataItem;
  Capture:    TApplyCapture;
begin
  Item       := MakeItem('LibA');
  Controller := MakeSingleSelection(Item, TreeView, Detail, Editor);
  Capture    := TApplyCapture.Create;
  try
    Controller.SetOnApplied(Capture.OnApplied);
    Controller.SelectionChanged;
    Controller.ApplyRequested;
    Assert.AreSame(Item, Capture.AppliedItem);
  finally
    Capture.Free;
  end;
end;

procedure TMetadataEditControllerTests.ApplyRequestedSingleItemExitsMultiEditMode;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Item:       IMetadataItem;
begin
  Item       := MakeItem('LibA');
  Controller := MakeSingleSelection(Item, TreeView, Detail, Editor);

  Controller.SelectionChanged;
  Controller.ApplyRequested;

  Assert.IsTrue(Editor.ExitMultiEditCallCount > 0);
end;

procedure TMetadataEditControllerTests.ApplyRequestedMultipleItemsUpdatesAllSuppliers;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  ItemA:      IMetadataItem;
  ItemB:      IMetadataItem;
  Items:      IList<IMetadataItem>;
begin
  ItemA := MakeItem('LibA');
  ItemB := MakeItem('LibB');
  Items := TCollections.CreateList<IMetadataItem>;
  Items.Add(ItemA);
  Items.Add(ItemB);
  Controller := MakeMultiSelection(
    Items as IReadOnlyList<IMetadataItem>, TreeView, Detail, Editor);
  Editor.StubSupplier := 'Acme Corp';

  Controller.SelectionChanged;
  Controller.ApplyRequested;

  Assert.AreEqual('Acme Corp', ItemA.Supplier);
  Assert.AreEqual('Acme Corp', ItemB.Supplier);
end;

procedure TMetadataEditControllerTests.ApplyRequestedMultipleItemsFiresOnAppliedForEach;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Items:      IList<IMetadataItem>;
  Capture:    TApplyCapture;
begin
  Items := TCollections.CreateList<IMetadataItem>;
  Items.Add(MakeItem('LibA'));
  Items.Add(MakeItem('LibB'));
  Items.Add(MakeItem('LibC'));
  Controller := MakeMultiSelection(
    Items as IReadOnlyList<IMetadataItem>, TreeView, Detail, Editor);
  Capture := TApplyCapture.Create;
  try
    Controller.SetOnApplied(Capture.OnApplied);
    Controller.SelectionChanged;
    Controller.ApplyRequested;
    Assert.AreEqual(3, Capture.ApplyCount);
  finally
    Capture.Free;
  end;
end;

procedure TMetadataEditControllerTests.ApplyRequestedMultipleItemsSkipsEmptyFieldsInMultiEdit;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  ItemA:      IMetadataItem;
  Items:      IList<IMetadataItem>;
begin
  ItemA := MakeItem('LibA');
  ItemA.Supplier := 'Original';
  Items := TCollections.CreateList<IMetadataItem>;
  Items.Add(ItemA);
  Items.Add(MakeItem('LibB'));
  Controller := MakeMultiSelection(
    Items as IReadOnlyList<IMetadataItem>, TreeView, Detail, Editor);
  // Empty supplier in multi-edit should not overwrite existing value
  Editor.StubSupplier := '';

  Controller.SelectionChanged;
  Controller.ApplyRequested;

  Assert.AreEqual('Original', ItemA.Supplier);
end;

procedure TMetadataEditControllerTests.RevertRequestedWithCurrentItemReloadsEditor;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
  Item:       IMetadataItem;
begin
  Item       := MakeItem('LibA');
  Controller := MakeSingleSelection(Item, TreeView, Detail, Editor);

  Controller.SelectionChanged;
  // Reset counter after SelectionChanged loaded the item
  Editor.LoadItemCallCount := 0;

  Controller.RevertRequested;

  Assert.AreEqual(1, Editor.LoadItemCallCount);
end;

procedure TMetadataEditControllerTests.RevertRequestedWithoutCurrentItemClearsEditor;
var
  Controller: IMetadataEditController;
  TreeView:   TStubTreeView;
  Detail:     TStubDetailView;
  Editor:     TStubEditor;
begin
  Controller := MakeController(TreeView, Detail, Editor);
  // No SelectionChanged called — FCurrentItem is nil
  Controller.RevertRequested;

  Assert.AreEqual(1, Editor.ClearCallCount);
end;

procedure TMetadataEditControllerTests.SelectionChangedBeforeInitializeDoesNothing;
var
  Controller: TMetadataEditController;
begin
  Controller := TMetadataEditController.Create;
  try
    Assert.WillNotRaise(
      procedure
      begin
        Controller.SelectionChanged;
      end);
  finally
    Controller.Free;
  end;
end;

procedure TMetadataEditControllerTests.ApplyRequestedBeforeInitializeDoesNothing;
var
  Controller: TMetadataEditController;
begin
  Controller := TMetadataEditController.Create;
  try
    Assert.WillNotRaise(
      procedure
      begin
        Controller.ApplyRequested;
      end);
  finally
    Controller.Free;
  end;
end;

procedure TApplyCapture.OnApplied(AItem: IMetadataItem);
begin
  AppliedItem := AItem;
  Inc(ApplyCount);
end;

initialization
  TDUnitX.RegisterTestFixture(TMetadataEditControllerTests);

end.
