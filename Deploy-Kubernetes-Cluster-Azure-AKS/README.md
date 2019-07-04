# Deploying a Kubernetes Cluster on Azure AKS with Embotics® vCommander®

This project enables you to use an ARM template to deploy an Azure Container Service (AKS) cluster with vCommander and add the deployed cluster to vCommander's inventory as a managed system.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

* vCommander release 7.0.2 or greater
* Add an Azure subscription as a vCommander managed system. See [Adding Azure Managed Systems](https://docs.embotics.com/vCommander/adding-azure-managed-systems.htm) to learn how.

## Install plug-in workflow step packages

This scenario uses the following plug-in workflow steps:

- Kubernetes plug-in workflow step package (`wfplugins-k8s.jar`), which provides a plug-in workflow step to add the deployed Kubernetes cluster to vCommander’s inventory as a managed system
- Azure plug-in workflow step package (`wfplugins-azure.jar`), which provides a plug-in workflow step to retrieve the kubeconfig of an AKS Kubernetes cluster created through an Azure template in a vCommander service

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `k8s` and `azure` directories, which contain the Kubernetes and Azure plug-in workflow step packages. 

To learn how to download and install workflow plug-in steps, see [Adding plug-in workflow steps](https://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Addingpluginworkflowsteps).

## Download scenario files

Go to [Embotics GitHub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the `Deploy-Kubernetes-Cluster-Azure-AKS` repository. Then install the following workflows: 

Download the following files from this project:

- `aks.template`: an ARM template that you will add to the service catalog
- `add-aks-cluster.yaml`: a vCommander completion workflow for Cloud Template components that you will import

## Import the completion workflow

Import a vCommander completion workflow to complete the provisioning and configuration of the cluster. 

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the repository.
1. In vCommander, go to **Configuration > Service Request Configuration > Completion Workflows** and click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploy-Kubernetes-Cluster-Azure-AKS` directory, select the `add-aks-cluster.yaml` file, and click **Open**.
   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.

​        To learn more, see [Exporting and Importing Workflow Definitions](https://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm).

## Generate an SSH public key

You must have a valid SSH public key that vCommander can use to connect with the Azure portal. You should generate the key on the same machine on which vCommander has been installed. 

You can use a tools such as PuTTYgen or ssh-keygen depending on your environment. 

## Create the required Azure objects

This section describes how to prepare Azure for AKS.

### Create a resource group

A resource group is required to create AKS cluster resources. The top-level resource group can be used, but here we're creating a dedicated resource group.

The resource group can be created from either the Azure CLI or the portal.

#### From CLI

Choose a name and location for the resource group.

```
$ az group create --name AKS-Resource-Group --location eastus
{
  "id": "/subscriptions/5823acf6-3825-4ad9-bc87-719962439177/resourceGroups/AKS-Resource-Group",
  "location": "eastus",
  "managedBy": null,
  "name": "AKS-Resource-Group",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null
}
```

#### From Portal

1. In the Azure portal, select **Resource Groups** and click **+ Add**. Enter a name and select a subscription and location. 
1. Click **Create**.


### Create a service principal

A service principal is required to deploy an AKS Kubernetes cluster. You can create the service principal from either the Azure CLI or the portal.

#### From CLI

Choose a name for the service principal, such as "AKS-SP".
```
$ az ad sp create-for-rbac --name AKS-SP
{
  "appId": "da5ba8fc-6fce-4fb1-8cbd-99c6edce1f7a",
  "displayName": "AKS-SP",
  "name": "http://AKS-SP",
  "password": "37c2ab86-368a-4bc7-adb9-50642a65efbc",
  "tenant": "65d36aa6-46ad-4368-9c57-dfc18a3f69f7"
}
```

#### From Portal

1. In the Azure portal, select **Azure Active Directory** > **App registrations** > **New application registration**.
1. For information on how to create a service principal, see https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal and perform the following procedures:
  - **Create an Azure Active Directory application**
  - **Assign the application to a role**
  - **Get values for signing in**
1. The appropriate permissions for assigning roles are required to create the Application Registration.  Refer to the  **Required permissions** section in the Microsoft page for more information. 

## Create a vCommander deployment destination

For general information on creating a deployment destination for Azure, see [Configuring Automated Deployment for Approved Service Requests](https://docs.embotics.com/vCommander/config_auto_placement_depl_vms.htm). 

**Notes:** 

- On the Target page, select the resource group created earlier, for example `AKS-Resource-Group`.
- On the Subnets page, select any subnet from **Available Subnets** and move it to **Configured Subnets**. If no subnets are available, you must create one in Azure. This subnet is not used by AKS, but selecting one is necessary to set up a deployment destination.

## Create a service catalog entry for users to request

1. In vCommander, go to **Configuration > Service Request Configuration > Service Catalog**.
1. Click **Add Service**.
1. Enter a service name and description, then click **Next**. 
1. On the Component Blueprints page, click **Add** > **ARM Template**.
1. In the Add ARM Template dialog, click **File**, **Add**, and browse to the Scenarios repo that you cloned or downloaded. Then from the `Deploy-Kubernetes-Cluster-Azure-AKS` directory, select the `aks.template` file and click **OK**. 
1. On the ArmTemplate component page, change the component name to something more descriptive, such as "AKS ARM Template". 
1. Assign the downloaded completion workflow to the component.
1. Now, set up the request form for this component. On the Form tab, under the Toolbox on the right, click **Input Text Field**. 
1. For the Input Text Field component that is added to the form, enter "Kubernetes Cluster Name" for the **Display Label** and click **OK**. 
1. Now we configure parameters required by the ARM template. On the Parameters tab, enter the following parameter values:
  * **dnsPrefix**: `#{form.inputField['Kubernetes Cluster Name']}`
  * **resourceName**: `#{form.inputField['Kubernetes Cluster Name']}`
  * **kubernetesVersion**: Required Kubernetes version: [List of supported Kubernetes versions](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)
  * **servicePrincipalClientId**: ID of service principal created above
  * **servicePrincipalClientSecret**: Password/key of service principal created above
  * **sshRSAPublicKey**: Contents of `~/.ssh/id_rsa.pub`
1. Modify the other parameters as needed. 
1. On the Summary page, click **Finish**. 
1. Click **Finish** again to create the service.


## Submit a service request

The service is now configured and ready to test. 
1. In vCommander or the Service Portal, go to the Service Catalog and request the service you just created. 
1. On the Component form, enter a cluster name and click **Submit**. 

    The deployed cluster will automatically be added to vCommander as a managed system.
