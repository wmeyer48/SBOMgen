object frmPrefixEditor: TfrmPrefixEditor
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit Prefixes -- Package Name'
  ClientHeight = 297
  ClientWidth = 186
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object lblExistingPrefixes: TLabel
    Left = 16
    Top = 8
    Width = 88
    Height = 15
    Caption = 'Existing Prefixes:'
  end
  object lbPrefixes: TRzListBox
    Left = 16
    Top = 26
    Width = 153
    Height = 167
    ItemHeight = 15
    TabOrder = 0
    OnClick = lbPrefixesClick
  end
  object RzPanel1: TRzPanel
    Left = 0
    Top = 262
    Width = 186
    Height = 35
    Align = alBottom
    TabOrder = 1
    Color = 15461355
    object btnCancel: TRzButton
      AlignWithMargins = True
      Left = 106
      Top = 5
      ModalResult = 2
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 0
    end
    object btnOK: TRzButton
      AlignWithMargins = True
      Left = 25
      Top = 5
      ModalResult = 1
      Align = alRight
      Caption = 'OK'
      TabOrder = 1
    end
  end
  object edtPrefix: TRzEdit
    Left = 16
    Top = 204
    Width = 153
    Height = 23
    Text = ''
    TabOrder = 2
    OnChange = edtPrefixChange
    OnKeyPress = edtPrefixKeyPress
  end
  object btnAdd: TRzButton
    Left = 16
    Top = 232
    Width = 61
    Caption = 'Add'
    TabOrder = 3
    OnClick = btnAddClick
  end
  object btnDelete: TRzButton
    Left = 108
    Top = 232
    Width = 61
    Caption = 'Delete'
    TabOrder = 4
    OnClick = btnDeleteClick
  end
end
