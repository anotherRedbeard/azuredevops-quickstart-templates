# Azure DevOps Quickstart

This folder contains several example (simple) Azure resources that provide a quick start to get something up and running and deploying to Azure using Yaml Pipelines in Azure DevOps.  More will be added as I have time so please keep checking in to see what's new.

## Structure

The structure of this folder is pretty basic.  We have the resource main directory then a src and iac sibling directories to store both the Infrastructure as Code and the Source Code for the resource.  Again these aren't meant to be complex examples, just something to give the basic idea of how to get your resource build as part of the Software Development Lifecycle (SDLC) using Continuous Integration and Continuous Delivery/Deployment (CI/CD).

### Folder Structure

```bash
 -resource (i.e. azurefunction)
   -src
   -iac
   azure-pipelines.yml
```

### How to use

This is meant to be a repo that you can clone and use as you like.  The only expectation is that since everything is in the same repo, you will want to navigate to each resource folder individually to work with that particular resource so everything builds as it should.  I recommend using `Visual Studio Code (VSCode)`.  Should you navigate out to the main folder using VSCode, you will likely see an error like this:

![Multi-root image](/docs/multiRootImage.png)

You don't need to do anything with this, just remember before you do any work open the specific resource folder using `VSCode`.

### Exceptions

Should there be any specific instructions or exceptions to these basic guidelines, just follow the README in each of the resource specific folders.

### Contributing

Please submit issues if you have any suggestions or questions or if something isn't working as expected.

#### Thanks!