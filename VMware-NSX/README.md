# NSX Scenarios

This folder contains a number of scenarios for integrating Commander with VMware NSX Software defined networking platform. It covers the basics from deploying an Edge device to adding a VApp to a logical load balancer.

All of these examples require the PowerNSX module (available [here](https://github.com/vmware/powernsx)) as well as API credentials and access from the Commander server.

## List of Scenarios
* [Deploy Edge Appliance](Deploy-Edge-Appliance.md) - Deploy an NSX Edge Gateway Services appliance via a Commander Service Request
* [Create Security Group](Create-SecurityGroup.md) - Create a Security Group, firewall rule, and attach a VM to it.
* [Create Load Balanced VApp](Create-LoadBalanced-VApp.md) - Deploy a pair of NGINX web servers as a VApp and Load Balance between them with NSX logical load balancer

## Common Setup for all Scenarios
### Install PowerNSX module
With PowerShell Gallery installation can be easily performed with the command:
```
Find-Module PowerNSX | Install-Module -Scope CurrentUser
```
(Omit the `-Scope` parameter to install for all users)

If you do not have PowerShell Gallery support, alternative installation options are available on the PowerNSX [homepage](https://github.com/vmware/powernsx).

### Create credentials for the NSX API
The completion workflows require "guest OS credentials" to connect to the NSX API. Before importing the workflow, you must create the credentials.
1. In Commander, go to **Configuration > Credentials**.
2. Click **Add**.
3. In the Add Credentials dialog: 

   a. Select **Username/Password** for the Credentials Type.
   b. Enter **NSX API** for the Name.

   ​    This name is hard-coded in the workflows, so enter the name exactly as shown (otherwise edit the workflow YAML before importing). Note that the Name field is Commander-specific, and is separate from the Username field.

   c. Enter the required username and password.

   e. Enter a description to help clarify the purpose of these credentials.

   f. For Category, select **Guest OS Credentials**.

   g. Click **OK**.
