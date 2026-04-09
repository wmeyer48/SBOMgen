unit i_SBOMComponent;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines the core public interfaces for the SBOMgen system.
  These contracts cover component representation, SBOM metadata,
  dependency graph management, and output generation in CycloneDX
  format.
*)

interface

uses
  Spring.Collections,
  u_SBOMEnums;

type
/// <summary>Represents a single component entry in the SBOM.</summary>
  /// <remarks>
  /// Most properties are read-only, established at construction time.
  /// Hashes are added incrementally via AddHash after construction.
  /// UserUpdated is set by the metadata editor when the user modifies
  /// a catalog entry — its presence marks the entry as user-owned and
  /// protects it from being overwritten by catalog schema upgrades.
  /// </remarks>
  ISBOMComponent = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the unique BOM reference identifier for this component.</summary>
    function GetBomRef: string;
    /// <summary>Returns the component display name.</summary>
    function GetName: string;
    /// <summary>Returns the component version string.</summary>
    function GetVersion: string;
    /// <summary>Returns the CycloneDX component type classification.</summary>
    function GetComponentType: TComponentType;
    /// <summary>Returns the name of the component supplier or vendor.</summary>
    function GetSupplier: string;
    /// <summary>Returns the URL of the component supplier or vendor.</summary>
    function GetSupplierURL: string;
    /// <summary>Returns the SPDX license identifier for this component.</summary>
    function GetLicenseID: string;
    /// <summary>Returns a short description of the component.</summary>
    function GetDescription: string;
    /// <summary>Returns the read-only list of SHA-256 hashes associated with this component.</summary>
    function GetHashes: IReadOnlyList<string>;
    /// <summary>
    /// Returns the ISO 8601 date string recording when the user last
    /// edited this catalog entry. Empty for unmodified built-in entries.
    /// </summary>
    function GetUserUpdated: string;

    /// <summary>Adds a hash string to this component. Ignored if AHash is empty.</summary>
    procedure AddHash(const AHash: string);
    /// <summary>
    /// Marks this entry as user-owned by recording the edit date.
    /// Once set, catalog schema upgrades will not overwrite this entry.
    /// </summary>
    procedure SetUserUpdated(const AValue: string);

    /// <summary>Unique BOM reference identifier for this component.</summary>
    property BomRef: string read GetBomRef;
    /// <summary>Component display name.</summary>
    property Name: string read GetName;
    /// <summary>Component version string.</summary>
    property Version: string read GetVersion;
    /// <summary>CycloneDX component type classification.</summary>
    property ComponentType: TComponentType read GetComponentType;
    /// <summary>Name of the component supplier or vendor.</summary>
    property Supplier: string read GetSupplier;
    /// <summary>URL of the component supplier or vendor.</summary>
    property SupplierURL: string read GetSupplierURL;
    /// <summary>SPDX license identifier for this component.</summary>
    property LicenseID: string read GetLicenseID;
    /// <summary>Short description of the component.</summary>
    property Description: string read GetDescription;
    /// <summary>Read-only list of SHA-256 hashes associated with this component.</summary>
    property Hashes: IReadOnlyList<string> read GetHashes;
    /// <summary>
    /// ISO 8601 date string of last user edit. Empty for built-in entries.
    /// Presence protects this entry from catalog schema upgrade replacement.
    /// </summary>
    property UserUpdated: string read GetUserUpdated write SetUserUpdated;
  end;

  /// <summary>Carries SBOM metadata describing the application under analysis.</summary>
  /// <remarks>
  /// All properties are read-only. Metadata state is established at
  /// construction time by the implementing class.
  /// </remarks>
  ISBOMMetadata = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    /// <summary>Returns the name of the application being analyzed.</summary>
    function GetApplicationName: string;
    /// <summary>Returns the version of the application being analyzed.</summary>
    function GetApplicationVersion: string;
    /// <summary>Returns the name of the SBOM author.</summary>
    function GetAuthor: string;
    /// <summary>Returns the timestamp at which the SBOM was generated.</summary>
    function GetTimestamp: TDateTime;
    /// <summary>Returns the name of the tool that generated the SBOM.</summary>
    function GetToolName: string;
    /// <summary>Returns the version of the tool that generated the SBOM.</summary>
    function GetToolVersion: string;

    /// <summary>Name of the application being analyzed.</summary>
    property ApplicationName: string read GetApplicationName;
    /// <summary>Version of the application being analyzed.</summary>
    property ApplicationVersion: string read GetApplicationVersion;
    /// <summary>Name of the SBOM author.</summary>
    property Author: string read GetAuthor;
    /// <summary>Timestamp at which the SBOM was generated.</summary>
    property Timestamp: TDateTime read GetTimestamp;
    /// <summary>Name of the tool that generated the SBOM.</summary>
    property ToolName: string read GetToolName;
    /// <summary>Version of the tool that generated the SBOM.</summary>
    property ToolVersion: string read GetToolVersion;
  end;

  /// <summary>Models the dependency relationships between SBOM components.</summary>
  ISBOMDependencyGraph = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    /// <summary>Records a dependency relationship from one BOM reference to another.</summary>
    /// <param name="AFrom">The BOM reference of the dependent component.</param>
    /// <param name="ATo">The BOM reference of the dependency being declared.</param>
    procedure AddDependency(const AFrom, ATo: string);
    /// <summary>Returns all BOM references that the specified component depends upon.</summary>
    /// <param name="ABomRef">The BOM reference of the component to query.</param>
    function GetDependencies(const ABomRef: string): IList<string>;
    /// <summary>Returns all BOM references registered in the dependency graph.</summary>
    function GetAllBomRefs: IList<string>;
  end;

  /// <summary>Generates SBOM output in CycloneDX format.</summary>
  ISBOMGenerator = interface
    ['{D4E5F6A7-B8C9-0123-DEF1-234567890123}']
    /// <summary>Assigns the SBOM metadata to be included in generated output.</summary>
    procedure SetMetadata(const AMetadata: ISBOMMetadata);
    /// <summary>Adds a component to the SBOM being assembled.</summary>
    procedure AddComponent(const AComponent: ISBOMComponent);
    /// <summary>Assigns the dependency graph to be included in generated output.</summary>
    procedure SetDependencyGraph(const AGraph: ISBOMDependencyGraph);
    /// <summary>Generates and returns the SBOM as a CycloneDX-format JSON string.</summary>
    function GenerateCycloneDX: string;
    /// <summary>Generates and writes the SBOM to the specified file.</summary>
    /// <param name="AFileName">Fully qualified output file path.</param>
    /// <param name="AFormat">Output format selector. Defaults to CycloneDX.</param>
    procedure SaveToFile(const AFileName: string;
      const AFormat: TOutputFormat = ofCycloneDX);
  end;

implementation

end.
