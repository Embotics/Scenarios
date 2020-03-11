# preamble
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'

# configuration
$VIServer = "172.16.10.30"
$nsxServer = "172.16.10.32"
$user = $Env:SELECTED_CREDENTIALS_USERNAME
$password = $Env:SELECTED_CREDENTIALS_PASSWORD

$vappName = "stack001"

# Init
Import-Module PowerNSX

# Connect to vcenter
Connect-VIServer -Server $viserver -User $user -Password $password
Connect-NsxServer -NsxServer $nsxServer -Username $user -Password $password

# Delete VIP, profile, and pool
Get-NsxEdge | Get-NsxLoadBalancer | 
    Get-NsxLoadBalancerVip | Where {$_.name -like "$vappName-vip-*"} | Remove-NsxLoadBalancerVip -Confirm:$false

Get-NsxEdge | Get-NsxLoadBalancer |
    Get-NsxLoadBalancerApplicationProfile  | Where {$_.name -eq "$vappName-Profile"} | Remove-NsxLoadBalancerApplicationProfile -Confirm:$false

Get-NsxEdge | Get-NsxLoadBalancer | 
    Get-NsxLoadBalancerPool | Where {$_.name -like "$vappName-Pool*"} | Remove-NsxLoadBalancerPool -Confirm:$false
