# Running Ansible Playbooks

This scenario enables you to use Embotics® Commander® to run an Ansible playbook on a target system using the `ansible-playbook` command.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires Commander release 7.0.2 or higher
* Target systems must be accessible for Guest OS commands (VMware tools or SSH)
* Ansible must be installed on the target system (see section below for more details)

### Installing Ansible on target instances

To run an Ansible playbook on a target system, you must install Ansible on that system. Ansible can be installed as part of the bootstrapping of the instance (that is, the template used has Ansible pre-installed). It can also be installed through a Commander **Guest OS > Run Program** workflow step. You can choose whichever is more appropriate for you development needs. 

The commands required to install Ansible varies for the different Linux distributions.

_Amazon Linux_

For Amazon Linux, Ansible can be installed using `pip`. Use the following commands:

```
sudo easy_install pip
sudo pip install ansible
```

_Ubuntu/Debian_

For Ubuntu/Debian, you can install Ansible using the default package manager. Use this command:

```
sudo apt-get update && sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update && sudo apt-get install ansible -y
```

_RedHat 7/CentOS 7_

For RedHat 7/CentOS 7, you can install Ansible by enabling the `epel` repo. Use the following commands:

```
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install ansible
```


## Scenario setup

This section describes how to set up a component blueprint in the service catalog that allows a user to select Ansible playbooks from a list and have them run as part of service provisioning.

### Create a custom attribute to hold the list of available playbooks
**Note:** To update this list automatically see "Optional: Updating the list of playbooks automatically" below.

1. In Commander, go to **Configuration menu > Custom Attributes.** 
1. On the **Custom Attributes** pane, click **Add**.
1. In the Configure Custom Attribute dialog, enter a name for the custom attribute, and do the following:

  * From the **Type** drop-down list, select **list**.
  * From **Applies to**, select as **form**.
1. Click **Next**.
1. On the Configure Attribute page, add values for each playbook that can be run.
1. Click **Finish**. 

### Install the plug-in workflow step package

This scenario uses the Ansible plug-in workflow step package (`wfplugins-ansible.jar`), which provides a plug-in workflow step to enable Commander to execute the ansible-playbook command to install playbook on a target VM.

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `ansible` directory, which contains the Ansible plug-in workflow step package. 

To learn how to download and install workflow plug-in steps, see [Adding plug-in workflow steps](https://docs.embotics.com/Commander/Using-Plug-In-WF-Steps.htm#Adding).

### Create guest OS credentials
The completion workflows require guest OS credentials to run Ansible playbooks on the deployed VM. Before importing the workflow, you must create a set of guest OS credentials.
1. In Commander, go to **Configuration > Credentials**.
1. Click **Add**.
1. In the Add Credentials dialog: 

   a. Select **Username/Password** for the Credentials Type.

   ​    **Note:** For Amazon EC2 instances, you must create **RSA Key** credentials instead.

   b. Enter **admin** for the Name.

   ​    This name is hard-coded in the completion workflow, so enter the name exactly as shown. Note that the Name field is Commander-specific, and is separate from the Username field.

   c. Enter the required username (for example "root", "ec2-user", or "ubuntu") and password.

   e. Enter a description to help clarify the purpose of these credentials.

   f. For Category, select **Guest OS Credentials**.

   g. Click **OK**.

## Download and edit the Ansible completion workflow
Download the completion workflow,`ansible-vm-component-workflow` from the [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) repo and then import it into Commander. To learn how to import workflows, see [Exporting and Importing Workflow Definitions](https://docs.embotics.com/commander/exporting-and-importing-workflows.htm).
The workflow contains two instances of the **Run ansible-playbook** step. 

- the first shows you how to run Ansible playbooks using inline playbook YAML. Note that the YAML used for this step is an example that works for Amazon EC2 instances, since it includes the action "ec2_facts". Edit the YAML for your target as required. 
- the second shows you how to use playbook URLs

These steps are configured to execute when specific conditions are met. For example, when "apache" is selected for the value of the Ansible Playbook custom attribute, the completion workflow runs the Apache playbook. 

You need to add a **Run ansible-playbook** step for each playbook on offer, using either inline YAML or playbook URLs.

**Note**: On the Assigned Components page of the Completion Workflow Configuration wizard, you can keep the default setting, **Do not apply this workflow to any component**, for now. You will apply the workflow when you create the service.

### Create the service catalog entry and component blueprint
1. In Commander, go to **Configuration > Service Request Configuration**, then click **Add Service**.
1. On the Service Description page, type a name for the server, then click **Next**.
1. On the Component Blueprints page, click **Add > VM Template, Image or AMI**. 
1. In the dialog that appears, select a Linux template as the component, click **Add to Service**, then **Close**.

    **Note:** If this template does not have Ansible pre-installed, you must configure the completion workflow to install Ansible. See the "Installing Ansible on target instances" section above for more information.
1. Then customize the component configuration parameters on each of the following tabs:
   - On the **Infrastructure** tab, specify the Ansible completion workflow you configured.
   - On the **Attributes** tab, add the Ansible Playbook attribute you created.
   - On the **form** tab, add the Ansible Playbooks attribute you created, and enable **Select Multiple**.
   - If you want to allow end users to upload their own Ansible playbooks, add the File Upload attribute. This attribute requires a `#{target.settings.uploadedFile['Uploaded Playbook'].file[1].content}` entry in the **Playbook YAML** field of the workflow step.
1. Click **Next**. 
1. On the Deployment page, use the default and click **Next**.
1. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. To learn more about Intelligent Placement, see [Intelligent Placement](https://docs.embotics.com/commander/intelligent-placement.htm) in the Commander User Guide.  
1. On the Visibility page, specify who can request this service, then click **Next**.
1. On the Summary page, review the service's configuration details, and click **Finish**. 

## Optional: Allowing end users to upload their own playbooks
To allow your end users to provide their own Ansible playbooks:
1. Edit the service catalog entry you created: 

   - On the Form tab for the Linux template, add the **File Upload** form element. 
   - Name the form element "Uploaded Playbook".

1. Edit the VM completion workflow you downloaded:  

   - In the **Playbook YAML** field for the **Run ansible-playbook** step, enter the following to retrieve the contents of the playbook uploaded through the request form:  

     `#{target.settings.uploadedFile['Uploaded Playbook'].file[1].content}`

## Optional: Updating the list of playbooks automatically

If you maintain a repository of playbooks and wish to offer all of them to your end users, Commander can retrieve the list of playbooks from your repository and update the service catalog and workflow as the list of playbooks changes. We've published a command workflow, `Update CA`, that performs this task. This command workflow has no inventory target and can be scheduled to run regularly.

### Create system credentials

The command workflow requires system credentials to execute a Commander REST API call. Before importing the workflow, you must create a set of system credentials.

1. In Commander, go to **Configuration > Credentials**.
1. Click **Add**.
1. In the Add Credentials dialog:

   a. Select **Username/Password** for the Credentials Type.

   b. Enter **Commander superuser** for the Name.
   ​    This name is hard-coded in the command workflow, so enter the name exactly as shown.

   c. Enter the username and password for the Commander Superuser account.

   d. Enter a description if you wish.

   e. For Category, select **System**.

   f. Click **OK**.
   
### Import the command workflow

1. Go to the [Embotics Git repository](https://github.com/Embotics/Scenarios) and download the Update CA workflow. 
1. In Commander, go to **Configuration > Command Workflows**.
1. Click **Import** and browse to the Upload CA file you downloaded.
1. Commander automatically validates the workflow. Click **Import**.

### Edit the command workflow
1. Select the imported workflow in the list and click **Edit**.
1. Replace the first workflow step with one or more steps that obtain the list of new playbooks by querying your remote repository. You must format the list as follows:  
     ```
     <allowedValues>value1</allowedValues><allowedValues>value2</allowedValues>
     ```
1. The second step, Get Attribute ID, retrieves the ID of the Ansible Playbooks custom attribute. Edit the URL as required.
1. The third step, Update Attribute, updates the values for the Ansible Playbooks custom attribute, using the output of the first step in the workflow. Edit the URL as required.
1. Click **Next**, enter a description of your changes, and click **Finish**.

### Schedule the command workflow

1. Go to **Configuration > Command Workflows**.
1. Select the imported workflow in the list and click **Schedule > Schedule**.
1. Configure the desired schedule.
1. Click **Next** and **Finish**. 