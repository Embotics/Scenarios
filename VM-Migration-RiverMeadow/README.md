# VM Migration with RiverMeadow

## Next Level Economics
Integrating Commander and RiverMeadow enables one click migration between clouds.
You can use this solution to bring additional value to Commanders existing ["VM Comparative Economics"](https://docs.embotics.com/commander/vm_comp_econ_report.htm?Highlight=vm%20comparative) report.
Using this solution you will be able to take action on VMs appearing in the report to maximize cost savings across your private and public clouds.

## Install
Download this package and run `python setup.py install` to install the API client library.

Example workflow modules and scripts are in the `workflow` folder

## Example Workflows
The example workflow is a change request completion workflow that assumes the following:
* You are migrating from a Linux VM Commander manages
* The RiverMeadow target appliance has SSH access to the VM
* You are migrating to AWS

To use the workflows you will need to import them and create the necessary dependencies.

1. Create a "Guest Credential" entry in Commander named "RiverMeadow"
    * This credential will store your RiverMeadow API credentials. 
2. Create a "System Credential" entry in Commander named "Commander API user"
    * This credential will store your Commander API credentials
3. Create a destination in Commander pointing to an AWS deployment destination. The name cannot contain spaces
4. Create a custom attribute called "RiverMeadow Destination" with the name of the destination(s) configured in step 3.
5. Import the workflows. The completion workflow (`RiverMeadow - Migration CR.yaml`) depends on the modules, so import them first.
6. You will also need to create a "Service Change Request" form in the Form Designer and associate the workflow to it.
> The change request form has the following fields:
> * RiverMeadow Target
> * Username (To the Source VM)
> * Password (To the Source VM)

7. Edit the completion workflow and apply it to the change request form you created.
8. Right click on a source VM and choose "Change Management > Request Service Change" and select the RiverMeadow Migration from the list.
9. Fill out the form and click OK
10. After the pre-flight checks complete, you will receive an email asking you to acknowledge it. You can at this point either acknowledge or cancel the workflow.
11. After acknowledgement, the migration profile is created and the migration is run.
