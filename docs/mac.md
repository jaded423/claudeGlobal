# Work Mac Configuration

**Machine:** MacBook Pro (Apple Silicon)
**OS:** macOS
**Last Updated:** December 20, 2025

---

## Power Management

### Always-On Configuration (Dec 20, 2025)

**Purpose:** Keep Mac running 24/7 to maintain Twingate connectivity and prevent disconnect/reconnect cycles.

**Problem Solved:** Twingate connector was sending frequent disconnect/reconnect emails because the Mac was sleeping after 1 minute of inactivity on battery power (6,466+ sleep/wake cycles since boot).

**Current Settings:**
```
SleepDisabled        1      # System NEVER sleeps automatically
sleep                0      # No auto-sleep timer
displaysleep         10     # Display sleeps after 10 minutes
disksleep            10     # Disk sleep after 10 minutes (irrelevant for SSD)
lowpowermode         0      # Low Power Mode disabled
```

**Commands Applied:**
```bash
# System never sleeps (including lid close)
sudo pmset -a sleep 0
sudo pmset -a disablesleep 1

# Display sleeps after 10 minutes
sudo pmset -a displaysleep 10

# Disable Low Power Mode (prevents aggressive power saving)
sudo pmset -a lowpowermode 0
```

**Behavior:**
- Closing the lid: Display turns off, system stays awake
- Idle for 10 minutes: Display turns off, system stays awake
- Manual sleep: Still works with Apple menu → Sleep
- Reboot/shutdown: Still works normally

**To Restore Default Sleep Behavior:**
```bash
sudo pmset -a disablesleep 0
sudo pmset -a sleep 1
# Or reset to defaults:
sudo pmset restoredefaults
```

**Verification:**
```bash
pmset -g                    # Show current settings
pmset -g assertions         # Show what's preventing sleep
pmset -g log | tail -20     # Recent power events
```

**Battery Impact:**
- With display off, Apple Silicon draws ~2-4W (vs ~0.5W in sleep)
- Estimated 2-4 hours less standby time
- Negligible impact when plugged in

**Thermal Consideration:**
- MacBooks use keyboard area for heat dissipation
- Running with lid closed is fine for light tasks (Twingate, background services)
- For intensive tasks with lid closed, monitor thermals

---

## Twingate Client

**Network:** jaded423
**Admin Console:** https://jaded423.twingate.com

### Troubleshooting

**After home lab server reboot - can't connect:**
1. Connectors show green in admin console but connections fail
2. Mac client has stale routing state
3. **Fix:** Restart Twingate on Mac:
   ```bash
   killall Twingate && open -a Twingate
   ```
4. Wait 5-10 minutes for full sync

**General connectivity issues:**
- Check Twingate is running: Look for menu bar icon
- Quit and reopen: Click icon → Quit → Reopen from Applications
- Check resources assigned in admin console

---

## SSH Configuration

**Config location:** `~/.ssh/config`

**Key hosts configured:**
- `192.168.2.250` - prox-book5 (Proxmox Node 1)
- `192.168.2.249` - prox-tower (Proxmox Node 2, management)
- `192.168.1.249` - prox-tower-fast (2.5GbE network)
- `192.168.2.161` - VM 100 Omarchy (via ProxyJump)
- `192.168.1.126` - VM 101 Ubuntu Server (via ProxyJump)

**ProxyJump:** VMs accessed through Proxmox hosts due to Twingate routing.

See **[ssh-access-cheatsheet.md](ssh-access-cheatsheet.md)** for complete reference.

---

## Shell & Terminal

**Shell:** ZSH with Oh My Zsh + Powerlevel10k
**Config:** `~/.zshrc` (symlinked from `~/projects/zshConfig/zshrc`)
**Theme:** `~/.p10k.zsh` (symlinked from `~/projects/zshConfig/p10k.zsh`)

**Terminal:** iTerm2
**Multiplexer:** tmux (persistent `claude` session for Claude Code operations)

---

## Development Environment

**Editor:** Neovim
**Config:** `~/.config/nvim` (symlinked from `~/projects/nvimConfig`)

**Package Managers:**
- Homebrew: `/opt/homebrew/bin/brew`
- Python: `/Library/Frameworks/Python.framework/Versions/3.13/bin/python3`
- Node.js: via nvm or Homebrew

**Claude Code:** Installed globally, uses `~/.claude/` for configuration

---

## Automated Tasks

### LaunchAgents (Background Jobs)

| Agent | Purpose | Schedule |
|-------|---------|----------|
| `dotfiles-backup` | Git backup of configs | Hourly |
| `email-reminder` | AR/AP email notifications | Scheduled |
| `claude-auto` | Claude Code automation | On demand |

**Location:** `~/Library/LaunchAgents/`

**Management:**
```bash
launchctl list | grep user          # List user agents
launchctl load ~/Library/LaunchAgents/com.user.agent.plist
launchctl unload ~/Library/LaunchAgents/com.user.agent.plist
```

### Crontab

```bash
crontab -l    # View scheduled tasks
crontab -e    # Edit crontab
```

---

## Google Drive

**Mount:** Native Google Drive for Desktop app
**Elevated Vault:** `/Users/j/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Elevated Vault/`

---

## Changelog

| Date | Change |
|------|--------|
| 2025-12-20 | **Always-on power config:** Disabled sleep, Low Power Mode off, display sleeps after 10 min. Fixes Twingate disconnect emails. |
