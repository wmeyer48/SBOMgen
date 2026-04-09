object frmValidationResults: TfrmValidationResults
  Left = 0
  Top = 0
  Margins.Right = 31
  BorderStyle = bsDialog
  Caption = 'Validation Results'
  ClientHeight = 286
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    500
    286)
  TextHeight = 15
  object lblTitle: TLabel
    Left = 16
    Top = 16
    Width = 97
    Height = 15
    Caption = 'Validation Results'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lstIssues: TListBox
    Left = 16
    Top = 40
    Width = 468
    Height = 195
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 15
    TabOrder = 0
  end
  object RzPanel1: TRzPanel
    Left = 0
    Top = 251
    Width = 500
    Height = 35
    Align = alBottom
    TabOrder = 1
    Color = 15461355
    object btnOK: TRzButton
      AlignWithMargins = True
      Left = 420
      Top = 5
      ModalResult = 1
      Align = alRight
      Caption = 'OK'
      TabOrder = 0
    end
    object btnCopy: TRzButton
      AlignWithMargins = True
      Left = 311
      Top = 5
      Margins.Right = 31
      Align = alRight
      Caption = 'Copy'
      TabOrder = 1
    end
  end
end
