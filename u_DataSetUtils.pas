unit u_DataSetUtils;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  FireDAC dataset display utilities. Provides column width sizing
  for TFDMemTable fields, either by measuring pixel widths against
  a canvas or by character count.
*)

interface

uses
  Vcl.Graphics,
  FireDAC.Comp.Client;

/// <summary>
/// Sets the DisplayWidth of each field in ADataset to accommodate
/// the widest value in that column, measured in pixels using ACanvas.
/// The current dataset position is preserved across the call.
/// </summary>
procedure AutoSizeColumns(ADataset: TFDMemTable; ACanvas: TCanvas);

/// <summary>
/// Sets the DisplayWidth of each field in ADataset to the character
/// count of the widest value in that column.
/// The current dataset position is preserved across the call.
/// </summary>
procedure AutoSizeColumnsByChar(ADataset: TFDMemTable);

implementation

uses
  System.Math,
  Data.DB;

procedure AutoSizeColumns(ADataset: TFDMemTable; ACanvas: TCanvas);
var
  FieldIndex: Integer;
  ColWidth:   Integer;
  Field:      TField;
  Bookmark:   TBookmark;
begin
  Bookmark := ADataset.GetBookmark;
  ADataset.DisableControls;
  try
    for FieldIndex := 0 to ADataset.FieldCount - 1 do
    begin
      Field    := ADataset.Fields[FieldIndex];
      ColWidth := ACanvas.TextWidth(Field.DisplayLabel);

      ADataset.First;
      while not ADataset.Eof do
      begin
        ColWidth := Max(ColWidth, ACanvas.TextWidth(Field.DisplayText));
        ADataset.Next;
      end;

      Field.DisplayWidth := Trunc(ColWidth * 1.05) + 30;
    end;
  finally
    if ADataset.BookmarkValid(Bookmark) then
      ADataset.GotoBookmark(Bookmark);
    ADataset.FreeBookmark(Bookmark);
    ADataset.EnableControls;
  end;
end;

procedure AutoSizeColumnsByChar(ADataset: TFDMemTable);
var
  FieldIndex: Integer;
  ColWidth:   Integer;
  Field:      TField;
  Bookmark:   TBookmark;
begin
  Bookmark := ADataset.GetBookmark;
  ADataset.DisableControls;
  try
    for FieldIndex := 0 to ADataset.FieldCount - 1 do
    begin
      Field    := ADataset.Fields[FieldIndex];
      ColWidth := Length(Field.DisplayLabel);

      ADataset.First;
      while not ADataset.Eof do
      begin
        ColWidth := Max(ColWidth, Length(Field.DisplayText));
        ADataset.Next;
      end;

      Field.DisplayWidth := ColWidth;
    end;
  finally
    if ADataset.BookmarkValid(Bookmark) then
      ADataset.GotoBookmark(Bookmark);
    ADataset.FreeBookmark(Bookmark);
    ADataset.EnableControls;
  end;
end;

end.
