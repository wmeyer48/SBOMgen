unit f_DisambiguatePackages;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  RzPanel,
  Vcl.StdCtrls,
  RzLabel,
  RzEdit,
  Vcl.ComCtrls,
  RzListVw,
  RzButton,
  Spring.Collections,
  i_AmbiguousUnit,
  i_SBOMComponent;

type
  TfrmDisambiguatePackages = class(TForm)
    btnCancel: TRzButton;
    btnConfirm: TRzButton;
    btnSelectAll: TRzButton;
    btnSelectNone: TRzButton;
    lblAmbiguousUnits: TRzLabel;
    lblAmbiguousUnitsCount: TRzLabel;
    lblInstructions: TRzLabel;
    lstCandidates: TRzListView;
    pnlBottom: TRzPanel;
    pnlListView: TRzPanel;
    pnlMemo: TRzPanel;
    RzMemo1: TRzMemo;
    RzPanel1: TRzPanel;
  public
    // Returns True if the user confirmed a selection, False if cancelled.
    class function Execute(AAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>;
        out AConfirmedPackages: IReadOnlyList<ISBOMComponent>): Boolean;
  end;

var
  frmDisambiguatePackages: TfrmDisambiguatePackages;

implementation

{$R *.dfm}

class function TfrmDisambiguatePackages.Execute(AAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>;
    out AConfirmedPackages: IReadOnlyList<ISBOMComponent>): Boolean;
begin
  Result := False;
end;

end.
