unit f_HelpViewer;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Markdown-based help viewer. Displays the SBOMgen guide from a
  local .md file using TMarkdownViewer. Instantiated on demand
  via the class method ShowHelpTopic and freed on close.
*)

interface

uses
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  HTMLUn2,
  HtmlView,
  MarkDownViewerComponents;

type
  TfrmHelpViewer = class(TForm)
    pnlTop:         TPanel;
    btnClose:       TButton;
    MarkdownViewer: TMarkdownViewer;
    procedure btnCloseClick(Sender: TObject);
  public
    /// <summary>Loads AHelpFile into the viewer and shows the form modally.</summary>
    procedure ShowHelp(const AHelpFile: string);
    /// <summary>
    /// Creates a viewer instance, displays AHelpFile, then frees the form.
    /// Call this from any context that needs to show help without managing
    /// a persistent form reference.
    /// </summary>
    class procedure ShowHelpTopic(const AHelpFile: string);
  end;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  System.IOUtils;

procedure TfrmHelpViewer.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHelpViewer.ShowHelp(const AHelpFile: string);
begin
  if not FileExists(AHelpFile) then
    raise EFileNotFoundException.CreateFmt(
      'Help file not found: %s', [AHelpFile]);

  MarkDownViewer.LoadFromFile(AHelpFile);
  ShowModal;
end;

class procedure TfrmHelpViewer.ShowHelpTopic(const AHelpFile: string);
var
  HelpForm: TfrmHelpViewer;
begin
  HelpForm := TfrmHelpViewer.Create(nil);
  try
    HelpForm.ShowHelp(AHelpFile);
  finally
    HelpForm.Free;
  end;
end;

end.
