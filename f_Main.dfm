object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'SBOM Generator'
  ClientHeight = 673
  ClientWidth = 1315
  Color = clBtnFace
  Constraints.MinHeight = 665
  Constraints.MinWidth = 1000
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlMainTop: TRzPanel
    Left = 0
    Top = 0
    Width = 1315
    Height = 35
    Align = alTop
    TabOrder = 0
    Color = 15461355
  end
  object pnlBottomClose: TRzPanel
    Left = 0
    Top = 638
    Width = 1315
    Height = 35
    Align = alBottom
    TabOrder = 1
    Color = 15461355
    object btnClose: TRzButton
      AlignWithMargins = True
      Left = 1235
      Top = 5
      Align = alRight
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
  end
  object pnlClient: TRzPanel
    Left = 0
    Top = 35
    Width = 1315
    Height = 603
    Align = alClient
    TabOrder = 2
    Color = 15461355
    object pcMain: TRzPageControl
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1305
      Height = 593
      Hint = ''
      ActivePage = tsApplicationCode
      Align = alClient
      BoldCurrentTab = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      StyleName = 'Windows'
      TabIndex = 3
      TabOrder = 0
      TabStyle = tsRoundCorners
      FixedDimension = 21
      object tsUserProfile: TRzTabSheet
        Color = 15461355
        Caption = 'Main'
        DesignSize = (
          1301
          565)
        object pnlMainUpper: TRzPanel
          Left = 0
          Top = 0
          Width = 1301
          Height = 177
          Align = alTop
          TabOrder = 0
          object pnlUserNAme: TRzPanel
            Left = 2
            Top = 2
            Width = 1297
            Height = 29
            Align = alTop
            BorderOuter = fsStatus
            TabOrder = 0
            object edtUserName: TLabeledEdit
              AlignWithMargins = True
              Left = 82
              Top = 4
              Width = 221
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 61
              EditLabel.Height = 21
              EditLabel.Caption = 'User Name:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
              ExplicitHeight = 23
            end
          end
          object pnlCompany: TRzPanel
            Left = 2
            Top = 31
            Width = 1297
            Height = 29
            Align = alTop
            BorderOuter = fsStatus
            TabOrder = 1
            object edtCompany: TLabeledEdit
              AlignWithMargins = True
              Left = 82
              Top = 4
              Width = 221
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 55
              EditLabel.Height = 21
              EditLabel.Caption = 'Company:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
              ExplicitHeight = 23
            end
          end
          object pnlStreet: TRzPanel
            Left = 2
            Top = 60
            Width = 1297
            Height = 29
            Align = alTop
            BorderOuter = fsStatus
            TabOrder = 2
            object edtStreet: TLabeledEdit
              AlignWithMargins = True
              Left = 82
              Top = 4
              Width = 221
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 33
              EditLabel.Height = 21
              EditLabel.Caption = 'Street:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
              ExplicitHeight = 23
            end
          end
          object pnlCityStatePostal: TRzPanel
            Left = 2
            Top = 89
            Width = 1297
            Height = 29
            Align = alTop
            BorderOuter = fsStatus
            TabOrder = 3
            object edtCity: TLabeledEdit
              AlignWithMargins = True
              Left = 82
              Top = 4
              Width = 221
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 24
              EditLabel.Height = 21
              EditLabel.Caption = 'City:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
              ExplicitHeight = 23
            end
            object edtStateProv: TLabeledEdit
              AlignWithMargins = True
              Left = 387
              Top = 4
              Width = 181
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 58
              EditLabel.Height = 21
              EditLabel.Caption = 'State/Prov:'
              LabelPosition = lpLeft
              TabOrder = 1
              Text = ''
              ExplicitHeight = 23
            end
            object edtPostal: TLabeledEdit
              AlignWithMargins = True
              Left = 652
              Top = 4
              Width = 101
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 66
              EditLabel.Height = 21
              EditLabel.Caption = 'Postal Code:'
              LabelPosition = lpLeft
              TabOrder = 2
              Text = ''
              ExplicitHeight = 23
            end
          end
          object pnlCLITool: TRzPanel
            Left = 2
            Top = 147
            Width = 1297
            Height = 29
            Align = alTop
            BorderOuter = fsStatus
            TabOrder = 4
            object edtCLIToolPath: TLabeledEdit
              AlignWithMargins = True
              Left = 82
              Top = 4
              Width = 221
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 45
              EditLabel.Height = 21
              EditLabel.Caption = 'CLI Tool:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
              ExplicitHeight = 23
            end
            object btnSelCLITool: TRzButton
              Left = 310
              Top = 4
              Width = 23
              Height = 21
              Caption = '...'
              TabOrder = 1
              OnClick = btnSelCLIToolClick
            end
          end
          object pnlPhone: TRzPanel
            Left = 2
            Top = 118
            Width = 1297
            Height = 29
            Align = alTop
            BorderOuter = fsStatus
            TabOrder = 5
            object edtPhone: TLabeledEdit
              AlignWithMargins = True
              Left = 82
              Top = 4
              Width = 221
              Height = 21
              Margins.Left = 81
              Align = alLeft
              EditLabel.Width = 37
              EditLabel.Height = 21
              EditLabel.Caption = 'Phone:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
              ExplicitHeight = 23
            end
          end
        end
        object btnSaveUserProfile: TRzButton
          Left = 84
          Top = 180
          Width = 221
          Anchors = [akLeft, akBottom]
          Caption = 'Save User Profile'
          TabOrder = 1
          OnClick = btnSaveUserProfileClick
        end
        object btnResetCatalog: TRzButton
          Left = 84
          Top = 213
          Width = 221
          Caption = 'Reset Catalog'
          TabOrder = 2
          OnClick = btnResetCatalogClick
        end
      end
      object tsProjectAndCompiler: TRzTabSheet
        Color = 15461355
        Caption = 'Project and Compiler'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object pnlProj: TRzPanel
          Left = 0
          Top = 0
          Width = 1301
          Height = 565
          Align = alClient
          TabOrder = 0
          object pnlProjectSettings: TRzPanel
            Left = 2
            Top = 2
            Width = 1297
            Height = 190
            Align = alTop
            BorderOuter = fsNone
            TabOrder = 0
            object pnlProject: TRzPanel
              Left = 0
              Top = 0
              Width = 1297
              Height = 31
              Align = alTop
              BorderOuter = fsNone
              TabOrder = 0
              Color = 15461355
              object lblProjectName: TLabel
                Left = 33
                Top = 8
                Width = 75
                Height = 15
                Alignment = taRightJustify
                Caption = 'Project Name:'
              end
              object btnSaveProject: TSpeedButton
                Left = 349
                Top = 4
                Width = 90
                Height = 23
                Caption = 'Save Project'
                OnClick = btnSaveProjectClick
              end
              object btnNewProject: TSpeedButton
                Left = 448
                Top = 4
                Width = 90
                Height = 23
                Caption = 'New Project'
                OnClick = btnNewProjectClick
              end
              object btnDeleteProject: TSpeedButton
                Left = 869
                Top = 5
                Width = 88
                Height = 23
                Caption = 'Delete Project'
                OnClick = btnDeleteProjectClick
              end
              object edtCreateDate: TLabeledEdit
                Left = 596
                Top = 5
                Width = 91
                Height = 23
                EditLabel.Width = 44
                EditLabel.Height = 23
                EditLabel.Caption = 'Created:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 1
                Text = ''
              end
              object edtUpdatedDate: TLabeledEdit
                Left = 745
                Top = 5
                Width = 91
                Height = 23
                EditLabel.Width = 48
                EditLabel.Height = 23
                EditLabel.Caption = 'Updated:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 2
                Text = ''
              end
              object cmbProject: TRzComboBox
                Left = 115
                Top = 5
                Width = 223
                Height = 23
                Hint = 'A simple name, not a file or path.'
                DropDownWidth = 215
                ParentShowHint = False
                ShowHint = True
                Sorted = True
                StyleElements = [seBorder]
                TabOrder = 0
                OnClick = cmbProjectSelect
              end
            end
            object pnlRootFolder: TRzPanel
              AlignWithMargins = True
              Left = 3
              Top = 31
              Width = 1291
              Height = 31
              Margins.Top = 0
              Margins.Bottom = 0
              Align = alTop
              BorderOuter = fsNone
              TabOrder = 1
              Color = 15461355
              DesignSize = (
                1291
                31)
              object lblRootFolders: TLabel
                Left = 44
                Top = 6
                Width = 64
                Height = 15
                Alignment = taRightJustify
                Caption = 'Root Folder:'
              end
              object btnSelRootFolders: TRzButton
                AlignWithMargins = True
                Left = 1259
                Top = 3
                Width = 27
                Height = 23
                Margins.Right = 5
                Margins.Bottom = 5
                Align = alRight
                Caption = '...'
                TabOrder = 1
                OnClick = btnSelRootFoldersClick
              end
              object edtRootFolders: TRzEdit
                Left = 112
                Top = 3
                Width = 1146
                Height = 23
                Text = ''
                Anchors = [akLeft, akTop, akRight]
                StyleElements = [seBorder]
                TabOrder = 0
              end
            end
            object pnlMapFile: TRzPanel
              AlignWithMargins = True
              Left = 3
              Top = 62
              Width = 1291
              Height = 31
              Margins.Top = 0
              Margins.Bottom = 0
              Align = alTop
              BorderOuter = fsNone
              TabOrder = 2
              Color = 15461355
              DesignSize = (
                1291
                31)
              object lblMapFile: TLabel
                Left = 60
                Top = 8
                Width = 48
                Height = 15
                Alignment = taRightJustify
                Caption = 'Map File:'
              end
              object btnSelMapFile: TRzButton
                AlignWithMargins = True
                Left = 1259
                Top = 3
                Width = 27
                Height = 23
                Margins.Right = 5
                Margins.Bottom = 5
                Align = alRight
                Caption = '...'
                TabOrder = 1
                OnClick = btnSelMapFileClick
              end
              object edtMapFile: TRzEdit
                Left = 112
                Top = 3
                Width = 1146
                Height = 23
                Text = ''
                Anchors = [akLeft, akTop, akRight]
                StyleElements = [seBorder]
                TabOrder = 0
              end
            end
            object pnlDprFile: TRzPanel
              AlignWithMargins = True
              Left = 3
              Top = 93
              Width = 1291
              Height = 31
              Margins.Top = 0
              Margins.Bottom = 0
              Align = alTop
              BorderOuter = fsNone
              TabOrder = 3
              Color = 15461355
              DesignSize = (
                1291
                31)
              object lblDprFile: TLabel
                Left = 62
                Top = 8
                Width = 46
                Height = 15
                Alignment = taRightJustify
                Caption = 'DPR File:'
              end
              object btnSelDprFile: TRzButton
                AlignWithMargins = True
                Left = 1259
                Top = 3
                Width = 27
                Height = 23
                Margins.Right = 5
                Margins.Bottom = 5
                Align = alRight
                Caption = '...'
                TabOrder = 1
                OnClick = btnSelDprFileClick
              end
              object edtDprFile: TRzEdit
                Left = 112
                Top = 3
                Width = 1146
                Height = 23
                Text = ''
                Anchors = [akLeft, akTop, akRight]
                StyleElements = [seBorder]
                TabOrder = 0
              end
            end
            object pnlExcludedPaths: TRzPanel
              AlignWithMargins = True
              Left = 3
              Top = 124
              Width = 1291
              Height = 31
              Margins.Top = 0
              Margins.Bottom = 0
              Align = alTop
              BorderOuter = fsNone
              TabOrder = 4
              Color = 15461355
              DesignSize = (
                1291
                31)
              object lblExcludedPaths: TLabel
                Left = 25
                Top = 6
                Width = 83
                Height = 15
                Alignment = taRightJustify
                Caption = 'Excluded Paths:'
              end
              object btnSelExcludedPaths: TRzButton
                AlignWithMargins = True
                Left = 1259
                Top = 3
                Width = 27
                Height = 23
                Margins.Right = 5
                Margins.Bottom = 5
                Align = alRight
                Caption = '...'
                TabOrder = 1
                OnClick = btnSelExcludedPathsClick
              end
              object edtExcludedPaths: TRzEdit
                Left = 112
                Top = 3
                Width = 1146
                Height = 23
                Text = ''
                Anchors = [akLeft, akTop, akRight]
                StyleElements = [seBorder]
                TabOrder = 0
              end
            end
            object pnlDelphiVersion: TRzPanel
              AlignWithMargins = True
              Left = 3
              Top = 155
              Width = 1291
              Height = 31
              Margins.Top = 0
              Margins.Bottom = 0
              Align = alTop
              BorderOuter = fsNone
              TabOrder = 5
              Color = 15461355
              DesignSize = (
                1291
                31)
              object lblCompilerVersion: TLabel
                Left = 15
                Top = 6
                Width = 93
                Height = 15
                Caption = 'Compiler Version:'
              end
              object cmbDelphiVersion: TRzComboBox
                Left = 112
                Top = 3
                Width = 885
                Height = 23
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 0
                OnClick = cmbDelphiVersionSelect
              end
              object pnlBitness: TRzPanel
                Left = 1008
                Top = 0
                Width = 254
                Height = 31
                Anchors = [akTop, akRight]
                BorderOuter = fsNone
                TabOrder = 1
                DesignSize = (
                  254
                  31)
                object rb32bit: TRzRadioButton
                  Left = 10
                  Top = 7
                  Width = 50
                  Height = 17
                  Anchors = [akTop, akRight]
                  AutoSizeWidth = 50
                  Caption = '32-bit'
                  TabOrder = 0
                  OnClick = rb32bitClick
                end
                object rb64bit: TRzRadioButton
                  Left = 75
                  Top = 7
                  Width = 50
                  Height = 17
                  Anchors = [akTop, akRight]
                  AutoSizeWidth = 50
                  Caption = '64-bit'
                  Checked = True
                  TabOrder = 1
                  TabStop = True
                  OnClick = rb64bitClick
                end
                object rb64bitModern: TRzRadioButton
                  Left = 137
                  Top = 8
                  Width = 93
                  Height = 17
                  AutoSizeWidth = 93
                  Caption = '64 bit Modern'
                  TabOrder = 2
                  OnClick = rb64bitModernClick
                end
              end
            end
          end
          object pnlProjClient: TRzPanel
            Left = 2
            Top = 192
            Width = 1297
            Height = 371
            Align = alClient
            BorderOuter = fsNone
            TabOrder = 1
            object pnlProjectLog: TRzPanel
              Left = 0
              Top = 0
              Width = 1112
              Height = 371
              Align = alClient
              BorderOuter = fsNone
              TabOrder = 0
              object memoMainLog: TRzMemo
                Left = 0
                Top = 0
                Width = 1112
                Height = 371
                Align = alClient
                PopupMenu = mnuMemoPopup
                ScrollBars = ssBoth
                TabOrder = 0
              end
            end
            object pnlProjectActions: TRzPanel
              Left = 1112
              Top = 0
              Width = 185
              Height = 371
              Align = alRight
              BorderOuter = fsNone
              TabOrder = 1
              object btnDetectComponents: TRzButton
                AlignWithMargins = True
                Left = 3
                Top = 3
                Width = 179
                Align = alTop
                Caption = 'Detect Components'
                TabOrder = 0
                OnClick = btnDetectComponentsClick
              end
              object btnGenerateSBOM: TRzButton
                AlignWithMargins = True
                Left = 3
                Top = 34
                Width = 179
                Margins.Bottom = 21
                Align = alTop
                Caption = 'Build SBOM'
                TabOrder = 1
                OnClick = btnGenerateSBOMClick
              end
              object btnClearProjectLog: TRzButton
                AlignWithMargins = True
                Left = 3
                Top = 132
                Width = 179
                Align = alTop
                Caption = 'Clear Project Log'
                TabOrder = 2
                OnClick = btnClearProjectLogClick
              end
              object btnSaveProjectLog: TRzButton
                AlignWithMargins = True
                Left = 3
                Top = 163
                Width = 179
                Align = alTop
                Caption = 'Save Project Log'
                TabOrder = 3
                OnClick = btnSaveProjectLogClick
              end
              object btnValidateSBOM: TRzButton
                AlignWithMargins = True
                Left = 3
                Top = 83
                Width = 179
                Margins.Bottom = 21
                Align = alTop
                Caption = 'Validate SBOM'
                TabOrder = 4
                OnClick = btnValidateSBOMClick
              end
            end
          end
        end
      end
      object tsPackages: TRzTabSheet
        Color = 15461355
        Caption = 'Packages'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object pnlPackages: TRzPanel
          Left = 0
          Top = 0
          Width = 826
          Height = 565
          Align = alClient
          TabOrder = 0
          object pnlPackagesUpper: TRzPanel
            Left = 2
            Top = 2
            Width = 822
            Height = 41
            Align = alTop
            BorderOuter = fsGroove
            TabOrder = 0
            object chkShowIncompleteOnly: TRzCheckBox
              Left = 48
              Top = 12
              Width = 139
              Height = 17
              AutoSizeWidth = 139
              Caption = 'Show Incomplete Only'
              Checked = True
              State = cbChecked
              TabOrder = 0
              OnClick = chkShowIncompleteOnlyClick
            end
          end
          object pnlPackagesGrid: TRzPanel
            Left = 2
            Top = 43
            Width = 822
            Height = 520
            Align = alClient
            BorderOuter = fsGroove
            TabOrder = 1
            object PackagesGrid: TRzDBGrid
              AlignWithMargins = True
              Left = 5
              Top = 5
              Width = 812
              Height = 510
              Align = alClient
              Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -12
              TitleFont.Name = 'Segoe UI'
              TitleFont.Style = []
              OnCellClick = PackagesGridCellClick
            end
          end
        end
        object pnlPackagesRight: TRzPanel
          Left = 826
          Top = 0
          Width = 475
          Height = 565
          Align = alRight
          TabOrder = 1
          object pnlPackagesDetail: TRzPanel
            Left = 2
            Top = 2
            Width = 471
            Height = 248
            Align = alTop
            BorderOuter = fsGroove
            TabOrder = 0
            object dtlPkgName: TLabeledEdit
              Left = 77
              Top = 16
              Width = 281
              Height = 23
              Color = clBtnFace
              EditLabel.Width = 35
              EditLabel.Height = 23
              EditLabel.Caption = 'Name:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 0
              Text = ''
            end
            object dtlPkgVersion: TLabeledEdit
              Left = 77
              Top = 54
              Width = 281
              Height = 23
              Color = clBtnFace
              EditLabel.Width = 41
              EditLabel.Height = 23
              EditLabel.Caption = 'Version:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 1
              Text = ''
            end
            object dtlPkgSupplier: TLabeledEdit
              Left = 77
              Top = 93
              Width = 281
              Height = 23
              Color = clBtnFace
              EditLabel.Width = 46
              EditLabel.Height = 23
              EditLabel.Caption = 'Supplier:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 2
              Text = ''
            end
            object dtlPkgSupplierURL: TLabeledEdit
              Left = 77
              Top = 131
              Width = 281
              Height = 23
              Color = clBtnFace
              EditLabel.Width = 24
              EditLabel.Height = 23
              EditLabel.Caption = 'URL:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 3
              Text = ''
            end
            object dtlPkgLicense: TLabeledEdit
              Left = 77
              Top = 170
              Width = 281
              Height = 23
              Color = clBtnFace
              EditLabel.Width = 42
              EditLabel.Height = 23
              EditLabel.Caption = 'License:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 4
              Text = ''
            end
            object dtlPkgDescription: TLabeledEdit
              Left = 77
              Top = 208
              Width = 281
              Height = 23
              Color = clBtnFace
              EditLabel.Width = 63
              EditLabel.Height = 23
              EditLabel.Caption = 'Description:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 5
              Text = ''
            end
          end
          object pnlPackagesEdit: TRzPanel
            Left = 2
            Top = 250
            Width = 471
            Height = 313
            Align = alClient
            BorderOuter = fsGroove
            TabOrder = 1
            object lblPackageLicense: TRzLabel
              Left = 32
              Top = 152
              Width = 42
              Height = 15
              Caption = 'License:'
            end
            object lblDescription: TRzLabel
              Left = 11
              Top = 192
              Width = 63
              Height = 15
              Caption = 'Description:'
            end
            object lblPkgMode: TLabel
              Left = 24
              Top = 8
              Width = 64
              Height = 15
              Caption = 'lblPkgMode'
              Visible = False
            end
            object edtPkgVersion: TLabeledEdit
              Left = 77
              Top = 29
              Width = 281
              Height = 23
              EditLabel.Width = 41
              EditLabel.Height = 23
              EditLabel.Caption = 'Version:'
              LabelPosition = lpLeft
              TabOrder = 0
              Text = ''
            end
            object edtPkgSupplier: TLabeledEdit
              Left = 77
              Top = 69
              Width = 281
              Height = 23
              EditLabel.Width = 46
              EditLabel.Height = 23
              EditLabel.Caption = 'Supplier:'
              LabelPosition = lpLeft
              TabOrder = 1
              Text = ''
            end
            object edtPkgSupplierURL: TLabeledEdit
              Left = 77
              Top = 109
              Width = 281
              Height = 23
              EditLabel.Width = 24
              EditLabel.Height = 23
              EditLabel.Caption = 'URL:'
              LabelPosition = lpLeft
              TabOrder = 2
              Text = ''
            end
            object cmbPkgLicense: TComboBox
              Left = 77
              Top = 149
              Width = 281
              Height = 23
              TabOrder = 3
            end
            object memoPkgDescription: TMemo
              Left = 77
              Top = 189
              Width = 281
              Height = 60
              ScrollBars = ssVertical
              TabOrder = 4
            end
            object btnPkgEditApply: TButton
              Left = 384
              Top = 27
              Width = 75
              Height = 25
              Caption = 'Apply'
              TabOrder = 5
            end
            object btnPkgEditRevert: TButton
              Left = 384
              Top = 58
              Width = 75
              Height = 25
              Caption = 'Revert'
              TabOrder = 6
            end
            object edtPkgPrefixes: TLabeledEdit
              Left = 77
              Top = 265
              Width = 281
              Height = 23
              EditLabel.Width = 44
              EditLabel.Height = 23
              EditLabel.Caption = 'Prefixes:'
              LabelPosition = lpLeft
              ReadOnly = True
              TabOrder = 7
              Text = ''
            end
            object btnEditPrefixes: TRzButton
              Left = 363
              Top = 265
              Width = 33
              Height = 23
              Caption = '...'
              TabOrder = 8
              OnClick = btnEditPrefixesClick
            end
          end
        end
      end
      object tsApplicationCode: TRzTabSheet
        Color = 15461355
        Caption = 'Application Code'
        object pnlAppCodePage: TRzPanel
          Left = 0
          Top = 0
          Width = 1301
          Height = 565
          Align = alClient
          BorderOuter = fsNone
          TabOrder = 0
          object Splitter1: TSplitter
            Left = 0
            Top = 289
            Width = 1301
            Height = 3
            Cursor = crVSplit
            Align = alTop
            ExplicitWidth = 276
          end
          object pnlAppCodeViewer: TRzPanel
            Left = 0
            Top = 292
            Width = 1301
            Height = 273
            Align = alClient
            TabOrder = 0
            object synSourceView: TSynEdit
              Left = 2
              Top = 2
              Width = 1297
              Height = 269
              Align = alClient
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Consolas'
              Font.Style = []
              Font.Quality = fqClearTypeNatural
              TabOrder = 0
              UseCodeFolding = False
              Gutter.Font.Charset = DEFAULT_CHARSET
              Gutter.Font.Color = clWindowText
              Gutter.Font.Height = -11
              Gutter.Font.Name = 'Consolas'
              Gutter.Font.Style = []
              Gutter.Bands = <
                item
                  Kind = gbkMarks
                  Width = 13
                end
                item
                  Kind = gbkLineNumbers
                end
                item
                  Kind = gbkFold
                end
                item
                  Kind = gbkTrackChanges
                end
                item
                  Kind = gbkMargin
                  Width = 3
                end>
              Highlighter = SynPasSyn1
              ReadOnly = True
              SelectedColor.Alpha = 0.400000005960464500
            end
          end
          object pnlAppCodeTop: TRzPanel
            Left = 0
            Top = 0
            Width = 1301
            Height = 41
            Align = alTop
            TabOrder = 1
          end
          object pnlAppCodeUpper: TRzPanel
            Left = 0
            Top = 41
            Width = 1301
            Height = 248
            Align = alTop
            TabOrder = 2
            object pnlAppCodeDetails: TRzPanel
              Left = 828
              Top = 2
              Width = 471
              Height = 244
              Align = alRight
              BorderOuter = fsBump
              TabOrder = 0
              object dispAppCodeName: TLabeledEdit
                Left = 85
                Top = 24
                Width = 281
                Height = 23
                Color = clBtnFace
                EditLabel.Width = 35
                EditLabel.Height = 23
                EditLabel.Caption = 'Name:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 0
                Text = ''
              end
              object dispAppCodeVersion: TLabeledEdit
                Left = 85
                Top = 61
                Width = 281
                Height = 23
                Color = clBtnFace
                EditLabel.Width = 41
                EditLabel.Height = 23
                EditLabel.Caption = 'Version:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 1
                Text = ''
              end
              object dispAppCodeSupplier: TLabeledEdit
                Left = 85
                Top = 99
                Width = 281
                Height = 23
                Color = clBtnFace
                EditLabel.Width = 46
                EditLabel.Height = 23
                EditLabel.Caption = 'Supplier:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 2
                Text = ''
              end
              object dispAppCodeSupplierURL: TLabeledEdit
                Left = 85
                Top = 136
                Width = 281
                Height = 23
                Color = clBtnFace
                EditLabel.Width = 24
                EditLabel.Height = 23
                EditLabel.Caption = 'URL:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 3
                Text = ''
              end
              object dispAppCodeLicense: TLabeledEdit
                Left = 85
                Top = 174
                Width = 281
                Height = 23
                Color = clBtnFace
                EditLabel.Width = 42
                EditLabel.Height = 23
                EditLabel.Caption = 'License:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 4
                Text = ''
              end
              object dispAppCodeDescription: TLabeledEdit
                Left = 85
                Top = 211
                Width = 281
                Height = 23
                Color = clBtnFace
                EditLabel.Width = 63
                EditLabel.Height = 23
                EditLabel.Caption = 'Description:'
                LabelPosition = lpLeft
                ReadOnly = True
                TabOrder = 5
                Text = ''
              end
            end
            object pnlAppCodeTree: TRzPanel
              Left = 2
              Top = 2
              Width = 826
              Height = 244
              Align = alClient
              BorderOuter = fsNone
              TabOrder = 1
              object vstAppCode: TVirtualStringTree
                Left = 0
                Top = 0
                Width = 826
                Height = 244
                Align = alClient
                Colors.UnfocusedSelectionColor = clHighlight
                DefaultNodeHeight = 19
                Header.AutoSizeIndex = 0
                Header.Height = 15
                Header.MainColumn = -1
                Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
                TabOrder = 0
                TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
                TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toSelectNextNodeOnRemoval]
                Touch.InteractiveGestures = [igPan, igPressAndTap]
                Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
                Columns = <>
              end
            end
          end
        end
      end
      object tsSBOM: TRzTabSheet
        Color = 15461355
        Caption = 'SBOM'
        object pnlSBOMPage: TRzPanel
          Left = 0
          Top = 0
          Width = 1301
          Height = 565
          Align = alClient
          TabOrder = 0
          object splitSBOM: TRzSplitter
            Left = 2
            Top = 43
            Width = 1297
            Height = 520
            Position = 198
            Percent = 15
            RealTimeDrag = True
            Align = alClient
            TabOrder = 0
            BarSize = (
              198
              0
              202
              520)
            UpperLeftControls = (
              pnlSBOMTree)
            LowerRightControls = (
              pnlSBOMViewer)
            object pnlSBOMTree: TRzPanel
              Left = 0
              Top = 0
              Width = 198
              Height = 520
              Align = alClient
              BorderOuter = fsGroove
              TabOrder = 0
            end
            object pnlSBOMViewer: TRzPanel
              Left = 0
              Top = 0
              Width = 1095
              Height = 520
              Align = alClient
              BorderOuter = fsGroove
              TabOrder = 0
              object synSBOMView: TSynEdit
                Left = 2
                Top = 2
                Width = 1091
                Height = 475
                Align = alClient
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -13
                Font.Name = 'Consolas'
                Font.Style = []
                Font.Quality = fqClearTypeNatural
                TabOrder = 0
                UseCodeFolding = False
                Gutter.Font.Charset = DEFAULT_CHARSET
                Gutter.Font.Color = clWindowText
                Gutter.Font.Height = -11
                Gutter.Font.Name = 'Consolas'
                Gutter.Font.Style = []
                Gutter.Bands = <
                  item
                    Kind = gbkMarks
                    Width = 13
                  end
                  item
                    Kind = gbkLineNumbers
                  end
                  item
                    Kind = gbkFold
                  end
                  item
                    Kind = gbkTrackChanges
                  end
                  item
                    Kind = gbkMargin
                    Width = 3
                  end>
                Highlighter = SynJSONSyn1
                ReadOnly = True
                SelectedColor.Alpha = 0.400000005960464500
              end
              object pnlSBOMViewerBottom: TRzPanel
                Left = 2
                Top = 477
                Width = 1091
                Height = 41
                Align = alBottom
                BorderOuter = fsGroove
                TabOrder = 1
              end
            end
          end
          object pnlSBOMTop: TRzPanel
            Left = 2
            Top = 2
            Width = 1297
            Height = 41
            Align = alTop
            TabOrder = 1
          end
        end
      end
    end
  end
  object SynJSONSyn1: TSynJSONSyn
    Left = 874
    Top = 148
  end
  object dlgOpenMap: TRzOpenDialog
    Filter = 'MAP file|*.map|All Files|*.*'
    FormPosition = poOwnerFormCenter
    Left = 550
    Top = 413
  end
  object dlgOpenDpr: TRzOpenDialog
    Filter = 'DPR File|*.dpr|All Files|*.*'
    FormPosition = poOwnerFormCenter
    Left = 406
    Top = 413
  end
  object mnuMemoPopup: TPopupMenu
    Left = 328
    Top = 329
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = btnClearProjectLogClick
    end
  end
  object SynPasSyn1: TSynPasSyn
    Left = 552
    Top = 319
  end
  object FPackagesDataSource: TDataSource
    Left = 384
    Top = 228
  end
end
