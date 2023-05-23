@description('The identity id of the resource.')
param principalId string

@description('The type of principal you trying to assign a role to. Default is ServicePrincipal')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'
@description('The role definition id')
param roleDefinitionId string
@description('The name of the resource you are trying to assign a role to')
param assignmentResourceName string
@description('The role assignment description')
param roleAssignmentDesc string

//existing resource
resource assignmentResourceExisting 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: assignmentResourceName
}

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  scope: assignmentResourceExisting
  properties: {
    description: roleAssignmentDesc
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
