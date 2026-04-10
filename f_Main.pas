unit f_Main;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.
*)

(*
  MARKDOWN_HELP must be defined as a project option to build with help support.
  Project, Options, Delphi Compiler, Conditional Defines
    All configurations, 32 or 64 bit. Add MARKDOWN_HELP
*)

interface

uses
  Data.DB,
  RzButton,
  RzCmboBx,
  RzEdit,
  RzPanel,
  RzShellDialogs,
  RzSplit,
  RzTabs,
  RzRadChk,
  RzLabel,
  RzDBGrid,
  Spring.Collections,
  Spring.Container,
  SynEdit,
  SynEditCodeFolding,
  SynEditHighlighter,
  SynHighlighterJSON,
  SynHighlighterPas,
  System.Classes,
  Vcl.Buttons,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.Menus,
  Vcl.StdCtrls,
  VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL,
  VirtualTrees,
  Winapi.Messages,
  Winapi.Windows,
  d_Metadata,
  f_ValidationResults,
  f_PrefixEditor,
  i_AmbiguousUnit,
  i_MetadataViewer,
  i_SBOMComponent,
  i_SBOMComponentDetection,
  u_CycloneDXValidator,
  u_DelphiEnvironment,
  u_DelphiVersionDetector_2,
  u_Logger,
  u_MapModules,
  u_PackageEditor,
  u_PackageMetadataRepository,
  u_PackageResolver,
  u_SBOMGenerationService,
  u_SBOMProject,
  u_UserProfile;

type
  TfrmMain = class(TForm)
    btnClearProjectLog:     TRzButton;
    btnClose:               TRzButton;
    btnDeleteProject:       TSpeedButton;
    btnDetectComponents:    TRzButton;
    btnEditPrefixes:        TRzButton;
    btnGenerateSBOM:        TRzButton;
    btnNewProject:          TSpeedButton;
    btnPkgEditApply:        TButton;
    btnPkgEditRevert:       TButton;
    btnResetCatalog:        TRzButton;
    btnSaveProject:         TSpeedButton;
    btnSaveProjectLog:      TRzButton;
    btnSaveUserProfile:     TRzButton;
    btnSelCLITool:          TRzButton;
    btnSelDprFile:          TRzButton;
    btnSelExcludedPaths:    TRzButton;
    btnSelMapFile:          TRzButton;
    btnSelRootFolders:      TRzButton;
    btnValidateSBOM:        TRzButton;
    chkShowIncompleteOnly:  TRzCheckBox;
    Clear1:                 TMenuItem;
    cmbDelphiVersion:       TRzComboBox;
    cmbPkgLicense:          TComboBox;
    cmbProject:             TRzComboBox;
    dispAppCodeDescription: TLabeledEdit;
    dispAppCodeLicense:     TLabeledEdit;
    dispAppCodeName:        TLabeledEdit;
    dispAppCodeSupplier:    TLabeledEdit;
    dispAppCodeSupplierURL: TLabeledEdit;
    dispAppCodeVersion:     TLabeledEdit;
    dlgOpenDpr:             TRzOpenDialog;
    dlgOpenMap:             TRzOpenDialog;
    dtlPkgDescription:      TLabeledEdit;
    dtlPkgLicense:          TLabeledEdit;
    dtlPkgName:             TLabeledEdit;
    dtlPkgSupplier:         TLabeledEdit;
    dtlPkgSupplierURL:      TLabeledEdit;
    dtlPkgVersion:          TLabeledEdit;
    edtCity:                TLabeledEdit;
    edtCLIToolPath:         TLabeledEdit;
    edtCompany:             TLabeledEdit;
    edtCreateDate:          TLabeledEdit;
    edtDprFile:             TRzEdit;
    edtExcludedPaths:       TRzEdit;
    edtMapFile:             TRzEdit;
    edtPhone:               TLabeledEdit;
    edtPkgPrefixes:         TLabeledEdit;
    edtPkgSupplier:         TLabeledEdit;
    edtPkgSupplierURL:      TLabeledEdit;
    edtPkgVersion:          TLabeledEdit;
    edtPostal:              TLabeledEdit;
    edtRootFolders:         TRzEdit;
    edtStateProv:           TLabeledEdit;
    edtStreet:              TLabeledEdit;
    edtUpdatedDate:         TLabeledEdit;
    edtUserName:            TLabeledEdit;
    FPackagesDataSource:    TDataSource;
    lblCompilerVersion:     TLabel;
    lblDescription:         TRzLabel;
    lblDprFile:             TLabel;
    lblExcludedPaths:       TLabel;
    lblMapFile:             TLabel;
    lblPackageLicense:      TRzLabel;
    lblPkgMode:             TLabel;
    lblProjectName:         TLabel;
    lblRootFolders:         TLabel;
    memoMainLog:            TRzMemo;
    memoPkgDescription:     TMemo;
    mnuMemoPopup:           TPopupMenu;
    PackagesGrid:           TRzDBGrid;
    pcMain:                 TRzPageControl;
    pnlAppCodeDetails:      TRzPanel;
    pnlAppCodePage:         TRzPanel;
    pnlAppCodeTop:          TRzPanel;
    pnlAppCodeTree:         TRzPanel;
    pnlAppCodeUpper:        TRzPanel;
    pnlAppCodeViewer:       TRzPanel;
    pnlBitness:             TRzPanel;
    pnlBottomClose:         TRzPanel;
    pnlCityStatePostal:     TRzPanel;
    pnlClient:              TRzPanel;
    pnlCLITool: TRzPanel;
    pnlCompany:             TRzPanel;
    pnlDelphiVersion:       TRzPanel;
    pnlDprFile:             TRzPanel;
    pnlExcludedPaths:       TRzPanel;
    pnlMainTop:             TRzPanel;
    pnlMainUpper:           TRzPanel;
    pnlMapFile:             TRzPanel;
    pnlPackages:            TRzPanel;
    pnlPackagesDetail:      TRzPanel;
    pnlPackagesEdit:        TRzPanel;
    pnlPackagesGrid:        TRzPanel;
    pnlPackagesRight:       TRzPanel;
    pnlPackagesUpper:       TRzPanel;
    pnlPhone:               TRzPanel;
    pnlProj:                TRzPanel;
    pnlProjClient:          TRzPanel;
    pnlProject:             TRzPanel;
    pnlProjectActions:      TRzPanel;
    pnlProjectLog:          TRzPanel;
    pnlProjectSettings:     TRzPanel;
    pnlRootFolder:          TRzPanel;
    pnlSBOMPage:            TRzPanel;
    pnlSBOMTop:             TRzPanel;
    pnlSBOMTree:            TRzPanel;
    pnlSBOMViewer:          TRzPanel;
    pnlSBOMViewerBottom:    TRzPanel;
    pnlStreet:              TRzPanel;
    pnlUserNAme:            TRzPanel;
    rb32bit:                TRzRadioButton;
    rb64bit:                TRzRadioButton;
    rb64bitModern:          TRzRadioButton;
    splitSBOM:              TRzSplitter;
    SynJSONSyn1:            TSynJSONSyn;
    SynPasSyn1:             TSynPasSyn;
    synSBOMView:            TSynEdit;
    synSourceView:          TSynEdit;
    tsApplicationCode:      TRzTabSheet;
    tsPackages:             TRzTabSheet;
    tsProjectAndCompiler:   TRzTabSheet;
    tsSBOM:                 TRzTabSheet;
    tsUserProfile:          TRzTabSheet;
    vstAppCode:             TVirtualStringTree;
    Splitter1: TSplitter;
    procedure btnClearProjectLogClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnDeleteProjectClick(Sender: TObject);
    procedure btnDetectComponentsClick(Sender: TObject);
    procedure btnEditPrefixesClick(Sender: TObject);
    procedure btnGenerateSBOMClick(Sender: TObject);
    procedure btnNewProjectClick(Sender: TObject);
    procedure btnResetCatalogClick(Sender: TObject);
    procedure btnSaveCLIToolPathClick(Sender: TObject);
    procedure btnSaveProjectClick(Sender: TObject);
    procedure btnSaveProjectLogClick(Sender: TObject);
    procedure btnSaveUserProfileClick(Sender: TObject);
    procedure btnSelCLIToolClick(Sender: TObject);
    procedure btnSelDprFileClick(Sender: TObject);
    procedure btnSelExcludedPathsClick(Sender: TObject);
    procedure btnSelMapFileClick(Sender: TObject);
    procedure btnSelRootFoldersClick(Sender: TObject);
    procedure btnValidateSBOMClick(Sender: TObject);
    procedure chkShowIncompleteOnlyClick(Sender: TObject);
    procedure cmbDelphiVersionSelect(Sender: TObject);
    procedure cmbProjectSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PackagesGridCellClick(Column: TColumn);
    procedure rb32bitClick(Sender: TObject);
    procedure rb64bitClick(Sender: TObject);
    procedure rb64bitModernClick(Sender: TObject);
  private
    FAppCodeDetailView:    IMetadataDetailView;
    FAppCodeTreeView:      IMetadataTreeView;
    FContainer:            TContainer;
    FCurrentProject:       ISBOMProject;
    FDetectedComponents:   IList<ISBOMComponent>;
    FEnvironment:          IDelphiEnvironment;
    FEnvironmentHarvester: IDelphiRegistryHarvester;
    FGenerationService:    ISBOMGenerationService;
    FHelpFile:             string;
    FInstalledVersions:    IReadOnlyList<IDelphiVersionInfo>;
    FLastSBOMFile:         string;
    FMapParser:            IMapModuleParser;
    FMetadataRepo:         IPackageMetadataRepository;
    FPackageManager:       IPackageEditManager;
    FPackageResolver:      IPackageResolver;
    FPackagesController:   IMetadataEditController;
    FPackagesDetailView:   IMetadataDetailView;
    FPackagesEditor:       IMetadataEditor;
    FPackagesGridAdapter:  IMetadataTreeView;
    FPlatform:             string;
    FProjectService:       ISBOMProjectService;
    FSelectedVersion:      IDelphiVersionInfo;
    FUserProfile:          IUserProfile;
    FUserProfileService:   IUserProfileService;
    FValidator:            ICycloneDXValidator;
    FVersionDetector:      IDelphiInstallationDetector;
    procedure ApplyUIToProject;
    procedure BuildModuleMaps;
    function BuildRootFolderList: IList<string>;
    procedure DoCreateNewProject;
    function EnsureVersionSelected: Boolean;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GenerateSBOM(const AExcludedPaths: IReadOnlyList<string>);
    function  GetMetadataFilePath: string;
    function GetProjectSBOMFiles: IReadOnlyList<string>;
    function  GetSelectedVersionInfo: IDelphiVersionInfo;
    procedure HarvestTheEnvironment;
    procedure InitialiseUIState;
    procedure InitializeAppCodeTab;
    procedure InitializePackagesTab;
    procedure LoadInstalledVersions;
    procedure LoadInternalModulesForReview(
      AModules: IReadOnlyList<IModuleInfo>);
    procedure LoadMetadataCatalog;
    procedure LoadMostRecentProject;
    procedure LoadPackages2;
    procedure LoadPackagesForReview(
      AComponents: IReadOnlyList<ISBOMComponent>);
    procedure OnAppCodeSelected(Sender: TObject);
    procedure OnPackageItemApplied(AItem: IMetadataItem);
    procedure Pkg2DataSourceChange(Sender: TObject; Field: TField);
    procedure PopulateVersionCombo;
    procedure PresentDetectionResults(ADetector: IComponentDetector; AUnknownPackages: IList<ISBOMComponent>);
    procedure RefreshPrefixDisplay(const APackageName: string);
    procedure RefreshProjectCombo;
    procedure ResolveServices;
    procedure RunDetection;
    procedure RunDisambiguationChecklist(AAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>; ADetector: IComponentDetector);
    procedure ShowContextHelp;
    function ValidateDetectionSettings: Boolean;
  public
    procedure LoadUserProfileToUI;
    procedure Log(const AMessage: string);
    procedure PopulateUIFromProject(AProject: ISBOMProject);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  System.StrUtils,
  System.SysUtils,
  System.UITypes,
  Vcl.FileCtrl,

  f_DeleteProject,
  f_DisambiguatePackages,
  f_HelpViewer,
  f_SelectPaths,
  i_PackageDataset,
  u_FileFinders,
  u_MetadataEditController,
  u_MetadataEditor,
  u_MetadataViewer,
  u_ModuleAdapter,
  u_PackagesGridAdapter,
  u_RegistryHelper,
  u_SBOMClasses,
  u_SBOMEnums,
  u_SBOMValidation,
  u_ServiceRegistration;

procedure TfrmMain.ApplyUIToProject;
begin
  FCurrentProject.ProjectName     := string(cmbProject.Text).Trim;
  FCurrentProject.ProjectFolder   := TPath.Combine(
    TPath.GetDocumentsPath, 'SBOMProjects',
    string(cmbProject.Text).Trim);
  FCurrentProject.RootFolders     := edtRootFolders.Text;
  FCurrentProject.MapFile         := edtMapFile.Text;
  FCurrentProject.DPRFile         := edtDprFile.Text;
  FCurrentProject.ExcludedPaths   := edtExcludedPaths.Text;
  FCurrentProject.CompilerVersion := cmbDelphiVersion.Text;
  FCurrentProject.LastModified    := Now;
end;

{ ── Misc handlers ────────────────────────────────────────────────────────── }

procedure TfrmMain.btnClearProjectLogClick(Sender: TObject);
begin
  memoMainLog.Clear;
end;

{ ── Standard button handlers ─────────────────────────────────────────────── }

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnDeleteProjectClick(Sender: TObject);
var
  SBOMFiles: IReadOnlyList<string>;
begin
  if not Assigned(FCurrentProject) then
  begin
    ShowMessage('No project loaded');
    Exit;
  end;

  SBOMFiles := GetProjectSBOMFiles;

  if TfrmDeleteProject.Execute(
    FCurrentProject.ProjectFolder,
    TPath.Combine(FCurrentProject.ProjectFolder,
                  FCurrentProject.ProjectName + '.sbomproj'),
    SBOMFiles) then
  begin
    if not FileExists(TPath.Combine(FCurrentProject.ProjectFolder,
                                    FCurrentProject.ProjectName +
                                    '.sbomproj')) then
    begin
      FCurrentProject          := nil;
      FDetectedComponents      := nil;
      btnGenerateSBOM.Enabled  := False;

      RefreshProjectCombo;
      cmbProject.Text          := '';
      edtRootFolders.Text      := '';
      edtMapFile.Text          := '';
      edtDprFile.Text          := '';
      edtExcludedPaths.Text    := '';
      edtCreateDate.Text       := '';
      edtUpdatedDate.Text      := '';
      btnSaveProject.Enabled   := cmbProject.Count > 0;
      btnDeleteProject.Enabled := cmbProject.Count > 0;
    end;
  end;
end;

procedure TfrmMain.btnDetectComponentsClick(Sender: TObject);
begin
  if not EnsureVersionSelected then
    Exit;

  BuildModuleMaps;

  if not ValidateDetectionSettings then
    Exit;

  RunDetection;
end;

procedure TfrmMain.btnEditPrefixesClick(Sender: TObject);
var
  SelectedItem: IMetadataItem;
  PackageName:  string;
  CurrentPrefixes: IReadOnlyList<string>;
  NewPrefixes:  IList<string>;
  Prefix:       string;
  Dlg:          TfrmPrefixEditor;
begin
  SelectedItem := FPackagesGridAdapter.GetSelectedItem;
  if not Assigned(SelectedItem) then
    Exit;

  PackageName     := SelectedItem.Name;
  CurrentPrefixes := FMetadataRepo.GetPrefixesForPackage(PackageName);

  Dlg := TfrmPrefixEditor.Create(nil);
  try
    Dlg.Caption := 'Edit Prefixes — ' + PackageName;
    Dlg.LoadPrefixes(CurrentPrefixes);

    if Dlg.ShowModal = mrOK then
    begin
      NewPrefixes := Dlg.GetPrefixes;

      // Clear existing prefixes for this package then re-register.
      FMetadataRepo.ClearPrefixesForPackage(PackageName);
      for Prefix in NewPrefixes do
        FMetadataRepo.RegisterPrefixMembership(PackageName, Prefix);

      RefreshPrefixDisplay(PackageName);

      if not FMetadataRepo.SaveGlobalMetadata(GetMetadataFilePath) then
        ShowMessage('Error saving package metadata');
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmMain.btnGenerateSBOMClick(Sender: TObject);
var
  ExcludedArr:  TArray<string>;
  ExcludedList: IList<string>;
  Path:         string;
begin
  if not Assigned(FDetectedComponents) then
  begin
    ShowMessage('Please detect components first');
    Exit;
  end;

  ExcludedArr  := string(edtExcludedPaths.Text).Split([';']);
  ExcludedList := TCollections.CreateList<string>;
  for Path in ExcludedArr do
  begin
    if not Path.Trim.IsEmpty then
      ExcludedList.Add(Path.Trim);
  end;

  GenerateSBOM(ExcludedList as IReadOnlyList<string>);
end;

procedure TfrmMain.btnNewProjectClick(Sender: TObject);
begin
  pnlMainTop.Caption       := '';

  cmbProject.Text          := '';
  edtRootFolders.Text      := '';
  edtMapFile.Text          := '';
  edtDprFile.Text          := '';
  edtExcludedPaths.Text    := '';

  btnSaveProject.Enabled   := True;
  btnDeleteProject.Enabled := True;
  DoCreateNewProject;
end;

procedure TfrmMain.btnResetCatalogClick(Sender: TObject);
var
  DefaultCount: Integer;
  MetadataFile: string;
begin
  if MessageDlg(
    'This will reset the package catalog to built-in defaults.' + sLineBreak +
    'All metadata you have entered or corrected will be lost.' + sLineBreak +
    sLineBreak +
    'This action cannot be undone. Continue?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  MetadataFile := GetMetadataFilePath;

  DefaultCount := FMetadataRepo.LoadBuiltInDefaults;

  if FMetadataRepo.SaveGlobalMetadata(MetadataFile) then
  begin
    Log(Format('Catalog reset to built-in defaults: %d entries', [DefaultCount]));
    ShowMessage(Format(
      'Catalog reset successfully. %d built-in entries loaded.',
      [DefaultCount]));
  end
  else
    ShowMessage('Catalog reset failed — see project log for details.');
end;

procedure TfrmMain.btnSaveCLIToolPathClick(Sender: TObject);
begin
  FUserProfile.CLIToolPath := edtCLIToolPath.Text;
  FUserProfileService.SaveProfile(FUserProfile);
  Log('CycloneDX CLI path saved: ' + FUserProfile.CLIToolPath);
end;

procedure TfrmMain.btnSaveProjectClick(Sender: TObject);
var
  ProjectName: string;
  FileName:    string;
begin
  ProjectName := string(cmbProject.Text).Trim;

  if ProjectName.IsEmpty then
  begin
    ShowMessage('Please enter a project name before saving.');
    Exit;
  end;

  if not Assigned(FCurrentProject) then
    FCurrentProject := FProjectService.CreateNew(ProjectName);

  ApplyUIToProject;

  FileName := TPath.Combine(
    FCurrentProject.ProjectFolder,
    FCurrentProject.ProjectName + '.sbomproj');

  FProjectService.SaveToFile(FCurrentProject, FileName);
  Log('Project saved: ' + FileName);

  PopulateUIFromProject(FCurrentProject);
  RefreshProjectCombo;
  cmbProject.Text := ProjectName;

  btnSaveProject.Enabled   := True;
  btnDeleteProject.Enabled := True;
end;

procedure TfrmMain.btnSaveProjectLogClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
  FileName:   string;
begin
  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.Title       := 'Save Project Log';
    SaveDialog.Filter      := 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
    SaveDialog.DefaultExt  := 'txt';
    SaveDialog.FileName    := 'SBOMgen-log-' +
      FormatDateTime('yyyy-mm-dd_hhnnss', Now) + '.txt';

    if Assigned(FCurrentProject) and TDirectory.Exists(FCurrentProject.ProjectFolder) then
      SaveDialog.InitialDir := FCurrentProject.ProjectFolder;

    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;
      memoMainLog.Lines.SaveToFile(FileName);
      Log('Log saved: ' + FileName);
    end;
  finally
    SaveDialog.Free;
  end;
end;

procedure TfrmMain.btnSaveUserProfileClick(Sender: TObject);
begin
  FUserProfile.UserName    := edtUserName.Text;
  FUserProfile.Company     := edtCompany.Text;
  FUserProfile.Street      := edtStreet.Text;
  FUserProfile.City        := edtCity.Text;
  FUserProfile.StateProv   := edtStateProv.Text;
  FUserProfile.Postal      := edtPostal.Text;
  FUserProfile.Phone       := edtPhone.Text;
  FUserProfile.CLIToolPath := edtCLIToolPath.Text;

  FUserProfileService.SaveProfile(FUserProfile);
  ShowMessage('User profile saved');
end;

procedure TfrmMain.btnSelCLIToolClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title  := 'Select CycloneDX CLI Executable';
    Dialog.Filter := 'Executable files (*.exe)|*.exe|All files (*.*)|*.*';
    if not string(edtCLIToolPath.Text).IsEmpty then
      Dialog.InitialDir := ExtractFilePath(edtCLIToolPath.Text);

    if Dialog.Execute then
      edtCLIToolPath.Text := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

procedure TfrmMain.btnSelDprFileClick(Sender: TObject);
begin
  dlgOpenDpr.Title := 'Select the DPR file';
  if dlgOpenDpr.Execute then
  begin
    if not dlgOpenDpr.FileName.IsEmpty then
    begin
      edtDprFile.Text := dlgOpenDpr.FileName;
      edtDprFile.Update;
    end;
  end;
end;

procedure TfrmMain.btnSelExcludedPathsClick(Sender: TObject);
begin
  edtExcludedPaths.Text := GetSelectedPaths('Select Excluded Folders',
    IfThen(edtExcludedPaths.Text <> '', edtExcludedPaths.Text, 'C:\'));
end;

procedure TfrmMain.btnSelMapFileClick(Sender: TObject);
begin
  dlgOpenMap.Title := 'Select the MAP file';
  if dlgOpenMap.Execute then
  begin
    if not dlgOpenMap.FileName.IsEmpty then
    begin
      edtMapFile.Text := dlgOpenMap.FileName;
      edtMapFile.Update;
    end;
  end;
end;

procedure TfrmMain.btnSelRootFoldersClick(Sender: TObject);
begin
  edtRootFolders.Text := GetSelectedPaths('Select Root Folders',
    IfThen(edtRootFolders.Text <> '', edtRootFolders.Text, 'C:\'));
end;

procedure TfrmMain.btnValidateSBOMClick(Sender: TObject);
var
  Output:   string;
  ExitCode: Integer;
begin
  if FLastSBOMFile.IsEmpty or not FileExists(FLastSBOMFile) then
  begin
    ShowMessage('No SBOM file available. Please generate an SBOM first.');
    Exit;
  end;

  if FUserProfile.CLIToolPath.IsEmpty then
  begin
    ShowMessage(
      'CycloneDX CLI tool path is not configured.' + sLineBreak +
      'Please install the CycloneDX CLI and set the path ' +
      'on the User Profile tab.' + sLineBreak + sLineBreak +
      'Download from: github.com/CycloneDX/cyclonedx-cli/releases');
    Exit;
  end;

  if not FileExists(FUserProfile.CLIToolPath) then
  begin
    ShowMessage(
      'CycloneDX CLI executable not found at:' + sLineBreak +
      FUserProfile.CLIToolPath);
    Exit;
  end;

  Log('Validating SBOM: ' + FLastSBOMFile);

  ExitCode := FValidator.Validate(
    FLastSBOMFile, FUserProfile.CLIToolPath, Output);

  if not Output.Trim.IsEmpty then
    Log('Validator: ' + Output.Trim);

  if ExitCode = 0 then
  begin
    Log('SBOM validation PASSED');
    ShowMessage('SBOM validation passed — no errors found.');
  end
  else
  begin
    Log(Format('SBOM validation FAILED (exit code %d)', [ExitCode]));
    ShowMessage(Format(
      'SBOM validation failed (exit code %d).' + sLineBreak +
      'See the project log for details.', [ExitCode]));
  end;
end;

procedure TfrmMain.BuildModuleMaps;
begin
  FPackageResolver := FContainer.Resolve<IPackageResolver>;
  FPackageResolver.BuildDelphiModuleMap(FSelectedVersion, FPlatform);
  FPackageResolver.BuildThirdPartyModuleMap(FSelectedVersion, FPlatform);
  SysLog.Add(FPackageResolver.GetStats);
end;

function TfrmMain.BuildRootFolderList: IList<string>;
var
  RootFolderArr: TArray<string>;
  I:             Integer;
begin
  Result        := TCollections.CreateList<string>;
  RootFolderArr := string(edtRootFolders.Text).Split([';']);

  for I := 0 to High(RootFolderArr) do
  begin
    if not RootFolderArr[I].Trim.IsEmpty then
    begin
      SysLog.Add('Root folder: ' + RootFolderArr[I].Trim);
      Result.Add(RootFolderArr[I].Trim);
    end;
  end;
end;

{ ── Checkbox handlers ────────────────────────────────────────────────────── }

procedure TfrmMain.chkShowIncompleteOnlyClick(Sender: TObject);
begin
  if Assigned(FPackagesGridAdapter) then
    FPackagesGridAdapter.SetShowIncompleteOnly(
      chkShowIncompleteOnly.Checked);
end;

procedure TfrmMain.cmbDelphiVersionSelect(Sender: TObject);
begin
  FSelectedVersion        := GetSelectedVersionInfo;
  HarvestTheEnvironment;
  FDetectedComponents     := nil;
  btnGenerateSBOM.Enabled := False;
end;

procedure TfrmMain.cmbProjectSelect(Sender: TObject);
var
  ProjectName: string;
  ProjectFile: string;
begin
  ProjectName := cmbProject.Text;
  if ProjectName.IsEmpty then
  begin
    ShowMessage('Please select a project');
    Exit;
  end;

  ProjectFile := TPath.Combine(
    TPath.GetDocumentsPath, 'SBOMProjects', ProjectName,
    ProjectName + '.sbomproj');

  if not FileExists(ProjectFile) then
  begin
    ShowMessage('Project file not found: ' + ProjectFile);
    Exit;
  end;

  FCurrentProject     := FProjectService.LoadFromFile(ProjectFile);
  FDetectedComponents := nil;
  FMapParser          := nil;
  FPackageResolver    := nil;
  btnGenerateSBOM.Enabled := False;
  btnValidateSBOM.Enabled := False;
  FLastSBOMFile           := '';

  PopulateUIFromProject(FCurrentProject);
end;

{ ── Private helpers ──────────────────────────────────────────────────────── }

procedure TfrmMain.DoCreateNewProject;
begin
  FCurrentProject := FProjectService.CreateNew('New Project');

  FDetectedComponents             := nil;
  btnGenerateSBOM.Enabled         := False;

  Log('New project prepared - enter required information before save');
end;

function TfrmMain.EnsureVersionSelected: Boolean;
begin
  Result := False;

  if (cmbDelphiVersion.Count > 0) and (FSelectedVersion = nil) then
  begin
    cmbDelphiVersion.ItemIndex := 0;
    cmbDelphiVersionSelect(Self);
  end;

  if not Assigned(FSelectedVersion) then
  begin
    SysLog.Add('ERROR: No Delphi version selected');
    ShowMessage('Cannot proceed without an installed Delphi version');
    Exit;
  end;

  SysLog.Add('Selected version: ' + FSelectedVersion.ProductName);
  Result := True;
end;

{ ── Form lifecycle ───────────────────────────────────────────────────────── }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  InitialiseUIState;
  ResolveServices;
  LoadMetadataCatalog;
  LoadMostRecentProject;
  LoadInstalledVersions;

  KeyPreview := True;
  OnKeyDown  := FormKeyDown;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FContainer.Free;
  inherited;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    ShowContextHelp;
    Key := 0;
  end;
end;

procedure TfrmMain.GenerateSBOM(
  const AExcludedPaths: IReadOnlyList<string>);
var
  Components: IList<ISBOMComponent>;
  OutputFile: string;
begin
  try
    Screen.Cursor := crHourGlass;
    try
      Components := TCollections.CreateList<ISBOMComponent>(
        FDetectedComponents);

      if Assigned(FPackageManager) and FPackageManager.HasModifications then
      begin
        FPackageManager.ApplyToComponents(Components);
        FPackageManager.SaveOverrides(FCurrentProject.ProjectFolder);
      end;

      if Assigned(FCurrentProject) then
        OutputFile := FProjectService.GenerateSBOMFileName(FCurrentProject)
      else
        OutputFile := ChangeFileExt(edtMapFile.Text, '.sbom.json');

      FGenerationService.Generate(
        cmbProject.Text,
        FUserProfile.Company,
        Components as IReadOnlyList<ISBOMComponent>,
        OutputFile,
        FContainer.Resolve<ISBOMGenerator>);

      // Mark generation timestamp on the project.
      if Assigned(FCurrentProject) then
      begin
        FCurrentProject.LastGenerated := Now;
        FProjectService.SaveToFile(FCurrentProject,
          TPath.Combine(FCurrentProject.ProjectFolder,
                        FCurrentProject.ProjectName + '.sbomproj'));
      end;

      SysLog.Add(Format('SBOM generated successfully:%s%s',
                        [sLineBreak, OutputFile]));

      FLastSBOMFile           := OutputFile;
      btnValidateSBOM.Enabled := True;

      if FileExists(OutputFile) then
        synSBOMView.Lines.LoadFromFile(OutputFile);

    finally
      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do
      MessageDlg('Error generating SBOM: ' + E.Message,
                 mtError, [mbOK], 0);
  end;
end;

function TfrmMain.GetMetadataFilePath: string;
begin
  Result := TPath.Combine(
    TPath.Combine(GetEnvironmentVariable('APPDATA'), 'SBOMGenerator'),
    'package-metadata.json');
end;

function TfrmMain.GetProjectSBOMFiles: IReadOnlyList<string>;
var
  SBOMFolder: string;
  Files:      TArray<string>;
  Result_:    IList<string>;
  FileName:   string;
begin
  Result_ := TCollections.CreateList<string>;

  if Assigned(FCurrentProject) then
  begin
    SBOMFolder := FProjectService.GetSBOMFolder(FCurrentProject);
    if TDirectory.Exists(SBOMFolder) then
    begin
      Files := TDirectory.GetFiles(SBOMFolder, '*.sbom.json');
      for FileName in Files do
        Result_.Add(FileName);
    end;
  end;

  Result := Result_ as IReadOnlyList<string>;
end;

function TfrmMain.GetSelectedVersionInfo: IDelphiVersionInfo;
var
  Idx: Integer;
begin
  Result := nil;
  Idx    := cmbDelphiVersion.ItemIndex;
  if (Idx >= 0) and (Idx < FInstalledVersions.Count) then
    Result := FInstalledVersions[Idx];
end;

{ ── Public interface ─────────────────────────────────────────────────────── }

procedure TfrmMain.HarvestTheEnvironment;
var
  VersionInfo: IDelphiVersionInfo;
  SearchPaths: IReadOnlyList<string>;
begin
  VersionInfo := GetSelectedVersionInfo;
  if not Assigned(VersionInfo) then
  begin
    ShowMessage('Please select a Delphi version');
    Exit;
  end;

  FEnvironment := FEnvironmentHarvester.HarvestEnvironment(VersionInfo);
  SearchPaths  := FEnvironment.GetLibrarySearchPaths(dpWin64);

  Log(Format('Loaded environment for %s%sFound %d library search paths',
             [VersionInfo.ProductName, sLineBreak, SearchPaths.Count]));
end;

procedure TfrmMain.InitialiseUIState;

  procedure MakeComboStrict(AComboBox: TRzComboBox);
  begin
    AComboBox.Items.StrictDelimiter := True;
    AComboBox.Items.Delimiter       := ',';
  end;

var
  I:       Integer;
  ExePath: string;
begin
  btnValidateSBOM.Enabled := False;
  btnGenerateSBOM.Enabled := False;
  btnDetectComponents.Enabled := True;
  FLastSBOMFile           := '';

  pcMain.ActivePage := tsProjectAndCompiler;
  for I := 0 to pcMain.PageCount - 1 do
  begin
    if not string(pcMain.Pages[I].Name).StartsWith('ts') then
      pcMain.Pages[I].TabVisible := False;
  end;

  dMetadata := TdMetadata.Create(Self);

  MakeComboStrict(cmbProject);
  MakeComboStrict(cmbDelphiVersion);

  SysLog      := TLogger.Create;
  SysLog.Memo := memoMainLog;

  FContainer := BuildContainer;

  ExePath   := ExtractFilePath(Application.ExeName);
  FHelpFile := FindFileUpTree(ExePath,
    TPath.Combine('Help', 'sbom-generator-guide.md'));

  if FHelpFile.IsEmpty then
    raise Exception.Create(
      'Help file not found: sbom-generator-guide.md');

  dMetadata.LoadSPDXLicenses(ExePath);
end;

{ ── Initialisation helpers ───────────────────────────────────────────────── }

procedure TfrmMain.InitializeAppCodeTab;
begin
  if Assigned(FAppCodeTreeView) then
    Exit;

  FAppCodeTreeView := TMetadataViewerFactory.CreateTreeView(vstAppCode);

  FAppCodeDetailView := TMetadataViewerFactory.CreateDetailView(
    dispAppCodeName,
    dispAppCodeVersion,
    dispAppCodeSupplier,
    dispAppCodeSupplierURL,
    dispAppCodeLicense,
    dispAppCodeDescription);

  synSourceView.ReadOnly  := True;
  synSourceView.Font.Name := 'Consolas';
  synSourceView.Font.Size := 10;

  FAppCodeTreeView.SetOnSelectionChanged(OnAppCodeSelected);
end;

procedure TfrmMain.InitializePackagesTab;
var
  Editor:   TMetadataEditor;
  Dataset:  IPackageDataset;
  Licenses: IList<string>;
begin
  if Assigned(FPackagesController) then
    Exit;

  FPackagesDataSource.DataSet      := dMetadata.fdmMetadata;
  FPackagesDataSource.OnDataChange := Pkg2DataSourceChange;
  PackagesGrid.DataSource          := FPackagesDataSource;
  PackagesGrid.Options             := PackagesGrid.Options
                                       + [dgMultiSelect, dgRowSelect,
                                          dgAlwaysShowSelection]
                                       - [dgEditing];
  PackagesGrid.ReadOnly := True;

  FPackagesDetailView := TMetadataViewerFactory.CreateDetailView(
    dtlPkgName,
    dtlPkgVersion,
    dtlPkgSupplier,
    dtlPkgSupplierURL,
    dtlPkgLicense,
    dtlPkgDescription);

  if not Supports(dMetadata, IPackageDataset, Dataset) then
    raise Exception.Create(
      'TdMetadata does not implement IPackageDataset — ' +
      'check interface table and uses clause');

  FPackagesGridAdapter := TPackagesGridAdapter.Create(
    PackagesGrid, Dataset);

  Editor := TMetadataEditor.Create(
    lblPkgMode,
    edtPkgVersion,
    edtPkgSupplier,
    edtPkgSupplierURL,
    cmbPkgLicense,
    memoPkgDescription,
    btnPkgEditApply,
    btnPkgEditRevert);

  FPackagesController := TMetadataViewerFactory.CreateController;
  FPackagesController.Initialize(
    FPackagesGridAdapter,
    FPackagesDetailView,
    Editor);

  FPackagesController.SetOnApplied(OnPackageItemApplied);

  Editor.Initialize(FPackagesController);
  FPackagesEditor := Editor;

  Licenses := TCollections.CreateList<string>;
  Licenses.Add('');

  if not dMetadata.fdmSPDXLicenses.IsEmpty then
  begin
    dMetadata.fdmSPDXLicenses.First;
    while not dMetadata.fdmSPDXLicenses.Eof do
    begin
      Licenses.Add(dMetadata.fdmSPDXLicensesLicenseID.AsString);
      dMetadata.fdmSPDXLicenses.Next;
    end;
  end;

  FPackagesEditor.PopulateLicenseItems(
    Licenses as IReadOnlyList<string>);
end;

procedure TfrmMain.LoadInstalledVersions;
begin
  FInstalledVersions := FVersionDetector.GetInstalledVersions;
  PopulateVersionCombo;
  if rb32bit.Checked then
    rb32bitClick(Self)
  else if rb64bit.Checked then
    rb64bitClick(Self)
  else if rb64bitModern.Checked then
    rb64bitModernClick(Self);
end;

procedure TfrmMain.LoadInternalModulesForReview(
  AModules: IReadOnlyList<IModuleInfo>);
var
  Items:     IList<IMetadataItem>;
  Module:    IModuleInfo;
  Adapter:   TModuleInfoAdapter;
  SeenNames: ISet<string>;
begin
  SysLog.Add(Format('Loading %d internal modules', [AModules.Count]));

  Items     := TCollections.CreateList<IMetadataItem>;
  SeenNames := TCollections.CreateSet<string>;

  for Module in AModules do
  begin
    if not Assigned(Module) then
      Continue;

    if SeenNames.Contains(Module.UnitName) then
      Continue;

    SeenNames.Add(Module.UnitName);

    try
      Adapter := TModuleInfoAdapter.Create(Module, FMapParser,
                                           FUserProfile);
      Items.Add(Adapter);
    except
      on E: Exception do
        SysLog.Add(Format('Error creating adapter for %s: %s',
                          [Module.UnitName, E.Message]));
    end;
  end;

  SysLog.Add(Format('Created %d unique adapters', [Items.Count]));

  if not Assigned(FAppCodeTreeView) then
    InitializeAppCodeTab;

  FAppCodeTreeView.LoadItems(Items as IReadOnlyList<IMetadataItem>);
end;

procedure TfrmMain.LoadMetadataCatalog;
var
  SBOMGenDir:   string;
  MetadataFile: string;
  DefaultCount: Integer;
begin
  // Ensure the SBOMGenerator directory exists before any file operations.
  SBOMGenDir := TPath.Combine(
    GetEnvironmentVariable('APPDATA'), 'SBOMGenerator');
  if not TDirectory.Exists(SBOMGenDir) then
    TDirectory.CreateDirectory(SBOMGenDir);

  MetadataFile := GetMetadataFilePath;

  if FileExists(MetadataFile) then
  begin
    if FMetadataRepo.LoadGlobalMetadata(MetadataFile) then
    begin
      SysLog.Add(Format('Loaded %d packages from metadata file',
                        [FMetadataRepo.GetPackageCount]));

      // Silently refresh un-edited entries if the built-in catalog
      // has been updated since this file was last written.
      if FMetadataRepo.IsSchemaOutdated then
      begin
        SysLog.Add('Catalog schema outdated — merging built-in defaults');
        FMetadataRepo.MergeBuiltInDefaults;
        if FMetadataRepo.SaveGlobalMetadata(MetadataFile) then
          SysLog.Add('Package catalog updated to current version');
      end;
    end;
  end
  else
  begin
    DefaultCount := FMetadataRepo.LoadBuiltInDefaults;
    SysLog.Add(Format('First run — loaded %d built-in package definitions',
                      [DefaultCount]));
    if FMetadataRepo.SaveGlobalMetadata(MetadataFile) then
      SysLog.Add('Saved built-in packages to metadata file');
  end;
end;

procedure TfrmMain.LoadMostRecentProject;
begin
  RefreshProjectCombo;

  if cmbProject.Count > 0 then
  begin
    cmbProject.ItemIndex := 0;
    cmbProjectSelect(Self);

    if cmbDelphiVersion.Count > 0 then
    begin
      if cmbDelphiVersion.ItemIndex < 0 then
        cmbDelphiVersion.ItemIndex := 0;
      cmbDelphiVersionSelect(Self);
    end;
  end
  else
  begin
    btnSaveProject.Enabled   := False;
    btnDeleteProject.Enabled := False;
    pnlMainTop.Caption :=
      'No projects found. Please click New Project and enter ' +
      'the required information.';
  end;
end;

procedure TfrmMain.LoadPackages2;
var
  Item: IMetadataItem;
begin
  InitializePackagesTab;

  // Clear controller state before repopulating. FCurrentItem from the
  // previous detection run would otherwise remain live during dataset
  // repopulation, causing stale-reference AVs if selection events fire.
  if Assigned(FPackagesController) then
    FPackagesController.RevertRequested;

  // Disconnect the grid during repopulation to suppress DataSourceChange
  // events until the dataset is in a consistent state.
  PackagesGrid.DataSource := nil;
  try
    dMetadata.PopulatePackages(
      FDetectedComponents as IReadOnlyList<ISBOMComponent>);
  finally
    PackagesGrid.DataSource := FPackagesDataSource;
  end;

  chkShowIncompleteOnly.Checked := True;
  FPackagesGridAdapter.SetShowIncompleteOnly(True);
  pcMain.ActivePage := tsPackages;

  Item := FPackagesGridAdapter.GetSelectedItem;
  if Assigned(Item) then
    RefreshPrefixDisplay(Item.Name)
  else
    edtPkgPrefixes.Text := '';
end;

procedure TfrmMain.LoadPackagesForReview(
  AComponents: IReadOnlyList<ISBOMComponent>);
begin
  FPackageManager := FContainer.Resolve<IPackageEditManager>;
  FPackageManager.LoadFromComponents(AComponents);

  if Assigned(FCurrentProject) then
    FPackageManager.LoadOverrides(FCurrentProject.ProjectFolder);
end;

procedure TfrmMain.LoadUserProfileToUI;
begin
  edtUserName.Text    := FUserProfile.UserName;
  edtCompany.Text     := FUserProfile.Company;
  edtStreet.Text      := FUserProfile.Street;
  edtCity.Text        := FUserProfile.City;
  edtStateProv.Text   := FUserProfile.StateProv;
  edtPostal.Text      := FUserProfile.Postal;
  edtPhone.Text       := FUserProfile.Phone;
  edtCLIToolPath.Text := FUserProfile.CLIToolPath;
end;

procedure TfrmMain.Log(const AMessage: string);
begin
  SysLog.Add(AMessage);
end;

procedure TfrmMain.OnAppCodeSelected(Sender: TObject);
var
  SelectedItem: IMetadataItem;
  ExtInfo:      IExtendedModuleInfo;
  FilePath:     string;
begin
  SelectedItem := FAppCodeTreeView.GetSelectedItem;
  FAppCodeDetailView.ShowItem(SelectedItem);

  if Supports(SelectedItem, IExtendedModuleInfo, ExtInfo) then
  begin
    FilePath := ExtInfo.FilePath;
    if not FilePath.IsEmpty and FileExists(FilePath) then
    begin
      try
        synSourceView.Lines.LoadFromFile(FilePath);
      except
        on E: Exception do
          synSourceView.Lines.Text := 'Error loading file: ' + E.Message;
      end;
    end
    else
      synSourceView.Lines.Text := Format(
        '// Source file not found for: %s', [ExtInfo.UnitName]);
  end;
end;

procedure TfrmMain.OnPackageItemApplied(AItem: IMetadataItem);
var
  Bookmarked: IBookmarkedMetadataItem;
begin
  if not Supports(AItem, IBookmarkedMetadataItem, Bookmarked) then
  begin
    SysLog.Add('OnPackageItemApplied: item does not support ' +
               'IBookmarkedMetadataItem — write-back skipped');
    Exit;
  end;

  PackagesGrid.DataSource := nil;
  try
    dMetadata.DisableControls;
    try
      dMetadata.ApplyItemValues(
        Bookmarked.Bookmark,
        AItem.Version,
        AItem.Supplier,
        AItem.SupplierURL,
        AItem.License,
        AItem.Description);
    finally
      dMetadata.EnableControls;
    end;

    dMetadata.UpdatePackages(FMetadataRepo);

    // Mark this catalog entry as user-owned so catalog schema upgrades
    // do not overwrite it. The presence of user-upd is the signal —
    // the date value provides an audit trail.
    FMetadataRepo.MarkUserUpdated(
      AItem.Name,
      FormatDateTime('yyyy-mm-dd', Now));

  finally
    PackagesGrid.DataSource := FPackagesDataSource;
  end;

  // Refresh prefix display for updated item.
  RefreshPrefixDisplay(AItem.Name);

  if not FMetadataRepo.SaveGlobalMetadata(GetMetadataFilePath) then
    ShowMessage('Error saving package metadata');
end;

procedure TfrmMain.PackagesGridCellClick(Column: TColumn);
var
  Item: IMetadataItem;
begin
  if Assigned(FPackagesController) then
    FPackagesController.SelectionChanged;

  Item := FPackagesGridAdapter.GetSelectedItem;
  if Assigned(Item) then
    RefreshPrefixDisplay(Item.Name)
  else
    edtPkgPrefixes.Text := '';
end;

{ ── Packages tab — DataSource change drives both panels ──────────────────── }

procedure TfrmMain.Pkg2DataSourceChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
  begin
    if Assigned(FPackagesController) then
      FPackagesController.SelectionChanged;
  end;
end;

procedure TfrmMain.PopulateUIFromProject(AProject: ISBOMProject);
begin
  if Assigned(AProject) then
  begin
    edtRootFolders.Text   := AProject.RootFolders;
    edtMapFile.Text       := AProject.MapFile;
    edtDprFile.Text       := AProject.DPRFile;
    edtExcludedPaths.Text := AProject.ExcludedPaths;
    cmbDelphiVersion.Text := AProject.CompilerVersion;

    if AProject.Created.HasValue then
      edtCreateDate.Text := DateToStr(AProject.Created.Value)
    else
      edtCreateDate.Text := '';

    if AProject.LastModified.HasValue then
      edtUpdatedDate.Text := DateToStr(AProject.LastModified.Value)
    else
      edtUpdatedDate.Text := '';
  end;
end;

procedure TfrmMain.PopulateVersionCombo;
var
  VersionInfo: IDelphiVersionInfo;
begin
  cmbDelphiVersion.Items.Clear;

  for VersionInfo in FInstalledVersions do
    cmbDelphiVersion.Items.AddObject(
      VersionInfo.ProductName,
      TObject(Pointer(VersionInfo)));

  if cmbDelphiVersion.Items.Count > 0 then
  begin
    cmbDelphiVersion.ItemIndex := 0;
    cmbDelphiVersion.Update;
  end;
end;

procedure TfrmMain.PresentDetectionResults(ADetector: IComponentDetector; AUnknownPackages: IList<ISBOMComponent>);
begin
  LoadPackagesForReview(
    FDetectedComponents as IReadOnlyList<ISBOMComponent>);
  LoadInternalModulesForReview(ADetector.GetInternalModules);
  LoadPackages2;

  SysLog.Add(Format('Packages tab loaded. Incomplete: %d',
                    [AUnknownPackages.Count]));

  if ADetector.GetAmbiguousUnits.Count > 0 then
    RunDisambiguationChecklist(
      ADetector.GetAmbiguousUnits, ADetector);

  btnGenerateSBOM.Enabled := True;

  if AUnknownPackages.Count > 0 then
    ShowMessage(Format('Detected %d package%s. %d need%s metadata updates.',
      [FDetectedComponents.Count,
       IfThen(FDetectedComponents.Count = 1, '', 's'),
       AUnknownPackages.Count,
       IfThen(AUnknownPackages.Count = 1, '', 's')]))
  else
    ShowMessage(Format(
      'Detection complete. External packages: %d  Internal modules: %d',
      [FDetectedComponents.Count,
       ADetector.GetInternalModules.Count]));
end;

{ ── Platform radio buttons ───────────────────────────────────────────────── }

procedure TfrmMain.rb32bitClick(Sender: TObject);
begin
  if rb32bit.Checked then
  begin
    rb64bit.Checked       := False;
    rb64bitModern.Checked := False;
    FPlatform             := 'Win32';
  end;
end;

procedure TfrmMain.rb64bitClick(Sender: TObject);
begin
  if rb64bit.Checked then
  begin
    rb32bit.Checked       := False;
    rb64bitModern.Checked := False;
    FPlatform             := 'Win64';
  end;
end;

procedure TfrmMain.rb64bitModernClick(Sender: TObject);
begin
  if rb64bitModern.Checked then
  begin
    rb32bit.Checked := False;
    rb64bit.Checked := False;
    FPlatform       := 'Win64x';
  end;
end;

procedure TfrmMain.RefreshPrefixDisplay(const APackageName: string);
var
  Prefixes:    IReadOnlyList<ISBOMComponent>;
  AllPrefixes: IReadOnlyList<string>;
  Prefix:      string;
  PackageName: string;
begin
  edtPkgPrefixes.Text := '';

  if APackageName.IsEmpty then
    Exit;

  // Walk the prefix index by checking which prefixes resolve to this package.
  // IPackageMetadataRepository.GetPrefixesForPackage is needed — see note below.
  AllPrefixes := FMetadataRepo.GetPrefixesForPackage(APackageName);
  if not Assigned(AllPrefixes) or (AllPrefixes.Count = 0) then
    Exit;

  edtPkgPrefixes.Text := string.Join(', ', AllPrefixes.ToArray);
end;

procedure TfrmMain.RefreshProjectCombo;
var
  ProjectName: string;
begin
  cmbProject.Items.Clear;
  for ProjectName in FProjectService.GetRecentProjects do
    cmbProject.Items.Add(ProjectName);
end;

procedure TfrmMain.ResolveServices;
begin
  FVersionDetector      := FContainer.Resolve<IDelphiInstallationDetector>;
  FEnvironmentHarvester := FContainer.Resolve<IDelphiRegistryHarvester>;
  FProjectService       := FContainer.Resolve<ISBOMProjectService>;
  FUserProfileService   := FContainer.Resolve<IUserProfileService>;
  FValidator            := FContainer.Resolve<ICycloneDXValidator>;
  FGenerationService    := FContainer.Resolve<ISBOMGenerationService>;
  FMetadataRepo         := FContainer.Resolve<IPackageMetadataRepository>;
  FUserProfile          := FUserProfileService.LoadProfile;
  LoadUserProfileToUI;
end;

procedure TfrmMain.RunDetection;
var
  RootFolders:       IList<string>;
  ComponentDetector: IComponentDetector;
  UnknownPackages:   IList<ISBOMComponent>;
begin
  Screen.Cursor := crHourGlass;
  try
    RootFolders := BuildRootFolderList;

    FMapParser := FContainer.Resolve<IMapModuleParser>;
    FMapParser.BuildModuleFileDictionary(
      RootFolders as IReadOnlyList<string>);
    SysLog.Add(Format('Found %d source files in root folders',
                      [FMapParser.GetDictionaryCount]));

    ComponentDetector := FContainer.Resolve<IComponentDetector>;
    ComponentDetector.SetInternalPathPrefixes(
      RootFolders as IReadOnlyList<string>);

    FDetectedComponents := ComponentDetector.DetectComponents(
      edtMapFile.Text, GetSelectedVersionInfo);
    SysLog.Add(Format('Components detected: %d',
                      [FDetectedComponents.Count]));

    UnknownPackages := FMetadataRepo.IdentifyUnknownPackages(
      FDetectedComponents as IReadOnlyList<ISBOMComponent>,
      GetSelectedVersionInfo.CompilerVersion);
    SysLog.Add(Format('Packages needing metadata: %d',
                      [UnknownPackages.Count]));

    PresentDetectionResults(ComponentDetector, UnknownPackages);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.RunDisambiguationChecklist(AAmbiguousUnits: IReadOnlyList<IAmbiguousUnit>; ADetector: IComponentDetector);
var
  ConfirmedPackages: IReadOnlyList<ISBOMComponent>;
  Confirmed:         ISBOMComponent;
begin
  if not TfrmDisambiguatePackages.Execute(
    AAmbiguousUnits, ConfirmedPackages) then
  begin
    Log('Disambiguation cancelled by user.');
    Exit;
  end;

  // Apply confirmed selections — replace any Unknown/unresolved
  // component in FDetectedComponents with the confirmed catalog entry.
  for Confirmed in ConfirmedPackages do
  begin
    Log(Format('Confirmed package: %s v%s',
      [Confirmed.Name, Confirmed.Version]));
  end;

  // TODO: persist confirmed selection to FCurrentProject.sbomproj
  // and apply resolved metadata to FDetectedComponents.
  // This will be completed when ISBOMProject gains confirmedPackages.
end;

procedure TfrmMain.ShowContextHelp;
var
  HelpSection: string;
begin
  case pcMain.ActivePageIndex of
    0: HelpSection := '#project-setup';
    1: HelpSection := '#package-metadata';
    2: HelpSection := '#application-code';
  else
    HelpSection := '#getting-started';
  end;
{$IFDEF MARKDOWN_HELP}
  TfrmHelpViewer.ShowHelpTopic(FHelpFile);
{$ELSE}
  ShowMessage('Help is available in the Manual folder as a PDF.');
{$ENDIF}
end;

function TfrmMain.ValidateDetectionSettings: Boolean;
var
  BasicValidator:   IBasicValidator;
  ValidationResult: IValidationResult;
begin
  Result := False;

  BasicValidator   := FContainer.Resolve<IBasicValidator>;
  ValidationResult := BasicValidator.ValidateBasicSettings(
    cmbProject.Text,
    edtRootFolders.Text,
    edtMapFile.Text,
    edtDprFile.Text,
    edtExcludedPaths.Text,
    cmbDelphiVersion.ItemIndex >= 0);

  if not ValidationResult.IsValid then
  begin
    TfrmValidationResults.ShowValidation(ValidationResult);
    Exit;
  end;

  if ValidationResult.HasWarnings then
  begin
    if MessageDlg('There are validation warnings. Continue anyway?',
                  mtWarning, [mbYes, mbNo], 0) = mrNo then
      Exit;
  end;

  Result := True;
end;

end.
