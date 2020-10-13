# Creating an Issue

## Prerequisites

- Jira API credentials
- JiraPS PowerShell module

Follow the instructions to set up these requirements in the [Readme](README.md)

## Configuration

### Required Configuration

The following values must be entered in [Jira_CreateIssue.ps1](./Scripts/Jira_CreateIssue.ps1).

| Variable       | Example                           | Description                                 |
| -------------- | --------------------------------- | ------------------------------------------- |
| `$Server`      | `"https://jira.example.com"`      | The base URL to your Jira instance          |
| `$Project`     | `"TEST"`                          | The Jira project to create the issue within |
| `$IssueType`   | `"Bug"`                           | The type of issue to create                 |
| `$Summary`     | `"an event occured in Commander"` | The issue summary                           |
| `$Description` | `"an event occured in Commander"` | The issue description                       |

### Optional Configuration

The following values are optional in Jira_CreateIssue.ps1. Any of these values may be null or empty, in which case, Jira
will use the default value (if any is configured).

| Variable    | Example                                                                               | Description                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `$Priority` | `3`                                                                                   | The issue priority                                                                                                       |
| `$Reporter` | `"john.doe"`                                                                          | The issue reporter; if null or empty, the API user's username will be used                                               |
| `$Labels`   | `@("production", "needs-grooming")`                                                   | An array of labels to add to the issue                                                                                   |
| `$Fields`   | `@{ "Story Points" = @{ value = 3}; customfield_12345 = @(@{ value = "Customer" }) }` | Additional fields to set on the issue; custom fields are allowed; [README.md](./README.md) describes the expected format |
