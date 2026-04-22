# 📧 Shared Mailbox Display Name Standardization (Exchange Online)

> A PowerShell script that automates the bulk standardization of shared mailbox display names in Exchange Online — reducing manual renaming time from ~1 hour to just minutes (~95% efficiency improvement).

---

## 📋 The Problem

In large Exchange Online tenants, shared mailboxes often accumulate inconsistent display names over time — especially after migrations, rebranding, or organizational changes. Manually renaming dozens of mailboxes through the Exchange Admin Center is time-consuming and error-prone.

This script automates the identification and renaming in a single, safe, auditable run.

---

## ✅ What This Script Does

- Connects to Exchange Online
- Scans **all mailboxes** for display names matching a defined keyword pattern within a specific SMTP domain
- Removes the keyword to enforce naming consistency
- Supports **-WhatIf mode** to preview all changes before applying
- Outputs a clear summary of all changes made

---

## 🛠️ Prerequisites

| Requirement | Details |
|---|---|
| PowerShell | Version 5.1 or later |
| Module | `ExchangeOnlineManagement` |
| Role | Exchange Administrator or Global Administrator |

**Install the required module:**
```powershell
Install-Module -Name ExchangeOnlineManagement -Force
```

---

## 🚀 Usage

### ⚠️ Always preview first with -WhatIf
```powershell
.\Update-SharedMailboxDisplayName.ps1 `
    -AdminUPN "admin@contoso.com" `
    -TargetKeyword "OLD-" `
    -TargetDomain "contoso.org" `
    -WhatIf
```

### Apply changes after confirming preview
```powershell
.\Update-SharedMailboxDisplayName.ps1 `
    -AdminUPN "admin@contoso.com" `
    -TargetKeyword "OLD-" `
    -TargetDomain "contoso.org"
```

### Parameters

| Parameter | Required | Description |
|---|---|---|
| `AdminUPN` | ✅ Yes | UPN of the Exchange Online administrator |
| `TargetKeyword` | ✅ Yes | Keyword/prefix to remove from display names |
| `TargetDomain` | ✅ Yes | SMTP domain to filter mailboxes |
| `-WhatIf` | ❌ Optional | Preview changes without applying (strongly recommended) |

---

## 📸 Sample Output

```
[INFO] Connecting to Exchange Online...
[SUCCESS] Connected to Exchange Online.
[INFO] Searching for mailboxes matching keyword 'OLD-' in domain 'contoso.org'...
[FOUND] 23 matching mailbox(es) identified.
[UPDATED] 'OLD- Finance Team'      →  'Finance Team'
[UPDATED] 'OLD- HR Support'        →  'HR Support'
[UPDATED] 'OLD- IT Helpdesk'       →  'IT Helpdesk'
...

[SUMMARY] Processing complete.
  Mailboxes processed : 23
  Changes applied     : 23

[INFO] Disconnected from Exchange Online. Script completed.
```

---

## 📊 Impact

| Metric | Before | After |
|---|---|---|
| Time to rename mailboxes | ~60 minutes (manual) | ~3 minutes (automated) |
| Risk of human error | High | Minimal |
| Auditability | Low | Full console log |
| Efficiency improvement | — | ~95% |

---

## 💡 Use Cases

- **Post-migration cleanup** — Remove legacy prefixes after tenant migrations
- **Rebranding** — Update display names after company name or department changes
- **Naming policy enforcement** — Standardize mailbox names across the tenant
- **Bulk corrections** — Fix accidental naming patterns applied at scale

---

## ⚠️ Important Notes

- Always run with **`-WhatIf` first** to preview changes before applying
- The script uses `UserPrincipalName` (not `DisplayName`) as the identity key for reliable targeting
- Changes may take a few minutes to propagate across Exchange Online

---

## 📁 Related Scripts

- [`Grant-OneDriveAccessDeletedUser.ps1`](../script1-onedrive-deleted-user/) — Recover orphaned OneDrive access
- [`Add-ADUsersToGroup.ps1`](../script4-ad-group-bulk-add/) — Bulk add users to AD groups by email

---

## 👤 Author

**Syed Sabeer Ali Akbar**
IT Systems Engineer | Exchange Online & Microsoft 365 Specialist
[LinkedIn](https://www.linkedin.com/in/syedsabeerali)
