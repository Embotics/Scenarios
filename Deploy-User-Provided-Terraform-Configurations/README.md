# Deploying User-Provided Terraform Configurations

This scenario enables you to provision resources specified in a Terraform configuration that has been uploaded by an end-user of Embotics® vCommander®. An optional approval workflow using the output of the Terraform plan command is also included.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

* vCommander release 7.0.2 or higher

* A system with Terraform installed that is accessible through SSH. This system is referred to hereafter as the Terraform host. 
   The Terraform host will be used to keep state and must be configured to use the proper credentials to allow access the Terraform host.
* Install the Terraform Workflow Plug-in Step Package

## Install the Terraform plug-in workflow step package

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then install the `wfplugins-terraform` step package. The workflows in this scenario reference those Terraform plug-in workflow steps.

To learn how to download and install workflow plug-in steps, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding).

## Set up the Service Catalog

To set up the service catalog to allow Terraform configurations to be uploaded, you must do the following:

1. Create the Terraform organization
1. Create the deployment destination
1. Create the Terraform deployment service request form
1. Create the Terraform deployment approval workflow
1. Create the deploy Terraform template completion workflow
1. Create the Terraform deployment blueprint

### Create the Terraform organization

The Terraform service request needs a form that can identify the owner of the deployed resources. That form must be assigned to an organization.

**Note**: The Terraform organization will already exist if you went through the *Deploying Embedded Terraform Configurations* scenario.

1. Log into vCommander, go to **Configuration > Organizations and Quotas**, then click the **Organizations** tab.
1. Click **Add**. 
1. In the Configure Organization dialog, for **Organization Name**, enter "Terraform Org".
1. Add groups or users to the organization.
1. If you need to configure additional organization details, click **Next** and configure the organization as required.
1. Click **Finish** when you're done.

### Create the deployment destination

For the Terraform configuration to provision resources, you must configure an automated deployment destination and assign the destination to Terraform Org.

For information on how to configure deployment destinations, see [Configuring Automated Deployment for Approved Service Requests](http://docs.embotics.com/vCommander/config_auto_placement_depl_vms.htm). This topic provides information for vCenter, AWS, Azure, and SCVMM managed systems.

### Create the Terraform deployment service request form

After the organization has been created, you need to create a form to capture the user that will be set as the owner of the deployed VM created by the Terraform template.
1. In vCommander go to **Configuration > Service Request Configuration**, then click the **Form Designer** tab.
2. Click **Add**. 
3. In the Add Request Form dialog, type "Terraform Deployment" for the **Form Name**, and in the **Organizations** section, select **Terraform Org** and click **Add**. Then click **OK**.
4. If the **Primary Owner** field isn't already present in the Service Form section of the Form Designer page, click the **Primary Owner** link on the right-hand side to add it. 
5. For the **Primary Owner** element, click **Edit**. Clear the **Display Only** checkbox, enable the **Required** checkbox, and click **OK**.
6. Click **Save** to save the form.

### Create the Terraform deployment approval workflow
Next, you need to create the approval workflow to run the Terraform generate the Terraform plan and have it approved. You can import an existing workflow definition that is provided from the Scenarios repository. See [Importing and Exporting Workflow Definitions](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm) for more information.

**Note:** The workflow definition that you will import has steps that contain credentials. Therefore credentials with the same name must exist on the vCommander installation where you're importing the file. For the workflow definition to successfully import, you can either add the appropriate credentials to vCommander or edit the workflow definition in a text editor to remove the credential names before you import it. 

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the Scenarios repository.
2. In vCommander, go to **Configuration > Service Request Configuration > Approval Workflow** and click **Import**.
3. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploying-User-Provided-Terraform-Configurations` directory, select the `terraform-approval` .yaml or .json file, and click **Open**.

   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
4. Enter a comment about the workflow in the **Description of Changes** field and click **Import**.
5. Select the `Terraform Approval` workflow from the list of approval workflows and click **Edit**.
6. In the Approval and Pre-Provisioning Workflow Configuration dialog, go to the **Steps** page and customize the step details as required for your Terraform environment and deployment destination.
7. Click **Next** when you are done.
8. On the Assigned Components page, click **Next**.
9. On the Summary page, enter a comment about the workflow in the **Description of Changes** field and click **Finish**.

### Create the deploy Terraform template completion workflow
Next, you have to create the completion workflow to apply the Terraform plan. You can import an existing workflow definition that is available from the Embotics Git Hub.

1. In vCommander, go to **Configuration > Service Request Configuration** and click the **Completion Workflow** tab.
1. Click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploying-User-Provided-Terraform-Configurations` directory, select the `uploaded-terraform-completion-workflow` .yaml or .json file, and click **Open**.

   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
1. After the Deploy Terraform Template completion workflow is imported, select it from the list, and click **Edit**.
1. In the Completion Workflow Configuration dialog, go to the **Steps** page and customize the step details as required for your Terraform environment and deployment destination.
1. Click **Next** when you are done.
1. On the **Assigned Components** page, ensure the **Do not apply this workflow to any custom component** option is enabled, and click **Next**.
1. On the Summary page, enter a comment about the workflow in the **Description of Changes** field and click **Finish**.

### Create the Terraform deployment blueprint
Finally, create the Service Definition for the Terraform deployment service.
1. In vCommander, go to **Configuration > Service Request Configuration**.
1. Click the **Service Catalog** tab, then click **Add Service**.
1. For **Name**, type "Uploaded Terraform Deployment" and click **Next**.
1. On the Component Blueprints page, select **Add > New Component Type**. 
1. In the Create New Component Type dialog, enter "Uploaded Terraform" for **Name**, enter 0 for **Annual Cost**, then click **Add to Service**.
1. Select the new Uploaded Terraform component blueprint, click the **Infrastructure** tab, then from the **Completion Workflow** dropdown, select `Uploaded Terraform Completion Workflow`.
1. Click the **Form** tab, then from the **Toolbox** at the right side of the window, do the following:
   - Click **Input Text Field**. Then in the added Input Text Field form element, enter "Name" in the **Display Label** box, ensure that the **Required** check box is enabled, and click **OK**. 
   - Click **File Upload**. Then in the added File Upload form element, enter "Configuration" in the **Display Label** box, ensure that the **Required** check box is enabled, and click **OK**.
1. Click **Next**.
1. On the Deployment page, click **Next**. 
1. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. 
  See [Intelligent Placement](http://docs.embotics.com/vCommander/intelligent-placement.htm) for information.
1. On the Visibility page select **Publish - Specific organizations, users and groups** and add **Terraform Org**. Then click **Next**.
1. On the Summary page, click **Finish**.

## Log in and test
1. Log in to the Service Portal as a member of *Terraform Org.*
1. Click **+ Service Catalog**, then for "Uploaded Terraform Deployment", click **+ Add** to request the service.
1. On the Service page, complete the form that appears. You must complete all fields marked with an asterisk (&ast;). Click **Next** when you are done.
1. On the Component page, enter a name for the infrastructure that Terraform will deploy.
1. Click **Choose**, browse a valid Terraform configuration file, and click **Open**.

    **Note**: A sample Terraform configuration file (`embotics-terraform-aws-configuration.tf`) is provided with this scenario. You can use this file for reference, or modify it as required for your Terraform environment and deployment destination.
1. Click **Submit** to submit the request.
