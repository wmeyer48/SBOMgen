object frmDeleteProject: TfrmDeleteProject
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Delete Project Items'
  ClientHeight = 350
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object lblWarning: TLabel
    Left = 16
    Top = 16
    Width = 314
    Height = 15
    Caption = 'Select items to delete. This operation cannot be undone.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblSBOMFiles: TLabel
    Left = 16
    Top = 48
    Width = 62
    Height = 15
    Caption = 'SBOM Files:'
  end
  object chkListSBOMs: TCheckListBox
    Left = 16
    Top = 67
    Width = 418
    Height = 210
    ItemHeight = 17
    TabOrder = 0
    OnClickCheck = chkListSBOMsClickCheck
  end
  object chkDeleteProject: TCheckBox
    Left = 16
    Top = 288
    Width = 418
    Height = 17
    Caption = 'Also delete project file (.sbomproj)'
    TabOrder = 1
    OnClick = chkDeleteProjectClick
  end
  object btnDelete: TButton
    Left = 278
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Delete'
    Enabled = False
    ModalResult = 1
    TabOrder = 2
    OnClick = btnDeleteClick
  end
  object btnCancel: TButton
    Left = 359
    Top = 312
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
