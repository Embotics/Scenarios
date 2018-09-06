# Running Ansible Playbooks

This scenario enables you to use Embotics vCommander to run an Ansible playbook on a target system using the ansible-playbook command.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires vCommander release 7.0 or higher.
* Target systems must be accessible for Guest OS commands (VMware tools or SSH).
* Ansible must be installed on the target system (see below).

### Installing Ansible on target instances
Ansible can be installed as part of the bootstrapping of the instance or with a Run Command in Guest workflow step. The method of installing Ansible varies for the different Linux distributions.

_Amazon Linux_

For Amazon Linux, Ansible can be installed using `pip`. You can use the following commands:

```
sudo easy_install pip
sudo pip install ansible
```

_Ubuntu / Debian_

For Ubuntu, you can install Ansible using the default package manager. Use this command:

```
sudo apt-get update && sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update && sudo apt-get install ansible -y
```

_RedHat 7 / CentOS 7_

For RedHat 7, you can install Ansible by enabling the `epel` repo. Use the following commands:

```
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install ansible
```




## Scenario setup

This section describes how to set up a blueprint in the service catalog that allows a user to select Ansible playbooks from a list and have them run as part of service provisioning.

### Step 1 - Create a custom attribute to hold the list of available Playbooks
**Note: To update this list automatically see "Updating the list of playbooks automatically" below**.

* Create a custom attribute with **Type** as **list** and **Applies to** as **form**.
* Add values for each playbook that can be run. 

### Step 2 - Create the workflow
* Create a completion workflow for VM components.
* There are two styles of workflow that can be used:
  * Conditional steps with inline playbook YAML
  * Conditional steps with playbook URLs
* The `Ansible-vm-component-completion-wf` file contains examples of both styles and can be imported. To learn how to import workflows, see [Exporting and Importing Workflow Definitions](http://docs.embotics.com/vCommander/exporting-and-importing-workflows.htm).
* Create the appropriate number of steps for the playbooks on offer and save the workflow.

### Step 3 - Create the service catalog blueprint

 * Create a service catalog entry with a Linux template as the component.
 * If this template does not have Ansible pre-installed, you must configure the completion workflow to install Ansible.
* On the **Infrastructure** tab, specify the workflow created in step 2.
* On the **Attributes** tab, add the Ansible Playbooks attribute created in step 1.
* On the **form** tab, Add the the Ansible Playbooks attribute created in step 1 and enable **Select Multiple**.

### Allowing end users to upload their own playbooks
* By using a File Upload control on the component form, you can allow your end users to provide their own Ansible playbooks. Use `#{target.settings.uploadedFile['Uploaded Playbook'].file[1].content}` in the **Playbook YAML** field of the workflow step.

### Updating the list of playbooks automatically

*If you maintain a repository of playbooks and wish to offer all of them to your end users, vCommander can retrieve the list of playbooks from your repository and update the blueprint and workflow as the list of playbooks changes.*

* Create a command workflow with no inventory target with steps that accomplish the following:
  1. Obtain the list of playbooks by querying the remote repository.

  1. Format the list of playbooks as:

    ```
    <allowedValues>playbook1</allowedValues><allowedValues>playbook2</allowedValues><allowedValues>playbook3</allowedValues>
    ```
  1. Update the custom attribute using the vCommander REST API.

  1. Schedule the workflow at the desired time.
