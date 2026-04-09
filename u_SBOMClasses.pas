unit u_SBOMClasses;

(*
  Copyright © 2025, 2026
  William Meyer   All rights reserved.

  Concrete implementations of the core SBOM interfaces defined in
  u_SBOMInterfaces. Covers component representation, metadata,
  dependency graph, and CycloneDX JSON generation.
*)

interface

uses
  System.SysUtils,
  System.JSON,
  System.DateUtils,
  System.Classes,
  Spring.Collections,
  i_SBOMComponent,
  u_SBOMEnums;

type
  /// <summary>Concrete implementation of ISBOMComponent.</summary>
  TSBOMComponent = class(TInterfacedObject, ISBOMComponent)
  private
    FBomRef:        string;
    FName:          string;
    FVersion:       string;
    FComponentType: TComponentType;
    FSupplier:      string;
    FSupplierURL:   string;
    FLicenseID:     string;
    FDescription:   string;
    FHashes:        IList<string>;
    FUserUpdated:   string;
  public
    constructor Create(
      const ABomRef, AName, AVersion: string;
            AType:                    TComponentType;
      const ASupplier, ASupplierURL, ALicenseID: string;
      const ADescription: string = '');

    function GetBomRef:        string;
    function GetName:          string;
    function GetVersion:       string;
    function GetComponentType: TComponentType;
    function GetSupplier:      string;
    function GetSupplierURL:   string;
    function GetLicenseID:     string;
    function GetDescription:   string;
    function GetHashes:        IReadOnlyList<string>;
    procedure AddHash(const AHash: string);
    function GetUserUpdated: string;
    procedure SetUserUpdated(const AValue: string);
  end;

  /// <summary>Concrete implementation of ISBOMMetadata.</summary>
  TSBOMMetadata = class(TInterfacedObject, ISBOMMetadata)
  private
    FApplicationName:    string;
    FApplicationVersion: string;
    FAuthor:             string;
    FTimestamp:          TDateTime;
    FToolName:           string;
    FToolVersion:        string;
  public
    constructor Create(
      const AAppName, AAppVersion, AAuthor: string;
      const AToolName:    string = 'Delphi SBOM Generator';
      const AToolVersion: string = '1.0.0');

    function GetApplicationName:    string;
    function GetApplicationVersion: string;
    function GetAuthor:             string;
    function GetTimestamp:          TDateTime;
    function GetToolName:           string;
    function GetToolVersion:        string;
  end;

  /// <summary>Concrete implementation of ISBOMDependencyGraph.</summary>
  TSBOMDependencyGraph = class(TInterfacedObject, ISBOMDependencyGraph)
  private
    FDependencies: IDictionary<string, IList<string>>;
  public
    constructor Create;

    procedure AddDependency(const AFrom, ATo: string);
    function GetDependencies(const ABomRef: string): IList<string>;
    function GetAllBomRefs: IList<string>;
  end;

  /// <summary>Concrete implementation of ISBOMGenerator. Produces CycloneDX JSON output.</summary>
  TSBOMGenerator = class(TInterfacedObject, ISBOMGenerator)
  private
    FMetadata:         ISBOMMetadata;
    FComponents:       IList<ISBOMComponent>;
    FDependencyGraph:  ISBOMDependencyGraph;

    function GenerateUUID: string;
    function ComponentTypeToString(AType: TComponentType): string;
    function GenerateCycloneDXJSON: TJSONObject;
  public
    constructor Create;

    procedure SetMetadata(const AMetadata: ISBOMMetadata);
    procedure AddComponent(const AComponent: ISBOMComponent);
    procedure SetDependencyGraph(const AGraph: ISBOMDependencyGraph);
    function GenerateCycloneDX: string;
    procedure SaveToFile(const AFileName: string;
      const AFormat: TOutputFormat = ofCycloneDX);
  end;

implementation

const
  COMPONENT_TYPE_STRINGS: array[TComponentType] of string = (
    'application',
    'framework',
    'library',
    'container',
    'device',
    'file',
    'firmware',
    'operating-system',
    'vcl-component',
    'fmx-component',
    'design-time'
  );

{ TSBOMComponent }

constructor TSBOMComponent.Create(
  const ABomRef, AName, AVersion: string;
        AType:                    TComponentType;
  const ASupplier, ASupplierURL, ALicenseID, ADescription: string);
begin
  inherited Create;
  FBomRef        := ABomRef;
  FName          := AName;
  FVersion       := AVersion;
  FComponentType := AType;
  FSupplier      := ASupplier;
  FSupplierURL   := ASupplierURL;
  FLicenseID     := ALicenseID;
  FDescription   := ADescription;
  FHashes        := TCollections.CreateList<string>;
end;

procedure TSBOMComponent.AddHash(const AHash: string);
begin
  if not AHash.IsEmpty then
    FHashes.Add(AHash);
end;

function TSBOMComponent.GetBomRef: string;
begin
  Result := FBomRef;
end;

function TSBOMComponent.GetName: string;
begin
  Result := FName;
end;

function TSBOMComponent.GetVersion: string;
begin
  Result := FVersion;
end;

procedure TSBOMComponent.SetUserUpdated(const AValue: string);
begin
  FUserUpdated := AValue;
end;

function TSBOMComponent.GetComponentType: TComponentType;
begin
  Result := FComponentType;
end;

function TSBOMComponent.GetSupplier: string;
begin
  Result := FSupplier;
end;

function TSBOMComponent.GetSupplierURL: string;
begin
  Result := FSupplierURL;
end;

function TSBOMComponent.GetUserUpdated: string;
begin
  Result := FUserUpdated;
end;

function TSBOMComponent.GetLicenseID: string;
begin
  Result := FLicenseID;
end;

function TSBOMComponent.GetDescription: string;
begin
  Result := FDescription;
end;

function TSBOMComponent.GetHashes: IReadOnlyList<string>;
begin
  Result := FHashes as IReadOnlyList<string>;
end;

{ TSBOMMetadata }

constructor TSBOMMetadata.Create(
  const AAppName, AAppVersion, AAuthor: string;
  const AToolName, AToolVersion: string);
begin
  inherited Create;
  FApplicationName    := AAppName;
  FApplicationVersion := AAppVersion;
  FAuthor             := AAuthor;
  FTimestamp          := Now;
  FToolName           := AToolName;
  FToolVersion        := AToolVersion;
end;

function TSBOMMetadata.GetApplicationName: string;
begin
  Result := FApplicationName;
end;

function TSBOMMetadata.GetApplicationVersion: string;
begin
  Result := FApplicationVersion;
end;

function TSBOMMetadata.GetAuthor: string;
begin
  Result := FAuthor;
end;

function TSBOMMetadata.GetTimestamp: TDateTime;
begin
  Result := FTimestamp;
end;

function TSBOMMetadata.GetToolName: string;
begin
  Result := FToolName;
end;

function TSBOMMetadata.GetToolVersion: string;
begin
  Result := FToolVersion;
end;

{ TSBOMDependencyGraph }

constructor TSBOMDependencyGraph.Create;
begin
  inherited Create;
  FDependencies := TCollections.CreateDictionary<string, IList<string>>;
end;

procedure TSBOMDependencyGraph.AddDependency(const AFrom, ATo: string);
var
  DependencyList: IList<string>;
begin
  if not FDependencies.TryGetValue(AFrom, DependencyList) then
  begin
    DependencyList := TCollections.CreateList<string>;
    FDependencies.Add(AFrom, DependencyList);
  end;

  if not DependencyList.Contains(ATo) then
    DependencyList.Add(ATo);
end;

function TSBOMDependencyGraph.GetDependencies(const ABomRef: string): IList<string>;
begin
  if not FDependencies.TryGetValue(ABomRef, Result) then
    Result := TCollections.CreateList<string>;
end;

function TSBOMDependencyGraph.GetAllBomRefs: IList<string>;
begin
  Result := TCollections.CreateList<string>(FDependencies.Keys);
end;

{ TSBOMGenerator }

constructor TSBOMGenerator.Create;
begin
  inherited Create;
  FComponents := TCollections.CreateList<ISBOMComponent>;
end;

procedure TSBOMGenerator.SetMetadata(const AMetadata: ISBOMMetadata);
begin
  FMetadata := AMetadata;
end;

procedure TSBOMGenerator.AddComponent(const AComponent: ISBOMComponent);
begin
  FComponents.Add(AComponent);
end;

procedure TSBOMGenerator.SetDependencyGraph(const AGraph: ISBOMDependencyGraph);
begin
  FDependencyGraph := AGraph;
end;

function TSBOMGenerator.GenerateUUID: string;
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  Result := GUIDToString(GUID).ToLower.Trim(['{', '}']);
end;

function TSBOMGenerator.ComponentTypeToString(AType: TComponentType): string;
begin
  Result := COMPONENT_TYPE_STRINGS[AType];
end;

function TSBOMGenerator.GenerateCycloneDXJSON: TJSONObject;
var
  Root, Metadata, ToolObj,
  MainComponent, Supplier:          TJSONObject;
  ToolsArray, ComponentsArray,
  LicensesArray, DependenciesArray,
  SupplierURLArray, DependsOnArray: TJSONArray;
  Component:                        ISBOMComponent;
  ComponentObj, LicenseObj,
  LicenseDetail, DependencyObj:     TJSONObject;
  BomRef:                           string;
  Dependencies:                     IList<string>;
  Dependency:                       string;
  HashesArray:                      TJSONArray;
  HashObj:                          TJSONObject;
  HashStr:                          string;
  ColonPos:                         Integer;
begin
  Root := TJSONObject.Create;
  try
    Root.AddPair('bomFormat',    'CycloneDX');
    Root.AddPair('specVersion',  '1.6');
    Root.AddPair('serialNumber', 'urn:uuid:' + GenerateUUID);
    Root.AddPair('version',      TJSONNumber.Create(1));

    Metadata := TJSONObject.Create;
    Metadata.AddPair('timestamp', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"',
      TTimeZone.Local.ToUniversalTime(FMetadata.Timestamp)));

    ToolsArray := TJSONArray.Create;
    ToolObj    := TJSONObject.Create;
    ToolObj.AddPair('vendor',  FMetadata.Author);
    ToolObj.AddPair('name',    FMetadata.ToolName);
    ToolObj.AddPair('version', FMetadata.ToolVersion);
    ToolsArray.AddElement(ToolObj);
    Metadata.AddPair('tools', ToolsArray);

    MainComponent := TJSONObject.Create;
    MainComponent.AddPair('type', 'application');
    MainComponent.AddPair('bom-ref',
      Format('pkg:generic/%s@%s', [FMetadata.ApplicationName.ToLower,
                                   FMetadata.ApplicationVersion]));
    MainComponent.AddPair('name',    FMetadata.ApplicationName);
    MainComponent.AddPair('version', FMetadata.ApplicationVersion);

    Supplier := TJSONObject.Create;
    Supplier.AddPair('name', FMetadata.Author);
    MainComponent.AddPair('supplier', Supplier);

    Metadata.AddPair('component', MainComponent);
    Root.AddPair('metadata', Metadata);

    ComponentsArray := TJSONArray.Create;
    for Component in FComponents do
    begin
      ComponentObj := TJSONObject.Create;
      ComponentObj.AddPair('type',    ComponentTypeToString(Component.ComponentType));
      ComponentObj.AddPair('bom-ref', Component.BomRef);
      ComponentObj.AddPair('name',    Component.Name);
      ComponentObj.AddPair('version', Component.Version);

      if not Component.Description.IsEmpty then
        ComponentObj.AddPair('description', Component.Description);

      if Component.Hashes.Count > 0 then
      begin
        HashesArray := TJSONArray.Create;
        for HashStr in Component.Hashes do
        begin
          ColonPos := HashStr.IndexOf(':');
          if ColonPos > 0 then
          begin
            HashObj := TJSONObject.Create;
            HashObj.AddPair('alg',     HashStr.Substring(0, ColonPos));
            HashObj.AddPair('content', HashStr.Substring(ColonPos + 1));
            HashesArray.AddElement(HashObj);
          end;
        end;

        if HashesArray.Count > 0 then
          ComponentObj.AddPair('hashes', HashesArray)
        else
          HashesArray.Free;
      end;

      if not Component.Supplier.IsEmpty then
      begin
        Supplier := TJSONObject.Create;
        Supplier.AddPair('name', Component.Supplier);

        if not Component.SupplierURL.IsEmpty then
        begin
          SupplierURLArray := TJSONArray.Create;
          SupplierURLArray.Add(Component.SupplierURL);
          Supplier.AddPair('url', SupplierURLArray);
        end;

        ComponentObj.AddPair('supplier', Supplier);
      end;

      if not Component.LicenseID.IsEmpty then
      begin
        LicensesArray := TJSONArray.Create;
        LicenseObj    := TJSONObject.Create;

        // CycloneDX 1.6 schema requires:
        // - Plain SPDX identifiers → { "license": { "id": "..." } }
        // - LicenseRef-*, NOASSERTION, and compound expressions
        //   (OR, AND, WITH) → { "expression": "..." }
        if Component.LicenseID.StartsWith('LicenseRef-', True) or
           SameText(Component.LicenseID, 'NOASSERTION') or
           Component.LicenseID.Contains(' OR ') or
           Component.LicenseID.Contains(' AND ') or
           Component.LicenseID.Contains(' WITH ') then
        begin
          LicenseObj.AddPair('expression', Component.LicenseID);
        end
        else
        begin
          LicenseDetail := TJSONObject.Create;
          LicenseDetail.AddPair('id', Component.LicenseID);
          LicenseObj.AddPair('license', LicenseDetail);
        end;

        LicensesArray.AddElement(LicenseObj);
        ComponentObj.AddPair('licenses', LicensesArray);
      end;

      ComponentsArray.AddElement(ComponentObj);
    end;
    Root.AddPair('components', ComponentsArray);

    if Assigned(FDependencyGraph) then
    begin
      DependenciesArray := TJSONArray.Create;

      BomRef := Format('pkg:generic/%s@%s', [FMetadata.ApplicationName.ToLower,
                                              FMetadata.ApplicationVersion]);
      Dependencies := FDependencyGraph.GetDependencies(BomRef);
      if Dependencies.Count > 0 then
      begin
        DependencyObj := TJSONObject.Create;
        DependencyObj.AddPair('ref', BomRef);

        DependsOnArray := TJSONArray.Create;
        for Dependency in Dependencies do
          DependsOnArray.Add(Dependency);

        DependencyObj.AddPair('dependsOn', DependsOnArray);
        DependenciesArray.AddElement(DependencyObj);
      end;

      Root.AddPair('dependencies', DependenciesArray);
    end;

    Result := Root;
  except
    Root.Free;
    raise;
  end;
end;

function TSBOMGenerator.GenerateCycloneDX: string;
var
  JSONObj: TJSONObject;
begin
  JSONObj := GenerateCycloneDXJSON;
  try
    Result := JSONObj.Format(2);
  finally
    JSONObj.Free;
  end;
end;

procedure TSBOMGenerator.SaveToFile(const AFileName: string;
  const AFormat: TOutputFormat);
var
  Content:    string;
  FileStream: TFileStream;
  Writer:     TStreamWriter;
begin
  case AFormat of
    ofCycloneDX: Content := GenerateCycloneDX;
  else
    raise EArgumentException.CreateFmt('Unsupported SBOM output format: %d',
      [Ord(AFormat)]);
  end;

  FileStream := TFileStream.Create(AFileName, fmCreate);
  try
    Writer := TStreamWriter.Create(FileStream, TEncoding.UTF8);
    try
      Writer.Write(Content);
    finally
      Writer.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

end.
