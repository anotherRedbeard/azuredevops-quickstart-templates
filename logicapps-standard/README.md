# Logic Apps (Standard, Single-tenant)

This folder contains a sample Logic App (standard, single-tenant) project with an Azure deployment pipeline example.  I created this example using the [documentation created by the Logic Apps team](https://docs.microsoft.com/en-us/azure/logic-apps/create-single-tenant-workflows-visual-studio-code) and I recommend that you get familiar with that doc in order to better understand what is in this folder.  The doc will tell you all the pre-requisites that you will need to run this project locally.

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
      "WORKFLOWS_TENANT_ID": "<tenant_id>",
      "WORKFLOWS_SUBSCRIPTION_ID": "<subscription_id>",
      "WORKFLOWS_RESOURCE_GROUP_NAME": "<resource_group_name",
      "WORKFLOWS_LOCATION_NAME": "<location>",
      "WORKFLOWS_MANAGEMENT_BASE_URI": "https://management.azure.com/",
      "Workflows.WebhookRedirectHostUri": "<ngrok_host_ip>.ngrok.io",
      "azurequeues-connectionKey": "<my_azure_queue_key>",
      "FUNCTIONS_WORKER_RUNTIME": "node"
    }
  }
  ```

### Create Azure Queue

This example uses a Queue within a storage account.  I am working on getting this to be part of the infrastructure deployment, but for now you will need to make sure and create a new queue called `logicappmessages` in the storage account that you are targeting.  Locally it would be your azurite account, in the Azure portal it would be the Azure storage account.

### Managed API Connections

This project uses an Azure Queue inside of a storage account.  You can see the managed api connection in the `connections.json` file.  Inside your `local.settings.json` file you will see the "azurequeues-connectionKey" which is used to store a temporary ({n} days) token that you can use to connect to the queue while you are creating your logic app. Most likely you will need to re-create this connection in the workflow designer the first time you use this.  When this project is deployed to Azure it will be using a [managed identity](https://docs.microsoft.com/en-us/azure/logic-apps/create-managed-service-identity?tabs=standard), so once this is deployed that token won't be used.

### DevOps (Standard, Single-tenant)

The `azure-pipelines.yml` file represents an example of how you can build and deploy (CI/CD) this standard logic app into a lower and higher level environment from your source control repo.  This is fairly straight-forward pipeline, but I'll call out some things below to notice. I created this using the [documentation created by Logic Apps team](https://docs.microsoft.com/en-us/azure/logic-apps/devops-deployment-single-tenant-azure-logic-apps)

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

The last thing you will need to do is to go out to the Azure Portal the first time a new connection is created and create an access policy for it.  The zip deployment does not create these settings for you so you have to create it and give the service principal (managed identity) of the Logic App Contributor to the queue in the storage account (since this example is connecting to an Azure Storage Queue).  See [After release to Azure section of the doc](https://docs.microsoft.com/en-us/azure/logic-apps/set-up-devops-deployment-single-tenant-azure-logic-apps?tabs=azure-devops#after-release-to-azure).

#### Transform Azure Functions Connections

*work in progress*


#### Parameters

*work in progress*
