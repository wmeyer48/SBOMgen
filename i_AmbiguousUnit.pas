unit i_AmbiguousUnit;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Defines IAmbiguousUnit — a detected unit name that maps to more
  than one catalog entry. Used by the disambiguation checklist to
  present the user with candidate packages for confirmation.

  Concrete implementation: u_AmbiguousUnit.TAmbiguousUnit.
*)

interface

uses
  Spring.Collections,
  i_SBOMComponent;

type
  /// <summary>
  /// Represents a single unit name that maps to more than one catalog
  /// entry. Carries the full list of candidate ISBOMComponent entries
  /// so the checklist can present supplier, version, and license for
  /// each candidate without additional catalog lookups.
  /// </summary>
  IAmbiguousUnit = interface
  ['{F1A2B3C4-D5E6-7890-ABCD-EF1234567890}']
    /// <summary>Returns the unit name that matched multiple catalog entries.</summary>
    function GetUnitName: string;
    /// <summary>Returns the candidate catalog entries for this unit.</summary>
    function GetCandidates: IReadOnlyList<ISBOMComponent>;

    /// <summary>Unit name that matched multiple catalog entries.</summary>
    property UnitName: string read GetUnitName;
    /// <summary>Candidate catalog entries for this unit.</summary>
    property Candidates: IReadOnlyList<ISBOMComponent> read GetCandidates;
  end;

implementation

end.
