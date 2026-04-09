unit u_TextTools;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Interface-wrapped TStringList utility providing delimiter-aware
  string list operations. The default delimiter is ASCII BEL (#7),
  chosen to minimise collision with typical text content.

  IDelimitedText is intentionally narrow: it covers parsing and
  serialisation of delimited string data only. Sorting, duplicate
  suppression, and searching are out of scope — use TStringList or
  Spring4D collections for those concerns.
*)

interface

uses
  System.Classes;

const
  DELIM_CHAR = #7; // ASCII BEL — collision-proof delimiter for general use.

type
  /// <summary>
  /// Delimiter-aware string collection. Supports parsing a string into
  /// entries using auto-detected or explicit delimiters, and serialising
  /// entries back to delimited text. Obtain an instance via GetDelimTextInst.
  /// </summary>
  IDelimitedText = interface
    ['{11051835-2D4D-4E61-995E-EA2B5FC35A80}']
    /// <summary>Appends S to the collection.</summary>
    procedure Add(const S: string);
    /// <summary>Removes all entries from the collection.</summary>
    procedure Clear;
    /// <summary>Removes the entry at the specified index. No-op if index is out of range.</summary>
    procedure Delete(Index: Integer);
    /// <summary>
    /// Detects the delimiter character used in AString.
    /// Returns BEL if BEL is present, CR if CR is present and BEL is not,
    /// otherwise returns comma.
    /// </summary>
    function  FindDelimiter(const AString: string): Char;
    /// <summary>Returns the collection contents as comma-delimited text.</summary>
    function  GetCommaText: string;
    /// <summary>Returns the number of entries in the collection.</summary>
    function  GetCount: Integer;
    /// <summary>Returns the collection contents using the current delimiter.</summary>
    function  GetDelimitedText: string;
    /// <summary>Returns the current delimiter character.</summary>
    function  GetDelimiter: Char;
    /// <summary>Returns the entry at the specified index.</summary>
    function  GetStrings(Index: Integer): string;
    /// <summary>Returns all entries as a line-break-delimited string.</summary>
    function  GetText: string;
    /// <summary>
    /// Parses AString into entries, auto-detecting the delimiter.
    /// Replaces any existing entries.
    /// </summary>
    procedure ParseString(const AString: string);
    /// <summary>Sets the entry at the specified index to Value.</summary>
    procedure PutStrings(Index: Integer; const Value: string);
    /// <summary>Replaces the collection contents by parsing Value using the current delimiter.</summary>
    procedure SetDelimitedText(const Value: string);
    /// <summary>Sets the delimiter character.</summary>
    procedure SetDelimiter(const Value: Char);
    /// <summary>Replaces all entries by parsing Value as line-break-delimited text.</summary>
    procedure SetText(const Value: string);

    /// <summary>Collection contents as comma-delimited text.</summary>
    property CommaText:     string  read GetCommaText;
    /// <summary>Number of entries in the collection.</summary>
    property Count:         Integer read GetCount;
    /// <summary>Collection contents using the current delimiter.</summary>
    property DelimitedText: string  read GetDelimitedText write SetDelimitedText;
    /// <summary>Current delimiter character.</summary>
    property Delimiter:     Char    read GetDelimiter     write SetDelimiter;
    /// <summary>Indexed access to individual entries.</summary>
    property Strings[Index: Integer]: string read GetStrings write PutStrings; default;
    /// <summary>All entries as a line-break-delimited string.</summary>
    property Text:          string  read GetText          write SetText;
  end;

/// <summary>
/// Returns a new IDelimitedText instance configured to use Delim
/// as its delimiter character. Defaults to DELIM_CHAR if not specified.
/// </summary>
function GetDelimTextInst(const Delim: Char = DELIM_CHAR): IDelimitedText;

implementation

uses
  System.StrUtils;

type
  TDelimitedText = class(TInterfacedObject, IDelimitedText)
  private
    FStringList: TStringList;
    function  GetCommaText: string;
    function  GetCount: Integer;
    function  GetDelimitedText: string;
    function  GetDelimiter: Char;
    function  GetStrings(Index: Integer): string;
    function  GetText: string;
    procedure PutStrings(Index: Integer; const Value: string);
    procedure SetDelimitedText(const Value: string);
    procedure SetDelimiter(const Value: Char);
    procedure SetText(const Value: string);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Add(const S: string);
    procedure Clear;
    procedure Delete(Index: Integer);
    function  FindDelimiter(const AString: string): Char;
    procedure ParseString(const AString: string);

    property CommaText:     string  read GetCommaText;
    property Count:         Integer read GetCount;
    property DelimitedText: string  read GetDelimitedText write SetDelimitedText;
    property Delimiter:     Char    read GetDelimiter     write SetDelimiter;
    property Strings[Index: Integer]: string read GetStrings write PutStrings; default;
    property Text:          string  read GetText          write SetText;
  end;

function GetDelimTextInst(const Delim: Char): IDelimitedText;
begin
  Result           := TDelimitedText.Create;
  Result.Delimiter := Delim;
end;

{ TDelimitedText }

constructor TDelimitedText.Create;
begin
  inherited Create;
  FStringList                 := TStringList.Create;
  FStringList.Delimiter       := DELIM_CHAR;
  FStringList.StrictDelimiter := True;
  FStringList.Sorted          := False;
end;

destructor TDelimitedText.Destroy;
begin
  FStringList.Free;
  inherited;
end;

procedure TDelimitedText.Add(const S: string);
begin
  FStringList.Add(S);
end;

procedure TDelimitedText.Clear;
begin
  FStringList.Clear;
end;

procedure TDelimitedText.Delete(Index: Integer);
begin
  if Index < FStringList.Count then
    FStringList.Delete(Index);
end;

function TDelimitedText.FindDelimiter(const AString: string): Char;
begin
  Result := ',';
  if PosEx(#7, AString) > 0 then
    Result := #7
  else if PosEx(#$D, AString) > 0 then
    Result := #$D;
end;

function TDelimitedText.GetCommaText: string;
begin
  Result := FStringList.CommaText;
end;

function TDelimitedText.GetCount: Integer;
begin
  Result := FStringList.Count;
end;

function TDelimitedText.GetDelimitedText: string;
begin
  Result := FStringList.DelimitedText;
end;

function TDelimitedText.GetDelimiter: Char;
begin
  Result := FStringList.Delimiter;
end;

function TDelimitedText.GetStrings(Index: Integer): string;
begin
  Result := FStringList[Index];
end;

function TDelimitedText.GetText: string;
begin
  Result := FStringList.Text;
end;

procedure TDelimitedText.ParseString(const AString: string);
begin
  FStringList.Clear;
  FStringList.Delimiter := FindDelimiter(AString);
  if FStringList.Delimiter = #$D then
    FStringList.Text := AString
  else
    FStringList.DelimitedText := AString;
end;

procedure TDelimitedText.PutStrings(Index: Integer; const Value: string);
begin
  FStringList[Index] := Value;
end;

procedure TDelimitedText.SetDelimitedText(const Value: string);
begin
  FStringList.DelimitedText := Value;
end;

procedure TDelimitedText.SetDelimiter(const Value: Char);
begin
  FStringList.Delimiter := Value;
end;

procedure TDelimitedText.SetText(const Value: string);
begin
  FStringList.Text := Value;
end;

end.
