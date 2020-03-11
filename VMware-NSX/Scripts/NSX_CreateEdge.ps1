# preamble
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'
Import-Module PowerNSX

# configuration
$VIServer = "172.16.10.30"
$nsxServer = "172.16.10.32"
$user = $Env:SELECTED_CREDENTIALS_USERNAME
$password = $Env:SELECTED_CREDENTIALS_PASSWORD
$rpoolName = "Edge Devices"
$dstoreName = "Datastore2tb"

$defaultGW = "172.16.10.1"
$availableIps = @(200..250 | %{"172.16.10.$_"})

# Connect to vcenter
Connect-VIServer -Server $viserver -User $user -Password $password
Connect-NsxServer -NsxServer $nsxServer -Username $user -Password $password

# get dependencies
$rpool = Get-ResourcePool -Name $rpoolName
$dstore = Get-Datastore -Name $dstoreName
$network = Get-VDPortGroup -Name "DPortGroup"
$genPass = 'aY@z8yp3ihFdAJP$Om3K'

# get name
$edgeName = "AutoEdge-" + ((get-nsxedge | where {$_.name -like "autoedge*"} | foreach {$_.name.split('-')[-1] -as [int]} | measure -max).maximum + 1)

# get next IP
$usedIps = Get-NsxEdge | Get-NsxEdgeInterface | 
    Get-NsxEdgeInterfaceAddress | Select-Object primaryAddress | ForEach-Object {$_.primaryAddress}
$nextIp = @($availableIps | Where-Object {$usedIps -notcontains $_})[0]
if ($null -eq $nextIp) {
    Write-Host "No more IP's left in the pool!"
    Exit 1
}

# create the interface spec and the edge device!
$vnic0 = New-NsxEdgeInterfaceSpec -Index 0 -Name Uplink -Type uplink -ConnectedTo $network -PrimaryAddress $nextIp -SubnetPrefixLength 24

New-NsxEdge -Name $edgeName -Interface $vnic0 -ResourcePool $rpool -Datastore $dstore -Password $genPass
Get-NsxEdge -Name $edgeName | Get-NsxEdgeRouting | Set-NsxEdgeRouting -DefaultGatewayAddress $defaultGW -Confirm:$false
Get-NsxEdge -name $edgeName | Get-NsxLoadBalancer | Set-NsxLoadBalancer -Enabled