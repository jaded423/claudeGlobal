# Claude Code - Windows PC (WSL)

**Machine:** Windows PC - etintake (WSL2 Ubuntu)
**IP:** 192.168.1.193
**User:** joshua (WSL), joshu (PowerShell)
**OS:** Windows 11 + WSL2 Ubuntu
**Shell:** zsh (WSL)

---

## Important: You Are NOT the Source of Truth

The **Mac (MacBook Air)** maintains all homelab documentation. Your role is to:
1. **Read** existing docs from GitHub when you need context
2. **Save** session notes locally for later integration
3. **Do NOT** try to maintain comprehensive docs here

---

## Reading Homelab Documentation

All homelab docs are available on GitHub. To find information about any machine or service:

```bash
# View the main homelab overview
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/homelab.md

# View this machine's docs
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/homelab/pc.md

# View other machine docs (replace MACHINE with: phone, mac, ubuntu, omarchy, tower, book5, etc.)
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/homelab/MACHINE.md

# View SSH access cheatsheet
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/ssh-access-cheatsheet.md
```

**GitHub Repos:** https://github.com/jaded423
- `scripts` - Contains ~/.claude/docs/ (homelab documentation)

---

## Saving Session Notes

When you make changes or discoveries, save notes for Mac Claude to integrate later.

**Location:** `~/notes/`
**Format:** `YYYY-MM-DD-topic.md`

### Note Template

```markdown
# Session Notes - YYYY-MM-DD
**Machine:** pc (Windows PC - WSL Ubuntu)
**Summary:** Brief description of what was done

---

## Changes Made
- What you configured/fixed/installed
- Commands used
- Files modified

## For Integration
Items that should be added to homelab docs:
- WSL configuration changes
- Twingate/Docker changes
- Port forwarding changes
- ICS/Pi1 connectivity changes

## Raw Details
Any verbose output, configs, or reference material
```

---

## This Machine's Configuration

### Network
| Interface | IP | Purpose |
|-----------|-----|---------|
| WiFi | 192.168.1.193 | Main network, Twingate |
| Ethernet | 192.168.137.1 | ICS gateway for Pi1 |

### Key Services (in WSL)
- Twingate Connector (Docker) - "Elevated" network
- SSH server (port 2222 via Windows port forward)
- ICS gateway for Pi1

### Quick Commands

```bash
# Check Docker/Twingate
docker ps | grep twingate

# Fix SSH after reboot
sudo /usr/local/bin/fix-wsl-ssh

# Check port forwards (PowerShell)
powershell.exe -Command "netsh interface portproxy show v4tov4"
```

### SSH Access (from this machine)

```bash
# Via Twingate (when connected)
ssh tower      # Proxmox Node 2
ssh book5      # Proxmox Node 1
ssh ubuntu     # VM 101

# Local
ssh pi1        # Pi1 via ICS (192.168.137.123)
```

---

## Workflow Summary

1. **Need info?** - Fetch from GitHub (see URLs above)
2. **Made changes?** - Save notes to `~/notes/YYYY-MM-DD-topic.md`
3. **Mac Claude** will SSH here later to retrieve and integrate your notes

The user will prompt Mac Claude with something like: "pull in the pc notes" and Mac Claude will SSH to this machine, read ~/notes/, and update the homelab docs.
