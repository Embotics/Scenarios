<#
Script to Update Security Tag on a VM from a vCommander form selection. 
Requirements vCommander powershell Client 2.8, vSphere 6.5 PowerCli

Designed to run as:
C:\Scripts\Set_NSXSecurityTag.ps1 -vmRemoteID #{target.remoteId} -NSXSecTag #{target.settings.customAttribute['Security Tag']}

Requirements vCommander powershell Client 2.8, vSphere 6.5 PowerCli
#>

[CmdletBinding()]
	param(
        [Parameter(Mandatory=$True)]
        [string] $VMRemoteId = $(Throw "Provide the RemoteID of the VM that you would like to assign a group to."), 
        [String] $NSXSecTag = $(Throw "Provide the Name of the NSX SecurityGroup.")
        ) 


###############################################################################################
# Configure the variables below using the Production vCommander & NSX
###############################################################################################

    #NSX
    $nsx = "10.16.0.31"           #address of your NSX server
    $nCredfile = 'C:\scripts\nsx.xml'   # Credential file to access NSX via API
    #VCenter
    $vCenterServer = "10.16.0.30"           #address of your vCenter server
    $vCredfile = 'C:\scripts\vCenter.xml'   # Credential file to access vCenter via API that has NSX permission. 

###############################################################################################
# Nothing to configure below this line - Starting the main function of the script
###############################################################################################
#Load vCommander Modules
###############################################################################################
#Import modules 
    Import-Module "VCommander"
    Import-Module "VCommanderRestClient"
    Import-Module "VMware.VimAutomation.Core"
################################################
################################################
# Setting Cert Policy - required for successful auth with the Zerto API
################################################
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
################################################
# Building NSX API string and invoking API
################################################
    $nCred = New-DecryptCredential $nCredfile
    $authInfo = ("{0}:{1}" -f $nCred.GetNetworkCredential().userName,$nCred.GetNetworkCredential().Password)
    ### Create authorization string and store in $header
	$authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
    $authInfo = [System.Convert]::ToBase64String($authInfo)
    $header = @{Authorization=("Basic {0}" -f $authInfo)}
    $contentType = "application/xml"
    $Response = Invoke-WebRequest -Uri "https://$nsx/api/2.0/services/securitytags/tag" -Headers $header -ContentType $contentType
    if ($Response.StatusCode -eq "200") {Write-Host -BackgroundColor:Black -ForegroundColor:Green Status:Connected to $NSX successfully.}
	    [ xml]$rxml = $Response.Content
        $TagData = $rxml.securityTags.securityTag  | Where-Object{$_.Name -EQ $NSXSecTag}

#Connect to vCenter and Disable Cert warnings
    $vCred = (New-DecryptCredential -keyFilePath $vCredFile) 
    Connect-VIServer -Server $vCenterServer -Credential $vCred
#Get VM information
    $VMid = "VirtualMachine-"+$VMRemoteId   
    $VMData = VMware.VimAutomation.Core\Get-vm -id $VMid
    $vmMoid = $VMData.ExtensionData.MoRef.Value
#GetTag Identifier
    $TagIdentifierString = $TagData.objectId
#Post Data to API
    $PostResponse = Invoke-WebRequest -Method Put -Uri "https://$nsx/api/2.0/services/securitytags/tag/$($TagIdentifierString)/vm/$($vmMoid)" -Headers $header -ContentType $contentType
    if ($PostResponse.StatusCode -eq "200") {Write-Host -BackgroundColor:Black -ForegroundColor:Green Status:  Adding Security Tag $TagIdentifierString to Virtual Machine $($vmMoid)
        Exit 0}
	    