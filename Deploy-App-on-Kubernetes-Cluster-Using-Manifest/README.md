# Deploying an Application into a Kubernetes Cluster Using a Manifest File

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Embotics® Commander® cloud management platform, you can deploy applications into Kubernetes clusters. 

This guide shows you how to use Commander 7.0.2 or greater to deploy a new application into an existing Kubernetes cluster. The requester provides input in the form of a Kubernetes manifest file. An optional approval workflow can be added to check the files before deploying. 

**Note:** The `readme.md` file packaged with the Kubernetes plug-in workflow step package documents important limitations to consider when uploading your own manifest file.

This guide is intended for systems administrators, engineers and IT professionals. Previous experience with Kubernetes is required.

## Prerequisites

Before you begin, you must add a Kubernetes cluster as a cloud account (managed system). You can do this in one of two ways:

- Add an existing Kubernetes cluster as a Commander cloud account. See [Adding Kubernetes Cloud Accounts](https://docs.embotics.com/commander/adding-kubernetes-cloud-accounts.htm).
- Create a new Kubernetes cluster through Commander and have it automatically added as a Commander cloud account. To learn how, search for "Kubernetes" on our [Knowledge Base](https://support.embotics.com/support/solutions/8000051955) and choose the article for your preferred platform for deploying Kubernetes clusters.

## Install the plug-in step package

This scenario uses the Kubernetes plug-in workflow step package (`wfplugins-k8s.jar`), which provides a plug-in workflow step to add the deployed Kubernetes cluster to Commander’s inventory as a cloud account. The completion workflow in this scenario reference this plug-in step.

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `k8s` directory, which contains the Kubernetes plug-in workflow step package. 

For information on how to download and install workflow plug-in steps, see [Adding plug-in workflow steps](https://docs.embotics.com/commander/Using-Plug-In-WF-Steps.htm#Adding).

## Import the completion workflow

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the repository.
1. In Commander, go to **Configuration > Service Request Configuration > Completion Workflows** and click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploy-App-on-Kubernetes-Cluster-Using-Manifest` directory, select the `deploy-on-k8s`  .yaml or .json file, and click **Open**.
   Commander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.

​        To learn more, see [Exporting and Importing Workflow Definitions](https://docs.embotics.com/commander/exporting-and-importing-workflows.htm).

##  Configure the change request form

1. In Commander, go to **Configuration > Service Request Configuration**, then click the **Form Designer** tab.
1. Click **Add**, and in the Add Request Form dialog, for **Form Name**, type “Deploy K8s App”.
1. From the **Form Type** list, select **Change Request Form**.
1. From the **Target Type** list, select **Cloud Account**.
1. From the **Completion Workflow** list, select **Deploy on K8s**.
1. Click **OK**.
1. From the Toolbox at the right side of the window, add the following form elements:
  - **Input Text Field**: For Display Label, enter “Namespace”.
     **Note:** If a namespace is specified, it must already exist when the completion workflow runs. If no namespace is specified, Commander checks the manifest file for the namespace; if the manifest doesn’t specify a namespace, the Default namespace is used. Therefore, you may want to disable the **Required** checkbox for this Input Text Field form element.
  - **File Upload**: For Display Label, enter “Manifest”. Enable the **Required** checkbox.
8. Remove unneeded form elements.
9. Click **Save**.

## Submit a change request

1. In Commander or the Service Portal, select a Kubernetes cloud account and run the **Request Change** command.
1. If you have multiple service change request forms available for cloud accounts, in the Select Change Request dialog, click **Deploy K8s App**.
1.  In the Request Service Change dialog, complete the request form by entering a Namespace, browsing to a manifest file, and clicking **OK**.

The chosen application is installed on the selected Kubernetes cluster.
