unit u_ServiceRegistration;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Builds and configures the Spring4D dependency injection container
  for SBOMgen. Call BuildContainer once at application startup and
  hold the returned TContainer for the lifetime of the application.
*)

interface

uses
  Spring.Container;

/// <summary>
/// Builds, configures, and returns the application DI container.
/// </summary>
/// <remarks>
/// Must be called once at application startup. The caller is
/// responsible for the lifetime of the returned TContainer instance.
/// </remarks>
function BuildContainer: TContainer;

implementation

uses
  i_SBOMComponent,
  i_SBOMComponentDetection,
  u_CLIRunner,
  u_CycloneDXValidator,
  u_DelphiVersionDetector_2,
  u_DelphiEnvironment,
  u_EnvironmentHelper,
  u_MapModules,
  u_PackageEditor,
  u_PackageMetadataRepository,
  u_PackageResolver,
  u_RegistryHelper,
  u_SBOMClasses,
  u_SBOMComponentDetectionImpl,
  u_SBOMGenerationService,
  u_SBOMProject,
  u_SBOMValidation,
  u_UserProfile;

function BuildContainer: TContainer;
begin
  Result := TContainer.Create;

  // Version detection
  Result.RegisterType<TDelphiVersionRepository>
    .Implements<IDelphiVersionRepository>
    .AsSingleton;

  Result.RegisterType<TRegistryDelphiDetector>
    .Implements<IDelphiInstallationDetector>
    .AsSingleton;

  // Environment harvesting
  Result.RegisterType<TDelphiRegistryHarvester>
    .Implements<IDelphiRegistryHarvester>
    .AsSingleton;

  Result.RegisterType<TPackageResolver>
    .Implements<IPackageResolver>
    .AsSingleton;

  // Package metadata
  Result.RegisterType<TPackageMetadataRepository>
    .Implements<IPackageMetadataRepository>
    .AsSingleton;

  Result.RegisterType<TDPROJParser>
    .Implements<IDPROJParser>;

  // Component detection
  Result.RegisterType<TMapModuleParser>
    .Implements<IMapModuleParser>
    .AsSingleton;

  Result.RegisterType<TComponentDetector>
    .Implements<IComponentDetector>;

  // SBOM generation
  Result.RegisterType<TSBOMGenerator>
    .Implements<ISBOMGenerator>;
  Result.RegisterType<TSBOMGenerationService>
    .Implements<ISBOMGenerationService>
    .AsSingleton;

  // Validation
  Result.RegisterType<TBasicValidator>
    .Implements<IBasicValidator>
    .AsSingleton;

  // CLI execution
  Result.RegisterType<TCLIRunner>
    .Implements<ICLIRunner>
    .AsSingleton;

  Result.RegisterType<TCycloneDXValidator>
    .Implements<ICycloneDXValidator>
    .AsSingleton;

  // Project management
  Result.RegisterType<TSBOMProjectService>
    .Implements<ISBOMProjectService>
    .AsSingleton;

  // Package editing
  Result.RegisterType<TPackageEditManager>
    .Implements<IPackageEditManager>;

  // Registry and environment
  Result.RegisterType<TDelphiRegistryHelper>
    .Implements<IDelphiRegistryHelper>
    .AsSingleton;

  Result.RegisterType<TEnvironmentHelper>
    .Implements<IEnvironmentHelper>
    .AsSingleton;

  // User profile
  Result.RegisterType<TUserProfileService>
    .Implements<IUserProfileService>
    .AsSingleton;

  Result.Build;
end;

end.
