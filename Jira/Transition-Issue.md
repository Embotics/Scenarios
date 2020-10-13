# Transitioning an Issue

## Prerequisites

- Jira API credentials
- JiraPS PowerShell module

Follow the instructions to set up these requirements in the [Readme](README.md)

## Configuration

### Required Configuration

The following values must be entered in [Jira_TransitionIssue.ps1](./Scripts/Jira_TransitionIssue.ps1).

| Variable              | Example                      | Description                               |
| --------------------- | ---------------------------- | ----------------------------------------- |
| `$Server`             | `"https://jira.example.com"` | The base URL to your Jira instance        |
| `$IssueKey`           | `"TEST-1"`                   | The unique key of the issue to transition |
| `$TransitionToStatus` | `"Done"`                     | The name of the status to transitin to    |

**Important**: The issue must be able to transition directly from its current status to `$TransitionToStatus`!
Jira_TransitionIssue.ps1 cannot perform multi-step transitions.

### Optional Configuration

The following values are optional in Jira_TransitionIssue.ps1. Any of these values may be null or empty, in which case,
Jira will use the default value (if any is configured).

| Variable    | Example                                                                               | Description                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `$Fields`   | `@{ "Story Points" = @{ value = 3}; customfield_12345 = @(@{ value = "Customer" }) }` | Additional fields to set on the issue; custom fields are allowed; [README.md](./README.md) describes the expected format |
| `$Assignee` | `"john.doe"`                                                                          | The new assignee                                                                                                         |
| `$Comment`  | `"Transitioned to Done via Snow Commander."`                                          | A comment to add                                                                                                         |
