# Automatically Syncing Foreign Exchange Rate to Commander

This scenario explores using a Scheduled Workflow in Commander to automatically update the exchange rate associated with a Commander Cost Model.

## Change Log

**Version 1.0:** Initial version.

## Prerequisites

* This scenario requires Commander release 7.0.2 or higher
* Commander REST API v2 Powershell Module

## Scenario setup

This section describes how to set up a scheduled workflow in Commander to automatically update the exchange rate associated with a Commander Cost Model.

### Create the Commander REST API Credential
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
  b. Select **No inventory Target** as the Target Type.
  c. For
