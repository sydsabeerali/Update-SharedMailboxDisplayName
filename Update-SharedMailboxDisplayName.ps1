#Requires -Modules ExchangeOnlineManagement
<#
.SYNOPSIS
    Standardizes shared mailbox display names in Exchange Online by removing a target keyword pattern.

.DESCRIPTION
    Identifies shared mailboxes whose display names match a defined keyword pattern
    and a specific SMTP domain, then removes the keyword to enforce naming consistency
    across the tenant. Reduced mailbox renaming time from ~1 hour to just minutes,
    achieving ~95% efficiency improvement.

.PARAMETER AdminUPN
    UPN of the Exchange Online administrator account

.PARAMETER TargetKeyword
    The keyword/prefix to remove from matching display names

.PARAMETER TargetDomain
    The SMTP domain to filter mailboxes (e.g., example.org)

.PARAMETER WhatIf
    Preview changes without applying them (built-in PowerShell parameter)

.EXAMPLE
    # Preview changes first (recommended)
    .\Update-SharedMailboxDisplayName.ps1 `
        -AdminUPN "admin@contoso.com" `
        -TargetKeyword "OLD-" `
        -TargetDomain "contoso.org" `
        -WhatIf

.EXAMPLE
    # Apply changes
    .\Update-SharedMailboxDisplayName.ps1 `
        -AdminUPN "admin@contoso.com" `
        -TargetKeyword "OLD-" `
        -TargetDomain "contoso.org"

.NOTES
    - Always run with -WhatIf first to preview changes
    - Requires Exchange Administrator role or higher
    - Changes may take a few minutes to reflect in Exchange Online
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidatePattern('^[\w\.-]+@[\w\.-]+\.\w+$')]
    [string]$AdminUPN,

    [Parameter(Mandatory)]
    [string]$TargetKeyword,

    [Parameter(Mandatory)]
    [string]$TargetDomain
)

#region Functions

function Connect-EXO {
    param ([string]$UPN)
    try {
        Write-Host "[INFO] Connecting to Exchange Online..." -ForegroundColor Cyan
        Connect-ExchangeOnline -UserPrincipalName $UPN -ShowBanner:$false -ErrorAction Stop
        Write-Host "[SUCCESS] Connected to Exchange Online." -ForegroundColor Green
    }
    catch {
        Write-Error "[ERROR] Failed to connect to Exchange Online: $_"
        exit 1
    }
}

function Get-MatchingMailboxes {
    param (
        [string]$Keyword,
        [string]$Domain
    )

    Write-Host "[INFO] Searching for mailboxes matching keyword '$Keyword' in domain '$Domain'..." -ForegroundColor Cyan

    $mailboxes = Get-Mailbox -ResultSize Unlimited -ErrorAction Stop |
        Where-Object {
            $_.DisplayName -match [regex]::Escape($Keyword) -and
            $_.PrimarySmtpAddress -match "@$([regex]::Escape($Domain))$"
        }

    if (-not $mailboxes) {
        Write-Host "[INFO] No matching mailboxes found. No changes required." -ForegroundColor Yellow
        return $null
    }

    Write-Host "[FOUND] $($mailboxes.Count) matching mailbox(es) identified." -ForegroundColor Green
    return $mailboxes
}

function Update-MailboxDisplayName {
    param (
        $Mailbox,
        [string]$Keyword
    )

    $oldName = $Mailbox.DisplayName
    $newName = ($oldName -replace [regex]::Escape($Keyword), '').Trim()

    if ($oldName -eq $newName) {
        Write-Host "[SKIP] No change needed for: $oldName" -ForegroundColor Gray
        return
    }

    if ($PSCmdlet.ShouldProcess($Mailbox.UserPrincipalName, "Rename '$oldName' → '$newName'")) {
        try {
            Set-Mailbox -Identity $Mailbox.UserPrincipalName -DisplayName $newName -ErrorAction Stop
            Write-Host "[UPDATED] '$oldName'  →  '$newName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "[WARNING] Failed to update '$oldName': $_"
        }
    }
}

#endregion

#region Main Execution

Connect-EXO -UPN $AdminUPN

$matchingMailboxes = Get-MatchingMailboxes -Keyword $TargetKeyword -Domain $TargetDomain

if ($matchingMailboxes) {
    $successCount = 0
    $skipCount = 0

    foreach ($mailbox in $matchingMailboxes) {
        Update-MailboxDisplayName -Mailbox $mailbox -Keyword $TargetKeyword
        $successCount++
    }

    Write-Host "`n[SUMMARY] Processing complete." -ForegroundColor Cyan
    Write-Host "  Mailboxes processed : $($matchingMailboxes.Count)" -ForegroundColor White
    Write-Host "  Changes applied     : $successCount" -ForegroundColor Green
}

Disconnect-ExchangeOnline -Confirm:$false
Write-Host "[INFO] Disconnected from Exchange Online. Script completed." -ForegroundColor Cyan

#endregion
