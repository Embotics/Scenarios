# Deploying Embedded Terraform Configurations

This scenario enables you to use deploy resources using Terraform configurations in the Embotics® vCommander® service catalog. It includes an optional approval workflow that uses the output of the Terraform plan command.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

- vCommander release 7.0.2 or higher

- A system with Terraform installed that is accessible through SSH. This system is referred to hereafter as the Terraform host.
  The Terraform host will be used to keep state and must be configured to use the proper credentials to allow access the Terraform host.
- Install the Terraform workflow plug-in step package

## Install the Terraform plug-in workflow step package

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then install the `wfplugins-terraform` step package. The workflows in this scenario reference those Terraform plug-in workflow steps.

To learn how to download and install workflow plug-in steps, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding).

## Set up the Service Catalog

To set up the service catalog to allow Terraform configurations to be uploaded, you must do the following:

1. Create the Terraform organization
1. Create an automated deployment destination
1. Configure a default ownership policy
1. Create the Terraform deployment service request form
1. Create the deploy Terraform approval workflow
1. Create the deploy Terraform template completion workflow
1. Create the Terraform deployment blueprint

### Create the Terraform organization

The Terraform service request requires a form that can identify the owner of the deployed resources. That form must be assigned to an organization.

1. Log into vCommander, go to **Configuration > Organizations and Quotas**, then click the **Organizations** tab.
1. Click **Add**. 
1. In the Configure Organization dialog, for **Organization Name**, enter "Terraform Org2".
1. Add groups or users to the organization.
1. If you need to configure additional organization details, click **Next** and configure the organization as required.
1. Click **Finish** when you're done.

### Create an automated deployment destination

For the Terraform configuration to be able to provision resources, you must configure an automated deployment destination and assign the destination to Terraform Org2.

The specific steps that are required depend on whether you are using vCenter, AWS, Azure, and SCVMM managed systems.  For information, see [Configuring Automated Deployment for Approved Service Requests](http://docs.embotics.com/vCommander/config_auto_placement_depl_vms.htm). 

### Configure a default ownership policy

To ensure that new VMs are visible to organization members, configure a default ownership policy that automatically assigns ownership of new VMs to Terraform Org2. 

1. In vCommander, go to **Configuration > Policies**.
1. On the Policies tab, click **Add**.
1. On the Choose a Policy page of the Policy Configuration wizard, select **Default Ownership** from the list of policies, then click **Next**.
1. On the Policy Name/Description page, enter a name and a description, then click **Next**.
1. On the Choose a Target page, from the **Target View Type** list, choose **Operational** to view a hierarchy of the entire compute infrastructure, then in the tree on the right of the page, select the target infrastructure elements for the policy, and click **Next**.
1. On the Configure the Policy page, select **Enable Policy** for the policy to come into effect immediately after you finish configuring it.
1. From the **Take Action** drop-down, select **Notify Only**, then click **Next**. When this option is selected, when the policy is triggered, a notification alert is created, but no action is taken for the service. 
1. In the **Default Owners** area, for Organization, select **Terraform Org2**. 
1. On the Summary page, review the summary and click **Finish**.

### Create the Terraform deployment service request form

After the organization has been created, you need to create a request form for the service.

1. In vCommander go to **Configuration > Service Request Configuration**, then click the **Form Designer** tab.
1. Click **Add**. 
1. In the Add Request Form dialog, type "Terraform Deployment" for the **Form Name**, and in the **Organizations** section, select **Terraform Org2** and click **Add**. Then click **OK**.
1. Click **Save** to save the form.

### Create the deploy Terraform approval workflow
You can use an approval workflow to generate the Terraform plan and have it approved. The approval workflow definition provided with this scenario will download the Terraform configuration through http from version control or an s3 bucket. 

See [Importing and Exporting Workflow Definitions](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm) for more information about how to import workflow definitions.

**Note:** The provided approval workflow definition has steps that require credentials. After you import this workflow definition, you must edit the workflow definition in a text editor to use the appropriate credentials that have been added to vCommander. For information on how to add credentials to vCommander, see [Adding Username/password credentials](http://docs.embotics.com/vCommander/credentials.htm#Adding).

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the Scenarios repository.
1. In vCommander, go to **Configuration > Service Request Configuration > Approval Workflows** and click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploying-Embedded-Terraform-Configurations` directory, select the `terraform-from-url-approval-workflow` .yaml or .json file, and click **Open**.

   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
1. Select the `Terraform from URL Approval` workflow from the list of approval workflows and click **Edit**.
1. In the Approval and Pre-Provisioning Workflow Configuration dialog, go to the **Steps** page and customize the step details as required for your Terraform environment and deployment destination.
1. Click **Next** when you are done.
1. On the Assigned Components page, click **Next**.
1. On the Summary page, enter a comment about the workflow in the **Description of Changes** field and click **Finish**.

### Create the deploy Terraform template completion workflow
Next, you have to create a completion workflow to apply the Terraform plan. For this workflow, the configuration is embedded in the workflow step.

 You can import an existing workflow definition that is provided from the Scenarios repository.

1. In vCommander, go to **Configuration > Service Request Configuration** and click the **Completion Workflow tab**.
1. Click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploying-Embedded-Terraform-Configurations` directory, select the `terraform-embedded-completion-workflow` .yaml or .json file, and click **Open**.

   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
1. After the completion workflow is imported, select it from the list, and click **Edit**.
1. In the Completion Workflow Configuration dialog, go to the **Assigned Components** page, and ensure the **Do not apply this workflow to any custom component** option is enabled. 
1. Click **Next**, then **Finish**.

### Create the Terraform deployment blueprint

Finally, create the Service Definition for the Terraform deployment service.

1. In vCommander, click the **Service Catalog** tab, then click **Add Service**.
1. For **Name**, type "Embedded Terraform Deployment" and click **Next**.
1. On the Component Blueprints page, select **Add > New Component Type**. 
1. In the Create New Component Type dialog, enter "EC2 Instance via Terraform" for **Name**, enter 0 for **Annual Cost**, then click **Add to Service**.
1. For the new EC2 Instance via Terraform component blueprint, click the **Infrastructure** tab, then from the **Completion Workflow** dropdown, select `Embedded Terraform completion workflow`.
1. Click the **Form** tab, and from the **Toolbox** at the right side of the window, click **Input Text Field**. Then in the added Input Text Field form element, enter "Name" in the **Display Label** box, ensure that the **Required** check box is enabled, and click **OK**.
1. Click **Next**.
1. On the Deployment page, click **Next**.
1. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. 
   To learn more, see [Intelligent Placement](http://docs.embotics.com/vCommander/intelligent-placement.htm).
1. On the Visibility page select **Publish - Specific organizations, users and groups** and add **Terraform Org2**. Then click **Next**.
1. On the Summary page, click **Finish**.

## Log in and test
1. Log in to the portal as a member of Terraform Org2.
1. Click **+ Service Catalog**, then for "Embedded Terrform Deployment", click **+ Add** to request the service.
1. On the Service page, complete the form that appears. You must complete all fields marked with an asterisk (&ast;). Click **Next** when you're done.
1. On the Component page, in the **Terraform Plan ID** field, enter the ID of the service request that you want to delete. 
1. Click **Submit** to submit the request.

