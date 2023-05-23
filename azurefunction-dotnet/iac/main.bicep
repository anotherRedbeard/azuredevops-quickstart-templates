@description('The name of the function app that you wish to create.')
param appName string

@description('Location prefix that you will use as part of the naming convention')
param location_prefix string

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_GRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('Environment you are deploying to')
param env string = 'dev'

@description('Storage account name for blob trigger')
param blobStorageAccountTriggerName string

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'

var functionAppName = 'red-${location_prefix}-${appName}-fn-${env}'
var hostingPlanName = 'red-${location_prefix}-${appName}-asp-${env}'
var applicationInsightsName = 'red-${location_prefix}-${appName}-ai-${env}'
var storageAccountName = 'st${appName}${env}9'
var functionWorkerRuntime = runtime

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}



resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'BlobTriggerStorage__accountName'
          value: blobStorageAccountTriggerName
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~10'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// Get Storage Blob Data Owner role definition from the guid
resource roleStorageBlobDataOwnerDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}
// Get Storage Account Owner role definition from the guid
resource roleStorageAccountOwnerDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}
// Get Storage Queue Data Contributor role definition from the guid
resource roleStorageQueueDataContributorDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}


// Create role assignment
module sbdoRoleAssignment './role.bicep' = {
  name: guid(uniqueString(resourceGroup().id, functionApp.id, 'StorageBlobDataOwner'))
  scope: resourceGroup('red-cus-storageaccountdemos-rg')
  params: {
    blobStorageAccountTriggerName: blobStorageAccountTriggerName
    roleAssignmentDesc: 'Storage Blob Data Owner assignment'
    roleAssignmentName: 'StorageBlobDataOwner'
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
    principalId: functionApp.identity.principalId
  }
}

/*resource sbdoRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(resourceGroup().id, functionApp.id, 'StorageBlobDataOwner'))
  scope: storageAccountExisting
  properties: {
    description: 'Storage Blob Data Owner assignment'
    principalId: functionApp.identity.principalId
    roleDefinitionId: roleStorageBlobDataOwnerDefinition.id
  }
}

// Create role assignment
resource saoRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(resourceGroup().id, functionApp.id, 'StorageAccountOwner'))
  scope: storageAccountExisting
  properties: {
    description: 'Storage Account Owner assignment'
    principalId: functionApp.identity.principalId
    roleDefinitionId: roleStorageAccountOwnerDefinition.id
  }
}

// Create role assignment
resource sqdcRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(resourceGroup().id, functionApp.id, 'StorageQueueDataContributor'))
  scope: storageAccountExisting
  properties: {
    description: 'Storage Queue Data Contributor assignment'
    principalId: functionApp.identity.principalId
    roleDefinitionId: roleStorageQueueDataContributorDefinition.id
  }
}
*/


output function_app string = functionApp.name
