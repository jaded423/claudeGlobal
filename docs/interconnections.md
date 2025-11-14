# System Interconnection Map

**⚠️ CRITICAL**: This map shows all file dependencies and automation connections. Review this before moving ANY files to avoid breaking automations.

## Visual Dependency Graph

### Project Dependency Network
```
                        ┌─────────────────┐
                        │   scripts       │
                        │ (Automation Hub)│
                        └────────┬────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        │                        │                        │
   ┌────▼─────┐           ┌─────▼─────┐           ┌─────▼─────┐
   │nvimConfig│           │odooReports│           │zshConfig  │
   │          │◄──────────┤           ├──────────►│           │
   └────┬─────┘  shares   └─────┬─────┘  shares   └─────┬─────┘
        │       OAuth creds      │       OAuth creds      │
        │                        │                        │
        └────────────────────────┼────────────────────────┘
                                 │
                          ┌──────▼──────┐
                          │  graveyard  │
                          │ (Archives)  │
                          └─────────────┘
```

### Shared Resource Matrix

| Resource | Owner | Used By | Impact if Moved |
|----------|-------|---------|-----------------|
| **Gmail OAuth** | odooReports/AR_AP | scripts, odooReports | All email automation fails |
| **gitBackup.sh** | scripts | All 11 projects | Hourly backups stop |
| **SSH Keys** | macOS Keychain | All git projects | GitHub push fails |
| **.zshrc** | zshConfig | System shell | Terminal breaks |
| **Python 3.13** | System | scripts, odooReports | Scripts fail |
| **Symlinks** | projects/* | System configs | Configs not loaded |

### Critical Dependency Chains

```
1. Email Automation Chain:
   credentials.json → send_gmail_oauth.py → gitBackup.sh → LaunchAgent
                   └─→ ar_ap_pdf_styled.py → crontab
                   └─→ odoo_stock_report.py → crontab

2. Configuration Chain:
   ~/projects/nvimConfig ← symlink ← ~/.config/nvim ← neovim
   ~/projects/zshConfig ← symlink ← ~/.zshrc ← terminal

3. Automation Chain:
   LaunchAgent → gitBackup.sh → Python 3.13 → send_gmail_oauth.py
              └─→ SSH keys → git push → GitHub
```

## Symlink Network

These symlinks create bidirectional dependencies - changes in one location automatically affect the other:

```
Active Location                     →  Git Repo Location
~/.config/nvim                      →  ~/projects/nvimConfig
~/.zshrc                            →  ~/projects/dotfilesPrivate/zshrc
~/.p10k.zsh                         →  ~/projects/dotfilesPrivate/p10k.zsh
~/scripts                           →  ~/projects/scripts
```

**Impact of moving files**:
- Moving `~/projects/nvimConfig` breaks `~/.config/nvim` symlink → Neovim won't load config
- Moving `~/projects/dotfilesPrivate` breaks `~/.zshrc` symlink → Shell config won't load
- Moving `~/projects/scripts` breaks `~/scripts` symlink → All launchd jobs and cron jobs will fail

## LaunchAgent Dependencies (macOS Background Jobs)

Three launchd jobs run automatically in the background:

### 1. Dotfiles Backup (`com.user.gitbackup.plist`)
**Schedule**: Every hour at minute 0
**Script**: `/Users/joshuabrown/scripts/gitBackup.sh`

**Dependencies**:
- `~/scripts` symlink → `~/projects/scripts`
- Python 3.13: `/Library/Frameworks/Python.framework/Versions/3.13/bin/python3`
- `send_gmail_oauth.py` at `~/Scripts/send_gmail_oauth.py`
- OAuth credentials: `~/projects/odooReports/AR_AP/credentials.json` + `token.json`
- SSH keys in macOS Keychain (for GitHub authentication)

**Backs up 5 repositories**:
1. `~/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Elevated Vault`
2. `~/projects/nvimConfig`
3. `~/projects/dotfilesPrivate`
4. `~/projects/hello-ai`
5. `~/projects/scripts`

**Sends email to**: `jaded423@gmail.com`

**⚠️ Breaking changes**:
- Moving `~/projects/scripts` breaks symlink → launchd can't find script
- Moving `send_gmail_oauth.py` breaks email notifications
- Moving `odooReports/AR_AP/` breaks Gmail OAuth (no credentials)
- Changing Python version breaks email sending
- Removing SSH keys from Keychain breaks GitHub push

### 2. Email Reminder (`com.user.emailreminder.plist`)
**Schedule**: Every 15 minutes (900 seconds)
**Script**: `/Users/joshuabrown/Scripts/email-reminder.scpt` (AppleScript)

**Dependencies**:
- `~/Scripts/gmail-reminder.py` (called by AppleScript)
- OAuth credentials: `~/scripts/credentials.json` + `gmail_token.pickle`
- Python 3 (system Python or custom installation)

**⚠️ Breaking changes**:
- Moving `email-reminder.scpt` breaks launchd job
- Moving `gmail-reminder.py` breaks AppleScript execution
- Moving credentials breaks Gmail API access

### 3. Claude Auto (`com.claude.auto.plist`)
**Schedule**: Hourly + daily at 8:30 AM
**Script**: `/Users/joshuabrown/claudeAuto/hi.sh`

**Dependencies**:
- Working directory: `/Users/joshuabrown/claudeAuto`
- PATH: `/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin`

**⚠️ Breaking changes**:
- Moving `~/claudeAuto/` directory breaks both schedule and execution

## Crontab Dependencies (Scheduled Tasks)

Two cron jobs run on specific schedules:

### 1. Odoo Reports
**Schedule**: Weekdays at 9:00 AM
**Script**: `/Users/joshuabrown/projects/odooReports/run_all_reports.sh`

**Environment Variables** (defined in crontab):
- `ODOO_API_KEY=6b0f5b7d1786d70c372b6f9c66481db74b1aebd1`
- `GDRIVE_PATH=/Users/joshuabrown/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Odoo Reports`

**Dependencies**:
- Python 3.13: `/Library/Frameworks/Python.framework/Versions/3.13/bin/python3`
- OAuth credentials: `~/projects/odooReports/AR_AP/credentials.json` + `token.json`
- `ar_ap_pdf_styled.py` in AR_AP directory
- `odoo_stock_report.py` in Labels directory
- `logo_lg.png` in AR_AP directory
- Python packages: google-auth, pandas, reportlab, xlsxwriter, openpyxl

**⚠️ Breaking changes**:
- Moving `~/projects/odooReports` breaks cron path → reports won't run
- Moving AR_AP or Labels subdirectories breaks scripts
- Changing Python version breaks execution
- Moving credentials breaks Gmail API email delivery
- Removing `logo_lg.png` breaks PDF generation

### 2. Claude Auto Reset
**Schedule**: Daily at 8:30 AM
**Script**: `/Users/joshuabrown/claudeAuto/reset_automation.sh`

**⚠️ Breaking changes**:
- Moving `~/claudeAuto/` directory breaks cron execution

## Gmail OAuth Credential Sharing

Multiple systems share the same Gmail OAuth credentials:

**Primary Credentials Location**: `~/projects/odooReports/AR_AP/`
- `credentials.json` - OAuth client credentials
- `token.json` - Access/refresh tokens

**Systems using these credentials**:
1. `send_gmail_oauth.py` (dotfiles backup notifications)
2. `ar_ap_pdf_styled.py` (AR/AP report emails)
3. `odoo_stock_report.py` (Labels report emails)

**⚠️ CRITICAL**: Moving `~/projects/odooReports/AR_AP/` breaks ALL email automation

**Separate credentials**:
- Email reminder system uses: `~/scripts/credentials.json` + `gmail_token.pickle`

## ZSH Function Dependencies

Custom shell functions in `~/.zshrc` reference specific paths:

```bash
backup-nvim()        → cd ~/projects/nvimConfig
backup-dotfiles()    → cd ~/projects/dotfilesPrivate
check-all-repos()    → Checks 10 hardcoded repo paths
```

**Hardcoded paths in `check-all-repos()`**:
1. `~/projects/adv360ProZmk`
2. `~/projects/bibleGatewayToObsidian`
3. `~/projects/dotfilesPrivate`
4. `~/projects/gitCheatsheet`
5. `~/projects/llmsFromScratch`
6. `~/projects/nvimConfig`
7. `~/projects/odooReports`
8. `~/projects/promptLibrary`
9. `~/projects/scripts`
10. `~/projects/hello-ai`

**⚠️ Breaking changes**: Moving any project directory requires updating `check-all-repos()` function

## Google Drive Sync Dependencies

Google Drive Desktop app syncs specific paths:

1. **Elevated Vault**: `~/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Elevated Vault`
   - Backed up hourly via `gitBackup.sh`
   - 2-second delay before git operations (allows sync to complete)
   - Exponential backoff retry logic (handles file locking)

2. **Odoo Reports Output**: `~/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Odoo Reports`
   - AR/AP reports saved here automatically
   - Labels reports saved here automatically
   - Referenced by `GDRIVE_PATH` in crontab

**⚠️ Breaking changes**:
- Moving Google Drive sync folder breaks both backup and report delivery
- Changing Google account breaks all cloud integrations

## Python Version Dependencies

**Multiple systems hardcode Python 3.13 path**:

```
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3
```

**Used by**:
1. `gitBackup.sh` (line 34) - for `send_gmail_oauth.py`
2. `odooReports/run_all_reports.sh` - for AR/AP and Labels scripts
3. `odooReports/.odoo_env.sh` - for report execution

**⚠️ Breaking changes**: Upgrading to Python 3.14+ breaks ALL automation unless paths are updated

## SSH Key Dependencies

GitHub operations require SSH keys in macOS Keychain:

**Key location**: `~/.ssh/id_ed25519`
**Config**: `~/.ssh/config` must have:
```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

**Added to Keychain**: `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`

**Used by**:
- `gitBackup.sh` - for hourly git push operations
- All manual git operations in projects

**⚠️ Breaking changes**: Removing SSH key from Keychain breaks automated backups

## Safe File Movement Checklist

Before moving ANY file or directory, check this list:

### If moving `~/projects/*` directories:
- [ ] Update `gitBackup.sh` REPOS array (if it's backed up)
- [ ] Update `check-all-repos()` function in `~/.zshrc`
- [ ] Update any crontab entries referencing the path
- [ ] Recreate symlinks if they pointed to this directory
- [ ] Update project CLAUDE.md files with new path
- [ ] Test all automations after moving

### If moving `~/scripts` or `~/projects/scripts`:
- [ ] Update `~/scripts` symlink target
- [ ] Update all launchd plist files referencing scripts
- [ ] Update `gitBackup.sh` REPOS array
- [ ] Update crontab entries
- [ ] Test launchd jobs after moving: `launchctl list | grep user`

### If moving `~/projects/odooReports`:
- [ ] Update crontab entry for `run_all_reports.sh`
- [ ] Update `send_gmail_oauth.py` credentials path (if hardcoded)
- [ ] Update `GDRIVE_PATH` in crontab
- [ ] Test email sending: `echo "Test" | python3 ~/scripts/send_gmail_oauth.py --to jaded423@gmail.com --subject "Test"`
- [ ] Test reports manually before next cron run

### If moving OAuth credentials (`odooReports/AR_AP/`):
- [ ] Update `send_gmail_oauth.py` default credentials_dir (line 41-46)
- [ ] Update AR/AP report script credential paths
- [ ] Update Labels report script credential paths
- [ ] Test email sending from all systems
- [ ] Verify token refresh works

### If moving `~/.config/nvim` or `~/projects/nvimConfig`:
- [ ] Recreate `~/.config/nvim` symlink to new location
- [ ] Update `gitBackup.sh` REPOS array
- [ ] Update `backup-nvim()` function in `~/.zshrc`
- [ ] Test Neovim loads: `nvim --version && nvim -c "checkhealth"`

### If moving `~/projects/dotfilesPrivate`:
- [ ] Recreate `~/.zshrc` symlink to new location
- [ ] Recreate `~/.p10k.zsh` symlink to new location
- [ ] Update `gitBackup.sh` REPOS array
- [ ] Update `backup-dotfiles()` function in `~/.zshrc`
- [ ] Test shell loads: `source ~/.zshrc`

### If changing Python version:
- [ ] Update `gitBackup.sh` Python path
- [ ] Update `odooReports/.odoo_env.sh` Python path
- [ ] Update `odooReports/AR_AP/run.sh` Python path
- [ ] Update `odooReports/Labels/run.sh` Python path
- [ ] Reinstall Python packages for new version
- [ ] Test all automation before scheduled runs

## Quick Reference: "What uses what?"

### What uses `~/scripts`?
- LaunchAgent: `com.user.dotfilesbackup.plist`
- LaunchAgent: `com.user.emailreminder.plist` (note: uses `~/Scripts` with capital S)
- Symlink: `~/scripts` → `~/projects/scripts`

### What uses `~/projects/odooReports`?
- Crontab: Odoo reports job (weekdays 9:00 AM)
- `send_gmail_oauth.py`: Default credentials location

### What uses Gmail OAuth credentials?
- `gitBackup.sh` → `send_gmail_oauth.py` → `~/projects/odooReports/AR_AP/credentials.json`
- `odooReports/AR_AP/ar_ap_pdf_styled.py` → `~/projects/odooReports/AR_AP/credentials.json`
- `odooReports/Labels/odoo_stock_report.py` → `~/projects/odooReports/Labels/credentials.json`
- Email reminder: `~/scripts/credentials.json` (separate credentials)

### What uses Python 3.13?
- `gitBackup.sh` (email sending)
- `odooReports/run_all_reports.sh` (AR/AP + Labels reports)
- `email-reminder.scpt` → `gmail-reminder.py`

### What uses SSH keys?
- `gitBackup.sh` (git push to GitHub)
- All manual git operations

### What backs up to GitHub hourly?
1. Elevated Vault (Obsidian)
2. nvimConfig
3. dotfilesPrivate
4. hello-ai
5. scripts
6. promptLibrary
7. zshConfig
8. odooReports
9. n8nDev
10. n8nProd
11. graveyard

## Cross-Project Impact Analysis

### If You Move `scripts/`:
**Severity**: 🔴 CRITICAL
- ❌ All hourly backups fail (LaunchAgent can't find gitBackup.sh)
- ❌ Email automation breaks (can't find send_gmail_oauth.py)
- ❌ Shell functions break (backup-nvim, backup-dotfiles)
- ❌ Dashboard update script becomes inaccessible
- **Fix**: Update symlink at ~/scripts, update LaunchAgent plist

### If You Move `odooReports/`:
**Severity**: 🔴 CRITICAL
- ❌ Daily reports stop running (crontab path broken)
- ❌ Email automation fails (OAuth credentials not found)
- ❌ All projects using shared OAuth lose email capability
- **Fix**: Update crontab, move/copy OAuth credentials, update all scripts

### If You Move `nvimConfig/`:
**Severity**: 🟠 HIGH
- ❌ Neovim won't load configuration
- ❌ Git backups reference wrong path
- ⚠️ Shell aliases point to wrong location
- **Fix**: Recreate symlink at ~/.config/nvim, update gitBackup.sh

### If You Move `zshConfig/`:
**Severity**: 🟠 HIGH
- ❌ Shell configuration won't load
- ❌ Terminal customizations lost
- ❌ All custom functions and aliases unavailable
- **Fix**: Recreate symlinks for ~/.zshrc and ~/.p10k.zsh

### If You Update Python Version:
**Severity**: 🟡 MEDIUM
- ⚠️ Update path in gitBackup.sh (line 69)
- ⚠️ Update path in email-reminder.scpt
- ⚠️ Reinstall Python packages for new version
- **Affected**: All email automation, Odoo reports

### If You Change GitHub Authentication:
**Severity**: 🟡 MEDIUM
- ⚠️ Re-add SSH keys to macOS Keychain
- ⚠️ Update git remote URLs if switching HTTP/SSH
- **Affected**: All automated git push operations

## Dependency Verification Commands

### Check All Symlinks
```bash
# Verify all symlinks are intact
ls -la ~/.config/nvim ~/.zshrc ~/.p10k.zsh ~/scripts | grep -E "^l"
```

### Check LaunchAgent Status
```bash
# Verify background jobs are running
launchctl list | grep -E "(gitbackup|emailreminder|claude.auto)"
```

### Check Crontab
```bash
# Verify scheduled tasks
crontab -l | grep -E "(odooReports|claudeAuto)"
```

### Verify Python Path
```bash
# Check if Python 3.13 exists
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3 --version
```

### Test Email OAuth
```bash
# Test email sending capability
echo "Test" | python3 ~/scripts/bin/send_gmail_oauth.py \
  --to joshua@elevatedtrading.com --subject "Dependency Test"
```

### Check SSH Keys
```bash
# Verify SSH keys in keychain
ssh-add -l
```

## Dependency Rules

1. **Never move without updating references** - Use grep to find all references first
2. **Test after any change** - Run verification commands above
3. **Backup before major changes** - Create copies of critical files
4. **Document all changes** - Update this file when dependencies change
5. **Maintain symlinks** - Always use absolute paths for reliability

## Quick Reference Cheatsheet

| Component | Location | Depends On | Used By |
|-----------|----------|------------|---------|
| gitBackup.sh | ~/scripts/bin/ | Python 3.13, OAuth, SSH | LaunchAgent |
| OAuth creds | ~/projects/odooReports/AR_AP/ | - | 3 scripts |
| Neovim config | ~/projects/nvimConfig | Symlink | Daily use |
| Shell config | ~/projects/zshConfig | Symlink | Every terminal |
| Cron reports | ~/projects/odooReports | Python 3.13 | Business ops |
| Dashboard | ~/.claude/docs/ | Update script | Documentation |

## Emergency Recovery

If everything breaks:
1. Check symlinks first: `ls -la ~/.*`
2. Verify Python path: `which python3`
3. Check LaunchAgent logs: `log show --predicate 'eventMessage contains "launchd"' --last 1h`
4. Reload LaunchAgents: `launchctl unload ~/Library/LaunchAgents/*.plist && launchctl load ~/Library/LaunchAgents/*.plist`
5. Test core functionality: `source ~/.zshrc && doc-check`
