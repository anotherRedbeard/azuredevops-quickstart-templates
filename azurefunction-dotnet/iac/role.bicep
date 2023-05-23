@description('The identity id of the resource.')
param principalId string

@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'
param roleDefinitionId string
param blobStorageAccountTriggerName string
@description('The role assignment name')
param roleAssignmentName string
@description('The role assignment description')
param roleAssignmentDesc string

//existing storage account
resource storageAccountExisting 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: blobStorageAccountTriggerName
}
/*
// Get role definition from the guid
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: roleDefinitionId
}

// Create role assignment, you will need write access on the subscription to add this role assignment which is above 
// the contributor role
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(resourceGroup().id, principalId, roleAssignmentName))
  scope: storageAccountExisting
  properties: {
    description: roleAssignmentDesc
    principalId: principalId
    roleDefinitionId: roleDefinition.id
  }
}
*/

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  scope: storageAccountExisting
  properties: {
    description: roleAssignmentDesc
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
