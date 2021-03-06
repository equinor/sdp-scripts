$ErrorActionPreference = "Continue"


if (Get-InstalledModule -Name ImportExcel) 
{
    Write-Host "Required module ImportExcel is installed, continuing script"
} 
else 
{
    Write-host "Installing required ImportExcel module before continuing.."
    Install-Module ImportExcel -Confirm
}

$userFrom = "gm_toolbox@equinor.com"
$excelFile = "C:\appl\outsidecollabs.xlsx"
$list = Import-Excel -Path $excelFile

if ($?)

    {
        $users = $list.login
        $emails = $list.RepoAdminsEmail
    }
else
    {
        Write-host "Error on import of users"
        exit
    }

$cred = Get-Credential -username $userFrom

for ($i = 0; $i -lt $emails.Length; $i++) { 

    Write-host "Sending email to users: $($emails[$i]) regarding repo $($list.RepoName[$i])"

    if ($emails[$i] -ne $null -and $emails[$i] -ne "")
    {
        Send-MailMessage -From "GM IT Toolbox <gm_toolbox@equinor.com>" -To $emails[$i].Split(", ") -Subject "Quarterly access review of repo: $($list.RepoName[$i])" `
        -Cc $userFrom -Body "
        This is a quarterly review of repo permissions for outside collaborators to Github repos.
        You are receiving this email because you have admin permissions to the repo: $($list.RepoName[$i]) which gives access to outside collaborators.

        The repo currently has the following outside collaborators with permissions: 
        $($list.OutsideCollaborators[$i])
        $($list.CollabsPermissions[$i])

        Please review the access settings at $($list.RepoSettingsUrl[$i])

        If one or more of the persoanl user accounts listed above has an @equinor.com email address, please ask for the user to be converted to a regular Github organization member instead of being listed as an outside collaborator.
        This is valid both for internal and external employees.

        If you have any questions, either reach out to @toolbox in the #sdpteam channel on Slack - https://equinor.slack.com/archives/C02JJGV05 , or reply to this email." `
        -SmtpServer "mrrr.statoil.com" -Port 25 -Credential $cred -UseSsl
    }
}

if ($?) 
{
    Write-Host "Script completed Successfully." -ForegroundColor Green
}
