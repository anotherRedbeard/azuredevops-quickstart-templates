using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace azurefunction
{
    public static class BlobTriggerDemo
    {
        [FunctionName("BlobTriggerDemo")]
        public static void Run(
            [BlobTrigger("dotnet/{name}", Connection = "AzureWebJobsStorage")] byte[] myBlob,
            string name,
            ILogger log)
        {
            log.LogInformation($"Blob trigger function processed blob: {name}");
        }
    }
}