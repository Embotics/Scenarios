# Deploying Embedded Terraform Configurations

This scenario enables you to use deploy resources using Terraform configurations in the Embotics® vCommander® service catalog. It includes an optional approval workflow that uses the output of the Terraform plan command. 

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

- vCommander release 7.0.2 or higher

- A system with Terraform installed that is accessible through SSH. This system is referred to hereafter as the Terraform host. 
  The Terraform host will be used to keep state and must be configured to use the proper credentials to allow access the Terraform host.
- Install the Terraform Workflow Plug-in Step Package

## Install the Terraform plug-in workflow step package

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then install the `wfplugins-terraform` step package. The workflows in this scenario reference those Terraform plug-in workflow steps.

To learn how to download and install workflow plug-in steps, see [Adding Workflow Plug-In Steps](http://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding) in the vCommander User Guide.

## Set up the Service Catalog

To set up the service catalog to allow Terraform configurations to be uploaded, you must do the following:

1. Create the Terraform organization
2. Create the Terraform deployment service request form
3. Create the reploy Terraform approval workflow
4. Create the deploy Terraform template completion workflow
5. Create the Terraform deployment blueprint

### Create the Terraform organization

The Terraform service request requires a form that can identify the owner of the deployed resources. That form must be assigned to an organization.

**Note**: The Terraform organization will already exist if you have already gone through the *Deploying User-Provided Terraform Configurations* scenario.

1. Log into vCommander, go to **Configuration >  Organizations and Quotas**, then click the **Organizations** tab.
2. Click **Add**. 
3. In the Configure Organization dialog, for **Organization Name**, enter "Terraform Org".
4. Add groups or users to the organization.
5. If you need to configure additional organization details, click **Next** and configure the organization as required.
6. Click **Finish** when you're done.

### Create the Terraform deployment service request form

After the organization has been created, you need to create a form to capture the user that will be set as the owner of the deployed VM created by the Terraform template.

1. In vCommander go to **Configuration > Service Request Configuration**, then click the **Form Designer** tab.
2. Click **Add**. 
3. In the Add Request Form dialog, type "Terraform Deployment" for the **Form Name**, and in the **Organizations** section, select **Terraform Org** and click **Add**. Then click **OK**.
4. If the **Primary Owner** field isn't already present in the Service Form section of the Form Designer page, click the **Primary Owner** link on the right-hand side to add it. 
5. For the **Primary Owner** element, click **Edit**. Clear the **Display Only** checkbox, enable the **Required** checkbox, and click **OK**.
6. Click **Save** to save the form.

### Create the deploy Terraform approval workflow (Optional)
You can optionally use an approval workflow to generate the Terraform plan and have it approved. The approval workflow definition provided with this scenario will download the Terraform configuration through http from version control or an s3 bucket. 

See the completion workflow for a different mechanism to load the Terraform configuration.

**Note:** The provided approval workflow definition has steps that require credentials. After you import this workflow definition, you must edit the workflow definition in a text editor to use the appropriate credentials that have been added to vCommander. For information on how to add credentials to vCommander, see [Adding Username/password credentials](http://docs.embotics.com/vCommander/credentials.htm#Adding).

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the Scenarios repository.
2. In vCommander, go to **Configuration > Service Request Configuration > Approval Workflows** and click **Import**.
3. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploying-Embedded-Terraform-Configurations` directory, select the `Terraform-from-url-approval-workflow ` .yaml or .json file, and click **Open**.
   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
4. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.

​        To learn more, see [Importing and Exporting Workflow Definitions](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm) in the vCommander User Guide.


### Create the deploy Terraform template completion workflow
Next, you have to create a completion workflow to apply the Terraform plan. For this workflow, the configuration is embedded in the workflow step.

 You can import an existing workflow definition that is provided from the Scenarios repository.

1. In vCommander, go to **Configuration > Service Request Configuration > Completion Workflows** and click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploying-Embedded-Terraform-Configurations` directory, select the `Terraform-embedded-completion-workflow ` .yaml or .json file, and click **Open**.

   vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
1. After the completion workflow is imported, select it from the list, and click **Edit**.
1. In the Completion Workflow Configuration dialog, go to the **Assigned Components** page, and ensure the **Do not apply this workflow to any custom component** option is enabled. 
1. Click **Next**, then **Finish**.

### Create the Terraform deployment blueprint

Finally, create the Service Definition for the Terraform deployment service.

1. In vCommander, click the **Service Catalog** tab, then click **Add Service**.
2. For **Name**, type "Embedded Terraform Deployment" and click **Next**.
3. On the Component Blueprints page, select **Add > New Component Type**. 
4. In the Create New Component Type dialog, enter "EC2 Instance via Terraform" for **Name**,  enter 0 for **Annual Cost**, then click **Add to Service**.
5. For the new EC2 Instance via Terraform component blueprint, click the **Infrastructure** tab, then from the **Completion Workflow** dropdown, select `Embedded Terraform completion workflow` .
6. Click the **Form** tab, and from the **Toolbox** at the right side of the window, click the **Input Text Field** form element. In the **Display Label** box, enter "Name" and click **OK**. 
7. Click **Next**.
8. On the Deployment page, click **Next**. 
9. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. 
   To learn more, see [Intelligent Placement](http://docs.embotics.com/vCommander/intelligent-placement.htm).
10. On the Visibility page select **Publish - Specific organizations, users and groups** and add **Terraform Org**. Then click **Next**.
11. On the Summary page, click **Finish**.

## Login and Test
1. Log in to the portal as a member of the *Terraform Organization*.
1. Click **+ New** and request "Embedded Terrform Deployment" from the Service Catalog.
1. In the New Service Request wizard, complete the form that appears. You must complete all fields marked with an asterisk (&ast;). Click **Next** when you're done.
1. On the Components page, in the **Terraform Plan ID** field, enter the ID of the service request that you want to delete. 
1. Click **Submit** to submit the request.
