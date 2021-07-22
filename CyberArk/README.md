# Adding Account to CyberArk for Safe based password policy rotation.

This scenario enables you to onboard a Deployed VM or instance to CyberArk as an account for Password policy rotation.

## Changelog

**Version 1.0:** Initial version.

## Prerequisites

- Commander release 8.7.1 or higher
- A system with CyberArk installed that is accessible Via API. This system is referred to hereafter as the CyberArk instance. 


## Install the CyberArk module workflow step package

In the Commander Admin Portal navigate to Configuration> Self Service> Completion.

Select the Modules tab. 

Select Import, then in the Import Workflow dialog,  choose “Onboard_Instance_Cyberark.json” add a description and click “Import”. Once complete you’ll see the module imported.

Now to edit a couple items in the module itself. Edit the module and select next to display the Steps. Click on the script contents window to expand it. The only item that needs to be edited is the $BypassCert variable. This variable defines if the script ignores an unsigned API endpoint on the CyberArk Server. If your Server has a valid Certificate, then set this value to “no”.

Click OK, Next and Finish to exit the wizard.

## Adding the Module to a completion Workflow

Navigate to Configuration> Self Service> Completion in the Snow Commander Admin Portal. 

Select the Workflow which you would like to add the module step to and Select Edit 

On the steps Selection, choose Add> Run Module.  

Now to set the variable details for this step. These are the variables that need to be populated:
   image_username
      -Username used in the image to be rotated by CyberArk.
      
   platform_id
      -Platform identifier for the account, this must already exist in CyberArk or the request will fail. 
      
   safe_name
      -Name of the Safe that the account will be created in.
      
   cyberark_authtype
      -Auth type for the user account used for API calls to CyberArk,  supported types are: CyberArk, LDAP, RADIUS, Windows.
      
   cyberark_instance
      -DNS address of the CyberArk Server.
      
   image_password 
      -Password in the image for the credential to be rotated by CyberArk



