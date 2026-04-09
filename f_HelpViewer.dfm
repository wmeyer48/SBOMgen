object frmHelpViewer: TfrmHelpViewer
  Left = 0
  Top = 0
  Caption = 'SBOM Generator Help'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnClose: TButton
      AlignWithMargins = True
      Left = 797
      Top = 4
      Width = 99
      Height = 33
      Align = alRight
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
  end
  object MarkdownViewer: TMarkdownViewer
    Left = 3
    Top = 44
    Width = 894
    Height = 553
    PrintMarginBottom = 2.000000000000000000
    PrintMarginLeft = 2.000000000000000000
    PrintMarginRight = 2.000000000000000000
    PrintMarginTop = 2.000000000000000000
    Align = alClient
    TabOrder = 1
  end
end
