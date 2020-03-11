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
$port = "80"
$monitorName = "default_tcp_monitor"
$alg = "round-robin"

# Init
Import-Module PowerNSX

# Connect to vcenter
Connect-VIServer -Server $viserver -User $user -Password $password
Connect-NsxServer -NsxServer $nsxServer -Username $user -Password $password

# find an edge device with available IPs
$allocated = Get-NsxEdge | Get-NsxEdgeInterface | 
Get-NsxEdgeInterfaceAddress | Select-Object primaryAddress | ForEach-Object {$_.primaryAddress}
$used = Get-NsxEdge | Get-NsxLoadBalancer | Get-NsxLoadBalancerVip | Select-Object ipAddress | ForEach-Object {$_.ipAddress}

$extIp = @($allocated | Where-Object {$used -notcontains $_})[0]

if ($null -eq $extIp) {
    Write-Host "No available IPs. Add a new edge device or an address to and existing edge device"
    Exit 1
}
# get edge with that IP
$edgeId = get-nsxedge | Get-NsxEdgeInterface | Get-NsxEdgeInterfaceAddress | where {$_.primaryAddress -eq $extIp} | select edgeId
function mylb {
    return Get-NsxEdge -objectId $edgeId.edgeId | Get-NsxLoadBalancer
}

# Enable load balancer
if (-not (mylb).enabled) {
    mylb | Set-NsxLoadBalancer -Enabled
}

# Pool
$spec = New-NsxLoadBalancerMemberSpec -Name "$vappName-$port" -Member (Get-VApp -Name $vappName) -Port $port

# work around for bad api
$spec | Add-Member -MemberType NoteProperty -Name "ipAddress" -Value "" 

$monitor = mylb | Get-NsxLoadBalancerMonitor -Name $monitorName
$pool = mylb | New-NsxLoadBalancerPool -description "auto" -Algorithm $alg -name "$vappName-Pool80" -MemberSpec $spec -Monitor $monitor -Transparent:$false

# Application Profile
$profile = mylb | New-NsxLoadBalancerApplicationProfile -Name "$vappName-Profile" -Type TCP

# Virtual Server VIP
mylb | Add-NsxLoadBalancerVip -IpAddress $extIP -Port $port -Name "$vappName-vip-$port" -DefaultPool $pool -Protocol "TCP" -ApplicationProfile $profile


