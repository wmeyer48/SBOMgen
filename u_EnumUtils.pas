unit u_EnumUtils;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Generic enumeration utility providing bidirectional conversion
  between enumerated constants and their string names. Used
  throughout SBOMgen for JSON serialisation and display formatting.
*)

interface

type
  /// <summary>
  /// Generic utility class for converting between enumerated constants
  /// and their string representations. Useful for JSON serialisation,
  /// display formatting, and any context where enum values must be
  /// expressed as human-readable strings.
  /// </summary>
  /// <typeparam name="T">
  /// The enumeration type to be converted. Must be a Delphi enumeration.
  /// </typeparam>
  TEnum<T> = class(TObject)
  public
    // Use reintroduce to prevent a compiler warning about hiding the virtual
    // ToString method inherited from TObject. Polymorphism is not required
    // here — this class is used only via its class methods.
    /// <summary>Returns the string name of the supplied enumeration value.</summary>
    class function ToString(const AEnumValue: T): string; reintroduce;
    /// <summary>
    /// Returns the enumeration value matching AEnumString, or ADefault
    /// if no match is found.
    /// </summary>
    class function FromString(const AEnumString: string;
      const ADefault: T): T;
  end;

implementation

uses
  System.Rtti,
  System.TypInfo;

{ TEnum<T> }

class function TEnum<T>.FromString(const AEnumString: string;
  const ADefault: T): T;
var
  OrdValue: Integer;
begin
  Assert(PTypeInfo(TypeInfo(T)).Kind = tkEnumeration,
    'Type parameter must be an enumeration');

  OrdValue := GetEnumValue(TypeInfo(T), AEnumString);
  if OrdValue < 0 then
    Result := ADefault
  else
    Result := TValue.FromOrdinal(TypeInfo(T), OrdValue).AsType<T>;
end;

class function TEnum<T>.ToString(const AEnumValue: T): string;
begin
  Assert(PTypeInfo(TypeInfo(T)).Kind = tkEnumeration,
    'Type parameter must be an enumeration');

  Result := GetEnumName(TypeInfo(T),
    TValue.From<T>(AEnumValue).AsOrdinal);
end;

end.
