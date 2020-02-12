# Automatically Syncing Foreign Exchange Rate to Commander

This scenario explores using a Scheduled Workflow in Commander to automatically update the exchange rate associated with a Commander Cost Model.
This scenario uses the Exchange Rate API, available here http://exchangeratesapi.io/, and is backed by exchange data from the European Central Bank. Currencies available for conversion depend on the data available from this API.

## Change Log

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires Commander release 7.0.2 or higher
* Commander REST API v2 Powershell Module

## Scenario setup

This section describes how to set up a scheduled workflow in Commander to automatically update the exchange rate associated with a Commander Cost Model.

### Create the Commander REST API Credential
   ​    If you have already created a credential for use with the Commander REST API you can skip this section and use that credential instead.
1. In Commander, select **Configuration > Credentials**.
2. Click **Add**.
3. In the Add Credentials dialog:

   a. Select **Username/Password** for the Credentials Type.
   
   b. Enter **Commander REST API** for the Name.
   
   c. Enter the required username (for example "apiuser") and password.
   
   ​    It is recommended to create a superuser account in Commander that is used for API actions such as this workflow so you cand easily identify actions taken by workflows or other automated systems.
   
   f. For Category, select **Guest OS Credentials**.
   
   g. Click **OK**.

### Create the Scheduled Workflow
1. In Commander, select **Configuration > Command Workflows**.
2. Click **Add**.
3. In the Command Workflow Configuration dialog:

   a. Enter **Commander Forex Sync** for the Name.
  
   b. Select **No inventory Target** as the Target Type. Click Next.
  
   c. Add an **Execute Embedded Script** step.
  
   d. Enter **Sync Forex** for the Name.
   
   e. Select the **Commander REST API** credential.
   
   f. Enter **powershell.exe** for the Executable.
   
   g. Copy and paste the contents of the **commander_forex_sync.ps1** file into the Script Contents.
   
   h. Edit the Script Contents and set the **$baseCurrency** to the 3-digit currency code for the currency your billing data is received in. 
   
   i. Set the **$convertToCurrency** to the 3-digit currency code for the currency you want to convert your billing data to.
   
   j. Set the **$targetCostModel** to the name of the Commander Cost Model related to the costs you wish to convert.
   
   k. Click Next and save the workflow.
  
 4. On the Command Workflow list, select the **Commander Forex Sync** workflow and select **Schedule > Schedule** at the bottom.
 5. Set the Frequency to **Daily** and select a Time. Click Next and save the schedule.
