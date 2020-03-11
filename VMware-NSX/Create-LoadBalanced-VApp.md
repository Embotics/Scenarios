# Create a load balanced App
In this scenario, we will deploy a pair of web servers as a VApp stack and serve them via NSX logical load balancing.

## Prerequisites
* NSX API Credentials and access
* PowerNSX module

Follow the instructions to set up these requirements in the [Readme](README.md)

## Scenario Setup
### Completion workflow
Import the required workflow module `NSX - Add Load Balancer.yaml` and the completion workflow `NSX - Load Balanced.yaml`

The Add Load Balancer module has an embedded script that will find an available IP address amongst Edge devices and create a load balancer configuration on that edge - adding the vApp as a member to the pool.

### Service Catalog Entry
Create a new service catalog entry in Commander with two (or more) VM components. In the "Deployment" section of the service, select "Deploy Service As: Virtual Service" - This will ensure the components are deployed together into a "vApp" container.

Select the previously imported completion workflow in the deployment section. Using a completion workflow in this section rather than on a component will use the "service" as the target instead of an individual component.

### Submit
Submit the service request through the portal. Once the VMs are done deploying, the service completion workflow will run which will create the load balancer configuration and add the vApp.

The following resources will be created in NSX:
* Application Profile
* Load balancer pool with the vApp as a member
* Virtual Server using the profile and pool

## Clean Up
The `NSX_CleanUpLoadBalancer.ps1` script can be used to remove configuration created by the creation script. This could be run as a command workflow or on decommissioning of the vApp stack.

