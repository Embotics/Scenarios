# Deploying a Kubernetes Cluster on vSphere through kubeadm with Snow® Commander®

Kubernetes is an open-source system for deploying and managing containerized applications within a hybrid or cloud environment. Using the Snow Commander cloud management platform, you can instantiate a Kubernetes cluster, and then use vCommander’s orchestration, self-service, cloud governance and cost optimization features to manage the cluster.

This article shows you how to use Commander and greater to get a Kubernetes cluster up and running quickly on VMware vSphere 6.5+, and to add the deployed cluster to vCommander’s inventory as a cloud account. While there are many ways to deploy Kubernetes, this solution uses the kubeadm deployment and installation method on Centos 7 Linux, 64-bit architecture. 

This article is intended for systems administrators, engineers and IT professionals. Previous experience with Kubernetes is required.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

- Commander release 7.0.2 or greater

Before you begin, you must:

- Add a vCenter as a Commander cloud account. See [Get started with vCenter in Commander](https://docs.embotics.com/commander/vmware-vcenter.htm).
- Create a Commander deployment destination, targeting the location in vCenter where the Kubernetes cluster will be deployed. See [Configuring Automated Deployment for Approved Service Requests](<https://docs.embotics.com/commander/config_auto_placement_depl_vms.htm>). 
- Ensure that the user requesting the Kubernetes cluster has permission to deploy to the targeted location in vSphere.
- Ensure that the root Linux user can log in through SSH, because Docker and Kubernetes require the configuration of system-level resources.

# Overview

To provision a Kubernetes cluster on vCenter with Commander, the following steps are required. Further details for each step are provided after this overview.

1. Configure a Centos 7 template in vSphere.
1. Create guest OS credentials for the root user; these credentials are referenced by the workflows you will import.
1. Install a workflow plug-in step that automatically adds the deployed cluster to vCommander’s inventory.
1. Import completion workflows from the Embotics Git repository; these workflows will run once the cluster is deployed.
1. Create a custom attribute for the Kubernetes version.
1. Create a custom attribute for the cloud account name.
1. Create a service catalog entry for users to request a Kubernetes cluster.
1. Submit a service request.

## Create a Centos 7 template in vSphere

Create a generic VM template in vSphere to use as the base image for all nodes in the Kubernetes cluster.

**Note:**  The sizing of your base VM depends on the expected workload. The minimum recommended settings are 2 vCPU cores, 4 GB RAM and 25 GB storage.

1. Download a Centos 7 64-bit minimal install ISO.
1. In vSphere, create a new VM, attach and install the ISO.
1. Boot up the VM and run the following command:
   `yum -y update`
1. Install the base tools using the following command:
   `yum -y install net-tools open-vm-tools ssh-server`
1. Enable and then start SSH with the following command:
   `systemctl enable sshd && systemctl start sshd`
1. Test an SSH login to the VM with the root user.
1. In vSphere, shut down the VM and take a snapshot.
   **Important**:  For this example, to minimize disk space usage and provisioning time, we used the “Linked Clones” method of provisioning in Commander. When deploying a linked clone, a VM snapshot must be available; otherwise, the deployment will fail.
1. In vSphere, convert the VM to a template.

## Install the plug-in workflow step package

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then using your local version of the repo, install the Kubernetes plug-in workflow step package (located in the `k8s` directory), which contains a plug-in workflow step to add the deployed Kubernetes cluster to vCommander’s inventory as a cloud account. The completion workflows in this scenario reference this plug-in step.

To learn how to download and install workflow plug-in steps, see [Adding Workflow Plug-In Steps](https://docs.embotics.com/commander/Using-Plug-In-WF-Steps.htm#Adding). 

## Create guest OS credentials for the root user

The completion workflows use root user credentials to SSH into the deployed VM. Before importing the workflows, you must create a set of credentials for the root user.

1. In Commander, go to **Configuration > Credentials**.
1. Click **Add**.
1. In the Add Credentials dialog, do the following:

   a. From **Credentials Type**, select **Username/Password**.

   b. For **Name**, enter **kubeadm-template**.

   ​    This name is hard-coded in the completion workflows, so enter the name exactly as shown.

   c. For **Username**, enter **root**.

   d. For **Password**, enter the root user password.

   e. For **Description**, optionally enter a description.

   f. For **Category**, select **Guest OS Credentials**.

   g. Click **OK**.

## Import the completion workflows

Import the two following Commander completion workflows to complete the provisioning and configuration of the cluster: 

- `vsphere-post-deploy-k8s-kubeadm-component.yaml`: a component-level completion workflow that runs on each provisioned node and provides common utilities (like Docker)
- `vsphere-post-deploy-k8s-kubeadm-svc.yaml`: a service-level completion workflow that facilitates configuration of the Kubernetes cluster


1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the repository.
1. In Commander, go to **Configuration > Service Request Configuration > Completion Workflow** and click **Import**.
1. Go to the Scenarios repo that you cloned or downloaded, then from the `Deploy-Kubernetes-Cluster-vSphere-Kubeadm` directory, select the `vsphere-post-deploy-k8s-kubeadm-component.yaml` file, and click **Open**.

    Commander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
1. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
1. Repeat this process to import the second downloaded workflow, `vsphere-post-deploy-k8s-kubeadm-svc.yaml`.

## Create a custom attribute for the Kubernetes version

To enable requesters to select which version of Kubernetes to install, create a custom attribute.

1. In Commander, go to **Configuration > Custom Attributes**.
1. Click **Add**.
1. Name the attribute **kubernetes_version** and keep the default values for all other settings on this page.
   This name is hard-coded in the completion workflows, so you must use this exact name.
1. Click **Next**, add the appropriate Kubernetes versions, and click **Finish**.

## Create a custom attribute for the cloud account name

To store the name of the Kubernetes cloud account, create another custom attribute.

1. In Commander, go to **Configuration > Custom Attributes**.
1. Click **Add**.
1. Name the attribute **kubernetes_name**.
   This name is hard-coded in the completion workflows, so you must use this exact name.
1. From the **Type** drop-down, select **Text**.
1. Keep the default values for all other settings on this page.
1. Click **Next**, choose **Free Form**, and click **Finish**.

## Create a service catalog entry

Next, create an entry in the service catalog that:

- Allows the requester to choose which Kubernetes version to deploy (optional)
- Allows the requester to specify the name of the Commander cloud account
- Provisions three linked clones from the previously built vSphere template
- Applies the component-level completion workflow to each deployed VM
- Applies the service-level completion workflow to the deployed cluster
- Emails the requester once the cluster is deployed
  

1. In Commander, go to **Configuration > Service Request Configuration > Service Catalog**, then click **Add Service**.

1. Enter a name and description for the service, and optionally apply a custom icon and categories, then click **Next**.

1. Add the template for provisioning the base VMs for the cluster. Click **Add > VM Template, Image or AMI** and navigate to the template created earlier (centos7-base).

   The workflows support any number of nodes, but in this example, we’re creating a cluster of a master and two worker nodes, so you must click **Add to Service** three times. When you click **Close**, the three components are visible.

1. Create a [custom component](https://docs.embotics.com/commander/make_service_available.htm#manage_component_types) to store the value for the Kubernetes version custom attribute on the request form. On the Component Blueprints page, click **Add > New Component Type**. 

1. In the Create New Component Type dialog, enter a name of **kubernetes_version**, an annual cost of 0, then click **Add to Service**.

    This name is hard-coded in the completion workflows, so you must use this exact name.

1. Create a second custom component to store the value for the name of the Kubernetes cluster when it’s added to Commander as a cloud account. On the Component Blueprints page, click **Add > New Component Type**. In the Create New Component Type dialog, enter a name of **kubernetes_name** and an annual cost of 0, then click **Add to Service**.

    This name is hard-coded in the completion workflows, so you must use this exact name.

1. Next, configure the blueprint for each of the components. Specify that deployed VMs will be **Linked Clones**, and select **vsphere-post-deploy-k8s-kubeadm-component** as the completion workflow.

  You can customize the Deployed Name to match your enterprise naming convention, using Commander variables. For example, the variable `#{uniqueNumber[3]}` can be used to add a three-digit unique number to the VM name.

1. Once you have configured all three VM components, configure the first custom component. On the Component Blueprint page for kubernetes_version, go to the **Attributes** tab and do the following:

  - Click **Add Attributes**, then select **kubernetes_version** from the list and click **OK**.
  - Back on the Attributes tab, choose a default value for **kubernetes_version** from the drop-down list. 

1. If you want to allow requesters to choose the Kubernetes version, add the custom attribute to the request form. On the Form tab, in the Toolbox on the right, click the **kubernetes_version** form element.

1. Click **Edit** to enable the **Required** flag if desired and click **OK**. 

1. Configure the blueprint for the second custom component. On the Component Blueprint page for kubernetes_name, go to the **Attributes** tab, click **Add Attributes**, select **kubernetes_name** from the list and click **OK**.

1. If you want to allow requesters to choose the name of the Kubernetes cloud account, add the custom attribute to the request form. On the Form tab, in the Toolbox on the right, click the **kubernetes_name** form element.

1. Click **Edit** to enable the **Required** flag and click **OK**.

1. On the Deployment page, assign the completion workflow **vsphere-post-deploy-k8s-kubeadm-svc**, then click **Next**.

1. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. To learn more about Intelligent Placement, see [Intelligent Placement](https://docs.embotics.com/commander/intelligent-placement.htm).

1. On the Visibility page, specify who can request this service, then click **Next**.

1. On Summary page, click **Finish**.

    The service catalog entry is now published. 

## Submit a service request

Our service is now configured and ready to test. In Commander or the Service Portal, go to the Service Catalog and request the Kubernetes service. Notice that you can specify the cluster name and select the Kubernetes version on the request form.

Once the service request has completed, the new cluster is added to vCommander’s inventory as a Kubernetes cloud account.

To learn more about Commander's support for Kubernetes, see [Managing Kubernetes](https://docs.embotics.com/commander/managing-kubernetes.htm).
