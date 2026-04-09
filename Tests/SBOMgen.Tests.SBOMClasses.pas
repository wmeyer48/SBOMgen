unit SBOMgen.Tests.SBOMClasses;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  DUnitX tests for u_SBOMClasses.
  Covers TSBOMComponent construction and hash handling,
  TSBOMDependencyGraph dependency tracking, and TSBOMGenerator
  CycloneDX 1.6 JSON output correctness including license
  expression vs id selection.
*)

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TSBOMComponentTests = class
  public
    [Test]
    procedure ConstructionSetsAllFields;

    [Test]
    procedure AddHashAppendsToHashes;

    [Test]
    procedure AddHashEmptyIsIgnored;

    [Test]
    procedure AddHashMultiple;

    [Test]
    procedure UserUpdatedDefaultsToEmpty;

    [Test]
    procedure SetUserUpdatedStoresValue;
  end;

  [TestFixture]
  TSBOMDependencyGraphTests = class
  public
    [Test]
    procedure AddDependencyStoresDependency;

    [Test]
    procedure AddDependencyDuplicateIsIgnored;

    [Test]
    procedure GetDependenciesReturnsEmptyListForUnknownRef;

    [Test]
    procedure GetAllBomRefsReturnsRegisteredRefs;

    [Test]
    procedure MultipleFromRefsAreIndependent;
  end;

  [TestFixture]
  TSBOMGeneratorTests = class
  public
    // ── Top-level structure ───────────────────────────────────────────────

    [Test]
    procedure OutputContainsBomFormat;

    [Test]
    procedure OutputSpecVersionIs16;

    [Test]
    procedure OutputSerialNumberHasUrnUuidPrefix;

    [Test]
    procedure OutputVersionIs1;

    // ── Metadata ─────────────────────────────────────────────────────────

    [Test]
    procedure MetadataContainsTimestamp;

    [Test]
    procedure MetadataToolNameAndVersionPresent;

    [Test]
    procedure MetadataComponentBomRefIsLowercased;

    // ── Component output ──────────────────────────────────────────────────

    [Test]
    procedure ComponentTypeStringIsLibrary;

    [Test]
    procedure ComponentTypeStringIsFramework;

    [Test]
    procedure ComponentDescriptionOmittedWhenEmpty;

    [Test]
    procedure ComponentDescriptionPresentWhenSet;

    [Test]
    procedure ComponentSupplierURLWrittenAsArray;

    // ── License handling ──────────────────────────────────────────────────

    [Test]
    procedure PlainSPDXLicenseWritesLicenseId;

    [Test]
    procedure LicenseRefWritesExpression;

    [Test]
    procedure NOASSERTIONWritesExpression;

    [Test]
    procedure CompoundORExpressionWritesExpression;

    [Test]
    procedure CompoundANDExpressionWritesExpression;

    [Test]
    procedure CompoundWITHExpressionWritesExpression;

    // ── Hash handling ─────────────────────────────────────────────────────

    [Test]
    procedure HashWrittenWithAlgAndContent;

    [Test]
    procedure ComponentWithNoHashesHasNoHashesKey;

    // ── Dependency graph ──────────────────────────────────────────────────

    [Test]
    procedure DependencySectionPresentWhenGraphSet;

    [Test]
    procedure DependencySectionAbsentWhenNoGraphSet;

    [Test]
    procedure DependencyRefMatchesAppBomRef;
  end;

implementation

uses
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,
  Spring.Collections,
  i_SBOMComponent,
  u_SBOMClasses,
  u_SBOMEnums;

{ TSBOMComponentTests }

procedure TSBOMComponentTests.ConstructionSetsAllFields;
var
  C: ISBOMComponent;
begin
  C := TSBOMComponent.Create(
    'pkg:generic/mylib@1.0', 'MyLib', '1.0', ctLibrary,
    'Acme Corp', 'https://acme.com', 'MIT', 'A library');

  Assert.AreEqual('pkg:generic/mylib@1.0', C.BomRef);
  Assert.AreEqual('MyLib',        C.Name);
  Assert.AreEqual('1.0',          C.Version);
  Assert.AreEqual(ctLibrary,      C.ComponentType);
  Assert.AreEqual('Acme Corp',    C.Supplier);
  Assert.AreEqual('https://acme.com', C.SupplierURL);
  Assert.AreEqual('MIT',          C.LicenseID);
  Assert.AreEqual('A library',    C.Description);
end;

procedure TSBOMComponentTests.AddHashAppendsToHashes;
var
  C: ISBOMComponent;
begin
  C := TSBOMComponent.Create('', 'X', '1.0', ctLibrary, '', '', '', '');
  C.AddHash('SHA-256:abc123');
  Assert.AreEqual(1, C.Hashes.Count);
  Assert.AreEqual('SHA-256:abc123', C.Hashes[0]);
end;

procedure TSBOMComponentTests.AddHashEmptyIsIgnored;
var
  C: ISBOMComponent;
begin
  C := TSBOMComponent.Create('', 'X', '1.0', ctLibrary, '', '', '', '');
  C.AddHash('');
  Assert.AreEqual(0, C.Hashes.Count);
end;

procedure TSBOMComponentTests.AddHashMultiple;
var
  C: ISBOMComponent;
begin
  C := TSBOMComponent.Create('', 'X', '1.0', ctLibrary, '', '', '', '');
  C.AddHash('SHA-256:aaa');
  C.AddHash('SHA-256:bbb');
  Assert.AreEqual(2, C.Hashes.Count);
end;

procedure TSBOMComponentTests.UserUpdatedDefaultsToEmpty;
var
  C: ISBOMComponent;
begin
  C := TSBOMComponent.Create('', 'X', '1.0', ctLibrary, '', '', '', '');
  Assert.AreEqual('', C.UserUpdated);
end;

procedure TSBOMComponentTests.SetUserUpdatedStoresValue;
var
  C: ISBOMComponent;
begin
  C := TSBOMComponent.Create('', 'X', '1.0', ctLibrary, '', '', '', '');
  C.SetUserUpdated('2026-03-24');
  Assert.AreEqual('2026-03-24', C.UserUpdated);
end;

{ TSBOMDependencyGraphTests }

procedure TSBOMDependencyGraphTests.AddDependencyStoresDependency;
var
  G: ISBOMDependencyGraph;
begin
  G := TSBOMDependencyGraph.Create;
  G.AddDependency('app', 'lib1');
  Assert.AreEqual(1, G.GetDependencies('app').Count);
  Assert.AreEqual('lib1', G.GetDependencies('app')[0]);
end;

procedure TSBOMDependencyGraphTests.AddDependencyDuplicateIsIgnored;
var
  G: ISBOMDependencyGraph;
begin
  G := TSBOMDependencyGraph.Create;
  G.AddDependency('app', 'lib1');
  G.AddDependency('app', 'lib1');
  Assert.AreEqual(1, G.GetDependencies('app').Count);
end;

procedure TSBOMDependencyGraphTests.GetDependenciesReturnsEmptyListForUnknownRef;
var
  G: ISBOMDependencyGraph;
begin
  G := TSBOMDependencyGraph.Create;
  Assert.AreEqual(0, G.GetDependencies('nobody').Count);
end;

procedure TSBOMDependencyGraphTests.GetAllBomRefsReturnsRegisteredRefs;
var
  G: ISBOMDependencyGraph;
begin
  G := TSBOMDependencyGraph.Create;
  G.AddDependency('app', 'lib1');
  G.AddDependency('app', 'lib2');
  Assert.AreEqual(1, G.GetAllBomRefs.Count);
  Assert.AreEqual('app', G.GetAllBomRefs[0]);
end;

procedure TSBOMDependencyGraphTests.MultipleFromRefsAreIndependent;
var
  G: ISBOMDependencyGraph;
begin
  G := TSBOMDependencyGraph.Create;
  G.AddDependency('app1', 'lib1');
  G.AddDependency('app2', 'lib2');
  Assert.AreEqual(1, G.GetDependencies('app1').Count);
  Assert.AreEqual(1, G.GetDependencies('app2').Count);
  Assert.AreEqual('lib1', G.GetDependencies('app1')[0]);
  Assert.AreEqual('lib2', G.GetDependencies('app2')[0]);
end;

{ TSBOMGeneratorTests — helpers }

function MakeGenerator(const AAppName, AAppVersion, AAuthor: string): ISBOMGenerator;
var
  Gen:  ISBOMGenerator;
  Meta: ISBOMMetadata;
begin
  Gen  := TSBOMGenerator.Create;
  Meta := TSBOMMetadata.Create(AAppName, AAppVersion, AAuthor);
  Gen.SetMetadata(Meta);
  Result := Gen;
end;

function MakeComponent(const AName, ALicense: string;
  AType: TComponentType = ctLibrary): ISBOMComponent;
begin
  Result := TSBOMComponent.Create(
    'pkg:generic/' + AName.ToLower + '@1.0',
    AName, '1.0', AType,
    'Acme', 'https://acme.com', ALicense, '');
end;

function ParseOutput(const AGenerator: ISBOMGenerator): TJSONObject;
var
  JSON: string;
begin
  JSON   := AGenerator.GenerateCycloneDX;
  Result := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
end;

{ TSBOMGeneratorTests }

procedure TSBOMGeneratorTests.OutputContainsBomFormat;
var
  Gen:  ISBOMGenerator;
  Root: TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Assert.AreEqual('CycloneDX', Root.GetValue<string>('bomFormat'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.OutputSpecVersionIs16;
var
  Gen:  ISBOMGenerator;
  Root: TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Assert.AreEqual('1.6', Root.GetValue<string>('specVersion'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.OutputSerialNumberHasUrnUuidPrefix;
var
  Gen:    ISBOMGenerator;
  Root:   TJSONObject;
  Serial: string;
begin
  Gen    := MakeGenerator('MyApp', '1.0', 'Author');
  Root   := ParseOutput(Gen);
  try
    Serial := Root.GetValue<string>('serialNumber');
    Assert.IsTrue(Serial.StartsWith('urn:uuid:'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.OutputVersionIs1;
var
  Gen:  ISBOMGenerator;
  Root: TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Assert.AreEqual(1, Root.GetValue<Integer>('version'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.MetadataContainsTimestamp;
var
  Gen:      ISBOMGenerator;
  Root:     TJSONObject;
  Metadata: TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Metadata := Root.GetValue<TJSONObject>('metadata');
    Assert.IsNotEmpty(Metadata.GetValue<string>('timestamp'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.MetadataToolNameAndVersionPresent;
var
  Gen:      ISBOMGenerator;
  Root:     TJSONObject;
  Metadata: TJSONObject;
  Tools:    TJSONArray;
  Tool:     TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Metadata := Root.GetValue<TJSONObject>('metadata');
    Tools    := Metadata.GetValue<TJSONArray>('tools');
    Tool     := Tools.Items[0] as TJSONObject;
    Assert.AreEqual('Delphi SBOM Generator', Tool.GetValue<string>('name'));
    Assert.AreEqual('1.0.0', Tool.GetValue<string>('version'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.MetadataComponentBomRefIsLowercased;
var
  Gen:       ISBOMGenerator;
  Root:      TJSONObject;
  Metadata:  TJSONObject;
  Component: TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Metadata  := Root.GetValue<TJSONObject>('metadata');
    Component := Metadata.GetValue<TJSONObject>('component');
    Assert.IsTrue(Component.GetValue<string>('bom-ref').Contains('myapp'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.ComponentTypeStringIsLibrary;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'MIT', ctLibrary));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Assert.AreEqual('library', Comp.GetValue<string>('type'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.ComponentTypeStringIsFramework;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('FwA', 'MIT', ctFramework));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Assert.AreEqual('framework', Comp.GetValue<string>('type'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.ComponentDescriptionOmittedWhenEmpty;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(TSBOMComponent.Create(
    'pkg:generic/x@1.0', 'X', '1.0', ctLibrary,
    'Acme', '', 'MIT', ''));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Assert.IsNull(Comp.GetValue('description'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.ComponentDescriptionPresentWhenSet;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(TSBOMComponent.Create(
    'pkg:generic/x@1.0', 'X', '1.0', ctLibrary,
    'Acme', '', 'MIT', 'A great library'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Assert.AreEqual('A great library', Comp.GetValue<string>('description'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.ComponentSupplierURLWrittenAsArray;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Supplier:   TJSONObject;
  URLs:       TJSONArray;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'MIT'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Supplier   := Comp.GetValue<TJSONObject>('supplier');
    URLs       := Supplier.GetValue<TJSONArray>('url');
    Assert.AreEqual(1, URLs.Count);
    Assert.AreEqual('https://acme.com', URLs.Items[0].Value);
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.PlainSPDXLicenseWritesLicenseId;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Licenses:   TJSONArray;
  LicObj:     TJSONObject;
  LicDetail:  TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'MIT'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Licenses   := Comp.GetValue<TJSONArray>('licenses');
    LicObj     := Licenses.Items[0] as TJSONObject;
    LicDetail  := LicObj.GetValue<TJSONObject>('license');
    Assert.IsNotNull(LicDetail);
    Assert.AreEqual('MIT', LicDetail.GetValue<string>('id'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.LicenseRefWritesExpression;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Licenses:   TJSONArray;
  LicObj:     TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'LicenseRef-Proprietary'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Licenses   := Comp.GetValue<TJSONArray>('licenses');
    LicObj     := Licenses.Items[0] as TJSONObject;
    Assert.IsNull(LicObj.GetValue('license'));
    Assert.AreEqual('LicenseRef-Proprietary',
      LicObj.GetValue<string>('expression'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.NOASSERTIONWritesExpression;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Licenses:   TJSONArray;
  LicObj:     TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'NOASSERTION'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Licenses   := Comp.GetValue<TJSONArray>('licenses');
    LicObj     := Licenses.Items[0] as TJSONObject;
    Assert.AreEqual('NOASSERTION',
      LicObj.GetValue<string>('expression'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.CompoundORExpressionWritesExpression;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Licenses:   TJSONArray;
  LicObj:     TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'MIT OR Apache-2.0'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Licenses   := Comp.GetValue<TJSONArray>('licenses');
    LicObj     := Licenses.Items[0] as TJSONObject;
    Assert.AreEqual('MIT OR Apache-2.0',
      LicObj.GetValue<string>('expression'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.CompoundANDExpressionWritesExpression;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Licenses:   TJSONArray;
  LicObj:     TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'MIT AND Apache-2.0'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Licenses   := Comp.GetValue<TJSONArray>('licenses');
    LicObj     := Licenses.Items[0] as TJSONObject;
    Assert.AreEqual('MIT AND Apache-2.0',
      LicObj.GetValue<string>('expression'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.CompoundWITHExpressionWritesExpression;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Licenses:   TJSONArray;
  LicObj:     TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA',
    'MPL-1.1 OR LGPL-2.1-only WITH Classpath-exception-2.0'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Licenses   := Comp.GetValue<TJSONArray>('licenses');
    LicObj     := Licenses.Items[0] as TJSONObject;
    Assert.AreEqual(
      'MPL-1.1 OR LGPL-2.1-only WITH Classpath-exception-2.0',
      LicObj.GetValue<string>('expression'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.HashWrittenWithAlgAndContent;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
  Hashes:     TJSONArray;
  HashObj:    TJSONObject;
  Component:  ISBOMComponent;
begin
  Gen       := MakeGenerator('MyApp', '1.0', 'Author');
  Component := MakeComponent('LibA', 'MIT');
  Component.AddHash('SHA-256:abc123def456');
  Gen.AddComponent(Component);
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Hashes     := Comp.GetValue<TJSONArray>('hashes');
    HashObj    := Hashes.Items[0] as TJSONObject;
    Assert.AreEqual('SHA-256',      HashObj.GetValue<string>('alg'));
    Assert.AreEqual('abc123def456', HashObj.GetValue<string>('content'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.ComponentWithNoHashesHasNoHashesKey;
var
  Gen:        ISBOMGenerator;
  Root:       TJSONObject;
  Components: TJSONArray;
  Comp:       TJSONObject;
begin
  Gen := MakeGenerator('MyApp', '1.0', 'Author');
  Gen.AddComponent(MakeComponent('LibA', 'MIT'));
  Root := ParseOutput(Gen);
  try
    Components := Root.GetValue<TJSONArray>('components');
    Comp       := Components.Items[0] as TJSONObject;
    Assert.IsNull(Comp.GetValue('hashes'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.DependencySectionPresentWhenGraphSet;
var
  Gen:    ISBOMGenerator;
  Graph:  ISBOMDependencyGraph;
  Root:   TJSONObject;
begin
  Gen   := MakeGenerator('MyApp', '1.0', 'Author');
  Graph := TSBOMDependencyGraph.Create;
  Graph.AddDependency('pkg:generic/myapp@1.0', 'pkg:generic/liba@1.0');
  Gen.SetDependencyGraph(Graph);
  Gen.AddComponent(MakeComponent('LibA', 'MIT'));
  Root := ParseOutput(Gen);
  try
    Assert.IsNotNull(Root.GetValue('dependencies'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.DependencySectionAbsentWhenNoGraphSet;
var
  Gen:  ISBOMGenerator;
  Root: TJSONObject;
begin
  Gen  := MakeGenerator('MyApp', '1.0', 'Author');
  Root := ParseOutput(Gen);
  try
    Assert.IsNull(Root.GetValue('dependencies'));
  finally
    Root.Free;
  end;
end;

procedure TSBOMGeneratorTests.DependencyRefMatchesAppBomRef;
var
  Gen:         ISBOMGenerator;
  Graph:       ISBOMDependencyGraph;
  Root:        TJSONObject;
  Deps:        TJSONArray;
  DepObj:      TJSONObject;
  AppBomRef:   string;
begin
  Gen       := MakeGenerator('MyApp', '1.0', 'Author');
  AppBomRef := 'pkg:generic/myapp@1.0';
  Graph     := TSBOMDependencyGraph.Create;
  Graph.AddDependency(AppBomRef, 'pkg:generic/liba@1.0');
  Gen.SetDependencyGraph(Graph);
  Gen.AddComponent(MakeComponent('LibA', 'MIT'));
  Root := ParseOutput(Gen);
  try
    Deps   := Root.GetValue<TJSONArray>('dependencies');
    DepObj := Deps.Items[0] as TJSONObject;
    Assert.AreEqual(AppBomRef, DepObj.GetValue<string>('ref'));
  finally
    Root.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TSBOMComponentTests);
  TDUnitX.RegisterTestFixture(TSBOMDependencyGraphTests);
  TDUnitX.RegisterTestFixture(TSBOMGeneratorTests);

end.
