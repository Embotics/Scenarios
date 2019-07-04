# Enabling requesters to choose applications to deploy on a Kubernetes cluster with Embotics® vCommander®

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Embotics vCommander cloud management platform, you can deploy applications into Kubernetes clusters.

This guide shows you how to use vCommander to deploy a new application into an existing Kubernetes cluster. The requester chooses from a preconfigured list of applications (our example includes nginx, mongo and redis). The required manifest files are embedded in a completion workflow step. An optional approval workflow can be added to check the files before deploying, but an approval process is arguably less necessary, since requesters must choose from a fixed list of applications.

This guide is intended for systems administrators, engineers and IT professionals. Previous experience with Kubernetes is required.

## Prerequisites
- vCommander release 7.0.2 or higher

Before you begin, you must add a Kubernetes cluster as a managed system. You can do this in one of two ways:

- Add an existing Kubernetes cluster as a vCommander managed system. See [Adding a Kubernetes managed system](https://docs.embotics.com/vCommander/adding-kubernetes-managed-systems.htm) a Kubernetes Managed System.
- Create a new Kubernetes cluster through vCommander and have it automatically added as a vCommander managed system. To learn how, see [Workflow Extension Scenarios](https://support.embotics.com/support/solutions/folders/8000085541).

## Install the plug-in step package

This scenario uses the Kubernetes plug-in workflow step package (`wfplugins-k8s.jar`), which provides a plug-in workflow step to add the deployed Kubernetes cluster to vCommander’s inventory as a managed system. The completion workflow in this scenario reference this plug-in step.

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `k8s` directory, which contains the Kubernetes plug-in workflow step package. 

For information on how to download and install workflow plug-in steps, see [Adding plug-in workflow steps](https://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding).

## Import the completion workflow

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the repository.
2. In vCommander, go to **Configuration > Service Request Configuration > Completion Workflows** and click **Import**.
3. Go to the Scenarios repo that you cloned or downloaded, then from the `Enable-Requesters-to-Choose-Apps-to-Deploy-on-Kubernetes-Cluster` directory, select the `deploy-specific-apps-on-k8s`  .yaml or .json file, and click **Open**.

    vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
4. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.

    To learn more, see [Exporting and Importing Workflows](https://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm).

## Create a custom attribute

You must create a custom attribute to enable requesters to choose from a preconfigured list of applications to install.

The completion workflow includes manifest files for nginx, mongo and redis. You can customize the completion workflow with your own applications and manifest files; if you do so, then you must add custom attribute values that match the application names.

Create a list-type custom attribute named “Application to Install” with the following values:

- `nginx`
- `mongo`
- `redis`

To learn more about custom attributes, see [Using Custom Attributes to Add Infrastructure Metadata](https://docs.embotics.com/vCommander/configuring_custom_attributes.htm).

## Configure the change request form

1. Create a change request form named “Install Apps”.
2. From the Completion Workflow list, select **Deploy specific apps on K8s**.
3. Click **OK**.
4. In the Toolbox, click **Custom Attribute**. 
5. The Custom Attribute form element appears on the form. In the Custom Attribute list, select **Application to Install**.
6. Remove any unneeded form elements.
7. Click **Save**.

## Configure the completion workflow (optional)

The completion workflow includes manifest files for nginx, mongo and redis. You can customize the completion workflow with your own applications and manifest files; if you do so, you must add custom attribute values that match the application names.

1. Select the new workflow in the Completion Workflows list and click **Edit**. 
2. On the Steps page, click **Add > Kubernetes > Kubernetes Deploy Resource**. 
3. For **Step Name**, enter a name that indicates the application to be deployed. 
4. For **Namespace**, enter the namespace where the application will be deployed.
5. In **K8s YAML manifest**, paste the contents of a YAML manifest file for this application.
6. For **Deploy Type**, change the default setting, **Create** or **Update**, if needed.
7. Add more Kubernetes Deploy Resource steps for additional applications as required.
8. Click **Next**, **Next**, then **Finish**.

## Submit a change request

1. In vCommander or the Service Portal, select a Kubernetes managed system and run the **Request Change** command.
2. In the Select Change Request dialog, click **Install Apps**.
3. Complete the request form by selecting an application to install and click **OK**.
   The chosen application is installed on the selected Kubernetes cluster.

