unit i_PackageDataset;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Narrow interface over the package metadata dataset.
  Abstracts FireDAC and VCL dependencies from units that need
  to read and write package data without knowing about
  TFDMemTable or d_Metadata directly.

  IBookmarkedMetadataItem extends IMetadataItem with a TBookmark
  for write-back. It is declared here rather than in
  i_MetadataViewer because the bookmark concept belongs to the
  dataset layer, not to the general metadata viewer contract.
*)

interface

uses
  Data.DB,
  i_MetadataViewer;

type
  /// <summary>
  /// Extends IMetadataItem with a dataset bookmark, allowing the
  /// write-back path to navigate to the originating record without
  /// casting interface references to concrete types.
  /// </summary>
  IBookmarkedMetadataItem = interface(IMetadataItem)
  ['{A7B8C9D0-E1F2-3456-0123-567890123456}']
    /// <summary>Returns the dataset bookmark for the originating record.</summary>
    /// <remark>The caller is responsible to call FreeBookmark after use.</remark>
    function GetBookmark: TBookmark;
    /// <summary>Dataset bookmark for the originating record.</summary>
    property Bookmark: TBookmark read GetBookmark;
  end;

  /// <summary>
  /// Narrow abstraction over the package metadata dataset.
  /// Consumers navigate, read, and write through this interface
  /// with no knowledge of FireDAC, TFDMemTable, or d_Metadata.
  /// </summary>
  IPackageDataset = interface
  ['{B8C9D0E1-F2A3-4567-1234-678901234567}']
    /// <summary>Returns a bookmark for the current dataset record.</summary>
    function  GetCurrentBookmark: TBookmark;
    /// <summary>Navigates the dataset to the record identified by the supplied bookmark.</summary>
    procedure GotoBookmark(const ABookmark: TBookmark);
    /// <summary>Releases a bookmark previously obtained from GetCurrentBookmark.</summary>
    procedure FreeBookmark(const ABookmark: TBookmark);
    /// <summary>Returns the value of the named field from the current record.</summary>
    /// <remarks>Call GotoBookmark before ReadFieldAsString to ensure the correct record is current.</remarks>
    function  ReadFieldAsString(const AFieldName: string): string;

    /// <summary>Writes edited values back to the record identified by the supplied bookmark.</summary>
    /// <remarks>
    /// Only the four user-editable fields are written: Supplier, SupplierURL,
    /// LicenseID, and Description.
    /// </remarks>
    procedure ApplyItemValues(
      const ABookmark:    TBookmark;
      const AVersion:     string;
      const ASupplier:    string;
      const ASupplierURL: string;
      const ALicenseID:   string;
      const ADescription: string);

    /// <summary>Disables dataset-linked controls during a batch update.</summary>
    procedure DisableControls;
    /// <summary>Re-enables dataset-linked controls after a batch update.</summary>
    procedure EnableControls;

    /// <summary>Applies a filter showing only packages with incomplete metadata.</summary>
    procedure ShowIncompleteOnly;
    /// <summary>Removes any active filter, showing all packages.</summary>
    procedure ShowAllPackages;

    /// <summary>Reverts all pending changes, restoring the dataset to its last saved state.</summary>
    procedure RevertPackages;

    /// <summary>Returns True if the dataset contains no records.</summary>
    function  IsEmpty: Boolean;
  end;

implementation

end.
