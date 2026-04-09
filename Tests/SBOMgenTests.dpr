program SBOMgenTests;

uses
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  u_Logger in '..\u_Logger.pas',
  u_TextTools in '..\..\SharedUtils\StrUtils\u_TextTools.pas',
  u_EnumUtils in '..\u_EnumUtils.pas',
  SBOMgen.Tests.TextTools in 'SBOMgen.Tests.TextTools.pas',
  SBOMgen.Tests.SBOMClasses in 'SBOMgen.Tests.SBOMClasses.pas',
  u_SBOMClasses in '..\u_SBOMClasses.pas',
  i_SBOMComponent in '..\i_SBOMComponent.pas',
  SBOMgen.Tests.SBOMValidation in 'SBOMgen.Tests.SBOMValidation.pas',
  u_SBOMValidation in '..\u_SBOMValidation.pas',
  i_SBOMComponentDetection in '..\i_SBOMComponentDetection.pas',
  u_DelphiVersionDetector_2 in '..\u_DelphiVersionDetector_2.pas',
  i_AmbiguousUnit in '..\i_AmbiguousUnit.pas',
  u_RegistryHelper in '..\u_RegistryHelper.pas',
  SBOMgen.Tests.PackageMetadataRepository in 'SBOMgen.Tests.PackageMetadataRepository.pas',
  u_PackageMetadataRepository in '..\u_PackageMetadataRepository.pas',
  SBOMgen.Tests.MetadataEditController in 'SBOMgen.Tests.MetadataEditController.pas',
  i_MetadataViewer in '..\i_MetadataViewer.pas',
  u_MetadataEditController in '..\u_MetadataEditController.pas',
  SBOMgen.Tests.MapModules in 'SBOMgen.Tests.MapModules.pas',
  u_MapModules in '..\u_MapModules.pas',
  u_SBOMEnums in '..\u_SBOMEnums.pas';

{$R *.res}
{$R 'package-metadata-defaults.res'}

begin
  SysLog := TLogger.Create;
  TestInsight.DUnitX.RunRegisteredTests;
end.
