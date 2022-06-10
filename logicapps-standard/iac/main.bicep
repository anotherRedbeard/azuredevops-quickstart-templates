// =========== main.bicep ===========
@minLength(1)
@description('The location of the logic app.')
param location string = resourceGroup().location

@description('Prefix for location to add to name')
param location_prefix string

@maxLength(10)
@minLength(2)
@description('The name of the logic app to create.')
param logic_app_name string 

@allowed([
  'dev'
  'tst'
  'prd'
])
@description('The name of the environment.')
param environment string

// =================================

// Create Log Analytics workspace
module logws './log-analytics-ws.bicep' = {
  name: 'LogWorkspaceDeployment'
  params: {
    environment: environment
    name: logic_app_name
    location: location
    location_prefix: location_prefix
  }
}

// Deploy the logic app service container
module logic './logic-app-std.bicep' = {
  name: 'LogicAppServiceDeployment'
  params: { // Pass on shared parameters
    environment: environment
    name: logic_app_name
    logwsid: logws.outputs.id
    location: location
    location_prefix: location_prefix
  }
}

output logic_app string = logic.outputs.app
output logic_plan string = logic.outputs.plan
