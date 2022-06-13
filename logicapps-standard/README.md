# Getting started with this repo

- Clone repo
- Create new `src/local.settings.json` in project root
- Use this a template for your `local.settings.json` file:

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