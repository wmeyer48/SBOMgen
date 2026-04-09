unit u_SBOMEnums;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.
*)

interface

type
  /// <summary>Component types as defined by the CycloneDX specification.</summary>
  TComponentType = (
    ctApplication,
    ctFramework,
    ctLibrary,
    ctContainer,
    ctDevice,
    ctFile,
    ctFirmware,
    ctOperatingSystem,
    ctVCLComponent,
    ctFMXComponent,
    ctDesignTime
  );

  /// <summary>Selects the output format for SBOM generation.</summary>
  TOutputFormat = (
    ofCycloneDX
  );

  /// <summary>Indicates whether a component originates inside or outside the application.</summary>
  TComponentScope = (csInternal, csExternal);

  /// <summary>Broad classification of an external component's origin.</summary>
  TComponentCategory = (
    ccDelphiRTL,     // System.*, Winapi.*
    ccDelphiVCL,     // Vcl.*
    ccDelphiFireDAC, // FireDAC.*
    ccThirdParty,    // VirtualTreeView, SynEdit, etc.
    ccInternal       // Internal application units
  );

implementation

end.
