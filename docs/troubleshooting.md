# Troubleshooting Guide

Common issues and solutions for the global Claude Code system.

## Commands not found

```bash
# Check if commands directory exists
ls ~/.claude/commands/

# Should show:
# compact.md

# If missing, commands might be in project-specific .claude/commands/
# Copy them to global location
```

## CLAUDE.md doesn't exist in project

```bash
# Create one following the template
# Then create symlinks:
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md
```

## Backups directory getting large

```bash
# Check size
du -sh backups/

# Optionally clean old backups (older than 6 months)
find backups/ -name "*.md" -mtime +180 -delete
```

## Git showing backups directory

```bash
# Add to .gitignore
echo "backups/" >> .gitignore
git add .gitignore
git commit -m "chore: Ignore backups directory"
```

## Symlinks not working

**Check if symlinks exist**:
```bash
# In your project directory
ls -la | grep -E "(GEMINI|AGENTS).md"

# Should show:
# lrwxr-xr-x  GEMINI.md -> CLAUDE.md
# lrwxr-xr-x  AGENTS.md -> CLAUDE.md
```

**Verify symlink targets**:
```bash
# Check where symlinks point
readlink GEMINI.md  # Should output: CLAUDE.md
readlink AGENTS.md  # Should output: CLAUDE.md
```

**Fix broken symlinks**:
```bash
# Remove broken symlinks
rm GEMINI.md AGENTS.md

# Recreate them
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md

# Verify they work
cat GEMINI.md  # Should show CLAUDE.md content
```

**Platform-specific issues**:

*macOS/Linux*:
```bash
# Symlinks work natively
ln -s CLAUDE.md GEMINI.md
```

*Windows*:
```powershell
# Requires admin privileges or Developer Mode
# Option 1: Use mklink (requires admin)
mklink GEMINI.md CLAUDE.md

# Option 2: Enable Developer Mode, then use ln in Git Bash
ln -s CLAUDE.md GEMINI.md

# Option 3: Use file copies instead (loses sync benefit)
copy CLAUDE.md GEMINI.md
copy CLAUDE.md AGENTS.md
```

## Commands not responding

**Check command file syntax**:
```bash
# Command files should be plain markdown
head ~/.claude/commands/compact.md

# Should start with explanation text, not special syntax
```

**Verify command location**:
```bash
# Global commands
ls ~/.claude/commands/

# Project-specific commands (override global)
ls .claude/commands/
```

**Test a command**:
```bash
# Try a simple command
/compact

# If it doesn't work, check:
# 1. File exists in commands directory
# 2. File has .md extension
# 3. File contains valid markdown instructions
```

## Automation Issues

### Backup not running

```bash
# Check if job is loaded
launchctl list | grep dotfiles

# Check system logs
log show --predicate 'eventMessage contains "git_backup"' --last 1h

# Verify SSH key is in Keychain
ssh-add -l
```

### Email not sending

```bash
# Test email manually
echo "Test" | python3 ~/scripts/send_gmail_oauth.py --to jaded423@gmail.com --subject "Test"

# Check credentials exist
ls -l ~/projects/odooReports/AR_AP/credentials.json
ls -l ~/projects/odooReports/AR_AP/token.json

# Re-authenticate if token expired
rm ~/projects/odooReports/AR_AP/token.json
python3 ~/scripts/send_gmail_oauth.py --to test@example.com --subject "Auth Test" --body "Test"
```

### Git operations failing

```bash
# Check repo status manually
cd "/path/to/repo"
git status
git remote -v

# Test SSH connection
ssh -T git@github.com

# Verify SSH config
cat ~/.ssh/config
```

## Python Issues

### Module not found

```bash
# Install missing dependencies
cd ~/projects/odooReports/AR_AP
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3 -m pip install -r requirements.txt

cd ../Labels
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3 -m pip install -r requirements.txt
```

### Wrong Python version

```bash
# Check which Python is being used
which python3
python3 --version

# If wrong version, update paths in:
# - gitBackup.sh
# - odooReports/.odoo_env.sh
# - odooReports/AR_AP/run.sh
# - odooReports/Labels/run.sh
```

## Neovim Issues

### Plugins Not Loading

```bash
# Check lazy.nvim status
nvim -c ":Lazy"

# Sync plugins
nvim -c ":Lazy sync"

# Check for errors
nvim -c ":messages"

# Profile startup
nvim -c ":Lazy profile"
```

### LSP Not Working

```bash
# Verify server installed
nvim -c ":Mason"

# Check LSP status
nvim -c ":LspInfo"

# View logs
nvim -c ":LspLog"

# Restart server
nvim -c ":LspRestart"
```

### Formatting Not Working

```bash
# Check formatter installed
nvim -c ":ConformInfo"

# Install via Mason
nvim -c ":MasonInstall prettier"

# Check format disabled
# Look for disable_autoformat flags

# Enable formatting
nvim -c ":FormatEnable"
```

## Odoo Reports Issues

### Reports Not Running

```bash
# Check cron logs
tail -f /tmp/git_backup.log
grep CRON /var/log/system.log

# Verify cron job is loaded
crontab -l | grep odoo

# Test manually
cd ~/projects/odooReports
bash run_all_reports.sh
```

### Authentication Errors

**Odoo "Authentication failed"**:
```bash
# Verify API key is set
echo $ODOO_API_KEY  # Should show key

# Check if key works
cd ~/projects/odooReports/AR_AP
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3 ar_ap_pdf_styled.py
```

**Gmail "Invalid credentials"**:
```bash
# Remove and regenerate token
cd ~/projects/odooReports/AR_AP
rm token.json
/Library/Frameworks/Python.framework/Versions/3.13/bin/python3 ar_ap_pdf_styled.py
# Complete OAuth flow in browser
```

### Email Not Sending from Reports

```bash
# Check logs for Gmail errors
tail -100 ~/projects/odooReports/AR_AP/logs/cron.log | grep -i error

# Verify token is valid
cd ~/projects/odooReports/AR_AP
ls -la token.json  # Should exist and be recent

# Check recipient list (ar_ap_pdf_styled.py:907)
# Should be: ["cody@elevatedtrading.com", "joshua@elevatedtrading.com"]
```

## Path Issues After Moving Files

If reports or backups fail after moving directories:

1. **Check crontab**:
   ```bash
   crontab -l | grep -E "odoo|claude"
   # Should show correct paths
   ```

2. **Check run scripts**:
   ```bash
   grep -r "OldPath" ~/projects/
   # Should find no matches
   ```

3. **Check environment file**:
   ```bash
   cat ~/projects/odooReports/.odoo_env.sh
   # Verify PATH is correct
   ```

4. **Check launchd plists**:
   ```bash
   grep -r "OldPath" ~/Library/LaunchAgents/
   # Should find no matches
   ```

## Getting Help

If you encounter an issue not covered here:

1. Check project-specific CLAUDE.md files for detailed troubleshooting
2. Review system logs: `log show --last 1h`
3. Check cron logs: `grep CRON /var/log/system.log`
4. View launchd job output: `cat /tmp/*.log`
5. Test components manually to isolate the issue
