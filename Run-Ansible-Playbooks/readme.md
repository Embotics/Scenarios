# Running Ansible Playbooks

This scenario enables you to use Embotics® vCommander® to run an Ansible playbook on a target system using the `ansible-playbook` command.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires vCommander release 7.0.2 or higher
* Target systems must be accessible for Guest OS commands (VMware tools or SSH)
* Ansible must be installed on the target system (see section below for more details)

### Installing Ansible on target instances

To run an Ansible playbook on a target system, you must install Ansible on that system. Ansible can be installed as part of the bootstrapping of the instance (that is, the template used has Ansible pre-installed). It can also be installed through a vCommander **Guest OS > Run Program** workflow step. You can choose whichever is more appropriate for you development needs. 

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

### Step 1 - Install the plug-in workflow step package

This scenario uses the Ansible plug-in workflow step package (wfplugins-ansible.jar), which provides a plug-in workflow step to enable vCommander to execute the ansible-playbook command to install playbook on a target VM.

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `ansible` directory, which contains the Ansible plug-in workflow step package. 

To learn how to download and install workflow plug-in steps, see [Adding plug-in workflow steps](http://docs.embotics.com/vCommander/Using-Plug-In-WF-Steps.htm#Adding).

### Step 2 - Create a custom attribute to hold the list of available playbooks
**Note: **To update this list automatically see "Updating the list of playbooks automatically" below.

1. In vCommander, go to **Configuration menu > Custom Attributes.** 
2. On the **Custom Attributes** pane, click **Add**.
3. In the Configure Custom Attribute dialog, enter a name for the custom attribute, and do the following:

  * From the **Type** drop-down list, select **list**.
  * From **Applies to**, select as **form**.
4. Click **Next**.
5. On the Configure Attribute page, add values for each playbook that can be run.
6. Click **Finish**. 

### Step 3 - Create the completion workflow

The completion workflow that will run the Ansible playbook can use the two types of steps:
   - Conditional steps with inline playbook YAML
   - Conditional steps with playbook URLs

The `Ansible-vm-component-completion-wf` file contains examples of both styles. Perform the following steps to import this file.
**Note:** This workflow definition has steps that contain credentials. Therefore credentials with the same name must exist on the vCommander installation where you're importing the file. For the workflow definition to successfully import, you can either add the appropriate credentials to vCommander or edit the workflow definition in a text editor to remove the credential names before you import it. 

1. Go to [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) and clone or download the repository.
2. In vCommander, go to **Configuration > Service Request Configuration > Completion Workflows** and click **Import**.
3. Go to the Scenarios repo that you cloned or downloaded, then from the Installing Ansible Playbooks directory, select the`Ansible-vm-component-completion-wf` .yaml or .json file, and click **Open**.
    vCommander automatically validates the workflow and displays the validation results in the Messages area of the Import Workflow dialog.
4. Enter a comment about the workflow in the **Description of Changes** field, and click **Import**.
    To learn more, see [Importing and Exporting Workflow Definitions](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm) in the vCommander User Guide.
5. Create the appropriate number of steps for the playbooks on offer, then click **Next**.
6. On the Assigned Components page, select **Do not apply this workflow to any component**, then click **Next**. The completion workflow will be assigned to a component through the service catalog entry. 
7. On the Summary page, enter details about the workflow in the **Description of Changes** field, then click **Finish**.        

### Step 4 - Create the service catalog entry and component blueprint

1. In vCommander, go to **Configuration > Service Request Configuration**, then click **Add Service**.
2. On the Service Description page, type a name for the server, then click Next.
3. On the Component Blueprints page, click Add > **VM Template, Image or AMI**. 
4. In the dialog that appears, select a Linux template as the component, click **Add to Service**, then **Close**.

    **Note:** If this template does not have Ansible pre-installed, you must configure the completion workflow to install Ansible. See the "Installing Ansible on target instances" section above for more information.
5. Then customize the component configuration parameters on each of the following tabs:
   - On the **Infrastructure** tab, specify the workflow created in step 3.
   - On the **Attributes** tab, add the Ansible Playbooks attribute created in step 2.
   - On the **form** tab, add the Ansible Playbooks attribute created in step 2, and enable **Select Multiple**.
   - If you want to allow end users to upload their own Ansible playbooks, add the File Upload attribute. This attribute requires a `#{target.settings.uploadedFile['Uploaded Playbook'].file[1].content}` entry  in the **Playbook YAML** field of the workflow step.
6. Click **Next**. 
7. On the Deployment page, use the default and click **Next**.
8. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. To learn more about Intelligent Placement, see [Intelligent Placement](http://docs.embotics.com/vCommander/intelligent-placement.htm) in the vCommander User Guide.  
9. On the Visibility page, specify who can request this service, then click **Next**.
10. On the Summary page, review the service's configuration details, and click **Finish**. 

### Updating the list of playbooks automatically

If you maintain a repository of playbooks and want to offer all of them to your end users, vCommander can retrieve the list of playbooks from your repository and update the blueprint and workflow as the list of playbooks changes.

For vCommander to update the list of playbooks automatically, you must create a command workflow with No Inventory Target. You must then configure steps that accomplish the following:
  1. Obtain the list of playbooks by querying the remote repository.
  1. Format the list of playbooks as:
    ```
    <allowedValues>playbook1</allowedValues><allowedValues>playbook2</allowedValues><allowedValues>playbook3</allowedValues>
    ```
  1. Update the custom attribute using the vCommander REST API.
  1. Schedule the workflow at the desired time.
