# VM 100 - Omarchy

**Device**: Proxmox VM on prox-book5
**Hostname**: omarchy
**OS**: Arch Linux
**DE**: Hyprland
**Role**: Linux desktop environment

---

## Quick Access

```bash
# From Mac
ssh omarchy         # Alias
ssh vm100           # Alias
ssh jaded@192.168.2.161

# ProxyJump through book5 (automatic via SSH config)
```

---

## VM Configuration

| Property | Value |
|----------|-------|
| VMID | 100 |
| Host | prox-book5 |
| RAM | 12GB |
| vCPU | 4 cores |
| Disk | 32GB (on book5 local-zfs) |
| Network | vmbr0 (192.168.2.x) |
| Display | VirtIO GPU |

---

## Network Configuration

| Interface | IP | Purpose |
|-----------|-----|---------|
| ens18 | 192.168.2.161 | Management, desktop use |
| Gateway | 192.168.2.1 | Router |

**Twingate:** DISABLED (was causing routing loop - VM couldn't reach host book5)

```
Mac → Twingate → book5 → ProxyJump → omarchy:22
```

**Note:** SSH uses conditional ProxyJump - tries direct first, falls back to book5.

---

## System Configuration

| Component | Details |
|-----------|---------|
| OS | Arch Linux (rolling release) |
| Kernel | linux-lts |
| DE | Hyprland |
| Shell | zsh |
| Terminal | kitty |
| Editor | neovim |

---

## Hyprland Desktop

### Keybindings

| Keys | Action |
|------|--------|
| SUPER + Q | Open terminal (kitty) |
| SUPER + R | Open launcher |
| SUPER + C | Close window |
| SUPER + 1-9 | Switch workspace |
| SUPER + SHIFT + 1-9 | Move window to workspace |
| SUPER + E | File manager |

### Configuration Files

| File | Purpose |
|------|---------|
| ~/.config/hypr/hyprland.conf | Hyprland config |
| ~/.config/kitty/kitty.conf | Terminal config |
| ~/.config/nvim/ | Neovim config |
| ~/.zshrc | Shell config |

---

## Installed Software

| Package | Purpose |
|---------|---------|
| hyprland | Window manager |
| kitty | Terminal emulator |
| neovim | Text editor |
| zsh | Shell |
| oh-my-zsh | Zsh framework |
| powerlevel10k | Zsh theme |
| waybar | Status bar |
| thunar | File manager |
| firefox | Web browser |

---

## Tower Guardian - Proxmox Health Monitor

**Project Location**: `~/docker/tower-guardian/`
**Purpose**: AI-powered health monitoring for prox-tower with automated alerting and power cycle capability

### Services

| Service | Port | Image | Purpose |
|---------|------|-------|---------|
| n8n | 5678 | n8nio/n8n | Workflow automation engine |
| Ollama | 11434 | ollama/ollama | Local LLM (Llama 3.1 8B) |

**Web Access**:
- n8n: http://192.168.2.161:5678
- Ollama API: http://192.168.2.161:11434

### Quick Commands

```bash
# Start/stop stack
cd ~/docker/tower-guardian
docker compose up -d
docker compose down

# Check status
docker ps

# Chat with Ollama
docker exec -it ollama ollama run llama3.1:8b

# View logs
docker logs n8n
docker logs ollama
```

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│  omarchy (192.168.2.161) - Tower Guardian               │
│  ├── n8n (port 5678) - Workflow engine                  │
│  └── ollama (port 11434) - Llama 3.1 8B (4.9GB)         │
└─────────────────────────────────────────────────────────┘
                            │
       ┌────────────────────┼────────────────────┐
       ▼                    ▼                    ▼
 ┌───────────┐      ┌─────────────┐      ┌─────────────┐
 │ prox-tower│      │ Email       │      │ Tapo P105   │
 │ .2.249    │      │ (Gmail)     │      │ Smart Plug  │
 │ SSH/API   │      │ Approval    │      │ Power Cycle │
 └───────────┘      └─────────────┘      └─────────────┘
```

### PC Health Monitor Workflow (v2.1)

**Active workflow** monitoring Windows PC heartbeat:

| Feature | Details |
|---------|---------|
| Check interval | Every 5 minutes |
| Warning threshold | 10-30 min stale |
| Critical threshold | >30 min stale |
| Max reboots | 2 attempts |
| Cooldown | 15 min after each reboot |
| Power control | IFTTT → Tapo smart plug |

**State files** (in n8n container `/home/node/.n8n/`):
- `pc_heartbeat.txt` - Unix timestamp from PC
- `pc_reboot_count.txt` - Reboot attempt counter
- `pc_last_reboot.txt` - Timestamp of last reboot

**PC sends heartbeat via:** `ssh book5 "curl -s -X POST http://192.168.2.161:5678/webhook/pc-heartbeat"`

### Setup Status

**Completed**:
- [x] Docker Compose stack created
- [x] n8n container running
- [x] Ollama container running
- [x] Llama 3.1 8B model installed
- [x] PC Health Monitor v2.1 workflow
- [x] IFTTT power cycle integration

**Remaining**:
- [ ] Email integration (Gmail SMTP/IMAP) for notifications
- [ ] SSH keys (n8n → prox-tower) for Tower monitoring
- [ ] Build prox-tower health check workflow

### Configuration Files

| File | Purpose |
|------|---------|
| `~/docker/tower-guardian/docker-compose.yml` | Container definitions |
| `~/docker/tower-guardian/README.md` | Full project documentation |
| Docker volume: `tower-guardian_n8n_data` | n8n workflows, credentials |
| Docker volume: `tower-guardian_ollama_data` | LLM models |

### Planned Workflow

1. **Schedule Trigger** - Every 5 minutes
2. **Health Checks** - Proxmox API, SSH, ICMP ping
3. **AI Analysis** - Ollama evaluates results
4. **Email Notification** - Request approval for action
5. **Tapo Power Cycle** - Hard reboot on approval
6. **Verify Recovery** - Confirm system back online

### Credentials Needed

- [ ] Tapo app email (lowercase!) and password
- [ ] Gmail app password for SMTP/IMAP
- [ ] SSH key for prox-tower root access

---

## SSH Configuration

### On Mac (`~/.ssh/config`)

```ssh-config
# Conditional ProxyJump - tries direct first, falls back to book5
Host 192.168.2.161 omarchy vm100
  HostName 192.168.2.161
  User jaded
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# ProxyJump only if direct connection fails (no Twingate)
Match host 192.168.2.161,omarchy,vm100 exec "! nc -z -w 1 192.168.2.161 22 2>/dev/null"
  ProxyJump 192.168.2.250
```

### On Omarchy

User: `jaded` (passwordless sudo)

---

## Package Management

```bash
# Update system
sudo pacman -Syu

# Install package
sudo pacman -S <package>

# Search packages
pacman -Ss <query>

# Clean cache
sudo pacman -Sc
```

---

## Troubleshooting

### Can't SSH in

1. Check VM is running: `ssh book5 "qm status 100"`
2. Start VM: `ssh book5 "qm start 100"`
3. Check network: `ssh book5 "qm guest cmd 100 network-get-interfaces"`

### Hyprland not starting

Check logs:
```bash
journalctl --user -u hyprland
cat ~/.local/share/hyprland/hyprland.log
```

### No display after boot

VM may need console access via Proxmox Web UI:
1. Go to https://192.168.2.250:8006
2. Select VM 100
3. Click Console tab

---

## Related Docs

- [book5.md](book5.md) - Host (prox-book5)
- [tower.md](tower.md) - Monitored by Tower Guardian
- [go.md](go.md) - Similar Hyprland setup on Pixelbook Go
