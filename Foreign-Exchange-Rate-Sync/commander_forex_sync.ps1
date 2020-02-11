$moduleName = "VCommanderRestClient"
If (-not (Get-Module -name $moduleName)) {Import-Module -Name $moduleName } 
else {Remove-Module $moduleName
        Import-Module -Name $moduleName }
$moduleName = "VCommander"
If (-not (Get-Module -name $moduleName)) {Import-Module -Name $moduleName} 
else {Remove-Module $moduleName
        Import-Module -Name $moduleName}

$commanderUser = (Get-Item Env:SELECTED_CREDENTIALS_USERNAME).value 
$commanderPass = (Get-Item Env:SELECTED_CREDENTIALS_PASSWORD).value
$commanderSecPass = ConvertTo-SecureString $commanderPass -AsPlainText -Force
$commanderCredential = New-Object System.Management.Automation.PSCredential($commanderUser,$commanderSecPass)  

#User Configuration - Edit these Settings
$CommanderServerURL = "localhost"
$baseCurrency = "SEK"
$convertToCurrency = "USD"
$targetCostModel = "Amazon Web Services"
#End User Configuration

#Connecting to vCommander
$Global:SERVICE_HOST = $CommanderServerURL
$Global:REQUEST_HEADERS =@{}
$Global:BASE_SERVICE_URI = $Global:BASE_SERVICE_URI_PATTERN.Replace("{service_host}",$Global:SERVICE_HOST)   
$cred = (New-DecryptCredential -keyFilePath $CredFile) 	
$Global:CREDENTIAL = $commanderCredential
VCommander\Set-IgnoreSslErrors
$connected = Connect-Client

#Get the FOREX info from EWBank
$forexURL = "https://api.exchangeratesapi.io/latest?base=$baseCurrency"
try
{       
    $rates = Invoke-WebRequest -Method GET -Uri $forexURL -ContentType “application/json” -UseBasicParsing
    $ratesObject = ConvertFrom-Json -InputObject $rates    
}
Catch
{
    Write-host "Failed to get exchange rates"
    Write-Host $_.Exception.ToString()
    $error[0] | Format-List -Force
    Exit 1
}

#Parse the exchange for the selected currency
$exchangeRate = $ratesObject.rates.$convertToCurrency
$exRateAsPercentage = [math]::Round(($exchangeRate * 100),2)

#Get the current Cost Model configurations from Commander
$model = (Get-CostModelByName -name $targetCostModel).CostModel

$costModel = New-DTOTemplateObject -DTOTagName "CostModel"
    $costModel.CostModel.name = $model.name
    $costModel.CostModel.id = $model.id

    # Retrieve the target
    Add-Member -InputObject $costModel.CostModel -MemberType NoteProperty -Name "targets" -Value $model.targets -Force

    # Valid values for view: OPERATIONAL | VMS_AND_TEMPLATES
    $costModel.CostModel.view = $model.view

    # Resource Costs
    $costModel.CostModel.reservedMemoryCost = $model.reservedMemoryCost
    $costModel.CostModel.allocatedMemoryCost = $model.allocatedMemoryCost
    $costModel.CostModel.reservedCpuCost = $model.reservedCpuCost
    $costModel.CostModel.allocatedCpuCost = $model.allocatedCpuCost

    $costModel.CostModel.pricingPlan = $model.pricingPlan

    # Storage Costs
    $costModel.CostModel.defaultStorageTier = $model.defaultStorageTier

    $costModel.CostModel.storageTierCosts = $model.storageTierCosts
    $costModel.CostModel.uptimeCalcs = $model.uptimeCalcs

    # Valid values for storageCostCalculation: ACTUAL_SIZE | PROVISIONED_SIZE
    $costModel.CostModel.storageCostCalculation = $model.storageCostCalculation
    $costModel.CostModel.uptimeCalcs = $model.uptimeCalcs
                
    #add the markup
    $newMarkup = New-Object -TypeName Object
    $newMarkup | Add-Member -MemberType NoteProperty -Name markupDiscount -Value $exRateAsPercentage
    $newMarkup | Add-Member -MemberType NoteProperty -Name serviceName -Value "Global Default"

    $costModel.CostModel | Add-Member -MemberType NoteProperty -Name "serviceMarkupDiscount" -Value $newMarkup -Force

#Update the cost model
$update = Update-CostModel -id $model.id -updatedCostModel $costModel
