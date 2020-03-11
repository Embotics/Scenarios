# Deploying an NSX Edge

This scenario explores using Commander to deploy a new VMware NSX Edge Services Gateway.

## Prerequisites
* NSX and vSphere API endpoints accessible to Commander
* PowerNSX PowerShell module

## Scenario setup
You'll need the PowerNSX module installed on the Commander server as well as access to the API. The provided workflow YAML uses a Commander Credential. See the main NSX Scenarios README file for instructions on how to add the credential.

### Create the completion workflow
Create the completion workflow either by importing the provided YAML file `Create NSX Edge.yml` or by adding the script yourself to a new workflow.

If creating a new workflow, the target type should be "After a custom component." You can use the `NSX_CreateEdge.ps1` script in an embedded script workflow step directly or use it as a starting place for further modifications.

### Create the service catalog entry
1. In Commander, create a new Self-Service catalog entry.
2. Add a custom component with an appropriate name (such as "NSX Load Balancer")
3. For that component choose the completion workflow we created in the previous step

### Submit the service request
Request the service through the portal or in the Commander admin console.
When approved, Commander will immediately run the Completion workflow for the custom component. If all goes well, you'll have a new NSX Edge device deployed to your cluster!

### NOTE
You must have a functional Virtual Distributed Switch for advanced NSX features to function (such as Load Balancing). A work around using standard networks is available in `NSX_CreateEdge_DVPGWorkaround.ps1` but is not recommended for use in production.

The workaround still requires a "dummy" DVPG to deploy the edge but then forces the adapter to connect to a standard network after deployment.
