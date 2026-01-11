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

# VM 100 - Omarchy Desktop (auto ProxyJump through Proxmox)
Host 192.168.2.161
  User jaded
  ProxyJump 192.168.2.250
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
# These now automatically jump through .250 first
ssh jaded@192.168.2.161  # Omarchy Desktop
ssh jaded@192.168.2.126  # Ubuntu Server

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
# 1. Verify routes (should only see .250, not VM IPs)
netstat -rn | grep 192.168.2

# 2. Test SSH to Proxmox host (should work)
ssh root@192.168.2.250 "hostname"

# 3. Test SSH to VMs via ProxyJump (should work)
ssh jaded@192.168.2.161 "hostname"  # Omarchy Desktop
ssh jaded@192.168.2.126 "hostname"  # Ubuntu Server

# 4. Test git operations
ssh jaded@192.168.2.126 "git --version"
```

**Why Not Fix Twingate on Proxmox?**
While you could remove Twingate from the Proxmox host or remove its .250 route, the ProxyJump approach is better because:
- Follows security best practice (single entry point)
- Simpler Twingate configuration (one resource vs many)
- Works with existing Proxmox Twingate setup (may be used for other purposes)
- More maintainable long-term

### SSH Timeouts When Remote - Missing Twingate Resources

**Problem:** SSH connections to Proxmox hosts (.249, .250) or VMs (.126, .161) timeout when working remotely, but work fine when at home on local network. Ollama server connections fail, gitBackup.sh can't reach servers, ollamaSummary.py fails with "connection timeout."

**Symptoms:**
- SSH hangs with "Operation timed out" when remote (at work, traveling)
- Works perfectly when at home on same LAN
- ProxyJump configuration exists but still times out
- Automated scripts that worked at home fail when remote

**Cause:**
When at home, you're on the same LAN (192.168.2.x/24) and can reach all devices directly without Twingate. When remote, you MUST have Twingate resources configured for each Proxmox host you want to access. Even if your ProxyJump is configured correctly, without Twingate resources, your Mac cannot reach the Proxmox hosts to establish the first hop.

**Solution - Configure Twingate Resources:**

**Step 1:** Log into Twingate Admin Console
```
https://jaded423.twingate.com
```

**Step 2:** Create resources for BOTH Proxmox hosts:

**Resource 1: prox-book5**
- Name: "prox-book5 SSH" (or similar)
- Address: `192.168.2.250`
- Ports: `22` (TCP)
- Assign to: Your user account
- Connector: Any available connector on your network

**Resource 2: prox-tower**
- Name: "prox-tower SSH" (or similar)
- Address: `192.168.2.249`
- Ports: `22` (TCP)
- Assign to: Your user account
- Connector: Any available connector on your network

**Step 3:** Wait 30 seconds for resources to deploy, then test:
```bash
# Test direct access to both Proxmox hosts
ssh root@192.168.2.250 "hostname"  # Should show: prox-book5
ssh root@192.168.2.249 "hostname"  # Should show: prox-tower

# Test VM access via ProxyJump (should now work)
ssh jaded@192.168.2.161 "hostname"  # Omarchy Desktop via .250
ssh jaded@192.168.2.126 "hostname"  # Ubuntu Server via .249

# Test Ollama connection
ssh 192.168.2.126 "ollama list"     # Should show installed models
```

**Why This Happens:**
- **At home:** Direct LAN access, no Twingate needed (192.168.2.x directly reachable)
- **Remote:** Must route through Twingate to reach home network
- **ProxyJump alone isn't enough:** SSH config tells how to route, but Twingate resources control what you can reach

**Key Learning:**
ProxyJump configuration in `~/.ssh/config` defines the routing path (Mac → host → VM), but Twingate resources control what you can access remotely. Both are required:
- **Twingate resources:** Permission/access to reach Proxmox hosts from remote locations
- **ProxyJump config:** Routing instructions for how to reach VMs through hosts

**Verification:**
After adding Twingate resources, your automated scripts should work from anywhere:
- ✅ `gitBackup.sh` - Can SSH to 192.168.2.126 for git operations
- ✅ `ollamaSummary.py` - Can reach Ollama server at 192.168.2.126
- ✅ Manual SSH to all hosts and VMs works remotely

### Mac Twingate Client Frequent Disconnections

**Problem:** Receiving frequent "disconnected/reconnected" emails from Twingate even though the Mac is on and active. Twingate client keeps cycling connection state.

**Symptoms:**
- Multiple disconnect/reconnect emails per day from Twingate
- Emails show brief disconnections followed by immediate reconnections
- Mac is not sleeping but Twingate reports connection cycling

**Root Causes Identified:**

1. **Network Service Priority:** USB Ethernet adapters (AX88179A, USB-C Dock Ethernet) are prioritized above Wi-Fi in macOS network service order. During sleep/wake cycles, macOS briefly checks these inactive adapters before falling back to Wi-Fi, causing momentary network drops.

2. **Sleep/Wake Cycling:** macOS undergoes frequent display/disk sleep cycles (potentially hundreds per day). Each cycle can briefly disrupt network connectivity.

3. **Network Over Sleep Disabled:** By default, `networkoversleep = 0`, meaning network connections aren't maintained during sleep states.

**Solution - Fix Both Issues:**

```bash
# 1. Check current network service order
networksetup -listnetworkserviceorder

# If Wi-Fi is not #1 and you primarily use Wi-Fi:
# 2. Move Wi-Fi to top priority
sudo networksetup -ordernetworkservices "Wi-Fi" "AX88179A" "USB 10/100/1000 LAN" "USB-C Dock Ethernet" "Thunderbolt Bridge" "Twingate"

# 3. Keep network alive during sleep
sudo pmset -a networkoversleep 1
```

**Verify Changes:**
```bash
# Check network order (Wi-Fi should be #1)
networksetup -listnetworkserviceorder

# Check networkoversleep (should show 1)
pmset -g | grep networkoversleep
```

**Why This Works:**
- **Wi-Fi priority:** macOS checks Wi-Fi first on wake, avoiding delays from inactive Ethernet adapters
- **Network over sleep:** Network connection persists through sleep states, preventing Twingate disconnections

**Diagnostic Commands Used:**
```bash
# Check sleep/wake frequency
pmset -g log | grep "Wake from\|Sleep" | tail -30

# Check power settings
pmset -g

# Check network interfaces and status
ifconfig en0 | grep status      # Wi-Fi
networksetup -getinfo "Wi-Fi"   # Wi-Fi details
route get default               # Active network interface
```

**Date Fixed:** 2025-12-19

### Claude Bridge: Cross-Machine AI Collaboration via Shared tmux

**Problem:** You have Claude Code running on two different machines (e.g., Mac and Pixelbook Go) that can't directly SSH to each other, but both need to collaborate to solve a connectivity issue between them.

**Scenario:**
- Machine A (Mac) has Claude Code and can SSH to a shared server (prox-book5)
- Machine B (Pixelbook) has Claude Code and can also SSH to the same shared server
- Machine A cannot SSH to Machine B (that's the problem you're trying to fix)
- You need both Claude instances to exchange information to debug the issue

**Solution - The Claude Bridge:**

Create a tmux session on the shared server that both Claude instances can access to "talk" to each other:

**Step 1:** From Machine A (Mac), create the bridge session:
```bash
ssh root@192.168.2.250 "tmux new-session -d -s bridge -x 200 -y 50"
ssh root@192.168.2.250 "tmux send-keys -t bridge 'echo \"=== Claude Bridge Session ===\"' Enter"
```

**Step 2:** Send messages from Machine A's Claude:
```bash
ssh root@192.168.2.250 "tmux send-keys -t bridge 'echo \"[Mac Claude] Your message here\"' Enter"
```

**Step 3:** Check for responses:
```bash
ssh root@192.168.2.250 "tmux capture-pane -t bridge -p -S -50"
```

**Step 4:** Tell the user to have Machine B's Claude connect:
> "SSH to root@192.168.2.250 and attach to tmux session 'bridge'. Send messages with:
> `tmux send-keys -t bridge 'echo \"[Go Claude] Your response\"' Enter`"

**Step 5:** Both Claudes can now exchange diagnostic info, SSH keys, config snippets, etc.

**Real-World Example (2026-01-10):**

Mac Claude couldn't SSH to Pixelbook Go (Crostini Linux). Used the bridge to:
1. Mac Claude asked Go Claude to check SSH daemon status and config
2. Go Claude reported SSH was running on port 2222, config OK
3. Mac Claude sent its public key via the bridge
4. Go Claude added the key to authorized_keys
5. Mac Claude sent instructions for bidirectional setup
6. Go Claude responded with its public key
7. Both machines now have full SSH access to each other

**Commands Quick Reference:**

```bash
# Create bridge (from any machine that can reach shared server)
ssh root@192.168.2.250 "tmux new-session -d -s bridge"

# Send message
ssh root@192.168.2.250 "tmux send-keys -t bridge 'echo \"[Your Claude] message\"' Enter"

# Read messages (last 50 lines)
ssh root@192.168.2.250 "tmux capture-pane -t bridge -p -S -50"

# User can watch live
ssh root@192.168.2.250 "tmux attach -t bridge"

# Clean up when done
ssh root@192.168.2.250 "tmux kill-session -t bridge"
```

**Why This Works:**
- tmux persists the session on the shared server
- Both Claude instances can read/write to the same terminal buffer
- No direct connectivity needed between the two machines
- Messages are visible to the user if they attach to the session
- Works for exchanging keys, configs, diagnostic output, or any text

**When to Use:**
- Debugging connectivity issues between two machines
- Setting up SSH keys when one direction doesn't work yet
- Any situation where two Claude instances need to coordinate
- "Break glass" emergency access when normal paths are broken

**Prerequisites:**
- At least one machine both Claudes can SSH to (the "bridge" host)
- tmux installed on the bridge host
- SSH keys configured for both machines to access the bridge

**Date Added:** 2026-01-10

---

## Getting Help

If you encounter an issue not covered here:

1. Check project-specific CLAUDE.md files for detailed troubleshooting
2. Review system logs: `log show --last 1h`
3. Check cron logs: `grep CRON /var/log/system.log`
4. View launchd job output: `cat /tmp/*.log`
5. Test components manually to isolate the issue
