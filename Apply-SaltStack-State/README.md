# Applying a SaltStack State

This scenario explores using Embotics® Commander® to apply a SaltStack state on a new or existing system.

## Change Log

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires Commander release 7.0.2 or higher
* A SaltStack API endpoint reachable by Commander
* The SaltStack minion service should be installed on the target system and authenticated with the master (see section below for more details)

### Installing SaltStack Minion Service

To run Salt commands and apply states you need to install the SaltStack "minion" service. The easiest way to do this is through the bootstrap script available [here](https://bootstrap.saltstack.com).

The workflow module `Install Salt Minion.yaml` gives an example of how to bootstrap a minion in Commander.

## Scenario setup

This section describes how to set up a component blueprint in the service catalog that allows a user to select Salt states from a list and have them be applied as part of service provisioning.

### Create a custom attribute to hold the list of available states

1. In Commander, go to **Configuration menu > Custom Attributes.** 
2. On the **Custom Attributes** pane, click **Add**.
3. In the Configure Custom Attribute dialog, enter a name for the custom attribute, and do the following:
    * From the **Type** drop-down list, select **list**.
    * From **Applies to**, select **form**.
4. Click **Next**.
5. On the Configure Attribute page, add values for the name of each state that can be chosen.
6. Click **Finish**. 

### Install the plug-in workflow step package

This scenario uses the SaltStack Community plug-in workflow step package (`wfplugins-saltstack.jar`), which provides a plug-in workflow step to enable Commander to make calls to the Salt API.

Go to [Embotics GitHub / Plug-in Workflow-Steps](https://github.com/Embotics/Plug-in-Workflow-Steps) and clone or download the repository. Then in your local version of the repo, browse to the `saltstack` directory, which contains the SaltStack plug-in workflow step package. 

To learn how to download and install workflow plug-in steps, see [Adding plug-in workflow steps](http://docs.embotics.com/commander/Using-Plug-In-WF-Steps.htm#Adding).

### Create credentials for the API
The completion workflows require "guest OS credentials" to connect to the Salt API. Before importing the workflow, you must create a set of guest OS credentials.
1. In Commander, go to **Configuration > Credentials**.
2. Click **Add**.
3. In the Add Credentials dialog: 

   a. Select **Username/Password** for the Credentials Type.
   b. Enter **salt-api** for the Name.

   ​    This name is hard-coded in the completion workflow, so enter the name exactly as shown. Note that the Name field is Commander-specific, and is separate from the Username field.

   c. Enter the required username (for example "salt") and password.

   e. Enter a description to help clarify the purpose of these credentials.

   f. For Category, select **Guest OS Credentials**.

   g. Click **OK**.

## Download and edit the Salt completion workflow
Download the completion workflow,`Salt State Example Workflow.yaml` from the [Embotics Git Hub / Scenarios](https://github.com/Embotics/Scenarios) repo and then import it into Commander. To learn how to import workflows, see [Exporting and Importing Workflow Definitions](http://docs.embotics.com/commander/exporting-and-importing-workflows.htm).

The workflow contains three steps:
* Install salt minion
* Run Module - Runs "test.ping" function to confirm the minion is connected
* Apply State - Applies the "apache" state to install and start the web server

**Note**: On the Assigned Components page of the Completion Workflow Configuration wizard, you can keep the default setting, **Do not apply this workflow to any component**, for now. You will apply the workflow when you create the service.

### Install the state on the Salt Master
This example uses the `apache` state from [here](https://github.com/saltstack-formulas/apache-formula.git). You can add this repository directly (see [here](https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html) for instructions on how to add a git repo to salt) or download it and add it to your state folder (typically `/srv/salt/`)

### Create the service catalog entry and component blueprint
1. In Commander, go to **Configuration > Service Request Configuration**, then click **Add Service**.
2. On the Service Description page, type a name for the server, then click **Next**.
3. On the Component Blueprints page, click **Add > VM Template, Image or AMI**. 
4. In the dialog that appears, select a Linux template as the component, click **Add to Service**, then **Close**.

5. Then customize the component configuration parameters on each of the following tabs:
   - On the **Infrastructure** tab, specify the Salt completion workflow you configured.
   - On the **Attributes** tab, add the Salt State attribute you created.
   - On the **form** tab, add the Salt State attribute you created.
6. Click **Next**. 
7. On the Deployment page, use the default and click **Next**.
8. For the purposes of this walk-through, we’ll skip the Intelligent Placement page. Click **Next**. To learn more about Intelligent Placement, see [Intelligent Placement](http://docs.embotics.com/commander/intelligent-placement.htm) in the Commander User Guide.  
9. On the Visibility page, specify who can request this service, then click **Next**.
10. On the Summary page, review the service's configuration details, and click **Finish**. 
