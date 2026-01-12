# Migration Plan: odooReports from Mac to PC/WSL

## Summary

Migrate the 4 scheduled Odoo reports from Mac cron to WSL on the always-on business PC. The Mac's sleep mode causes missed 6 AM Monday reports - the PC stays online 24/7.

## Current State

**Mac cron schedule:**
- `0 6 * * 1` - lastOrder/run.sh (Mondays 6 AM)
- `0 6 * * 1` - manufacturing/run.sh (Mondays 6 AM)
- `0 6 * * 1-5` - Labels/run.sh (Weekdays 6 AM, emails Mondays)
- `0 9 * * 1-5` - AR_AP/run.sh (Weekdays 9 AM)

**WSL environment:**
- Ubuntu 24.04 LTS
- Python 3.12.3 (compatible with 3.13 requirements)
- User: `joshua`, home: `/home/joshua/`
- 952GB disk space available
- Cron installed but NOT running (WSL limitation)
- SSH access: `ssh wsl` (port 2222)

## Migration Steps

### Step 1: Enable cron auto-start on WSL

Add cron to the existing WSL startup script `/etc/wsl-ssh-startup.sh`:
```bash
# Start cron daemon
service cron start
```

### Step 2: Copy odooReports to WSL

```bash
# From Mac, rsync the entire project
rsync -avz --progress ~/projects/odooReports/ wsl:~/projects/odooReports/
```

Files to copy (~2MB total):
- All Python scripts (5 reports)
- All run.sh wrappers
- `odoo_credentials.json` (contains API key)
- `AR_AP/credentials.json` + `token.json` (Gmail OAuth)
- `Labels/credentials.json` + `token.json` (Drive OAuth)
- `.env` file (ODOO_API_KEY)
- `shared/config.py`
- Logo file for PDFs

### Step 3: Install Python dependencies

```bash
ssh wsl "pip3 install --user pandas openpyxl xlsxwriter reportlab google-auth google-auth-oauthlib google-api-python-client certifi"
```

### Step 4: Update run.sh scripts for Linux

Change Python path in all 4 run.sh files from:
```bash
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3
```
To:
```bash
/usr/bin/python3
```

Files to update:
- `AR_AP/run.sh`
- `Labels/run.sh`
- `lastOrder/run.sh`
- `manufacturing/run.sh`

### Step 5: Update credential paths in config

Update `shared/config.py` to use Linux-style paths (or ensure it uses relative paths that work on both systems).

### Step 6: Set up cron on WSL

```bash
ssh wsl "crontab -e"
```

Add entries:
```cron
# Odoo Reports - migrated from Mac 2026-01-12
ODOO_API_KEY=6b0f5b7d1786d70c372b6f9c66481db74b1aebd1

# Last Order Report - Every Monday at 6:00 AM
0 6 * * 1 /home/joshua/projects/odooReports/lastOrder/run.sh

# Labels Report - Daily at 6:00 AM (email on Mondays)
0 6 * * 1-5 /home/joshua/projects/odooReports/Labels/run.sh

# AR_AP Report - Daily at 9:00 AM
0 9 * * 1-5 /home/joshua/projects/odooReports/AR_AP/run.sh

# Manufacturing Report - Every Monday at 6:00 AM
0 6 * * 1 /home/joshua/projects/odooReports/manufacturing/run.sh
```

### Step 7: Test each report manually

Run each report interactively to verify OAuth tokens work:
```bash
ssh wsl "cd ~/projects/odooReports/AR_AP && ./run.sh"
ssh wsl "cd ~/projects/odooReports/Labels && ./run.sh"
ssh wsl "cd ~/projects/odooReports/lastOrder && ./run.sh"
ssh wsl "cd ~/projects/odooReports/manufacturing && ./run.sh"
```

### Step 8: Disable Mac cron jobs

Comment out the odooReports entries in Mac crontab to prevent duplicates:
```bash
crontab -e
# Comment out the 4 odooReports lines
```

## Key Files

| File | Purpose |
|------|---------|
| `/etc/wsl-ssh-startup.sh` | Add cron start command |
| `*/run.sh` (4 files) | Update Python path |
| `shared/config.py` | Verify path handling |
| WSL crontab | Add 4 job entries |
| Mac crontab | Comment out 4 jobs |

## Verification

1. **Cron running**: `ssh wsl "pgrep cron"` should return PID
2. **Cron jobs loaded**: `ssh wsl "crontab -l"` shows 4 entries
3. **Manual test**: Each report sends email successfully
4. **Next Monday**: Verify 6 AM reports arrive automatically

## Rollback

If issues occur, re-enable Mac cron jobs:
```bash
crontab -e
# Uncomment the 4 odooReports lines
```

## Notes

- OAuth tokens (`token.json`) should work after copy - they're not machine-specific
- If tokens fail, run report interactively once to re-authorize (browser flow)
- WSL cron persists across reboots due to startup script
- Timezone: WSL uses system time (should match Mac if both in same location)
