# Requesting and Releasing IP Addresses with Infoblox

This scenario enables you to use Embotics® vCommander® to request an IP address for a VM from the Infoblox IPAM solution as part of a vCommander Approval Workflow as well as releasing IP addresses as part of a vCommander Decommissioning Workflow.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires vCommander release 7.0.2 or higher
* This scenario requires a List-type Custom Attribute named "Service Type" be created in vCommander. 

### Creating the Service Type Custom Attribute

For information on creating the Custom Attribute see:
[Configuring Custom Attributes in vCommander] (https://docs.embotics.com/vCommander/configuring_custom_attributes.htm)

The list of values should contain one entry for each of the Infoblox Networks you want to be able to select from. Make sure that the values entered here match the Comment field of the Networks in Infoblox. 
For example, if I want to be able to target a specific Network where the Comment field equals "Infoblox Network" then I would add an entry of "Infoblox Network" here in the custom attribute.


## Scenario setup

This section describes how to set up the workflow module in vCommander.

### Install the workflow module step package

Go to [Embotics GitHub / Scenarios / Infoblox IP Management](https://github.com/Embotics/ScenariosInfoblox-IP-Management) and download the "Infoblox - Reserve Next Available IP" and "Infoblox - Release Reserved IP" files. You can choose JSON or YAML based on your preferences.

To learn how to download and install workflow plug-in steps, see [Adding workflow module steps](https://docs.embotics.com/vCommander/using-workflow-modules.htm).

### Create Infoblox credentials
The  workflows require credentials to be created to allow the workflow step to communicate with the Infoblox API.
To learn how to create the required credentials file, see {Creating PowerShell Credentials for vCommander} (https://support.embotics.com/support/solutions/articles/8000035233-encrypting-credentials-for-powershell-scripting).
1. Create a credential to authenticate to the Infoblox REST API.
2. Record the path to the credential file.
3. When adding one of the workflow module steps to a workflow, populate the "Path to Infoblox Credentials" field with the absolute path to the credential file created above.


### Create vCommander API credentials

The  workflows require credentials to be created to allow the workflow step to communicate with the vCommander API.
To learn how to create the required credentials file, see {Creating PowerShell Credentials for vCommander} (https://support.embotics.com/support/solutions/articles/8000035233-encrypting-credentials-for-powershell-scripting).
1. Create a credential to authenticate to the vCommander REST API. 
	It is recommended that a privileged user be created in vCommander for this purpose and that the user be named something like "vCommander API User" so that it is clear in logs and events when an action was taken by an automated process, such as a workflow step.
2. Record the path to the credential file.
3. When adding one of the workflow module steps to a workflow, populate the "Path to vCommander Credentials" field with the absolute path to the credential file created above.

   
### Import the Reserve Next Available IP workflow module

1. In vCommander, go to **Configuration > Approval Workflows**.
1. Click **Import** and browse to the Upload JSON or YAML file you downloaded. Select the "Infoblox - Reserve Next Available IP" file.
1. vCommander automatically validates the workflow. Click **Import**.

### Import the Release Reserved IP workflow module

1. In vCommander, go to **Configuration > Completion Workflows**.
1. Click **Import** and browse to the Upload JSON or YAML file you downloaded. Select the "Infoblox - Release Reserved IP" file.
1. vCommander automatically validates the workflow. Click **Import**.

The two workflow steps can no be used in Approval and Completion workflows to reserve and release IP addresses from Infoblox.
