# Jira Scenarios

## Common Setup for all Scenarios

### Install JiraPS Module

Log in to your Windows server as the user account that runs Commander, then launch a Powershell session and run:

```PowerShell
Find-Module JiraPS | Install-Module -Scope CurrentUser
```

(Alternatively, launch a PowerShell session with Administrator privileges and use `-Scope AllUsers` to install the
module for all users on the server.)

### Set the Jira API Credentials in Commander

The Jira scripts rely on basic authentication to authenticate with the Jira API.

1. Follow [Atlassian's steps to create an API token](https://confluence.atlassian.com/cloud/api-tokens-938839638.html).
1. In Commander, go to **Configuration > Credentials**.
1. Click **Add**.
1. In the Add Credentials dialog:

   1. Select **Username/Password** for the Credentials Type.
   1. Enter **Jira API** for the Name.
      - This name is hard-coded in the workflows, so enter the name exactly as shown (otherwise edit the workflow YAML
        before importing). Note that the Name field is Commander-specific, and is separate from the Username field.
   1. For username, enter the Jira user's name and for password, enter the API token created in Step 1.
   1. Enter a description to help clarify the purpose of these credentials.
   1. For Category, select **System Credentials**.
   1. Click **OK**.

### Fields Format

For Jira scripts that can modify issue fields, the format for the `$Fields` variable follows the
[format described by JiraPS](https://atlassianps.org/docs/JiraPS/about/custom-fields.html).

In short, `$Fields` is a mapping of field names or field ids to field values. For example:

```PowerShell
$Fields = @{
   labels            = @("needs-grooming", "production")
   customfield_11223 = @{ id = 12345 }
   Customers         = @(@{ value = "Customer1" }, @{ value = "Customer2" })
}
```

The format of each field value differs depending on the field type. An exhaustive list of examples for each field type
is available in JiraPS's documentation; a few examples are provided directly below for convenience.

#### Number

```PowerShell
@{ "Story Points" = 2 }
```

#### Text

```PowerShell
@{ customfield_11111 = "value" }
```

#### Single Select

```PowerShell
@{ customfield_11223 = @{ value = "option" } }
# or
@{ customfield_11223 = @{ id = 12345 } }
```

#### Multi-Select

```PowerShell
@{ Customers = @(@{ value = "Customer1" }, @{ value = "Customer2" }) }
```
