# preamble
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# server configuration
$Server = "http://jira.example.com/"

# required issue configuration
$Project = "TEST"
$IssueType = "Story"
$Summary = "an event occured in Snow Commander"
$Description = @"
An event occured in Snow Commander.

Do something about it.
"@

# optional issue configuration
$Priority = 0       # set to an integer 1-5 or set to 0 to use jira's default priority for new issues
$Reporter = ""      # set to a jira username or set to empty string to use the user from the below credentials
$Labels = @()       # add an array of strings or set to an empty array (or null) to add no labels
$Fields = @{ }      # enter a mapping of field names or field ids (custom fields are allowed) to values or set to an empty hashtable (or null) to add no fields

# credentials
$Username = $Env:SELECTED_CREDENTIALS_USERNAME
$ApiToken = ConvertTo-SecureString -AsPlainText -Force $Env:SELECTED_CREDENTIALS_PASSWORD
$Credential = New-Object pscredential $Username, $ApiToken

# init
Import-Module JiraPS
Set-JiraConfigServer $Server
New-JiraSession $Credential

# work
$NewJiraIssueSplat = @{
    Project     = $Project
    IssueType   = Get-JiraIssueType $IssueType | Select-Object -ExpandProperty ID
    Summary     = $Summary
    Description = $Description
}

if ($Priority) {
    $NewJiraIssueSplat.Priority = $Priority
}

if ($Reporter) {
    $NewJiraIssueSplat.Reporter = $Reporter
}
else {
    $NewJiraIssueSplat.Reporter = $Username
}

if ($Labels) {
    $NewJiraIssueSplat.Labels = $Labels
}

if ($Fields -and 0 -lt $Fields.Count) {
    $NewJiraIssueSplat.Fields = $Fields
}

New-JiraIssue @NewJiraIssueSplat
