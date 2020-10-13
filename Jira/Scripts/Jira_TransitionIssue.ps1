# preamble
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# server configuration
$Server = "https://jira.example.com/"

# required issue configuration
$IssueKey = "TEST-1"
$TransitionToStatus = "Done"

# optional issue configuration
$Fields = @{ }  # enter a mapping of field names or field ids (custom fields are allowed) to values or set to an empty hashtable (or null) to add no fields
$Assignee = ""  # set to a jira username to reassign the issue
$Comment = @"
"@              # enter a comment

# credentials
$ApiToken = ConvertTo-SecureString -AsPlainText -Force $Env:SELECTED_CREDENTIALS_PASSWORD
$Credential = New-Object pscredential $Env:SELECTED_CREDENTIALS_USERNAME, $ApiToken

# init
Import-Module JiraPS
Set-JiraConfigServer $Server
New-JiraSession $Credential

# work
$InvokeJiraIssueTransitionSplat = @{ Issue = $IssueKey }
$Issue = Get-JiraIssue $IssueKey
$Transitions = Select-Object -ExpandProperty Transition -InputObject $Issue
$DesiredTransition = $Transitions | Where-Object {
    $ResultStatus = Select-Object -ExpandProperty ResultStatus -InputObject $_ | Select-Object -ExpandProperty Name
    $ResultStatus -eq $TransitionToStatus
}

if ($DesiredTransition) {
    $InvokeJiraIssueTransitionSplat.Transition = $DesiredTransition
}
else {
    $IssueStatus = Select-Object -ExpandProperty Status -InputObject $Issue
    $AvailableStatuses = (
        $Transitions | Select-Object -ExpandProperty ResultStatus | Select-Object -ExpandProperty Name
    ) -join ", "

    Write-Error (
        "Issue $IssueKey does not have a transition from its current status of $IssueStatus to $TransitionToStatus." +
        " The available statuses are: $AvailableStatuses."
    )
}

if ($Fields -and 0 -lt $Fields.Count) {
    $InvokeJiraIssueTransitionSplat.Fields = $Fields
}

if ($Assignee) {
    $InvokeJiraIssueTransitionSplat.Assignee = $Assignee
}

if ($Comment) {
    $InvokeJiraIssueTransitionSplat.Comment = $Comment
}

Invoke-JiraIssueTransition @InvokeJiraIssueTransitionSplat
