object dMetadata: TdMetadata
  OnCreate = DataModuleCreate
  Height = 378
  Width = 556
  object fdmMetadata: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 64
    Top = 48
    object fdmMetadataBomRef: TStringField
      FieldName = 'BomRef'
      Visible = False
      Size = 200
    end
    object fdmMetadataName: TStringField
      FieldName = 'Name'
      Size = 50
    end
    object fdmMetadataVersion: TStringField
      FieldName = 'Version'
      Size = 50
    end
    object fdmMetadataComponentType: TStringField
      FieldName = 'ComponentType'
    end
    object fdmMetadataSupplier: TStringField
      FieldName = 'Supplier'
      Size = 100
    end
    object fdmMetadataSupplierURL: TStringField
      FieldName = 'SupplierURL'
      Size = 200
    end
    object fdmMetadataLicenseID: TStringField
      FieldName = 'LicenseID'
      Size = 100
    end
    object fdmMetadataDescription: TMemoField
      FieldName = 'Description'
      Visible = False
      BlobType = ftMemo
    end
    object fdmMetadataHashes: TMemoField
      FieldName = 'Hashes'
      Visible = False
      BlobType = ftMemo
    end
  end
  object fdmSPDXLicenses: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 184
    Top = 48
    object fdmSPDXLicensesLicenseID: TStringField
      FieldName = 'LicenseID'
      Size = 100
    end
    object fdmSPDXLicensesName: TStringField
      FieldName = 'Name'
      Size = 100
    end
    object fdmSPDXLicensesIsOsiApproved: TBooleanField
      FieldName = 'IsOsiApproved'
    end
    object fdmSPDXLicensesIsDeprecated: TBooleanField
      FieldName = 'IsDeprecated'
    end
    object fdmSPDXLicensesSeeAlso: TMemoField
      FieldName = 'SeeAlso'
      BlobType = ftMemo
    end
  end
end
