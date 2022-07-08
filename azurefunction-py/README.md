# Azure Functions

This folder contains a sample Azure Functions project with an Azure deployment pipeline example.  I created this example using the [documentation created by the Functions team](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python) and I recommend that you get familiar with that doc in order to better understand what is in this folder.  The doc will tell you all the pre-requisites that you will need to run this project locally.

I did run into a problem trying to run my python function using the typically debug function (F5).  

- When I would go to debug it would display the following message:  
    ![Azure function python debug error](../docs/pyDebugError.png)

  - What I did to fix this was to just run `func host start` from the command line.
  
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
            "FUNCTIONS_WORKER_RUNTIME": "python",
            "blobstoragetriggerpyacct_STORAGE": "<connection string from portal storage account>"
        }
    }
    ```

### DevOps

The `azure-pipelines.yml` file represents an example of how you can build and deploy (CI/CD) this standard logic app into a lower and higher level environment from your source control repo.  This is fairly straight-forward pipeline, but I'll call out some things below to notice. I created this using the [documentation created by Functions team](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-azure-devops?tabs=dotnet-core%2Cyaml%2Ccsharp)

- The overall flow of the `azure-pipelines.yml` file is to package up the files that will be used to deploy the infrastructure and the code into artifacts, then deploy them to Azure.
  - The infrastructure piece is using Bicep templates and is stored in the `iac` folder.  This is all the templates you will need to create all the resources you need to stand-up a Functions App.
  - The code piece is stored in the `publish_output` folder that was created when I used the Publish task to publish the app.  That is what is getting archived into a `build${BuildId}.zip` file that gets deployed to Azure.

#### Parameters

*will be updated soon*