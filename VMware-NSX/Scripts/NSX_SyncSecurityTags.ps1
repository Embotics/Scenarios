<#
Nightly Sync Script to Update Form Security Group attribute in vCommander. 
In some cases it might be required to trust the default NSX manager Certificate

Designed to run as:
C:\Scripts\NSX_SyncSecurityTags.ps1

Requirements vCommander powershell Client 2.8, Powershell 4 or higher
#>


##############################################################################################################
#Edit These For your Environment
    #vComamnder
    $vCommanderServer = "localhost" #address of your vCommander server
    $CredFile = 'C:\scripts\superuser.xml'  #Credential file to access your vCommander
    #NSX
    $nsx = "10.16.0.31"           #address of your NSX server
    $nCredfile = 'C:\scripts\nsx.xml'   # Credential file to access NSX via API

    #Attribute to Create/Update
    $Attribute = "Security Tag"   # Attrib to be updated or created

##############################################################################################################
#Do not Edit Below
##############################################################################################################

#Import modules 
    Import-Module "VCommanderRestClient"
    Import-Module "VCommander"
    Import-Module "VMware.VimAutomation.Core"

#Connecting to vCommander
    $Global:SERVICE_HOST = $vCommanderServer
    $Global:REQUEST_HEADERS =@{}
    $Global:BASE_SERVICE_URI = $Global:BASE_SERVICE_URI_PATTERN.Replace("{service_host}",$Global:SERVICE_HOST)   
	$Cred = (New-DecryptCredential -keyFilePath $CredFile) 	
    $Global:CREDENTIAL = $Cred
    VCommander\Set-IgnoreSslErrors
    Connect-Client

################################################
# Setting Cert Policy - required for successful auth with the API
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
        $TagData = $rxml.securityTags.securityTag
#Get NSX Security Groups
   $nSecTags = $TagData.name

#Populate Attribute $Attribute
        $CheckAttrib = (Get-CustomAttributes).CustomAttributeCollection.CustomAttributes | Where-Object{$_.Name -EQ $Attribute}
        $attribid = $CheckAttrib.id
    If ($CheckAttrib.displayName -ne $Attribute)
            {$caObject = New-DTOTemplateObject -DTOTagName "CustomAttribute"
            #Specify attribute value
            $caObject.CustomAttribute.name="$Attribute"
            $caObject.CustomAttribute.description="Applied Security Profile - NSX"
            $caObject.CustomAttribute.targetManagedObjectTypes = @("ALL")
            $caObject.CustomAttribute.portalEditable = "false"
            $caObject.CustomAttribute.id = -1
            $caObject.CustomAttribute.allowedValues = @($nSecTags)
            $createdCa = New-CustomAttribute -customAttributeDTo $caObject
            Write-host "$Attribute has been created"
            }
#Reload the form Attribute with values from NSX
    If ($CheckAttrib.displayName -eq $Attribute)
        {   $caObject1 = Get-CustomAttributeById -id $attribid
            $allowedValues = $caObject1.CustomAttribute.allowedValues
            $caObject1.CustomAttribute.allowedValues = @()
            $caObject1.CustomAttribute.allowedValues += $nSecTags
            $updatedCa1 = Update-CustomAttribute -id $attribid -customAttributeDTo $caObject1
            Write-Host "Update of $Attribute attribute complete"
            }

Disconnect-Client

	
