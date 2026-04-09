unit SBOMgen.Tests.TextTools;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  DUnitX tests for u_TextTools.IDelimitedText and GetDelimTextInst.
  Covers construction defaults, delimiter detection, parse/round-trip,
  and the boundary conditions of the narrow IDelimitedText contract.
*)

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTextToolsTests = class
  public
    // ── Construction and defaults ────────────────────────────────────────

    [Test]
    procedure DefaultDelimiterIsBEL;

    [Test]
    procedure CustomDelimiterIsHonoured;

    [Test]
    procedure NewInstanceIsEmpty;

    // ── Add / Count / Clear ──────────────────────────────────────────────

    [Test]
    procedure AddIncreasesCount;

    [Test]
    procedure ClearResetsCount;

    [Test]
    procedure AddAllowsDuplicates;

    // ── Delete ───────────────────────────────────────────────────────────

    [Test]
    procedure DeleteRemovesItemAtIndex;

    [Test]
    procedure DeleteOutOfRangeDoesNotRaise;

    // ── Indexed access ───────────────────────────────────────────────────

    [Test]
    procedure StringsByIndexReturnsCorrectEntry;

    [Test]
    procedure PutStringsUpdatesEntry;

    // ── FindDelimiter ─────────────────────────────────────────────────────

    [Test]
    procedure FindDelimiterReturnsBELWhenBELPresent;

    [Test]
    procedure FindDelimiterReturnsCRWhenCRPresentAndNoBEL;

    [Test]
    procedure FindDelimiterReturnsCommaWhenNeitherBELNorCR;

    [Test]
    procedure FindDelimiterBELTakesPrecedenceOverCR;

    // ── ParseString ───────────────────────────────────────────────────────

    [Test]
    procedure ParseStringWithBELDelimiter;

    [Test]
    procedure ParseStringWithCommaDelimiter;

    [Test]
    procedure ParseStringWithCRDelimiter;

    [Test]
    procedure ParseStringReplacesExistingEntries;

    [Test]
    procedure ParseStringEmptyStringProducesEmptyCollection;

    // ── DelimitedText round-trip ──────────────────────────────────────────

    [Test]
    procedure DelimitedTextRoundTripWithBEL;

    [Test]
    procedure DelimitedTextRoundTripWithSemicolon;

    // ── SetDelimitedText ──────────────────────────────────────────────────

    [Test]
    procedure SetDelimitedTextParsesUsingCurrentDelimiter;

    // ── SetText / GetText ─────────────────────────────────────────────────

    [Test]
    procedure SetTextParsesLineBreakDelimitedContent;

    [Test]
    procedure GetTextReturnsLineBreakDelimitedContent;

    // ── CommaText ─────────────────────────────────────────────────────────

    [Test]
    procedure CommaTextReturnsCommaDelimitedContent;

    // ── Delimiter switching ───────────────────────────────────────────────

    [Test]
    procedure DelimiterCanBeChanged;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  u_TextTools;

{ TTextToolsTests }

procedure TTextToolsTests.DefaultDelimiterIsBEL;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(DELIM_CHAR, DT.Delimiter);
end;

procedure TTextToolsTests.CustomDelimiterIsHonoured;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst(';');
  Assert.AreEqual(';', DT.Delimiter);
end;

procedure TTextToolsTests.NewInstanceIsEmpty;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(0, DT.Count);
end;

procedure TTextToolsTests.AddIncreasesCount;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  Assert.AreEqual(2, DT.Count);
end;

procedure TTextToolsTests.ClearResetsCount;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  DT.Clear;
  Assert.AreEqual(0, DT.Count);
end;

procedure TTextToolsTests.AddAllowsDuplicates;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Alpha');
  Assert.AreEqual(2, DT.Count);
end;

procedure TTextToolsTests.DeleteRemovesItemAtIndex;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  DT.Delete(0);
  Assert.AreEqual(1, DT.Count);
  Assert.AreEqual('Beta', DT[0]);
end;

procedure TTextToolsTests.DeleteOutOfRangeDoesNotRaise;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  Assert.WillNotRaise(
    procedure
    begin
      DT.Delete(99);
    end);
end;

procedure TTextToolsTests.StringsByIndexReturnsCorrectEntry;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  Assert.AreEqual('Alpha', DT[0]);
  Assert.AreEqual('Beta',  DT[1]);
end;

procedure TTextToolsTests.PutStringsUpdatesEntry;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT[0] := 'Gamma';
  Assert.AreEqual('Gamma', DT[0]);
end;

procedure TTextToolsTests.FindDelimiterReturnsBELWhenBELPresent;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(DELIM_CHAR,
    DT.FindDelimiter('Alpha' + DELIM_CHAR + 'Beta'));
end;

procedure TTextToolsTests.FindDelimiterReturnsCRWhenCRPresentAndNoBEL;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(#$D,
    DT.FindDelimiter('Alpha' + #$D + 'Beta'));
end;

procedure TTextToolsTests.FindDelimiterReturnsCommaWhenNeitherBELNorCR;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(',', DT.FindDelimiter('Alpha,Beta'));
end;

procedure TTextToolsTests.FindDelimiterBELTakesPrecedenceOverCR;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(DELIM_CHAR,
    DT.FindDelimiter('Alpha' + DELIM_CHAR + 'Beta' + #$D + 'Gamma'));
end;

procedure TTextToolsTests.ParseStringWithBELDelimiter;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.ParseString('Alpha' + DELIM_CHAR + 'Beta' + DELIM_CHAR + 'Gamma');
  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
  Assert.AreEqual('Beta',  DT[1]);
  Assert.AreEqual('Gamma', DT[2]);
end;

procedure TTextToolsTests.ParseStringWithCommaDelimiter;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.ParseString('Alpha,Beta,Gamma');
  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
  Assert.AreEqual('Beta',  DT[1]);
  Assert.AreEqual('Gamma', DT[2]);
end;

procedure TTextToolsTests.ParseStringWithCRDelimiter;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.ParseString('Alpha' + #$D + 'Beta' + #$D + 'Gamma');
  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
end;

procedure TTextToolsTests.ParseStringReplacesExistingEntries;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Old');
  DT.ParseString('Alpha' + DELIM_CHAR + 'Beta');
  Assert.AreEqual(2,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
end;

procedure TTextToolsTests.ParseStringEmptyStringProducesEmptyCollection;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.ParseString('');
  Assert.AreEqual(0, DT.Count);
end;

procedure TTextToolsTests.DelimitedTextRoundTripWithBEL;
var
  DT:       IDelimitedText;
  Original: string;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  DT.Add('Gamma');
  Original := DT.DelimitedText;

  DT.Clear;
  DT.DelimitedText := Original;

  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
  Assert.AreEqual('Beta',  DT[1]);
  Assert.AreEqual('Gamma', DT[2]);
end;

procedure TTextToolsTests.DelimitedTextRoundTripWithSemicolon;
var
  DT:       IDelimitedText;
  Original: string;
begin
  DT := GetDelimTextInst(';');
  DT.Add('Alpha');
  DT.Add('Beta');
  DT.Add('Gamma');
  Original := DT.DelimitedText;

  DT.Clear;
  DT.DelimitedText := Original;

  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
  Assert.AreEqual('Beta',  DT[1]);
  Assert.AreEqual('Gamma', DT[2]);
end;

procedure TTextToolsTests.SetDelimitedTextParsesUsingCurrentDelimiter;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst(';');
  DT.DelimitedText := 'Alpha;Beta;Gamma';
  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
  Assert.AreEqual('Gamma', DT[2]);
end;

procedure TTextToolsTests.SetTextParsesLineBreakDelimitedContent;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Text := 'Alpha' + sLineBreak + 'Beta' + sLineBreak + 'Gamma';
  Assert.AreEqual(3,       DT.Count);
  Assert.AreEqual('Alpha', DT[0]);
end;

procedure TTextToolsTests.GetTextReturnsLineBreakDelimitedContent;
var
  DT: IDelimitedText;
  Text: string;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  Text := DT.Text;
  Assert.IsTrue(Text.Contains('Alpha'));
  Assert.IsTrue(Text.Contains('Beta'));
end;

procedure TTextToolsTests.CommaTextReturnsCommaDelimitedContent;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  DT.Add('Alpha');
  DT.Add('Beta');
  Assert.AreEqual('Alpha,Beta', DT.CommaText);
end;

procedure TTextToolsTests.DelimiterCanBeChanged;
var
  DT: IDelimitedText;
begin
  DT := GetDelimTextInst;
  Assert.AreEqual(DELIM_CHAR, DT.Delimiter);
  DT.Delimiter := ';';
  Assert.AreEqual(';', DT.Delimiter);
end;

initialization
  TDUnitX.RegisterTestFixture(TTextToolsTests);

end.
