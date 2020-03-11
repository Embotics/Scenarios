# preamble
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'

# configuration
$VIServer = "172.16.10.30"
$nsxServer = "172.16.10.32"
$user = $Env:SELECTED_CREDENTIALS_USERNAME
$password = $Env:SELECTED_CREDENTIALS_PASSWORD

$sgName = "L002"

Import-Module PowerNSX

Connect-VIServer -Server $VIServer -User $user -Password $password
Connect-NsxServer -NsxServer $nsxServer -Username $user -Password $password

Get-NsxFirewallSection -Name $sgName | Remove-NsxFirewallSection -force:$true -Confirm:$false
Get-NsxSecurityGroup -Name $sgName | Remove-NsxSecurityGroup -confirm:$false -force:$true
Get-NsxService | Where {$_.Name -like "$sgName-*"} | Remove-NsxService -Confirm:$false -force:$true
