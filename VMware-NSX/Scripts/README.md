# NSX Integrations

This folder contains a collection of scripts and workflow steps for integrating with VMware NSX

## Scripts included in this package
*Firewall and Security Group*
* `NSX_CreateSecurityGroup.ps1` - Create a new Security Group and firewall section
* `NSX_RemoveSecurityGroup.ps1` - Remove a Security Group and firewall section
* `NSX_AddToSecurityGroup.ps1` - Add a VM to a Security Group
* `NSX_RemoveFromSecurityGroup.ps1` - Remove a VM from a security group
* `NSX_AddFirewallRule.ps1` - Add a firewall section and rule
* `NSX_SetSecurityTag.ps1` - Add a security tag to a VM
* `NSX_SyncSecurityTags.ps1` - Sync security tags

*Load Balancing*
* `NSX_CreateLoadBalancer.ps1` - Create an NSX Load Balancer configuration for a vApp
* `NSX_CleanUpLoadBalancer.ps1` - Remove a LoadBalancer configuration previously created through automation
* `NSX_CreateEdge.ps1` - Deploy an NSX Edge Gateway Services appliance

## Examples
See [Scenarios](../Scenarios/README.md)

## Installation
These scripts rely on the PowerNSX module available from VMware.
This module can be installed using PowerShell Gallery:
```
Find-Module PowerNSX | Install-Module -Scope CurrentUser
```

To use the scripts, either call them from disk in an `Execute Script` step or paste them directly into an `Execute Embedded Script`. 

For further instructions and information on PowerNSX please see the [homepage](https://github.com/vmware/powernsx)
