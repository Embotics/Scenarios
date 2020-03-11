# preamble
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'

#Config
$VIServer = "172.16.10.30"
$nsxServer = "172.16.10.32"
$user = $Env:SELECTED_CREDENTIALS_USERNAME
$password = $Env:SELECTED_CREDENTIALS_PASSWORD

$sgName = "sgTest"
$vmRemoteId = "1234"

# Init
Import-Module PowerNSX

# Connect to vcenter and nsx
Connect-VIServer -Server $viserver -User $user -Password $password
Connect-NsxServer -NsxServer $nsxServer -Username $user -Password $password

$member = get-vm -Id "VirtualMachine-$vmRemoteId"
Get-NsxSecurityGroup -name $sgName | Add-NsxSecurityGroupMember -Member $member
