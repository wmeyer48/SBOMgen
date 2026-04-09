program SBOMgen;

uses
  Vcl.Forms,
  Vcl.Styles,
  Vcl.Themes,
  f_Main in 'f_Main.pas' {frmMain},
  f_HelpViewer in 'f_HelpViewer.pas' {frmHelpViewer},
  f_SelectPaths in 'f_SelectPaths.pas' {fSelectPaths},
  f_ValidationResults in 'f_ValidationResults.pas' {frmValidationResults},
  f_DeleteProject in 'f_DeleteProject.pas' {frmDeleteProject},
  f_DisambiguatePackages in 'f_DisambiguatePackages.pas' {frmDisambiguatePackages},
  d_Metadata in 'd_Metadata.pas' {dMetadata: TDataModule},
  i_AmbiguousUnit in 'i_AmbiguousUnit.pas',
  i_MetadataViewer in 'i_MetadataViewer.pas',
  i_PackageDataset in 'i_PackageDataset.pas',
  i_SBOMComponent in 'i_SBOMComponent.pas',
  i_SBOMComponentDetection in 'i_SBOMComponentDetection.pas',
  u_AmbiguousUnit in 'u_AmbiguousUnit.pas',
  u_DataSetUtils in 'u_DataSetUtils.pas',
  u_DelphiEnvironment in 'u_DelphiEnvironment.pas',
  u_DelphiVersionDetector_2 in 'u_DelphiVersionDetector_2.pas',
  u_EnumUtils in 'u_EnumUtils.pas',
  u_EnvironmentHelper in 'u_EnvironmentHelper.pas',
  u_FileFinders in 'u_FileFinders.pas',
  u_Logger in 'u_Logger.pas',
  u_MapModules in 'u_MapModules.pas',
  u_MetadataEditController in 'u_MetadataEditController.pas',
  u_MetadataEditor in 'u_MetadataEditor.pas',
  u_MetadataViewer in 'u_MetadataViewer.pas',
  u_ModuleAdapter in 'u_ModuleAdapter.pas',
  u_PackageEditor in 'u_PackageEditor.pas',
  u_PackageMetadataRepository in 'u_PackageMetadataRepository.pas',
  u_PackageResolver in 'u_PackageResolver.pas',
  u_PackagesGridAdapter in 'u_PackagesGridAdapter.pas',
  u_RegistryHelper in 'u_RegistryHelper.pas',
  u_SBOMClasses in 'u_SBOMClasses.pas',
  u_SBOMComponentDetectionImpl in 'u_SBOMComponentDetectionImpl.pas',
  u_SBOMEnums in 'u_SBOMEnums.pas',
  u_SBOMProject in 'u_SBOMProject.pas',
  u_SBOMValidation in 'u_SBOMValidation.pas',
  u_ServiceRegistration in 'u_ServiceRegistration.pas',
  u_SPDXLicenses in 'u_SPDXLicenses.pas',
  u_TextTools in 'u_TextTools.pas',
  u_UserProfile in 'u_UserProfile.pas' {f_PrefixEditor in 'f_PrefixEditor.pas' {frmPrefixEditor},
  f_PrefixEditor in 'f_PrefixEditor.pas' {frmPrefixEditor},
  u_CLIRunner in 'u_CLIRunner.pas',
  u_CycloneDXValidator in 'u_CycloneDXValidator.pas',
  u_SBOMGenerationService in 'u_SBOMGenerationService.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Wedgewood Light');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
