# Deploying a Kubernetes Cluster on Azure AKS with Embotics vCommander

This project enables you to use an ARM template to deploy an Azure Container Service (AKS) cluster with vCommander and add the deployed cluster to vCommander's inventory as a managed system.

## Prerequisites

* vCommander release 7.0 or greater
* Add an Azure subscription as a vCommander managed system. See [Adding a Managed System](http://docs.embotics.com/index.html?adding_a_managed_system.htm) to learn how.

## Install two plug-in step packages

Go to the [Embotics GitHub Repository](https://github.com/Embotics/Plug-in-Workflow-Steps) and download and install the following plug-in workflow step packages: 

- azure
- k8s

The completion workflow in this scenario references plug-in steps in these packages.

To learn how to install workflow plug-in steps, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding). 

## Download scenario files

Download the following files from this project:

- `aks.template` - an ARM template that you will add to the service catalog
- `Add AKS Cluster.yaml` - a vCommander completion workflow for Cloud Template components that you will import

## Import the workflow

Import a vCommander completion workflow to complete the provisioning and configuration of the cluster. 

1. In vCommander, go to **Configuration > Service Request Configuration > Completion Workflow**.
2. Click **Import** and browse to the **Add AKS Cluster.yaml** file you downloaded.
3. vCommander automatically validates the workflow. Click **Import**.

## Create the required Azure objects

This section describes how to prepare Azure for AKS.

### Create a resource group

A resource group is required to create AKS cluster resources.  The top-level resource group can be used, but here we're creating a dedicated resource group.

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

1. In the Azure portal, select **Resource Groups** and click **+ Add**.  Enter a name and select a subscription and location. 

2. Click **Create**.


### Create a service principal

A service principal is required to deploy an AKS Kubernetes cluster.  You can create the service principal from either the Azure CLI or the portal.

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

2. Enter the service principal name and a sign-on URL.  You may enter any valid URL.

3. Click **Create**. 

4. Click **Settings > Keys**.  Enter a Description and select a Duration.  Click **Save**. 

5. **Important:** Copy and save the displayed key value!  You will not be able to access it later.

6. Now give permission to the service principal to manage the resource group.

7. Select the previously created resource group. Click **Access Control (IAM)**.

8. Click **+ Add** to add the service principal.

9. Select **Contributor** for the Role.  Under **Select**, enter the service principal name. 

10. Click **Save**.


## Create a vCommander deployment destination

For general information on creating a deployment destination for Azure, see [Configuring Automated Deployment for Approved Service Requests](http://docs.embotics.com/index.html?config_auto_placement_depl_vms.htm#config_dest_arm). 

Note the following: 

- On the Target page, select the resource group created earlier, for example AKS-Resource-Group.
- On the Subnets page, select any subnet from Available Subnets and move it to Configured Subnets.  If no subnets are available, you must create one in Azure. This subnet is not used by AKS, but selecting one is necessary to set up a deployment destination.

## Create a service catalog entry for users to request

1. In vCommander, go to **Configuration > Service Request Configuration > Service Catalog**.

2. Click **Add Service**.

3. Enter a service name and description. 

4. On the Component Blueprints page, click **Add** **>** **ARM Template**.

5. Browse to the downloaded `aks.template` file and click **OK**. 

6. Change the component name to something more descriptive, such as "AKS ARM Template". 
7. Assign the downloaded completion workflow to the component.
8. Now, set up the request form for this component. On the Form tab, under the Toolbox, click **Input Text Field**. 
9. For the Display Label, enter "Kubernetes Cluster Name".  Click **OK**. 
10. Now we configure parameters required by the ARM template. On the Parameters tab, enter the following parameter values:

* dnsPrefix: #{form.inputField['Kubernetes Cluster Name']}
* resourceName: #{form.inputField['Kubernetes Cluster Name']}
* servicePrincipalClientId: ID of service principal created above
* servicePrincipalClientSecret: Password/Key of service principal created above
* sshRSAPublicKey: Contents of ~/.ssh/id_rsa.pub

11. Modify the other parameters as needed. 

12. On the Summary page, click **Finish**. 
13. Click **Finish** again to create the service.


## Submit a service request

The service is now configured and ready to test. 

1. In vCommander or the Service Portal, go to the Service Catalog and request the service you just created. 

2. On the Component form, enter a cluster name and click **Submit**. 


The deployed cluster will automatically be added to vCommander as a managed system.