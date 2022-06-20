// =========== logic-service.bicep ===========
@allowed([
  'dev'
  'tst'
  'prd'
])
param environment string
param name string
param logwsid string
param location string = resourceGroup().location
param location_prefix string

// Set minimum of 2 worker nodes in production
//var minimumElasticSize = ((environment == 'prd') ? 2 : 1)

// =================================

// Storage account for the service
resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
name: 'st${name}${environment}'
location: location
kind: 'StorageV2'
sku: {
  name: 'Standard_GRS'
}
properties: {
  supportsHttpsTrafficOnly: true
  minimumTlsVersion: 'TLS1_2'
}
}

// Dedicated app plan for the service
resource plan 'Microsoft.Web/serverfarms@2021-02-01' = {
name: 'red-${location_prefix}-${name}-asp-${environment}'
location: location
sku: {
  tier: 'WorkflowStandard'
  name: 'WS1'
}
properties: {
  targetWorkerCount: 1 //minimumElasticSize
  maximumElasticWorkerCount: 1 //20
  elasticScaleEnabled: true
  isSpot: false
  zoneRedundant: false
}
}

// Create application insights
resource appi 'Microsoft.Insights/components@2020-02-02' = {
name: 'red-${location_prefix}-${name}-ai-${environment}'
location: location
kind: 'web'
properties: {
  Application_Type: 'web'
  Flow_Type: 'Bluefield'
  publicNetworkAccessForIngestion: 'Enabled'
  publicNetworkAccessForQuery: 'Enabled'
  Request_Source: 'rest'
  RetentionInDays: 30
  WorkspaceResourceId: logwsid
}
}

// App service containing the workflow runtime
resource site 'Microsoft.Web/sites@2021-02-01' = {
name: 'red-${location_prefix}-${name}-las-${environment}'
location: location
kind: 'functionapp,workflowapp'
identity: {
  type: 'SystemAssigned'
}
properties: {
  httpsOnly: true
  siteConfig: {
    appSettings: [
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~3'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'node'
      }
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '~12'
      }
      {
        name: 'AzureWebJobsStorage'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'WEBSITE_CONTENTSHARE'
        value: 'app-${toLower(name)}-logicservice-${toLower(environment)}a6e9'
      }
      {
        name: 'AzureFunctionsJobHost__extensionBundle__id'
        value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
      }
      {
        name: 'AzureFunctionsJobHost__extensionBundle__version'
        value: '[1.*, 2.0.0)'
      }
      {
        name: 'APP_KIND'
        value: 'workflowApp'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
      {
        name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
        value: '~2'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appi.properties.ConnectionString
      }
    ]
    use32BitWorkerProcess: true
  }
  serverFarmId: plan.id
  clientAffinityEnabled: false
}
}

// Azure Queues connection
resource logicAppConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azurequeues-${environment}'
  location: location
  properties: {
    displayName: 'connect-to-azurequeue'
    parameterValues: { }
    api: {
      name: 'azurequeues'
      displayName: 'Azure Queues'
      description: 'Azure Queue storage provides cloud messaging between application components. Queue storage also supports managing asynchronous tasks and building process work flows.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1546/1.0.1546.2665/azurequeues/icon.png'
      brandColor: '#0072C6'
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/azurequeues'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [ 
      {
        requestUri: '${az.environment().resourceManager}/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/azurequeues/extensions/proxy/testConnection?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

// Return the Logic App service name and farm name
output app string = site.name
output plan string = plan.name
