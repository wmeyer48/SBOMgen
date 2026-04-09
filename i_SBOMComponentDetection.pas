unit i_SBOMComponentDetection;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Interface definitions for the component detection subsystem.
  Covers module classification, Delphi version resolution, and
  the top-level detection orchestrator.
  No VCL dependencies — fully testable without a UI.

  Declaration order is intentional: each type depends only on
  those declared above it.
*)

interface

uses
  Spring.Collections,
  i_AmbiguousUnit,
  i_SBOMComponent,
  u_DelphiVersionDetector_2,
  u_SBOMEnums;

type
  /// <summary>Represents a single parsed module entry from a MAP file report.</summary>
  IModuleInfo = interface
    ['{E5F6A7B8-C9D0-1234-EF12-345678901234}']
    /// <summary>Returns the Delphi unit name of this module.</summary>
    function GetUnitName: string;
    /// <summary>Returns the resolved file path of this module.</summary>
    function GetFilePath: string;
    /// <summary>Returns whether this module is internal or external to the application.</summary>
    function GetScope: TComponentScope;
    /// <summary>Returns the broad category of this module's origin.</summary>
    function GetCategory: TComponentCategory;
    /// <summary>Returns the package name this module belongs to, if known.</summary>
    function GetPackageName: string;

    /// <summary>Delphi unit name of this module.</summary>
    property UnitName: string read GetUnitName;
    /// <summary>Resolved file path of this module.</summary>
    property FilePath: string read GetFilePath;
    /// <summary>Whether this module is internal or external to the application.</summary>
    property Scope: TComponentScope read GetScope;
    /// <summary>Broad category of this module's origin.</summary>
    property Category: TComponentCategory read GetCategory;
    /// <summary>Package name this module belongs to, if known.</summary>
    property PackageName: string read GetPackageName;
  end;

  /// <summary>Carries resolved version and path information for an installed Delphi IDE.</summary>
  IDelphiVersion = interface
    ['{F6A7B8C9-D0E1-2345-F123-456789012345}']
    /// <summary>Returns the CycloneDX BOM reference for this Delphi version.</summary>
    function GetBomRef: string;
    /// <summary>Returns the precise build version string, e.g. "29.0.55362.2017".</summary>
    function GetBuildVersion: string;
    /// <summary>Returns the major version number.</summary>
    function GetMajorVersion: Integer;
    /// <summary>Returns the marketing product name, e.g. "Delphi 12 Athens".</summary>
    function GetProductName: string;
    /// <summary>Returns the root installation path of this Delphi version.</summary>
    function GetStudioPath: string;
    /// <summary>CycloneDX BOM reference for this Delphi version.</summary>
    property BomRef: string read GetBomRef;
    /// <summary>Precise build version string, e.g. "29.0.55362.2017".</summary>
    property BuildVersion: string read GetBuildVersion;
    /// <summary>Major version number.</summary>
    property MajorVersion: Integer read GetMajorVersion;
    /// <summary>Marketing product name, e.g. "Delphi 12 Athens".</summary>
    property ProductName: string read GetProductName;
    /// <summary>Root installation path of this Delphi version.</summary>
    property StudioPath: string read GetStudioPath;
  end;

  /// <summary>Orchestrates the end-to-end component detection process.</summary>
  IComponentDetector = interface
    ['{F2A3B4C5-D6E7-8901-6789-012345678901}']
    /// <summary>
    /// Parses the supplied MAP file and returns the list of detected SBOM components.
    /// AVersionInfo is used to correlate Delphi RTL and VCL units.
    /// </summary>
    function DetectComponents(const AMapFile: string;
      AVersionInfo: IDelphiVersionInfo): IList<ISBOMComponent>;
    /// <summary>Returns the resolved Delphi version used during the last detection run.</summary>
    function GetDelphiVersion: IDelphiVersion;
    /// <summary>Returns a read-only list of all internal modules identified during detection.</summary>
    function GetInternalModules: IReadOnlyList<IModuleInfo>;
    /// <summary>
    /// Returns the list of ambiguous units found during the last detection run.
    /// An empty list means no disambiguation is required.
    /// </summary>
    function GetAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>;
    /// <summary>Sets the path prefixes used to distinguish internal from external modules.</summary>
    procedure SetInternalPathPrefixes(const APrefixes: IReadOnlyList<string>);
  end;

implementation

end.
