unit u_SBOMGenerationService;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines ISBOMGenerationService and its implementation. Orchestrates
  the assembly and serialisation of a CycloneDX 1.6 SBOM from a list
  of detected components.

  Distinct from u_SBOMClasses, which defines the data model and JSON
  serialisation primitives. This unit is concerned with orchestration —
  assembling metadata, components, and the dependency graph, then
  delegating to ISBOMGenerator for output.

  TSBOMGenerationService has no UI dependencies. All inputs are passed
  as parameters and the output file path is returned to the caller.
  Registered as a singleton in the DI container since it holds no
  mutable state between calls.
*)

interface

uses
  Spring.Collections,
  i_SBOMComponent;

type
  /// <summary>
  /// Orchestrates assembly and serialisation of a CycloneDX 1.6 SBOM.
  /// Accepts the project name, author, detected components, and output
  /// file path. Returns True on success, False on failure.
  /// </summary>
  ISBOMGenerationService = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789013}']
    /// <summary>
    /// Generates a CycloneDX 1.6 SBOM from AComponents and writes it
    /// to AOutputFile. AProjectName and AAuthor populate the metadata
    /// section. Returns True on success.
    /// </summary>
    function Generate(
      const AProjectName: string;
      const AAuthor:      string;
            AComponents:  IReadOnlyList<ISBOMComponent>;
      const AOutputFile:  string): Boolean;
  end;

  TSBOMGenerationService = class(TInterfacedObject, ISBOMGenerationService)
  private
    FContainer: TObject;
  public
    constructor Create(AContainer: TObject);

    function Generate(
      const AProjectName: string;
      const AAuthor:      string;
            AComponents:  IReadOnlyList<ISBOMComponent>;
      const AOutputFile:  string): Boolean;
  end;

implementation

uses
  System.SysUtils,
  Spring.Container,
  u_SBOMClasses,
  u_SBOMEnums;

{ TSBOMGenerationService }

constructor TSBOMGenerationService.Create(AContainer: TObject);
begin
  inherited Create;
  FContainer := AContainer;
end;

function TSBOMGenerationService.Generate(
  const AProjectName: string;
  const AAuthor:      string;
        AComponents:  IReadOnlyList<ISBOMComponent>;
  const AOutputFile:  string): Boolean;
var
  SBOMGenerator: ISBOMGenerator;
  Metadata:      ISBOMMetadata;
  Component:     ISBOMComponent;
  DepGraph:      ISBOMDependencyGraph;
  AppBomRef:     string;
begin
  Result := False;

  try
    SBOMGenerator := TContainer(FContainer).Resolve<ISBOMGenerator>;

    Metadata := TSBOMMetadata.Create(AProjectName, '1.0.0', AAuthor);
    SBOMGenerator.SetMetadata(Metadata);

    for Component in AComponents do
      SBOMGenerator.AddComponent(Component);

    // Build the dependency graph — the application component depends
    // on every detected external component.
    AppBomRef := Format('pkg:generic/%s@1.0.0',
      [AProjectName.ToLower.Replace(' ', '-')]);

    DepGraph := TSBOMDependencyGraph.Create;
    for Component in AComponents do
      DepGraph.AddDependency(AppBomRef, Component.BomRef);

    SBOMGenerator.SetDependencyGraph(DepGraph);
    SBOMGenerator.SaveToFile(AOutputFile, ofCycloneDX);

    Result := True;
  except
    // Caller is responsible for display — re-raise so the exception
    // propagates to btnGenerateSBOMClick for user notification.
    raise;
  end;
end;

end.
