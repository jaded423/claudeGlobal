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

## Twingate & SSH Issues

### SSH to VMs breaks when adding Twingate resources for VM IPs

**Problem:** When you add a Twingate resource for a VM IP (like 192.168.2.126 for VM 102), SSH to the Proxmox host (192.168.2.250) fails with "timeout during banner exchange" even though routes exist and TCP connections succeed.

**Symptoms:**
- Routes for both .250 and .126 appear in routing table (`netstat -rn | grep 192.168.2`)
- TCP connections to port 22 succeed (`nc -v -z 192.168.2.250 22` shows success)
- SSH hangs during banner exchange and times out after ~60 seconds
- Only happens when ANY Twingate resource pointing to VM IPs (.126, .131, etc.) exists
- Works fine when only the Proxmox host (.250) resource exists in Twingate
- Removing the VM resource immediately fixes SSH to .250

**Root Cause:**
The Proxmox host is running its own Twingate daemon (`/usr/sbin/twingated`) with a route for its own IP through the sdwan0 interface:
```bash
# On Proxmox host, check routes:
ssh root@192.168.2.250 "ip route show dev sdwan0"
# Shows: 192.168.2.250 dev sdwan0 proto static scope host metric 25
```

When your Mac's Twingate tries to route to a VM on the same network (192.168.2.x/24), it creates a routing conflict. The Proxmox Twingate daemon gets confused about traffic destined for the 192.168.2.x network, causing SSH banner exchange to fail (TCP connects but application-level protocol breaks).

**Solution - Use SSH ProxyJump:**

Instead of creating Twingate resources for VM IPs, configure SSH ProxyJump to access VMs through the Proxmox host:

**Step 1:** Only keep Proxmox host (.250) in Twingate resources
- Remove any resources pointing to VM IPs (.126, .131, etc.)
- Keep only the "proxmox-web" resource (192.168.2.250, ports 22 and 8006)

**Step 2:** Configure ProxyJump in `~/.ssh/config` on your Mac:
```ssh
Host 192.168.2.250
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 102 - Ubuntu Server (auto ProxyJump through Proxmox)
Host 192.168.2.126
  User jaded
  ProxyJump 192.168.2.250
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

**Step 3:** Access VMs automatically:
```bash
# This now automatically jumps through .250 first
ssh jaded@192.168.2.126

# Your git backup scripts work without changes
# SSH config handles the routing transparently
```

**Benefits:**
- ✅ No Twingate routing conflicts
- ✅ Automated scripts work without modification (SSH config handles routing)
- ✅ Only one Twingate resource needed (Proxmox host at .250)
- ✅ All VMs accessible via automatic ProxyJump
- ✅ Single point of security (only .250 exposed through Twingate)

**For Additional VMs:**
Add similar ProxyJump entries for any other VMs:
```ssh
Host 192.168.2.131
  User pi
  ProxyJump 192.168.2.250
  IdentityFile ~/.ssh/id_ed25519
```

**Testing the Fix:**
```bash
# 1. Verify routes (should only see .250, not .126)
netstat -rn | grep 192.168.2

# 2. Test SSH to Proxmox host (should work)
ssh root@192.168.2.250 "hostname"

# 3. Test SSH to VM via ProxyJump (should work)
ssh jaded@192.168.2.126 "hostname"

# 4. Test git operations
ssh jaded@192.168.2.126 "git --version"
```

**Why Not Fix Twingate on Proxmox?**
While you could remove Twingate from the Proxmox host or remove its .250 route, the ProxyJump approach is better because:
- Follows security best practice (single entry point)
- Simpler Twingate configuration (one resource vs many)
- Works with existing Proxmox Twingate setup (may be used for other purposes)
- More maintainable long-term

## Getting Help

If you encounter an issue not covered here:

1. Check project-specific CLAUDE.md files for detailed troubleshooting
2. Review system logs: `log show --last 1h`
3. Check cron logs: `grep CRON /var/log/system.log`
4. View launchd job output: `cat /tmp/*.log`
5. Test components manually to isolate the issue
