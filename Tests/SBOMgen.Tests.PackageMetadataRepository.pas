unit SBOMgen.Tests.PackageMetadataRepository;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  DUnitX tests for u_PackageMetadataRepository.
  Covers LoadGlobalMetadata, FindMetadata, FindByUnitName,
  IsSchemaOutdated, MergeBuiltInDefaults, UpdatePackageMetadata
  with user-upd preservation, and IdentifyUnknownPackages.

  Uses Tests\Fixtures\test-metadata.json as the catalog fixture.
  LoadBuiltInDefaults tests use the embedded resource directly.
*)

interface

uses
  DUnitX.TestFramework,
  u_PackageMetadataRepository;

type
  [TestFixture]
  TPackageMetadataRepositoryTests = class
  private
    FRepo:        IPackageMetadataRepository;
    FFixturePath: string;
    FTempDir:     string;
    procedure LoadFixture;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // ── LoadGlobalMetadata ────────────────────────────────────────────────

    [Test]
    procedure LoadGlobalMetadataReturnsTrueOnSuccess;

    [Test]
    procedure LoadGlobalMetadataLoadsCorrectCount;

    [Test]
    procedure LoadGlobalMetadataReadsSchemVersion;

    [Test]
    procedure LoadGlobalMetadataReturnsFalseForMissingFile;

    // ── LoadBuiltInDefaults ───────────────────────────────────────────────

    [Test]
    procedure LoadBuiltInDefaultsReturnsPositiveCount;

    [Test]
    procedure LoadBuiltInDefaultsSetsCurrentSchemaVersion;

    // ── FindMetadata ──────────────────────────────────────────────────────

    [Test]
    procedure FindMetadataReturnsComponentForKnownName;

    [Test]
    procedure FindMetadataReturnsNilForUnknownName;

    [Test]
    procedure FindMetadataIsCaseInsensitive;

    [Test]
    procedure FindMetadataReturnsCorrectSupplier;

    // ── FindByUnitName ────────────────────────────────────────────────────

    [Test]
    procedure FindByUnitNameReturnsComponentForRegisteredUnit;

    [Test]
    procedure FindByUnitNameReturnsNilForUnregisteredUnit;

    [Test]
    procedure FindByUnitNameIsCaseInsensitive;

    [Test]
    procedure FindByUnitNameReturnsCorrectPackage;

    // ── IsSchemaOutdated ──────────────────────────────────────────────────

    [Test]
    procedure IsSchemaOutdatedTrueWhenFileVersionLower;

    [Test]
    procedure IsSchemaOutdatedFalseAfterLoadBuiltInDefaults;

    // ── UpdatePackageMetadata ─────────────────────────────────────────────

    [Test]
    procedure UpdatePackageMetadataUpdatesExistingEntry;

    [Test]
    procedure UpdatePackageMetadataAddsNewEntry;

    [Test]
    procedure UpdatePackageMetadataPreservesUserUpdatedDate;

    [Test]
    procedure UpdatePackageMetadataDoesNotSetUserUpdatedOnFreshEntry;

    // ── MergeBuiltInDefaults ──────────────────────────────────────────────

    [Test]
    procedure MergeBuiltInDefaultsPreservesUserModifiedEntry;

    [Test]
    procedure MergeBuiltInDefaultsReplacesUnmodifiedEntry;

    [Test]
    procedure MergeBuiltInDefaultsAddsNewBuiltInEntries;

    [Test]
    procedure MergeBuiltInDefaultsSetsCurrentSchemaVersion;

    // ── IdentifyUnknownPackages ───────────────────────────────────────────

    [Test]
    procedure IdentifyUnknownPackagesReturnsUnknownSupplier;

    [Test]
    procedure IdentifyUnknownPackagesReturnsNOASSERTIONLicense;

    [Test]
    procedure IdentifyUnknownPackagesSkipsPkgDelphiPrefix;

    [Test]
    procedure IdentifyUnknownPackagesReturnsEmptyForFullyKnown;

    // ── Prefix membership ─────────────────────────────────────────────────

    [Test]
    procedure FindByUnitNameReturnsByPrefixMatch;

    [Test]
    procedure FindByUnitNamePrefixIsCaseSensitive;

    [Test]
    procedure RegisterPrefixMembershipIgnoresDuplicate;

    [Test]
    procedure MergeBuiltInDefaultsPreservesPrefixes;

    [Test]
    procedure SaveAndReloadPreservesPrefixes;

  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Spring.Collections,
  i_SBOMComponent,
  u_SBOMClasses,
  u_SBOMEnums;


{ TPackageMetadataRepositoryTests }

procedure TPackageMetadataRepositoryTests.Setup;
begin
  FRepo := TPackageMetadataRepository.Create;
  FFixturePath := TPath.Combine(
    TPath.GetDirectoryName(ParamStr(0)),
    TPath.Combine('Fixtures', 'test-metadata.json'));
  FTempDir := TPath.Combine(TPath.GetTempPath, 'SBOMgenPMRTests');
  TDirectory.CreateDirectory(FTempDir);
end;

procedure TPackageMetadataRepositoryTests.TearDown;
begin
  if TDirectory.Exists(FTempDir) then
    TDirectory.Delete(FTempDir, True);
end;

procedure TPackageMetadataRepositoryTests.LoadFixture;
begin
  FRepo.LoadGlobalMetadata(FFixturePath);
end;

// ── LoadGlobalMetadata ──────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.LoadGlobalMetadataReturnsTrueOnSuccess;
begin
  Assert.IsTrue(FRepo.LoadGlobalMetadata(FFixturePath));
end;

procedure TPackageMetadataRepositoryTests.LoadGlobalMetadataLoadsCorrectCount;
begin
  FRepo.LoadGlobalMetadata(FFixturePath);
  Assert.AreEqual(4, FRepo.GetPackageCount);
end;

procedure TPackageMetadataRepositoryTests.LoadGlobalMetadataReadsSchemVersion;
begin
  FRepo.LoadGlobalMetadata(FFixturePath);
  // Fixture has schemaVersion: 1 which is outdated — indirect verification
  Assert.IsTrue(FRepo.IsSchemaOutdated);
end;

procedure TPackageMetadataRepositoryTests.LoadGlobalMetadataReturnsFalseForMissingFile;
begin
  Assert.IsFalse(FRepo.LoadGlobalMetadata('C:\NoSuchFile_SBOMgenTest.json'));
end;

// ── LoadBuiltInDefaults ─────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.LoadBuiltInDefaultsReturnsPositiveCount;
begin
  Assert.IsTrue(FRepo.LoadBuiltInDefaults > 0);
end;

procedure TPackageMetadataRepositoryTests.LoadBuiltInDefaultsSetsCurrentSchemaVersion;
begin
  FRepo.LoadBuiltInDefaults;
  Assert.IsFalse(FRepo.IsSchemaOutdated);
end;

// ── FindMetadata ────────────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.FindMetadataReturnsComponentForKnownName;
begin
  LoadFixture;
  Assert.IsNotNull(FRepo.FindMetadata('Spring4D'));
end;

procedure TPackageMetadataRepositoryTests.FindMetadataReturnsNilForUnknownName;
begin
  LoadFixture;
  Assert.IsNull(FRepo.FindMetadata('NoSuchPackage'));
end;

procedure TPackageMetadataRepositoryTests.FindMetadataIsCaseInsensitive;
begin
  LoadFixture;
  Assert.IsNotNull(FRepo.FindMetadata('spring4d'));
  Assert.IsNotNull(FRepo.FindMetadata('SPRING4D'));
end;

procedure TPackageMetadataRepositoryTests.FindMetadataReturnsCorrectSupplier;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  Component := FRepo.FindMetadata('Spring4D');
  Assert.AreEqual('Stefan Glienke', Component.Supplier);
end;

// ── FindByUnitName ──────────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.FindByUnitNameReturnsComponentForRegisteredUnit;
begin
  LoadFixture;
  Assert.IsNotNull(FRepo.FindByUnitName('SVGIconImageList'));
end;

procedure TPackageMetadataRepositoryTests.FindByUnitNameReturnsNilForUnregisteredUnit;
begin
  LoadFixture;
  Assert.IsNull(FRepo.FindByUnitName('NoSuchUnit'));
end;

procedure TPackageMetadataRepositoryTests.FindByUnitNameIsCaseInsensitive;
begin
  LoadFixture;
  Assert.IsNotNull(FRepo.FindByUnitName('svgiconimagelist'));
  Assert.IsNotNull(FRepo.FindByUnitName('HTMLVIEW'));
end;

procedure TPackageMetadataRepositoryTests.FindByUnitNameReturnsCorrectPackage;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  Component := FRepo.FindByUnitName('MarkdownProcessor');
  Assert.AreEqual('SVGIconImageList', Component.Name);
end;

// ── IsSchemaOutdated ────────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.IsSchemaOutdatedTrueWhenFileVersionLower;
begin
  // Fixture has schemaVersion: 1, built-in is higher
  FRepo.LoadGlobalMetadata(FFixturePath);
  Assert.IsTrue(FRepo.IsSchemaOutdated);
end;

procedure TPackageMetadataRepositoryTests.IsSchemaOutdatedFalseAfterLoadBuiltInDefaults;
begin
  FRepo.LoadBuiltInDefaults;
  Assert.IsFalse(FRepo.IsSchemaOutdated);
end;

// ── UpdatePackageMetadata ───────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.UpdatePackageMetadataUpdatesExistingEntry;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  FRepo.UpdatePackageMetadata('Spring4D', '2.0.2', ctLibrary,
    'Stefan Glienke', 'https://bitbucket.org/sglienke/spring4d/',
    'Apache-2.0', 'Updated description');
  Component := FRepo.FindMetadata('Spring4D');
  Assert.AreEqual('2.0.2', Component.Version);
end;

procedure TPackageMetadataRepositoryTests.UpdatePackageMetadataAddsNewEntry;
begin
  LoadFixture;
  FRepo.UpdatePackageMetadata('NewLib', '1.0.0', ctLibrary,
    'Supplier', 'https://example.com', 'MIT', 'New library');
  Assert.IsNotNull(FRepo.FindMetadata('NewLib'));
  Assert.AreEqual(5, FRepo.GetPackageCount);
end;

procedure TPackageMetadataRepositoryTests.UpdatePackageMetadataPreservesUserUpdatedDate;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  // VirtualTrees has user-upd: 2026-01-15 in fixture
  FRepo.UpdatePackageMetadata('VirtualTrees', '8.4', ctLibrary,
    'JAM Software', 'https://github.com/Virtual-TreeView/Virtual-TreeView',
    'MPL-1.1 OR LGPL-2.1-only WITH Classpath-exception-2.0', 'TreeView');
  Component := FRepo.FindMetadata('VirtualTrees');
  Assert.AreEqual('2026-01-15', Component.UserUpdated);
end;

procedure TPackageMetadataRepositoryTests.UpdatePackageMetadataDoesNotSetUserUpdatedOnFreshEntry;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  // Spring4D has no user-upd in fixture
  FRepo.UpdatePackageMetadata('Spring4D', '2.0.2', ctLibrary,
    'Stefan Glienke', 'https://bitbucket.org/sglienke/spring4d/',
    'Apache-2.0', 'Updated');
  Component := FRepo.FindMetadata('Spring4D');
  Assert.AreEqual('', Component.UserUpdated);
end;

// ── MergeBuiltInDefaults ────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.MergeBuiltInDefaultsPreservesUserModifiedEntry;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  // VirtualTrees has user-upd in fixture — merge must not overwrite it
  FRepo.MergeBuiltInDefaults;
  Component := FRepo.FindMetadata('VirtualTrees');
  Assert.IsNotNull(Component);
  Assert.AreEqual('2026-01-15', Component.UserUpdated);
end;

procedure TPackageMetadataRepositoryTests.MergeBuiltInDefaultsReplacesUnmodifiedEntry;
var
  Component: ISBOMComponent;
  BuiltIn:   IPackageMetadataRepository;
begin
  LoadFixture;
  // Spring4D has no user-upd — merge should replace with built-in version
  FRepo.MergeBuiltInDefaults;
  Component := FRepo.FindMetadata('Spring4D');
  Assert.IsNotNull(Component);
  // After merge, Spring4D should match the built-in catalog version
  BuiltIn := TPackageMetadataRepository.Create;
  BuiltIn.LoadBuiltInDefaults;
  Assert.AreEqual(
    (BuiltIn as IPackageMetadataRepository).FindMetadata('Spring4D').Version,
    Component.Version);
end;

procedure TPackageMetadataRepositoryTests.MergeBuiltInDefaultsAddsNewBuiltInEntries;
var
  CountBefore:  Integer;
  BuiltInCount: Integer;
  BuiltIn:      IPackageMetadataRepository;
begin
  LoadFixture;
  CountBefore := FRepo.GetPackageCount;

  BuiltIn := TPackageMetadataRepository.Create;
  BuiltIn.LoadBuiltInDefaults;
  BuiltInCount := (BuiltIn as IPackageMetadataRepository).GetPackageCount;

  FRepo.MergeBuiltInDefaults;

  // After merge the count should be at least as large as the built-in count
  Assert.IsTrue(FRepo.GetPackageCount >= BuiltInCount);
  Assert.IsTrue(FRepo.GetPackageCount >= CountBefore);
end;

procedure TPackageMetadataRepositoryTests.MergeBuiltInDefaultsSetsCurrentSchemaVersion;
begin
  LoadFixture;
  FRepo.MergeBuiltInDefaults;
  Assert.IsFalse(FRepo.IsSchemaOutdated);
end;

// ── IdentifyUnknownPackages ─────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.IdentifyUnknownPackagesReturnsUnknownSupplier;
var
  Detected:   IList<ISBOMComponent>;
  Unknown:    IList<ISBOMComponent>;
  Component:  ISBOMComponent;
begin
  LoadFixture;
  Detected := TCollections.CreateList<ISBOMComponent>;
  Component := TSBOMComponent.Create(
    'pkg:generic/testlib@1.0', 'TestLib', '1.0', ctLibrary,
    'Unknown', '', 'MIT', '');
  Detected.Add(Component);
  Unknown := FRepo.IdentifyUnknownPackages(
    Detected as IReadOnlyList<ISBOMComponent>, '');
  Assert.AreEqual(1, Unknown.Count);
end;

procedure TPackageMetadataRepositoryTests.IdentifyUnknownPackagesReturnsNOASSERTIONLicense;
var
  Detected:  IList<ISBOMComponent>;
  Unknown:   IList<ISBOMComponent>;
  Component: ISBOMComponent;
begin
  LoadFixture;
  Detected := TCollections.CreateList<ISBOMComponent>;
  Component := TSBOMComponent.Create(
    'pkg:generic/testlib@1.0', 'TestLib', '1.0', ctLibrary,
    'Acme', '', 'NOASSERTION', '');
  Detected.Add(Component);
  Unknown := FRepo.IdentifyUnknownPackages(
    Detected as IReadOnlyList<ISBOMComponent>, '');
  Assert.AreEqual(1, Unknown.Count);
end;

procedure TPackageMetadataRepositoryTests.IdentifyUnknownPackagesSkipsPkgDelphiPrefix;
var
  Detected:  IList<ISBOMComponent>;
  Unknown:   IList<ISBOMComponent>;
  Component: ISBOMComponent;
begin
  LoadFixture;
  Detected := TCollections.CreateList<ISBOMComponent>;
  Component := TSBOMComponent.Create(
    'pkg:delphi/rad-studio@29.0', 'Delphi 12 Athens', '29.0',
    ctFramework, 'Embarcadero Technologies', '',
    'LicenseRef-Embarcadero-Proprietary', '');
  Detected.Add(Component);
  Unknown := FRepo.IdentifyUnknownPackages(
    Detected as IReadOnlyList<ISBOMComponent>, '');
  Assert.AreEqual(0, Unknown.Count);
end;

procedure TPackageMetadataRepositoryTests.IdentifyUnknownPackagesReturnsEmptyForFullyKnown;
var
  Detected:  IList<ISBOMComponent>;
  Unknown:   IList<ISBOMComponent>;
  Component: ISBOMComponent;
begin
  LoadFixture;
  Detected := TCollections.CreateList<ISBOMComponent>;
  Component := TSBOMComponent.Create(
    'pkg:generic/spring4d@2.0.1', 'Spring4D', '2.0.1', ctLibrary,
    'Stefan Glienke', 'https://bitbucket.org/sglienke/spring4d/',
    'Apache-2.0', '');
  Detected.Add(Component);
  Unknown := FRepo.IdentifyUnknownPackages(
    Detected as IReadOnlyList<ISBOMComponent>, '');
  Assert.AreEqual(0, Unknown.Count);
end;

// ── Prefix membership ─────────────────────────────────────────────────

procedure TPackageMetadataRepositoryTests.FindByUnitNameReturnsByPrefixMatch;
begin
  LoadFixture;
  // IdHTTP starts with 'Id' — should resolve to Indy via prefix
  Assert.IsNotNull(FRepo.FindByUnitName('IdHTTP'));
  Assert.AreEqual('Indy', FRepo.FindByUnitName('IdHTTP').Name);
end;

procedure TPackageMetadataRepositoryTests.FindByUnitNamePrefixIsCaseSensitive;
begin
  LoadFixture;
  // 'id' does not match prefix 'Id' — case-sensitive
  Assert.IsNull(FRepo.FindByUnitName('idHTTP'));
end;

procedure TPackageMetadataRepositoryTests.RegisterPrefixMembershipIgnoresDuplicate;
begin
  LoadFixture;
  // Indy already has 'Id' registered — registering again must not raise
  Assert.WillNotRaise(
    procedure
    begin
      FRepo.RegisterPrefixMembership('Indy', 'Id');
    end);
  // And still resolves correctly
  Assert.IsNotNull(FRepo.FindByUnitName('IdTCPClient'));
end;

procedure TPackageMetadataRepositoryTests.MergeBuiltInDefaultsPreservesPrefixes;
var
  Component: ISBOMComponent;
begin
  LoadFixture;
  FRepo.MergeBuiltInDefaults;
  // After merge, Indy prefix lookup should still work
  // (built-in catalog also has Id prefix for Indy)
  Component := FRepo.FindByUnitName('IdHTTP');
  Assert.IsNotNull(Component);
  Assert.AreEqual('Indy', Component.Name);
end;

procedure TPackageMetadataRepositoryTests.SaveAndReloadPreservesPrefixes;
var
  TempFile: string;
  Repo2:    IPackageMetadataRepository;
begin
  LoadFixture;
  TempFile := TPath.Combine(FTempDir, 'test-save-prefixes.json');
  FRepo.SaveGlobalMetadata(TempFile);

  Repo2 := TPackageMetadataRepository.Create;
  Repo2.LoadGlobalMetadata(TempFile);

  Assert.IsNotNull(Repo2.FindByUnitName('IdHTTP'));
  Assert.AreEqual('Indy', Repo2.FindByUnitName('IdHTTP').Name);
end;



initialization
  TDUnitX.RegisterTestFixture(TPackageMetadataRepositoryTests);

end.
