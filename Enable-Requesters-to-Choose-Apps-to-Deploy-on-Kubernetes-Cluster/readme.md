# Enabling requesters to choose  applications to deploy on a Kubernetes cluster with Embotics® vCommander®

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Embotics vCommander cloud management platform, you can deploy applications into Kubernetes clusters.

This guide shows you how to use vCommander 7.0+ to deploy a new application into an existing Kubernetes cluster. The requester chooses from a preconfigured list of applications (our example includes nginx, mongo and redis). The required manifest files are embedded in a completion workflow step. An optional approval workflow can be added to check the files before deploying, but an approval process is arguably less necessary, since requesters must choose from a fixed list of applications.

This guide is intended for systems administrators, engineers and IT professionals. Previous experience with Kubernetes is required.

## Prerequisites

Before you begin, you must add a Kubernetes cluster as a managed system. You can do this in one of two ways:

- Add an existing Kubernetes cluster as a vCommander managed system. See Adding a Kubernetes Managed System in the vCommander 7.0 User Guide.
- Create a new Kubernetes cluster through vCommander and have it automatically added as a vCommander managed system. To learn how, see: [[LINKS TO KB ARTICLES FOR DEPLOYING K8S CLUSTER]]

## Install the plug-in step package

Go to the Embotics GitHub repository located at https://github.com/Embotics/Plug-in-Workflow-Steps and download the Kubernetes workflow plug-in step package, **wfplugins-k8s.jar**.

Install the workflow plug-in step package. To learn how, see Adding Workflow Plug-In Steps in the vCommander 7.0 User Guide.

## Import the completion workflows

1. Go to the Embotics GitHub repository located at https://github.com/Embotics/Scenarios and download the Deploy_specific_apps_on_K8s completion workflow definition.
   You can download either the .yaml file or the .json file.
3. In vCommander, go to **Configuration > Completion Workflows** and click **Import**.
4. Browse to the .yaml or .json file you downloaded and click **Open**.
   vCommander automatically validates the workflow. 
6. Click **Import**.

To learn more, see “Importing and Exporting Workflows” in the vCommander 7.0 User Guide.

## Create a custom attribute

You must create a custom attribute to enable requesters to choose from a preconfigured list of applications to install.

The completion workflow includes manifest files for nginx, mongo and redis. You can customize the completion workflow with your own applications and manifest files; if you do so, then you must add custom attribute values that match the application names.

Create a list-type custom attribute named “Application to Install” with the following values:

- nginx
- mongo
- redis

To learn more about custom attributes, see Using Custom Attributes to Add Infrastructure Metadata.

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
2. On the Steps page, click **Add > K8S_DEPLOY**. 
3. For Step Name, enter a name that indicates the application to be deployed. 
4. For Namespace, enter the namespace where the application will be deployed.
5. In the K8s YAML manifest, paste the contents of a YAML manifest file for this application.
6. For Deploy Type, change the default setting, **Create** or **Update**, if needed.
7. Add more K8s_DEPLOY steps for additional applications as required.
8. Click **Next**, **Next** and **Finish**.

## Submit a change request

1. In vCommander or the Service Portal, select a Kubernetes managed system and run the **Request Change** command.
2. In the Select Change Request dialog, click either **Deploy K8s App** or **Install Apps**.
3. Complete the request form by selecting an application to install and click **OK**.
   The chosen application is installed on the selected Kubernetes cluster.

