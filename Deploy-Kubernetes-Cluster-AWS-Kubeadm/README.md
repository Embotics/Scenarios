# Deploying a Kubernetes Cluster on AWS through kubeadm with Snow® Commander®

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Snow Commander cloud management platform, you can instantiate a Kubernetes cluster, and then use vCommander’s  orchestration, self-service, cloud governance and cost optimization features to manage the cluster.

This article shows you how to use Commander 7.0.2 and greater to get a Kubernetes cluster up and running quickly on AWS, and to add the deployed cluster to Commander’s inventory. While there are many ways to deploy Kubernetes, this solution uses the kubeadm deployment and installation method on Centos 7 Linux, 64-bit architecture. 

This article is intended for systems administrators, engineers and IT professionals. Previous experience with Linux, Docker and AWS is required.

## Changelog

**Version 1.0:** Initial version

## Prerequisites

- Commander release 7.0.2 or greater

Before you begin, you must:

- Add an AWS cloud account. See [Adding AWS cloud accounts](https://docs.embotics.com/commander/adding-aws-cloud-accounts.htm).
- Create a Commander deployment destination, targeting the location in AWS where the Kubernetes cluster will be deployed. See [Configuring Automated Deployment for Approved Service Requests](https://docs.embotics.com/commander/config_auto_placement_depl_vms.htm). 
- Ensure that the user requesting the Kubernetes cluster has permission to deploy to the targeted location in AWS.
- Ensure that the root Linux user can log in through SSH, because Docker and Kubernetes require the configuration of system-level resources.

# Overview

To provision a Kubernetes cluster on AWS with Commander, the following steps are required. Further details for each step are provided after this overview.

1. Create a CentOS 7 AMI in AWS.
1. Test an SSH connection to the deployed instance.
1. Create guest OS credentials for the “centos” user; these credentials are referenced by the workflows you will import.
1. Install a workflow plug-in step that automatically adds the deployed cluster to vCommander’s inventory.
1. Import completion workflows from the Embotics GitHub repository; these workflows will run once the cluster is deployed.
1. Create a custom attribute for the Kubernetes version.
1. Create a custom attribute for the cloud account name.
1. Synchronize the inventory for your AWS cloud account.
1. Create a service catalog entry for users to request a Kubernetes cluster.
1. Submit a service request.

## Create a CentOS 7 AMI in AWS

Create a generic AMI in AWS to use as the base image for all nodes in the Kubernetes cluster.

1. Log into the AWS console, navigate to EC2, and click **Launch Instance**.
1. Choose an Amazon Machine Image (AMI): Go to the AWS Marketplace tab, search for “centos”, and select **CentOS 7 (x86_64) - with Updates HVM**. This image has no software cost, but will incur AWS usage fees.
1. Review the AMI details and click **Continue**.
1. On the Instance Type page, select “t2.medium”. T2.Medium is a good starting point for Kubernetes deployments. You may want to choose a larger instance type, depending on your application workloads. Click **Next: Configure Instance Details**.
1. On the Configure Instance Details page, configure options appropriate for your organization. Click **Next: Add Storage**.
1. On the Add Storage page, keep the default size of 8 GiB. (Kubernetes can run on any storage class or volume type.) Click **Next: Add Tags**.
1. On the Add Tags page, add tags as required. Click **Next: Configure Security Group**.
1. On the Configure Security Group page, configure the following firewall rules:
  - **SSH**: `TCP port 22`
  - **Custom TCP**: `TCP port 6443`
1. Click **Review and Launch**.
1. A dialog appears, prompting you to select an existing key pair or create a new one. If you already have an AWS key pair, select it in the list. If not, select **Create a new key pair**. Enter a key pair name, such as kubernetes-aws-Commander, and click **Download Key Pair**. See [Managing Key Pairs](https://docs.embotics.com/Commander/managing-key-pairs.htm) to learn more.
1. Save the .pem file to a known location.
   **Important**: Do not lose your SSH private key file. This PEM-encoded file is required to connect the Commander workflow to the deployed EC2 instances.
1. Click **Launch Instances**.
1. Under Instances, right-click the instance and select **Image > Create Image**.

Once AWS has created the image, which may take up to five minutes, your AMI is available for use.

## Test an SSH connection to the deployed instance

Ensure that you can open an SSH connection to the instance you just deployed, using your saved PEM-encoded SSH key. Commander workflows will use this key to authenticate to AWS. For example:

`ssh -i /path/to/my-key-pair.pem ec2-user@ec2-198-51-100-1.compute-1.amazonaws.com`

To learn more, see [Connect to Your Container Instance](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance-connect.html) in the AWS documentation.

## Create guest OS credentials for the “centos” user

The completion workflows use “centos” user credentials to open an SSH connection to the deployed instances. Before importing the workflows, you must create a set of credentials for the centos user, using the PEM-encoded key from the instance you just created.

1. In Commander, go to **Configuration > Credentials**.
1. Click **Add**.
1. In the Add Credentials dialog, for the **Credentials Type**, select **RSA Key**.
1. For **Name**, enter **aws**.
    This name is hard-coded in the completion workflows, so you must use this exact name.
1. For **Username**, enter **centos**.
1. Open the key.pem file from the instance in a text editor, copy the entire contents, and paste the contents into the RSA Key field.
1. For **Description**, enter **Kubernetes-AWS**.
1. For **Category**, keep the default setting, **Guest OS Credentials**.
1. Click **OK**.

## Install the plug-in workflow step package

This scenario uses the Kubernetes plug-in workflow step package (`wfplugins-k8s.jar`), which provides a plug-in workflow step to add the deployed Kubernetes cluster to vCommander’s inventory as a cloud account. The completion workflow in this scenario reference this plug-in step.

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `k8s` directory, which contains the Kubernetes plug-in workflow step package.

To learn how to download and install workflow plug-in steps, see [Adding Workflow Plug-In Steps](https://docs.embotics.com/commander/Using-Plug-In-WF-Steps.htm#Adding). 

## Import the completion workflows

Import the two following Commander completion workflows to complete the provisioning and configuration of the cluster: 

- `aws-post-deploy-k8s-kubeadm-component.yaml`: a component-level completion workflow that runs on each provisioned node and provides common utilities (like Docker)
- `aws-post-deploy-k8s-kubeadm-svc.yaml`: a service-level completion workflow that facilitates configuration of the Kubernetes cluster


1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the repository.
1. In Commander, go to **Configuration > Service Request Configuration > Completion Workflow** and click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploy-Kubernetes-Cluster-AWS-Kubeadm` directory, select the `aws-post-deploy-k8s-kubeadm-component.yaml` file, and click **Open**.

    Commander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
1. Repeat this process to import the second downloaded workflow, `aws-post-deploy-k8s-kubeadm-svc.yaml`.

## Create a custom attribute for the Kubernetes version

To enable requesters to select which version of Kubernetes to install, create a custom attribute.
1. In Commander, go to **Configuration > Custom Attributes**.
1. Click **Add**.
1. Name the attribute **kubernetes_version** and keep the default values for all other settings on this page.
    This name is hard-coded in the completion workflows, so you must use this exact name.
1. Click **Next**, add the appropriate Kubernetes versions, and click **OK**.


## Create a custom attribute for the cloud account name

To store the name of the Kubernetes cloud account, create another custom attribute.

1. In Commander, go to **Configuration > Custom Attributes**.
1. Click **Add**.
1. Name the attribute **kubernetes_name**.
   This name is hard-coded in the completion workflows, so you must use this exact name.
1. From the **Type** list, select **Text**.
1. Keep the default values for all other settings on this page.
1. Click **Next**, choose **Free Form**, and click **Finish**.

## Synchronize the inventory for your AWS cloud account

To  ensure that your newly created AMI is available to add to the service  catalog, synchronize the inventory for your AWS cloud account.

1. In Commander, go to **Views > Operational**.
1. Right-click your AWS cloud account and select **Synchronize Inventory**.

## Create a service catalog entry

Next, create an entry in the service catalog that:

- Allows the requester to choose which Kubernetes version to deploy (optional)
- Allows the requester to specify the name of the Commander cloud account
- Provisions three instances from the previously created EC2 AMI
- Applies the component-level completion workflow to each deployed instance
- Applies the service-level completion workflow to the deployed cluster


1. In Commander, go to **Configuration > Service Request Configuration > Service Catalog**, then click **Add Service**.
1. Enter a name and description for the service, and optionally apply a custom icon and categories, then click **Next**.
1. Add the AMI for provisioning the base instances for the cluster. Click **Add > VM Template, Image or AMI** and navigate to the AMI you created earlier.

    The workflows support any number of nodes, but in this example, we’re creating a cluster of a master and two worker nodes, so you must click **Add to Service** three times. When you click **Close**, the three components are visible.
1. Create a custom component to store the value for the Kubernetes version custom attribute. On the Component Blueprints page, click **Add > New Component Type**. In the Create New Component Type dialog, enter a name of **kubernetes_version**, an annual cost of 0, then click **Add to Service**. **Note:** This name is hard-coded in the completion workflows, so you must use this exact name.
1. Create a second custom component to store the value for the name of the Kubernetes cluster when it’s added to Commander as a cloud account. On the Component Blueprints page, click **Add > New Component Type**. In the Create New Component Type dialog, enter a name of **kubernetes_name** and an annual cost of 0, then click **Add to Service**.

    This name is hard-coded in the completion workflows, so you must use this exact name.
1. Next, configure the blueprint for each of the VM components. On the Infrastructure tab:
   * For **Completion Workflow**, select **aws-post-deploy-k8s-kubeadm-component**.
   * Customize the **Deployed Name** to match your enterprise naming convention, using Commander variables.
1. On the Resources tab:
  * Set the Instance Type to t2.medium (at minimum).
    **Note:** Increase the resources to support more concurrent pods/containers per host, if required.
  * From the **Key Pair** list, select the key pair created in AWS earlier.  
1. Perform this configuration for the remaining two VM components.
1. Once you have configured all three VM components, configure the first custom component. On the Component Blueprint page for kubernetes_version, click the **Attributes** tab, then click **Add Attributes**. In the Add Attributes dialog, select **kubernetes_version** in the list and click **OK**.
1. Back on the Attributes tab, choose a default value for kubernetes_version from the drop-down list.
1. If you want to allow requesters to choose the Kubernetes version, add the custom attribute to the request form. On the Form tab, in the Toolbox on the right, click the **kubernetes_version** form element.
1. Click **Edit** to enable the **Required** flag if desired and click **OK**.
1. Configure the blueprint for the second custom component. On the Component Blueprint page for kubernetes_name, click the **Attributes** tab, then click **Add Attributes**. In the Add Attributes dialog, select **kubernetes_name** in the list and click **OK**.
1. If you want to allow requesters to choose the name of the Kubernetes cloud account, add the custom attribute to the request form. On the Form tab, in the Toolbox on the right, click the **kubernetes_name** form element.
1. Click **Edit** to enable the **Required** flag and click **OK**.
1. On the Deployment page, for Completion Workflow, select **aws-post-deploy-k8s-kubeadm-svc**, then click **Next**.
1. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. 
   To learn more, see [Intelligent Placement](https://docs.embotics.com/commander/intelligent-placement.htm).
1. On the Visibility page, specify who can request this service, then click **Next**.
1. On Summary page, click **Finish**.

The service catalog entry is now published.

## Submit a service request

The service is now configured and ready to test. In Commander or the Service Portal, go to the Service Catalog and request the Kubernetes service. Notice that you can specify the cluster name and select the Kubernetes version on the request form.

Once the service request has completed, the new cluster is added to vCommander’s inventory as a Kubernetes cloud account.