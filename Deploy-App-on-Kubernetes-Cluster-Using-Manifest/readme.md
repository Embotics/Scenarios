# Deploying an Application into a Kubernetes Cluster Using a Manifest File

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Embotics vCommander cloud management platform, you can deploy applications into Kubernetes clusters. 

This guide shows you how to use vCommander 7.0+ to deploy a new application into an existing Kubernetes cluster. The requester provides input in the form of a Kubernetes manifest file. An optional approval workflow can be added to check the files before deploying. 

**Note:** The readme.md file packaged with the Kubernetes plug-in workflow step package documents important limitations to consider when uploading your own manifest file.

This guide is intended for systems administrators, engineers and IT professionals. Previous experience with Kubernetes is required.

## Prerequisites

Before you begin, you must add a Kubernetes cluster as a managed system. You can do this in one of two ways:

- Add an existing Kubernetes cluster as a vCommander managed system. See [Adding a Kubernetes Managed System](http://docs.embotics.com/vCommander/adding_a_managed_system.htm#add_k8s) in the vCommander 7.0 User Guide.
- Create a new Kubernetes cluster through vCommander and have it automatically added as a vCommander managed system. To learn how, search for "Kubernetes" on our [Knowledge Base](https://support.embotics.com/support/solutions/8000051955) and choose the article for your preferred platform for deploying Kubernetes clusters.

## Install the plug-in step package

Go to the Embotics GitHub repository located at https://github.com/Embotics/Plug-in-Workflow-Steps and download the Kubernetes workflow plug-in step package, **wfplugins-k8s.jar**.

Install the workflow plug-in step package. To learn how, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Adding-Pluggable-WF-Steps.htm) in the vCommander 7.0 User Guide.

## Import the completion workflows

1. Go to the Embotics GitHub repository located at https://github.com/Embotics/Scenarios and download the **Deploy_on_K8s** completion workflow definition.
   You can download either the .yaml file or the .json file.

2.  In vCommander, go to **Configuration > Completion Workflows** and click **Import**.

3. Browse to the .yaml or .json file you downloaded and click **Open**.
   vCommander automatically validates the workflow.

4. Click **Import**.

To learn more, see [Importing and Exporting Workflows](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm) in the vCommander 7.0 User Guide.

##  Configure the change request form

1. Create a change request form called “Deploy K8s App”.
2. From the Completion Workflow list, select **Deploy on K8s**.
3. Click **OK**.
4. Add the following form elements:
     **Input Text Field**: For Display Label, enter “Namespace”.
     **Note:** If a namespace is specified, it must already exist when the completion workflow runs. If no namespace is specified, vCommander checks the manifest file for the namespace; if the manifest doesn’t specify a namespace, the Default namespace is used. Therefore, you may want to disable the **Required** checkbox for the Input Text Field form element.
     **File Upload**: For Display Label, enter “Manifest”.
     Enable the Required checkbox.
9. Remove unneeded form elements.
10. Click **Save**.

## Submit a change request

1. In vCommander or the Service Portal, select a Kubernetes managed system and run the **Request Change** command.
2. In the Select Change Request dialog, click **Deploy K8s App**.
3. Complete the request form by entering a Namespace, browsing to a manifest file, and clicking **OK**.

The chosen application is installed on the selected Kubernetes cluster.