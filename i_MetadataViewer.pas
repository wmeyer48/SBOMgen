unit i_MetadataViewer;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Interface definitions for the metadata viewer subsystem.
  No VCL dependencies — fully testable without a UI.

  Declaration order is intentional: each type depends only on
  those declared above it.
*)

interface

uses
  System.Classes,
  Spring.Collections;

type
  /// <summary>
  /// Read-only view of a single metadata item as presented in the
  /// tree and detail panel. IsModified drives bold rendering in
  /// the tree; Name is immutable once loaded.
  /// </summary>
  IMetadataItem = interface
  ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the immutable display name of this metadata item.</summary>
    function GetName:        string;
    /// <summary>Returns the current version string.</summary>
    function GetVersion:     string;
    /// <summary>Returns the current supplier name.</summary>
    function GetSupplier:    string;
    /// <summary>Returns the current supplier URL.</summary>
    function GetSupplierURL: string;
    /// <summary>Returns the current SPDX license identifier.</summary>
    function GetLicense:     string;
    /// <summary>Returns the current description text.</summary>
    function GetDescription: string;
    /// <summary>Returns True if any field has been modified since last load.</summary>
    function GetIsModified:  Boolean;

    /// <summary>Sets the version string.</summary>
    procedure SetVersion(const AValue:     string);
    /// <summary>Sets the supplier name.</summary>
    procedure SetSupplier(const AValue:    string);
    /// <summary>Sets the supplier URL.</summary>
    procedure SetSupplierURL(const AValue: string);
    /// <summary>Sets the SPDX license identifier.</summary>
    procedure SetLicense(const AValue:     string);
    /// <summary>Sets the description text.</summary>
    procedure SetDescription(const AValue: string);

    /// <summary>Immutable display name of this metadata item.</summary>
    property Name:        string  read GetName;
    /// <summary>Version string; editable.</summary>
    property Version:     string  read GetVersion     write SetVersion;
    /// <summary>Supplier name; editable.</summary>
    property Supplier:    string  read GetSupplier    write SetSupplier;
    /// <summary>Supplier URL; editable.</summary>
    property SupplierURL: string  read GetSupplierURL write SetSupplierURL;
    /// <summary>SPDX license identifier; editable.</summary>
    property License:     string  read GetLicense     write SetLicense;
    /// <summary>Description text; editable.</summary>
    property Description: string  read GetDescription write SetDescription;
    /// <summary>True if any field has been modified since last load.</summary>
    property IsModified:  Boolean read GetIsModified;
  end;

  TMetadataAppliedEvent = procedure(AItem: IMetadataItem) of object;

  /// <summary>
  /// Tree view presenting a filtered list of IMetadataItem instances.
  /// Raises OnSelectionChanged when the selection changes; has no
  /// knowledge of the editor or controller.
  /// </summary>
  IMetadataTreeView = interface
  ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    /// <summary>Populates the tree from the supplied read-only item list.</summary>
    procedure LoadItems(AItems: IReadOnlyList<IMetadataItem>);
    /// <summary>Assigns the handler raised when the tree selection changes.</summary>
    procedure SetOnSelectionChanged(AHandler: TNotifyEvent);
    /// <summary>When True, the tree displays only items with incomplete metadata.</summary>
    procedure SetShowIncompleteOnly(AValue: Boolean);
    /// <summary>Repaints all visible nodes without reloading the item list.</summary>
    procedure Refresh;
    /// <summary>Marks the specified items as requiring a repaint.</summary>
    procedure InvalidateItems(AItems: IReadOnlyList<IMetadataItem>);
    /// <summary>Clears any current selection and selects exactly the specified item.</summary>
    procedure SelectSingleItem(AItem: IMetadataItem);
    /// <summary>Returns the currently selected item, or nil if nothing is selected.</summary>
    function  GetSelectedItem:  IMetadataItem;
    /// <summary>Returns a read-only snapshot of all currently selected items.</summary>
    function  GetSelectedItems: IReadOnlyList<IMetadataItem>;
    /// <summary>Returns the count of currently selected items.</summary>
    function  GetSelectedCount: Integer;
  end;

  /// <summary>
  /// Read-only detail display for a single IMetadataItem.
  /// Implemented against TLabeledEdit controls injected from
  /// the host form — owns no layout responsibility.
  /// </summary>
  IMetadataDetailView = interface
  ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    /// <summary>Populates the detail panel with data from the specified item.</summary>
    procedure ShowItem(AItem: IMetadataItem);
    /// <summary>Clears all fields in the detail panel.</summary>
    procedure Clear;
  end;

  /// <summary>
  /// Behavioural editor for one or more IMetadataItem instances.
  /// Owns no controls — all controls are injected from the host form.
  ///
  /// Initialize must be called after construction to wire event
  /// handlers and enable the editor. It is intentionally not part
  /// of this interface to avoid a circular dependency with
  /// IMetadataEditController.
  ///
  /// PopulateLicenseItems decouples the editor from any specific
  /// license data source. The host form is responsible for building
  /// the item list from whatever source is available — FireDAC
  /// dataset, container service, or static list — and passing it in.
  /// </summary>
  IMetadataEditor = interface
  ['{D4E5F6A7-B8C9-0123-DEF0-234567890123}']
    /// <summary>
    /// Populates the license drop-down from the supplied read-only list.
    /// The caller is responsible for sourcing and ordering the items.
    /// </summary>
    procedure PopulateLicenseItems(AItems: IReadOnlyList<string>);
    /// <summary>Loads a single item into the editor controls for editing.</summary>
    procedure LoadItem(AItem: IMetadataItem);
    /// <summary>Switches the editor into multi-edit mode for the specified item count.</summary>
    procedure EnterMultiEditMode(ACount: Integer);
    /// <summary>Returns the editor to single-item mode.</summary>
    procedure ExitMultiEditMode;
    /// <summary>Clears all editor controls.</summary>
    procedure Clear;
    /// <summary>Returns the current value of the Version control.</summary>
    function  GetVersion:     string;
    /// <summary>Returns the current value of the Supplier control.</summary>
    function  GetSupplier:    string;
    /// <summary>Returns the current value of the SupplierURL control.</summary>
    function  GetSupplierURL: string;
    /// <summary>Returns the current value of the License control.</summary>
    function  GetLicense:     string;
    /// <summary>Returns the current value of the Description control.</summary>
    function  GetDescription: string;
    /// <summary>Returns True if any editor control holds an unsaved change.</summary>
    function  HasPendingChanges: Boolean;
  end;

  /// <summary>
  /// Orchestrates the tree view and editor. Owns the apply and
  /// revert logic; fires OnApplied once per item after each
  /// successful apply. Has no VCL dependencies.
  /// </summary>
  IMetadataEditController = interface
  ['{E5F6A7B8-C9D0-1234-EF01-345678901234}']
    /// <summary>
    /// Wires the controller to its collaborating view and editor.
    /// Must be called once after construction before any other method.
    /// </summary>
    procedure Initialize(
      ATreeView:   IMetadataTreeView;
      ADetailView: IMetadataDetailView;
      AEditor:     IMetadataEditor);
    /// <summary>Assigns the handler raised after each successful apply operation.</summary>
    procedure SetOnApplied(AHandler: TMetadataAppliedEvent);
    /// <summary>Called by the host when the tree selection changes.</summary>
    procedure SelectionChanged;
    /// <summary>Applies pending editor changes to all selected items.</summary>
    procedure ApplyRequested;
    /// <summary>Discards pending editor changes and reloads the current selection.</summary>
    procedure RevertRequested;
  end;

implementation

end.
