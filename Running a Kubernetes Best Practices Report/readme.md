# Running a Kubernetes Best Practices Report with Embotics® vCommander®

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Embotics vCommander cloud management platform, you can run a best practices report that compares the current state of a Kubernetes cluster against a set of checks to ensure that the resources (such as pods and containers) deployed on the cluster follow best practices and corporate standards.

This guide shows you how to use vCommander 7.0+ to run a best practices report as a command workflow against a Kubernetes cluster. The best practices report is based on best practices documented by Kubernetes related to [configuration](https://kubernetes.io/docs/concepts/configuration/overview/), [security](https://kubernetes.io/blog/2016/08/security-best-practices-kubernetes-deployment), and [large clusters](https://kubernetes.io/docs/admin/cluster-large/), as well as on our own experience with Kubernetes.

This guide is intended for systems administrators, engineers and IT professionals. Previous experience with Kubernetes is required.

## Prerequisites

Before you begin, you must add a Kubernetes cluster as a managed system. You can do this in one of two ways:

- Add an existing Kubernetes cluster as a vCommander managed system. See [Adding a Kubernetes Managed System](http://docs.embotics.com/vCommander/adding_a_managed_system.htm#add_k8s) in the vCommander 7.0 User Guide.
- Create a new Kubernetes cluster through vCommander and have it automatically added as a vCommander managed system. To learn how, search for "Kubernetes" on our [Knowledge Base](https://support.embotics.com/support/solutions/8000051955) and choose the article for your preferred platform for deploying Kubernetes clusters.

## Install the plug-in steps

Go to the Embotics GitHub repository located at https://github.com/Embotics/Plug-in-Workflow-Steps and download the following workflow plug-in step packages:

- wfplugins-k8s.jar
- wfplugins-text.jar 
- wfplugins-email.jar

Install the workflow plug-in step packages. To learn how, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Adding-Pluggable-WF-Steps.htm) in the vCommander 7.0 User Guide.

## Import the command workflow

1. Download the command workflow “K8s best practices” from the Embotics GitHub repository located at https://github.com/Embotics/Scenarios. 
2. In vCommander, go to **Configuration > Command Workflows** and click **Import**.
3. Browse to the .yaml file you downloaded and click **Open**.
4. vCommander automatically validates the workflow. 
5. Click **Import**.

To learn more, see [Exporting and Importing Workflows](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm) in the vCommander 7.0 User Guide.

## Optional: Customize the rules and their thresholds

To customize the set of rules and their thresholds used by the best practices report:

1. Download the defaultBestPracticesRulesFile.yaml configuration file from the Embotics GitHub repository located at https://github.com/Embotics/Scenarios.
2. Edit the rules and their thresholds as required.
3. Save the file to a known location on the vCommander server.

## Configure the command workflow

1. Select the **K8s best practices and email** workflow in the Command Workflows list and click **Edit**. 
2. Navigate to the Steps page.
3. **Kubernetes Best Practices** workflow step: This step runs the checks against the selected Kubernetes cluster.
   **Rules File**: If you customized the rules and thresholds in the .yaml configuration file, enter the absolute path to the file on the vCommander server, for example, `C:\temp\mybestpractices.workflow.yaml`. If no file is specified, the default set of rules is used.
4. **XSLT Transform** step: This step processes the output of the previous step. 
   **Output**: Specify an absolute path for the output file. The specified directory must already exist.
   **Stylesheet**: Specify the absolute path to a stylesheet file on the vCommander server.
   **Parameters**: Adjust parameter values, such as the report title, as required.
5. **Email Attachment** step: This step emails the output of the previous step. 
   **To**: Enter one or more email addresses as required. 
   **Subject**: Customize as required.
   **Body**: Customize as required.
6. Click **Next** and **Finish**.

## Run the command workflow

1. Select a Kubernetes cluster in the Operational or Deployed view. 
2. Right-click and select **Run Workflow**.
3. In the Select a Workflow dialog, select the workflow and click **Run**.

The report is generated and emailed to recipients.
