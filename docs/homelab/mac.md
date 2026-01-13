# MacBook Air - Primary Workstation

**Device**: MacBook Air M2
**Hostname**: macAir
**OS**: macOS Sonoma
**Role**: Primary development machine, homelab control point

---

## Quick Access

```bash
# From homelab (book5, tower, ubuntu)
ssh mac             # Alias
ssh j@192.168.2.226

# From Pixelbook Go (mDNS)
ssh mac             # Uses macAir.local

# From termux (phone)
ssh mac             # ProxyJump via tower-fast
```

---

## Hardware

| Component | Details |
|-----------|---------|
| Model | MacBook Air M2 (2022) |
| Chip | Apple M2 (8-core CPU, 8-core GPU) |
| RAM | 16GB unified memory |
| Storage | 512GB SSD |
| Display | 13.6" Liquid Retina |

---

## Network Configuration

| Network | IP | Purpose |
|---------|-----|---------|
| Home WiFi | 192.168.2.226 | LAN access to homelab |
| Twingate | Dynamic | Remote access to homelab |

```
Mac → Twingate → homelab (192.168.2.x)
homelab → Mac (direct LAN when on same network)
```

---

## Development Environment

### Shell

| Component | Details |
|-----------|---------|
| Shell | zsh |
| Framework | Oh My Zsh |
| Theme | Powerlevel10k |
| Config | ~/projects/zshConfig (symlinked) |

### Editor

| Component | Details |
|-----------|---------|
| Editor | Neovim |
| Config | ~/projects/nvimConfig (symlinked to ~/.config/nvim) |

### Key Tools

| Tool | Purpose |
|------|---------|
| Homebrew | Package manager |
| Claude Code | AI assistant CLI |
| Git | Version control |
| Docker Desktop | Container runtime |
| Twingate | VPN client |

---

## Symlinks

Critical symlinks that connect projects to system locations:

| Symlink | Target |
|---------|--------|
| ~/.config/nvim | ~/projects/nvimConfig |
| ~/.zshrc | ~/projects/zshConfig/.zshrc |
| ~/.p10k.zsh | ~/projects/zshConfig/.p10k.zsh |

---

## Projects Directory

```
~/projects/
├── promptLibrary/    # AI prompt engineering
├── nvimConfig/       # Neovim configuration
├── zshConfig/        # Zsh configuration
├── odooReports/      # Business automation
├── scripts/          # Backup system, automation
├── n8nDev/           # n8n workflows (dev)
├── n8nProd/          # n8n workflows (prod)
├── graveyard/        # Obsolete file archive
└── loom/             # Loom → SOP pipeline
```

All projects backed up hourly to GitHub.

---

## Automation

### LaunchAgents

| Agent | Schedule | Purpose |
|-------|----------|---------|
| com.user.backup | Hourly | Git backup to GitHub |
| com.user.email | On trigger | Email automation |
| com.user.claude-auto | On trigger | Claude automation |

```bash
# List agents
launchctl list | grep user

# Check specific agent
launchctl list com.user.backup
```

### Crontab

```bash
# View crontab
crontab -l

# Includes:
# - Odoo report automation
# - Claude auto reset
```

---

## SSH Configuration

### Homelab Access (`~/.ssh/config`)

```ssh-config
# Proxmox hosts
Host book5
  HostName 192.168.2.250
  User root

Host tower
  HostName 192.168.2.249
  User root

# VMs (ProxyJump)
Host ubuntu vm101
  HostName 192.168.2.126
  User jaded
  ProxyJump tower

Host omarchy vm100
  HostName 192.168.2.161
  User jaded
  ProxyJump book5

# Pixelbook Go (reverse tunnel)
Host go
  HostName localhost
  Port 2244
  User jaded
  ProxyJump book5

# Pixelbook Go (direct mDNS)
Host go-local
  HostName go.local
  User jaded
```

### Keys

| Key | Location | Purpose |
|-----|----------|---------|
| id_ed25519 | ~/.ssh/id_ed25519 | All SSH connections |
| GitHub | In ssh-agent | Git operations |

---

## Twingate

| Property | Value |
|----------|-------|
| Network | jaded423 |
| Client | Twingate.app |
| Status | Menu bar icon |

```bash
# Check status
twingate status

# Restart client
killall Twingate && open -a Twingate
```

**Note**: After homelab reboot, may need to restart Twingate client and wait 5-10 minutes.

---

## Quick Commands

```bash
# SSH to homelab
ssh book5           # Proxmox Node 1
ssh tower           # Proxmox Node 2
ssh ubuntu          # VM 101 (services)
ssh go              # Pixelbook Go

# Backup projects
backup-all          # Custom function in zshrc

# Check Twingate
twingate status

# Open Samba share
open smb://192.168.2.250/Shared
```

---

## Claude Code

Global configuration in `~/.claude/`:

| File | Purpose |
|------|---------|
| CLAUDE.md | Global instructions |
| commands/ | Slash commands (/init, /log, /sum) |
| docs/ | Documentation (including homelab/) |
| settings.json | Claude Code settings |

---

## Troubleshooting

### Can't reach homelab

```bash
# Check Twingate
twingate status

# If disconnected
open -a Twingate

# Test connectivity
ping 192.168.2.250
```

### SSH timeout to VMs

VMs require ProxyJump through Proxmox hosts:
```bash
# Test jump host first
ssh book5 hostname

# Then VM
ssh ubuntu hostname
```

### Symlinks broken

```bash
# Check symlinks
ls -la ~/.config/nvim
ls -la ~/.zshrc

# Recreate if needed
ln -sf ~/projects/nvimConfig ~/.config/nvim
ln -sf ~/projects/zshConfig/.zshrc ~/.zshrc
```

### Homebrew issues

```bash
# Update Homebrew
brew update

# Fix permissions
sudo chown -R $(whoami) /opt/homebrew

# Doctor
brew doctor
```

---

## Related Docs

- [../projects.md](../projects.md) - All active projects
- [../interconnections.md](../interconnections.md) - System dependency map
- [go.md](go.md) - Pixelbook Go (similar dev setup)
