# Deleting Terraform Managed Infrastructure

This scenario enables you to destroy resources provisioned through Terraform and Embotics® vCommander®. An optional approval workflow using the output of the Terraform plan command is also included.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

- vCommander release 7.0.2 or higher
- A system with Terraform installed that is accessible through SSH. This system is referred to hereafter as the Terraform host. 
  The Terraform host will be used to keep state and must be configured to use the proper credentials to allow access the Terraform host.
- Install the Terraform Workflow Plug-in Step Package
- You must have already worked through the *Deploying User-Provided Terraform Configurations* or  *Deploying Embedded Terraform Configurations* scenarios. This scenario will use the "Terraform Org" organization created through those scenarios, and it will also use an ID of a service request that was through those deployment scenarios. 

## Install the Terraform plug-in workflow step package

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then install the `wfplugins-terraform` plug-in workflow package. The workflows in this scenario reference those Terraform plug-in workflow steps.

To learn how to download and install workflow plug-in steps, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding).

## Set up the Service Catalog

This section describes how to set up the service catalog to allow Terraform configurations to be destroyed. 

It assumes that the *Deploying Embedded Terraform Configurations* or *Deploying User-Provided Terraform Configurations* scenarios have been setup because the Terraform configuration state will be referenced through the ID of the service request that was submitted to deploy created the infrastructure.

**Note**: To obtain the other Terraform scenarios, go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the Scenarios repository.

### Edit the Deploy Terraform approval workflow (optional)
You can optionally use an Approval Workflow to generate the Terraform plan and have it approved. 

You should confirm that the Approval Workflow is configured with an option to generate a plan from an existing configuration.

1. In vCommander go to **Configuration > Service Request Configuration**, then click the **Approval Workflow** tab.
1. Select the "Terraform Approval" workflow and click **Edit**.
1. Go to the Steps page, then select the first step.
1. The Step Execution field should be set to **When conditions are met**, click **Edit** beside the field.
1. In the Variable Assistant dialog, ensure that `#{request.services[1].publishedName}" -ne "Terraform Decomission` is set as a condition and click **OK**.
1. For the second step in the workflow, ensure that the same condition is set.
1. Go to the Summary page and click **Finish**.


### Create the Destroy Terraform completion workflow
Next, you have to create the completion Workflow to destroy the Terraform managed infrastructure. You can import an existing workflow definition that is included with the Scenarios repository.

1. In vCommander, go to **Configuration > Service Request Configuration > Completion Workflows** and click **Import**.
1. Go to the Scenarios repo that you previously cloned or downloaded, then from the `Delete-Terraform-Managed-Infrastructure` directory, select the `terraform-delete-completion-workflow ` .yaml or .json file, and click **Open**.

   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**. To learn more, see [Importing and Exporting Workflow Definitions](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm).
1. After the Terraform Destroy completion workflow is imported, select it from the list, and click **Edit**.
1. In the Completion Workflow Configuration dialog, go to the **Assigned Components** page, and ensure the **Do not apply this workflow to any custom component** option is enabled. 
1. Click **Next**, then **Finish**.

### Create the Terraform deployment blueprint

Finally, create the Service Definition for the Terraform deployment service.

1. In vCommander, click the **Service Catalog** tab, then click **Add Service**.
1. For **Name**, type "Destroy Terraform Managed Infrastructure" and click **Next**.
1. On the Component Blueprints page, select **Add > New Component Type**. 
1. In the Create New Component Type dialog, enter "EC2 Instance via Terraform" for **Name**,  enter 0 for **Annual Cost**, then click **Add to Service**.
1. For the new EC2 Instance via Terraform component blueprint, click the **Infrastructure** tab, then from the **Completion Workflow** dropdown, select the`Terraform Destroy` workflow.
1. Click the **Form** tab, and from the Toolbox at the right side of the window, click the **Input Text Field** form element. Then in the **Text** box, enter "Terraform Plan ID" and click **OK**. 
1. Click **Next**.
1. On the Deployment page, click **Next**. 
1. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. 
   To learn more, see [Intelligent Placement](http://docs.embotics.com/vCommander/intelligent-placement.htm).
1. On the Visibility page, select **Publish - Specific organizations, users and groups** and add the Terraform organization. Then click **Next**.
1. On the Summary page, click **Finish**.

## Log in and test
1. Log in to the Service Portal as a member of the Terraform Organization.
1. Go to the Service Request page to find the ID of the service request that provisioned the infrastructure.
1. Click **+ New** and request "Uploaded Terraform Deployment" from the Service Catalog.
1. In the New Service Request wizard, complete the form that appears. You must complete all fields marked with an asterisk (&ast;). Click **Next** when you're done.
1. On the Components page, in the **Terraform Plan ID** field, enter the ID of the service request that you want to delete. 
1. Click **Submit** to submit the request.
