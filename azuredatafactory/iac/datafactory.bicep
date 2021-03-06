
param dataFactoryName string = 'red-demo-adf-dev'
param location string = resourceGroup().location
param environment string = 'development'

// @allowed([
//   'FactoryVSTSConfiguration'
//   'FactoryGitHubConfiguration'
// ])
param repositoryType string = 'FactoryGitHubConfiguration'
param projectName string  = 'Sandbox'
param repositoryName string = 'azuredevops-quickstart-templates'
param accountName string = 'anotherRedbeard'
param collaborationBranch string = 'main'
param rootFolder string = '/azuredatafactory/src'

var azDevopsRepoConfiguration = {
  accountName: accountName
  repositoryName: repositoryName
  collaborationBranch: collaborationBranch
  rootFolder: rootFolder  
  type: repositoryType
  projectName: projectName
}

var gitHubRepoConfiguration = {
  accountName: accountName
  repositoryName: repositoryName
  collaborationBranch: collaborationBranch
  rootFolder: rootFolder  
  type: repositoryType
}

var properties = {
  repoConfiguration: (repositoryType == 'FactoryVSTSConfiguration') ? azDevopsRepoConfiguration : gitHubRepoConfiguration 
}


resource dataFactoryName_resource 'Microsoft.DataFactory/factories@2018-06-01' =  {
  name: dataFactoryName
  location: location

  properties: (environment == 'development') ? properties : {}
  
  identity: {
    type: 'SystemAssigned'
  }  
}
