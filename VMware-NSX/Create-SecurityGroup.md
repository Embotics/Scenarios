# Working with NSX Security Groups
In this scenario, we will show how to create, add to, and remove NSX Security Groups and firewall sections.

## Prerequisites
* NSX API Credentials and access
* PowerNSX module

Follow the instructions to set up these requirements in the [Readme](README.md)

## Scenario Setup
### Completion workflow
Import the provided completion workflow modules
* `NSX - Add Security Group.yml`
* `NSX - Add Firewall Rule.yml`
* `NSX - Add VM to Security Group.yml`

These will are used in the completion workflow which you can import from `NSX - Ubuntu Webserver - In Security Group.yml`

### Service Catalog entry
Create a new Service Catalog entry in Commander with a VMware template component. In the example, we are using a Ubuntu server image with NGINX pre installed but you can use any VMware template you wish

Set the completion workflow to the one created in the previous step.

### Submit
Submit the service request through the portal. Once the VM is done deploying, the completion workflow will run which will, if everything goes according to plan, create the following objects in NSX:
* Security Group with our deployed VM as a member
* Firewall Section
* Firewall services for TCP ports 80 and 443
* Firewall Rules for those services

## Clean Up
As part of decommissioning or as a change request, clean up of the created resources could be performed. The scripts `NSX_RemoveFromSecuirtyGroup.ps1` and `NSX_RemoveSecuiryGroup.ps1` can be used to easily automate this task.

### NOTE
The script automatically names things according to this pattern (where `$name` is the provided name for the group):
* Security Group: `$name`
* Firewall Section: `$name`
* NSX Service pattern: `$name-$protocol-$port` (protocol and port specified)
* Firewall rule: `$name-$protocol-$port`
