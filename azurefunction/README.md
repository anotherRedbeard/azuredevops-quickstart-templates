# Azure Functions

This folder contains a sample Azure Functions project with an Azure deployment pipeline example.  I created this example using the [documentation created by the Functions team](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-csharp?tabs=in-process) and I recommend that you get familiar with that doc in order to better understand what is in this folder.  The doc will tell you all the pre-requisites that you will need to run this project locally.

## Folder Structure

Notice this doesn't follow our similar pattern of having an iac and src folder as siblings under the root folder.
```bash
 -resource (i.e. azurefunction)
   -src
   -iac
   azure-pipelines.yml
```

Instead it has all the src files under the root folder like this
```bash
 -resource (i.e. azurefunction)
   -iac
   -.vscode
   <all the src files/folders>
   azure-pipelines.yml
```

This is due to how the cli creates the functions app/project for you.  At some point I might go back and figure out if it can be modified by passing in a 'root', but my early attempts were unsuccessful so we have this for now.

## Local

To run the project locally, you will need to do the following:

### VS Code
- Clone repo
- Create new `src/local.settings.json` in project root and make sure it has the following variables:
  ```json
{
    "IsEncrypted": false,
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet"
    }
}
  ```

### DevOps

The `azure-pipelines.yml` file represents an example of how you can build and deploy (CI/CD) this standard logic app into a lower and higher level environment from your source control repo.  This is fairly straight-forward pipeline, but I'll call out some things below to notice. I created this using the [documentation created by Functions team](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-csharp?tabs=in-process)

- The overall flow of the `azure-pipelines.yml` file is to package up the files that will be used to deploy the infrastructure and the code into artifacts, then deploy them to Azure.
  - The infrastructure piece is using Bicep templates and is stored in the `iac` folder.  This is all the templates you will need to create all the resources you need to stand-up a Logic App (standard, single-tenant).
  - The code piece is stored in teh `src` folder and what is getting archived into a `{BuildId}.zip` file that gets deployed to Azure.

#### Transform Managed API Connections

For managed API connections we are manipulating the `connections.json` file in the `{BuildId}.zip` archive by using the [File Transform task using JSON variable substitution](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/transforms-variable-substitution?view=azure-devops&tabs=yaml#json-variable-substitution). The basic usage pattern is that you supply variables using 'dot' notation for the objects and the file transform updates the values within the file.

>*For example*, let's say you have a `.json` file that looks like this and you wanted to replace the type value:

```json
{
  {
  "managedApiConnections": {
      "authentication": {
        "type": "Raw"
      }
    }
  }
}

```

>Yaml code:

```yaml
# setting variables for the connections.json file that need to be transformed to work in Azure
  variables:
    managedApiConnections.authentication.type: 'ManagedServiceIdentity'

# Update connections.json via FileTransform task using variables above
    - task: FileTransform@1
      displayName: 'File transformation: connections.json'
      inputs:
        folderPath: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'
        targetFiles: '**/connections.json'
        fileType: json

```

#### Transform Azure Functions Connections

*comming soon*


#### Parameters

*comming soon*