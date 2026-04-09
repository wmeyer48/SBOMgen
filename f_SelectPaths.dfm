object fSelectPaths: TfSelectPaths
  Left = 0
  Top = 0
  Caption = 'fSelectPaths'
  ClientHeight = 515
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTop: TRzPanel
    Left = 0
    Top = 0
    Width = 393
    Height = 35
    Align = alTop
    TabOrder = 0
    Color = 15461355
    object lblListOfPaths: TRzLabel
      Left = 15
      Top = 9
      Width = 64
      Height = 15
      Caption = 'List of paths'
    end
  end
  object RzPanel2: TRzPanel
    Left = 0
    Top = 35
    Width = 393
    Height = 445
    Align = alClient
    TabOrder = 1
    Color = 15461355
    object lbPaths: TRzListBox
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 343
      Height = 363
      Align = alClient
      ItemHeight = 15
      TabOrder = 0
    end
    object pnlSelect: TRzPanel
      Left = 2
      Top = 371
      Width = 389
      Height = 72
      Align = alBottom
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      Color = 15461355
      DesignSize = (
        389
        72)
      object edtPath: TLabeledEdit
        Left = 38
        Top = 8
        Width = 308
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 27
        EditLabel.Height = 23
        EditLabel.Caption = 'Path:'
        LabelPosition = lpLeft
        TabOrder = 0
        Text = ''
      end
      object btnSelectPath: TRzButton
        Left = 351
        Top = 8
        Width = 32
        Height = 23
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 1
        OnClick = btnSelectPathClick
      end
      object RzPanel1: TRzPanel
        Left = 2
        Top = 38
        Width = 385
        Height = 32
        Align = alBottom
        BorderOuter = fsNone
        TabOrder = 2
        Color = 15461355
        object btnAdd: TRzButton
          AlignWithMargins = True
          Left = 188
          Top = 3
          Height = 26
          Align = alRight
          Caption = 'Add'
          TabOrder = 0
          OnClick = btnAddClick
        end
        object btnDelete: TRzButton
          AlignWithMargins = True
          Left = 269
          Top = 3
          Height = 26
          Margins.Right = 41
          Align = alRight
          Caption = 'Delete'
          TabOrder = 1
          OnClick = btnDeleteClick
        end
      end
    end
    object pnlRight: TRzPanel
      Left = 351
      Top = 2
      Width = 40
      Height = 369
      Align = alRight
      TabOrder = 2
      Color = 15461355
      object btnMoveUp: TRzBitBtn
        AlignWithMargins = True
        Left = 5
        Top = 296
        Width = 30
        Height = 31
        Align = alBottom
        Caption = 'btnMoveUp'
        TabOrder = 0
        OnClick = btnMoveUpClick
        ImageIndex = 1
        Images = SVGIconImageList1
      end
      object btnMoveDown: TRzBitBtn
        AlignWithMargins = True
        Left = 5
        Top = 333
        Width = 30
        Height = 31
        Align = alBottom
        Caption = 'btnMoveDown'
        TabOrder = 1
        OnClick = btnMoveDownClick
        ImageIndex = 0
        Images = SVGIconImageList1
      end
    end
  end
  object pnlBottom: TRzPanel
    Left = 0
    Top = 480
    Width = 393
    Height = 35
    Align = alBottom
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    Color = 15461355
    object btnOK: TRzButton
      AlignWithMargins = True
      Left = 232
      Top = 5
      ModalResult = 1
      Align = alRight
      Caption = 'OK'
      TabOrder = 0
    end
    object btnCancel: TRzButton
      AlignWithMargins = True
      Left = 313
      Top = 5
      ModalResult = 2
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 1
    end
  end
  object SVGIconImageList1: TSVGIconImageList
    SVGIconItems = <
      item
        IconName = 'down'
        SVGText = 
          '<svg version="1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0' +
          ' 48 48" enable-background="new 0 0 48 48">'#13#10'    <g fill="#3F51B5' +
          '">'#13#10'        <polygon points="24,44 12.3,30 35.7,30"/>'#13#10'        <' +
          'rect x="20" y="6" width="8" height="27"/>'#13#10'    </g>'#13#10'</svg>'#13#10
      end
      item
        IconName = 'up'
        SVGText = 
          '<svg version="1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0' +
          ' 48 48" enable-background="new 0 0 48 48">'#13#10'    <g fill="#3F51B5' +
          '">'#13#10'        <polygon points="24,4 35.7,18 12.3,18"/>'#13#10'        <r' +
          'ect x="20" y="15" width="8" height="27"/>'#13#10'    </g>'#13#10'</svg>'#13#10
      end>
    Scaled = True
    Left = 248
    Top = 187
  end
  object dlgSelFolder: TRzSelectFolderDialog
    FormPosition = poOwnerFormCenter
    Left = 176
    Top = 299
  end
end
