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
end
