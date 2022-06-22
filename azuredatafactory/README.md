# Azure Data Factory

## Overview
This folder project is using the new way to deploy ADF using azure pipelines.  I used the [Azure Data Factory CI-CD made simple: Building and deploying ARM templates with Azure DevOps YAML Pipelines][4] article to build out this working pipeline.  Like the other folder projects in this repo the Bicep templates (Infrastructure) is in the `iac` directory and the source for ADF is in the `src` directory.

### Working with Parameters
What I typically do is add global parameters and then reference those everywhere.  Then in your build you can override the global parameters with the values that you want.

So from your 'child' pipelines, you would create a pipeline parameter, and the value of that parameter would be the global parameter name like this:

[![enter image description here][1]][1]

[![enter image description here][2]][2]

Here are a couple of links on the specifics of global parameters and how to override them in a pipeline:

- [ADF Release - Set global params during deployment][5]
- [Global parameters in Azure Data Factory][3]


  [1]: https://i.stack.imgur.com/e36qO.png
  [2]: https://i.stack.imgur.com/jZs9B.png
  [3]: https://docs.microsoft.com/en-us/azure/data-factory/author-global-parameters
  [4]: https://towardsdatascience.com/azure-data-factory-ci-cd-made-simple-building-and-deploying-your-arm-templates-with-azure-devops-30c30595afa5
  [5]: https://microsoft-bitools.blogspot.com/2021/11/adf-snack-set-global-params-during.html
*work in progress*
