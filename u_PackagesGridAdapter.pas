unit u_PackagesGridAdapter;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Adapts TRzDBGrid + IPackageDataset to IMetadataTreeView,
  allowing TMetadataEditController to drive the Packages tab
  using the same controller pattern as the AppCode tab.

  TPackageDatasetItem — snapshot of one dataset record at the
    time of selection. Implements IBookmarkedMetadataItem,
    capturing field values so the cursor can move freely.
    The bookmark is used for write-back by the host form's
    OnPackageItemApplied handler.

  TPackagesGridAdapter — implements IMetadataTreeView over a
    TRzDBGrid backed by IPackageDataset. GetSelectedItems
    returns TPackageDatasetItem instances for each selected
    row, or the current row if nothing is explicitly selected,
    preserving prior single-record apply behaviour.

  Write-back responsibility belongs to the host form, which
  holds both the repository and the metadata file path.
  The adapter is responsible only for selection and navigation.
*)

interface

uses
  System.Classes,
  Data.DB,
  RzDBGrid,
  Spring.Collections,
  i_MetadataViewer,
  i_PackageDataset;

type
  /// <summary>
  /// Snapshot of a single dataset record identified by bookmark.
  /// Implements IBookmarkedMetadataItem — the bookmark allows
  /// the write-back path to navigate without knowing the
  /// concrete type. IsModified is set True by any setter call.
  /// </summary>
  TPackageDatasetItem = class(TInterfacedObject,
    IMetadataItem, IBookmarkedMetadataItem)
  private
    FBookmark:    TBookmark;
    FName:        string;
    FVersion:     string;
    FSupplier:    string;
    FSupplierURL: string;
    FLicense:     string;
    FDescription: string;
    FIsModified:  Boolean;

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

  public
    constructor Create(
      const ABookmark:    TBookmark;
      const AName:        string;
      const AVersion:     string;
      const ASupplier:    string;
      const ASupplierURL: string;
      const ALicense:     string;
      const ADescription: string);

    function GetBookmark: TBookmark;
  end;

  /// <summary>
  /// Adapts TRzDBGrid and IPackageDataset to IMetadataTreeView.
  /// The controller sees a uniform interface regardless of whether
  /// the backing store is an in-memory collection (AppCode tab)
  /// or a FireDAC dataset (Packages tab).
  ///
  /// Write-back on apply is handled by the host form via its
  /// OnPackageItemApplied handler, which holds the repository
  /// and file path. The adapter owns selection and navigation only.
  /// </summary>
  TPackagesGridAdapter = class(TInterfacedObject, IMetadataTreeView)
  private
    FGrid:               TRzDBGrid;
    FDataset:            IPackageDataset;
    FOnSelectionChanged: TNotifyEvent;

    function BuildItemFromCurrentRecord: IMetadataItem;

  public
    constructor Create(
      AGrid:    TRzDBGrid;
      ADataset: IPackageDataset);

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

implementation

uses
  System.SysUtils;

{ TPackageDatasetItem }

constructor TPackageDatasetItem.Create(
  const ABookmark:    TBookmark;
  const AName:        string;
  const AVersion:     string;
  const ASupplier:    string;
  const ASupplierURL: string;
  const ALicense:     string;
  const ADescription: string);
begin
  inherited Create;
  FBookmark    := ABookmark;
  FName        := AName;
  FVersion     := AVersion;
  FSupplier    := ASupplier;
  FSupplierURL := ASupplierURL;
  FLicense     := ALicense;
  FDescription := ADescription;
  FIsModified  := False;
end;

function TPackageDatasetItem.GetBookmark: TBookmark;
begin
  Result := FBookmark;
end;

function TPackageDatasetItem.GetName: string;
begin
  Result := FName;
end;

function TPackageDatasetItem.GetVersion: string;
begin
  Result := FVersion;
end;

function TPackageDatasetItem.GetSupplier: string;
begin
  Result := FSupplier;
end;

function TPackageDatasetItem.GetSupplierURL: string;
begin
  Result := FSupplierURL;
end;

function TPackageDatasetItem.GetLicense: string;
begin
  Result := FLicense;
end;

function TPackageDatasetItem.GetDescription: string;
begin
  Result := FDescription;
end;

function TPackageDatasetItem.GetIsModified: Boolean;
begin
  Result := FIsModified;
end;

procedure TPackageDatasetItem.SetVersion(const AValue: string);
begin
  FVersion    := AValue;
  FIsModified := True;
end;

procedure TPackageDatasetItem.SetSupplier(const AValue: string);
begin
  FSupplier   := AValue;
  FIsModified := True;
end;

procedure TPackageDatasetItem.SetSupplierURL(const AValue: string);
begin
  FSupplierURL := AValue;
  FIsModified  := True;
end;

procedure TPackageDatasetItem.SetLicense(const AValue: string);
begin
  FLicense    := AValue;
  FIsModified := True;
end;

procedure TPackageDatasetItem.SetDescription(const AValue: string);
begin
  FDescription := AValue;
  FIsModified  := True;
end;

{ TPackagesGridAdapter }

constructor TPackagesGridAdapter.Create(
  AGrid:    TRzDBGrid;
  ADataset: IPackageDataset);
begin
  inherited Create;

  Assert(Assigned(AGrid),
    'TPackagesGridAdapter.Create: AGrid is nil');
  Assert(Assigned(ADataset),
    'TPackagesGridAdapter.Create: ADataset is nil');

  FGrid    := AGrid;
  FDataset := ADataset;
end;

function TPackagesGridAdapter.BuildItemFromCurrentRecord: IMetadataItem;
begin
  Result := TPackageDatasetItem.Create(
    FDataset.GetCurrentBookmark,
    FDataset.ReadFieldAsString('Name'),
    FDataset.ReadFieldAsString('Version'),
    FDataset.ReadFieldAsString('Supplier'),
    FDataset.ReadFieldAsString('SupplierURL'),
    FDataset.ReadFieldAsString('LicenseID'),
    FDataset.ReadFieldAsString('Description'));
end;

procedure TPackagesGridAdapter.LoadItems(
  AItems: IReadOnlyList<IMetadataItem>);
begin
  // Dataset-backed adapter — the grid is already bound to the dataset.
  // LoadItems is intentionally a no-op; the dataset drives the grid.
end;

procedure TPackagesGridAdapter.SetOnSelectionChanged(AHandler: TNotifyEvent);
begin
  FOnSelectionChanged := AHandler;
end;

procedure TPackagesGridAdapter.SetShowIncompleteOnly(AValue: Boolean);
begin
  if AValue then
    FDataset.ShowIncompleteOnly
  else
    FDataset.ShowAllPackages;
end;

procedure TPackagesGridAdapter.Refresh;
begin
  FGrid.Refresh;
end;

procedure TPackagesGridAdapter.InvalidateItems(
  AItems: IReadOnlyList<IMetadataItem>);
begin
  FGrid.Refresh;
end;

procedure TPackagesGridAdapter.SelectSingleItem(AItem: IMetadataItem);
var
  Bookmarked: IBookmarkedMetadataItem;
begin
  if not Assigned(AItem) then
    Exit;

  if Supports(AItem, IBookmarkedMetadataItem, Bookmarked) then
    FDataset.GotoBookmark(Bookmarked.Bookmark);
end;

function TPackagesGridAdapter.GetSelectedItem: IMetadataItem;
begin
  if FDataset.IsEmpty then
    Exit(nil);

  Result := BuildItemFromCurrentRecord;
end;

function TPackagesGridAdapter.GetSelectedItems: IReadOnlyList<IMetadataItem>;
var
  I:            Integer;
  RowMark:      TBookmark;
  CurrentMark:  TBookmark;
  CurrentFound: Boolean;
  Items:        IList<IMetadataItem>;
begin
  Items := TCollections.CreateList<IMetadataItem>;

  if not FDataset.IsEmpty then
  begin
    CurrentMark  := FDataset.GetCurrentBookmark;
    CurrentFound := False;
    try
      for I := 0 to FGrid.SelectedRows.Count - 1 do
      begin
        RowMark := FGrid.SelectedRows[I];
        if CompareMem(Pointer(RowMark), Pointer(CurrentMark),
                      Length(RowMark)) then
          CurrentFound := True;
        FDataset.GotoBookmark(RowMark);
        Items.Add(BuildItemFromCurrentRecord);
      end;

      if not CurrentFound then
      begin
        FDataset.GotoBookmark(CurrentMark);
        Items.Add(BuildItemFromCurrentRecord);
      end;
    finally
      FDataset.FreeBookmark(CurrentMark);
    end;
  end;

  Result := Items as IReadOnlyList<IMetadataItem>;
end;

function TPackagesGridAdapter.GetSelectedCount: Integer;
var
  CurrentMark: TBookmark;
  I:           Integer;
  RowMark:     TBookmark;
  CurrentFound: Boolean;
begin
  if FDataset.IsEmpty then
    Exit(0);

  CurrentMark  := FDataset.GetCurrentBookmark;
  CurrentFound := False;
  Result       := 0;

  try
    for I := 0 to FGrid.SelectedRows.Count - 1 do
    begin
      RowMark := FGrid.SelectedRows[I];
      Inc(Result);
      if CompareMem(Pointer(RowMark), Pointer(CurrentMark), Length(RowMark)) then
        CurrentFound := True;
    end;

    // Current row is not in SelectedRows — add it.
    if not CurrentFound then
      Inc(Result);
  finally
    FDataset.FreeBookmark(CurrentMark);
  end;
end;

end.
