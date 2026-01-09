# Work Mac Configuration

**Machine:** MacBook Pro (Apple Silicon)
**OS:** macOS
**Last Updated:** December 24, 2025

---

## Power Management

### Power-Source-Specific Configuration (Dec 24, 2025)

**Purpose:** Keep Mac awake on AC power for Twingate connectivity, but allow sleep on battery to prevent drain.

**Problem Solved:**
- Original issue (Dec 20): Twingate disconnect/reconnect emails from Mac sleeping on battery
- Follow-up issue (Dec 24): Always-on settings drained battery overnight (100% → 2%)

**Current Settings:**

| Setting | Battery | AC Power | Purpose |
|---------|---------|----------|---------|
| `sleep` | 10 min | 0 (never) | Battery sleeps, AC stays awake |
| `displaysleep` | 10 min | 10 min | Display always sleeps after 10 min |
| `disksleep` | 10 min | 10 min | Irrelevant for SSD |
| `powernap` | 0 (off) | 1 (on) | Save battery, allow background tasks on AC |
| `lowpowermode` | 0 | 0 | Disabled |

**Commands Applied:**
```bash
# AC Power: System stays awake for Twingate
sudo pmset -c sleep 0
sudo pmset -c disablesleep 1
sudo pmset -c powernap 1

# Battery: System sleeps after 10 minutes to preserve battery
sudo pmset -b sleep 10
sudo pmset -b disablesleep 0
sudo pmset -b powernap 0

# Both: Display sleeps after 10 minutes
sudo pmset -a displaysleep 10
```

**Behavior:**
- **On AC power**: System stays awake indefinitely, display sleeps after 10 min
- **On battery**: System sleeps after 10 min idle, preserving battery
- **Closing lid on AC**: Display off, system stays awake
- **Closing lid on battery**: System sleeps normally
- Manual sleep/reboot/shutdown: Works normally

**To Restore Default Sleep Behavior:**
```bash
sudo pmset restoredefaults
```

**Verification:**
```bash
pmset -g custom             # Show AC and battery settings separately
pmset -g                    # Show current active settings
pmset -g assertions         # Show what's preventing sleep
```

**Why This Works:**
- Twingate stays connected when plugged in (common use case)
- Battery protected when unplugged overnight
- Display always sleeps to save power regardless of power source

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
- `192.168.2.126` - VM 101 Ubuntu Server (via ProxyJump)

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
| 2025-12-24 | **Power-source-specific config:** AC stays awake (Twingate), battery sleeps after 10 min. Fixes overnight battery drain from previous always-on config. |
| 2025-12-20 | **Always-on power config:** Disabled sleep, Low Power Mode off, display sleeps after 10 min. Fixes Twingate disconnect emails. |
