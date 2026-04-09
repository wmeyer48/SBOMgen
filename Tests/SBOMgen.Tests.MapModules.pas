unit SBOMgen.Tests.MapModules;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  DUnitX tests for u_MapModules.TMapModuleParser.
  Uses Tests\Fixtures\SBOMgen.map as the reference MAP file.
  Module names confirmed present in the fixture:
    d_Metadata, u_SBOMClasses, u_DelphiVersionDetector_2, u_SBOMValidation
*)

interface

uses
  DUnitX.TestFramework,
  u_MapModules;

type
  [TestFixture]
  TMapModuleParserTests = class
  private
    FParser:     IMapModuleParser;
    FFixtureMap: string;
    FTempDir:    string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ── ParseMapFile ──────────────────────────────────────────────────────

    [Test]
    procedure ParseMapFileReturnsNonEmptyListForValidFile;

    [Test]
    procedure ParseMapFileReturnsEmptyListForMissingFile;

    [Test]
    procedure ParseMapFileContainsKnownModule_dMetadata;

    [Test]
    procedure ParseMapFileContainsKnownModule_uSBOMClasses;

    [Test]
    procedure ParseMapFileContainsKnownModule_uDelphiVersionDetector2;

    [Test]
    procedure ParseMapFileContainsKnownModule_uSBOMValidation;

    [Test]
    procedure ParseMapFileDeduplicatesModules;

    [Test]
    procedure ParseMapFileResultIsReadOnly;

    // ── BuildModuleFileDictionary ─────────────────────────────────────────

    [Test]
    procedure BuildModuleFileDictionaryPopulatesDictionary;

    [Test]
    procedure BuildModuleFileDictionarySkipsNonExistentFolders;

    [Test]
    procedure BuildModuleFileDictionarySkipsEmptyFolderEntry;

    [Test]
    procedure BuildModuleFileDictionaryClearsOnRebuild;

    // ── GetModuleFilePath ─────────────────────────────────────────────────

    [Test]
    procedure GetModuleFilePathReturnsPathForKnownModule;

    [Test]
    procedure GetModuleFilePathReturnsEmptyForUnknownModule;

    [Test]
    procedure GetModuleFilePathIsCaseInsensitive;

    // ── GetDictionaryCount ────────────────────────────────────────────────

    [Test]
    procedure GetDictionaryCountReturnsZeroInitially;

    [Test]
    procedure GetDictionaryCountReflectsLoadedFiles;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,
  Spring.Collections;

{ TMapModuleParserTests }

procedure TMapModuleParserTests.Setup;
begin
  FParser := TMapModuleParser.Create;

  FFixtureMap := TPath.Combine(
    TPath.GetDirectoryName(ParamStr(0)),
    TPath.Combine('Fixtures', 'SBOMgen.map'));

  FTempDir := TPath.Combine(TPath.GetTempPath,
    'SBOMgenMapTests_' + IntToStr(GetCurrentProcessId));
  TDirectory.CreateDirectory(FTempDir);

  TFile.WriteAllText(TPath.Combine(FTempDir, 'u_Alpha.pas'), 'unit u_Alpha;');
  TFile.WriteAllText(TPath.Combine(FTempDir, 'u_Beta.pas'),  'unit u_Beta;');
  TFile.WriteAllText(TPath.Combine(FTempDir, 'u_Gamma.pas'), 'unit u_Gamma;');
end;

procedure TMapModuleParserTests.TearDown;
begin
  if TDirectory.Exists(FTempDir) then
    TDirectory.Delete(FTempDir, True);
end;

// ── ParseMapFile ────────────────────────────────────────────────────────

procedure TMapModuleParserTests.ParseMapFileReturnsNonEmptyListForValidFile;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Assert.IsTrue(Modules.Count > 0);
end;

procedure TMapModuleParserTests.ParseMapFileReturnsEmptyListForMissingFile;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile('C:\NoSuchFile_SBOMgenTest.map');
  Assert.AreEqual(0, Modules.Count);
end;

procedure TMapModuleParserTests.ParseMapFileContainsKnownModule_dMetadata;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Assert.IsTrue(Modules.Contains('d_Metadata'));
end;

procedure TMapModuleParserTests.ParseMapFileContainsKnownModule_uSBOMClasses;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Assert.IsTrue(Modules.Contains('u_SBOMClasses'));
end;

procedure TMapModuleParserTests.ParseMapFileContainsKnownModule_uDelphiVersionDetector2;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Assert.IsTrue(Modules.Contains('u_DelphiVersionDetector_2'));
end;

procedure TMapModuleParserTests.ParseMapFileContainsKnownModule_uSBOMValidation;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Assert.IsTrue(Modules.Contains('u_SBOMValidation'));
end;

procedure TMapModuleParserTests.ParseMapFileDeduplicatesModules;
var
  Modules: IReadOnlyList<string>;
  Name:    string;
  Seen:    ISet<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Seen    := TCollections.CreateSet<string>(
    TStringComparer.OrdinalIgnoreCase);
  for Name in Modules do
  begin
    Assert.IsFalse(Seen.Contains(Name),
      'Duplicate module found: ' + Name);
    Seen.Add(Name);
  end;
end;

procedure TMapModuleParserTests.ParseMapFileResultIsReadOnly;
var
  Modules: IReadOnlyList<string>;
begin
  Modules := FParser.ParseMapFile(FFixtureMap);
  Assert.IsNotNull(Modules);
end;

// ── BuildModuleFileDictionary ───────────────────────────────────────────

procedure TMapModuleParserTests.BuildModuleFileDictionaryPopulatesDictionary;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add(FTempDir);
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Assert.AreEqual(3, FParser.GetDictionaryCount);
end;

procedure TMapModuleParserTests.BuildModuleFileDictionarySkipsNonExistentFolders;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add('C:\NoSuchFolder_SBOMgenTest');
  Assert.WillNotRaise(
    procedure
    begin
      FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
    end);
  Assert.AreEqual(0, FParser.GetDictionaryCount);
end;

procedure TMapModuleParserTests.BuildModuleFileDictionarySkipsEmptyFolderEntry;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add('');
  Folders.Add('   ');
  Assert.WillNotRaise(
    procedure
    begin
      FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
    end);
  Assert.AreEqual(0, FParser.GetDictionaryCount);
end;

procedure TMapModuleParserTests.BuildModuleFileDictionaryClearsOnRebuild;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add(FTempDir);
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Assert.AreEqual(3, FParser.GetDictionaryCount);

  Folders.Clear;
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Assert.AreEqual(0, FParser.GetDictionaryCount);
end;

// ── GetModuleFilePath ───────────────────────────────────────────────────

procedure TMapModuleParserTests.GetModuleFilePathReturnsPathForKnownModule;
var
  Folders: IList<string>;
  Path:    string;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add(FTempDir);
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Path := FParser.GetModuleFilePath('u_Alpha');
  Assert.IsNotEmpty(Path);
  Assert.IsTrue(Path.EndsWith('u_Alpha.pas'));
end;

procedure TMapModuleParserTests.GetModuleFilePathReturnsEmptyForUnknownModule;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add(FTempDir);
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Assert.AreEqual('', FParser.GetModuleFilePath('u_NoSuchModule'));
end;

procedure TMapModuleParserTests.GetModuleFilePathIsCaseInsensitive;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add(FTempDir);
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Assert.IsNotEmpty(FParser.GetModuleFilePath('U_ALPHA'));
  Assert.IsNotEmpty(FParser.GetModuleFilePath('u_alpha'));
end;

// ── GetDictionaryCount ──────────────────────────────────────────────────

procedure TMapModuleParserTests.GetDictionaryCountReturnsZeroInitially;
begin
  Assert.AreEqual(0, FParser.GetDictionaryCount);
end;

procedure TMapModuleParserTests.GetDictionaryCountReflectsLoadedFiles;
var
  Folders: IList<string>;
begin
  Folders := TCollections.CreateList<string>;
  Folders.Add(FTempDir);
  FParser.BuildModuleFileDictionary(Folders as IReadOnlyList<string>);
  Assert.AreEqual(3, FParser.GetDictionaryCount);
end;

initialization
  TDUnitX.RegisterTestFixture(TMapModuleParserTests);

end.
