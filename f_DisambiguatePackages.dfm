object frmDisambiguatePackages: TfrmDisambiguatePackages
  Left = 0
  Top = 0
  Caption = 'frmDisambiguatePackages'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object RzPanel1: TRzPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 89
    Align = alTop
    TabOrder = 0
    object lblInstructions: TRzLabel
      Left = 32
      Top = 16
      Width = 65
      Height = 15
      Caption = 'Instructions: '
      WordWrap = True
    end
    object lblAmbiguousUnits: TRzLabel
      Left = 13
      Top = 68
      Width = 95
      Height = 15
      Caption = 'Ambiguous Units:'
    end
    object lblAmbiguousUnitsCount: TRzLabel
      Left = 113
      Top = 68
      Width = 135
      Height = 15
      Caption = 'lblAmbiguousUnitsCount'
    end
  end
  object pnlMemo: TRzPanel
    Left = 0
    Top = 89
    Width = 217
    Height = 311
    Align = alLeft
    TabOrder = 1
    object RzMemo1: TRzMemo
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 207
      Height = 301
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 32
      ExplicitTop = -24
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
  object pnlListView: TRzPanel
    Left = 217
    Top = 89
    Width = 407
    Height = 311
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 384
    ExplicitTop = 184
    ExplicitWidth = 185
    ExplicitHeight = 41
    object lstCandidates: TRzListView
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 397
      Height = 301
      Align = alClient
      Columns = <>
      TabOrder = 0
      ExplicitLeft = 72
      ExplicitTop = 48
      ExplicitWidth = 250
      ExplicitHeight = 150
    end
  end
  object pnlBottom: TRzPanel
    Left = 0
    Top = 400
    Width = 624
    Height = 41
    Align = alBottom
    TabOrder = 3
    ExplicitLeft = 128
    ExplicitTop = 280
    ExplicitWidth = 185
    object btnCancel: TRzButton
      AlignWithMargins = True
      Left = 528
      Top = 5
      Width = 91
      Height = 31
      ModalResult = 2
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 0
      ExplicitLeft = 544
    end
    object btnConfirm: TRzButton
      AlignWithMargins = True
      Left = 431
      Top = 5
      Width = 91
      Height = 31
      ModalResult = 1
      Align = alRight
      Caption = 'Confirm'
      TabOrder = 1
      ExplicitLeft = 463
    end
    object btnSelectAll: TRzButton
      AlignWithMargins = True
      Left = 307
      Top = 5
      Width = 101
      Height = 31
      Margins.Right = 20
      Align = alRight
      Caption = 'Select All'
      TabOrder = 2
      ExplicitLeft = 365
    end
    object btnSelectNone: TRzButton
      AlignWithMargins = True
      Left = 200
      Top = 5
      Width = 101
      Height = 31
      Align = alRight
      Caption = 'Select None'
      TabOrder = 3
      ExplicitLeft = 284
    end
  end
end
