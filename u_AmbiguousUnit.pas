unit u_AmbiguousUnit;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Concrete implementation of IAmbiguousUnit. Carries a unit name
  that maps to more than one catalog entry, together with the full
  list of candidate ISBOMComponent instances for disambiguation.
*)

interface

uses
  Spring.Collections,
  i_AmbiguousUnit,
  i_SBOMComponent;

type
  /// <summary>
  /// Concrete implementation of IAmbiguousUnit.
  /// </summary>
  TAmbiguousUnit = class(TInterfacedObject, IAmbiguousUnit)
  private
    FUnitName:   string;
    FCandidates: IList<ISBOMComponent>;
  public
    constructor Create(const AUnitName: string);
    procedure AddCandidate(const ACandidate: ISBOMComponent);
    function GetUnitName:   string;
    function GetCandidates: IReadOnlyList<ISBOMComponent>;
  end;

implementation

{ TAmbiguousUnit }

constructor TAmbiguousUnit.Create(const AUnitName: string);
begin
  inherited Create;
  FUnitName   := AUnitName;
  FCandidates := TCollections.CreateList<ISBOMComponent>;
end;

procedure TAmbiguousUnit.AddCandidate(const ACandidate: ISBOMComponent);
begin
  FCandidates.Add(ACandidate);
end;

function TAmbiguousUnit.GetUnitName: string;
begin
  Result := FUnitName;
end;

function TAmbiguousUnit.GetCandidates: IReadOnlyList<ISBOMComponent>;
begin
  Result := FCandidates as IReadOnlyList<ISBOMComponent>;
end;

end.
