# SSH Access Cheat Sheet

Quick reference for accessing all machines in the multi-location network.

**Last Updated:** January 13, 2026 (Added Pixelbook Go - CachyOS Hyprland via Twingate)

---

## Quick Access Commands

### From Mac (Local or Remote via Twingate)

```bash
# Proxmox Hosts (direct access)
ssh root@192.168.2.250      # prox-book5 (Node 1)
ssh root@192.168.2.249      # prox-tower (Node 2) - Management network
ssh root@192.168.1.249      # prox-tower (Node 2) - 2.5GbE primary network

# VMs (auto ProxyJump configured)
ssh jaded@192.168.2.161     # VM 100 - Omarchy Desktop (via prox-book5)
ssh jaded@192.168.2.126     # VM 101 - Ubuntu Server (via prox-tower, on 1GbE)

# Raspberry Pi
ssh jaded@192.168.2.131     # magic-pihole (Pi-hole, Twingate, MagicMirror)

# Mac (from homelab - direct LAN access)
ssh j@192.168.2.226                    # Mac direct (from book5, tower)
ssh mac                                # Using alias (works from book5, tower, termux)

# Windows PC - WSL Ubuntu (aliases: etintake, wsl, pc)
ssh etintake                           # Port 2222, user joshua

# Pi1 @ Elevated (via Windows PC port forward)
ssh pi1                                # Port 2223, user pi (git backup mirror)

# Pixelbook Go - CachyOS (via Twingate)
ssh go                                 # CachyOS Hyprland, user jaded
ssh pixelbook                          # Alias for go
```

---

## Network Diagram

```
                        ┌─────────────────────────────────────────┐
                        │           TWINGATE CLOUD                │
                        │         (jaded423 network)              │
                        └───────────────┬─────────────────────────┘
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        │                               │                               │
        ▼                               ▼                               ▼
┌───────────────┐              ┌───────────────┐              ┌───────────────┐
│  CONNECTOR 1  │              │  CONNECTOR 2  │              │  CONNECTOR 3  │
│ prox-book5    │              │ prox-tower    │              │ magic-pihole  │
│ systemd svc   │              │ systemd svc   │              │ Docker        │
│ (on host)     │              │ (on host)     │              │ 192.168.2.131 │
└───────┬───────┘              └───────┬───────┘              └───────────────┘
        │                               │
        ▼                               ▼
┌───────────────────┐          ┌─────────────────────────────────┐
│ prox-book5        │          │ prox-tower (DUAL-NIC)           │
│ 192.168.2.250     │          │ Management: 192.168.2.249 (1G)  │
│ Proxmox Node 1    │          │ Primary:    192.168.1.249 (2.5G)│
│ User: root        │          │ Proxmox Node 2 | User: root     │
├───────────────────┤          ├─────────────────────────────────┤
│ └─ VM 100         │          │ └─ VM 101 (on 1GbE vmbr0)   │
│    192.168.2.161  │          │    192.168.2.126                │
│    Omarchy        │          │    Ubuntu Server                │
│    User: jaded    │          │    User: jaded                  │
└───────────────────┘          └─────────────────────────────────┘
```

**Note (Dec 13, 2025):** prox-tower now has dual NICs - Intel I218-LM (1GbE, management/Twingate) and Realtek RTL8125 (2.5GbE, VMs/primary). VM 101 now runs on 1GbE (vmbr0) - 2.5GbE used for direct inter-node link.

---

## Device Reference Table

| Device | IP | User | Access Method | Services |
|--------|-----|------|---------------|----------|
| **prox-book5** | 192.168.2.250 | root | Direct SSH | Proxmox Node 1, Twingate (systemd) |
| **prox-tower** | 192.168.2.249 (mgmt) | root | Direct SSH | Proxmox Node 2, Twingate (systemd) |
| **prox-tower** | 192.168.1.249 (2.5G) | root | Direct SSH | Primary network, VM bridge |
| **VM 100 (Omarchy)** | 192.168.2.161 | jaded | ProxyJump via .250 | Arch Desktop |
| **VM 101 (Ubuntu)** | **192.168.2.126** | jaded | ProxyJump via .249 | Docker, Ollama, Jellyfin (1GbE) |
| **magic-pihole** | 192.168.2.131 | jaded | Direct SSH | Pi-hole, Twingate, MagicMirror |
| **Mac (macAir)** | 192.168.2.226 | j | Direct (book5/tower), ProxyJump (termux) | Development |
| **etintake (Win PC)** | 192.168.1.193:2222 | joshua | Direct/Twingate | WSL Ubuntu, Twingate connector |
| **Pi1 (Elevated)** | 192.168.1.193:2223 | pi | Via PC port forward | Git backup mirror (Pi 1B+) |
| **Pixelbook Go** | 192.168.1.244 | jaded | Twingate | CachyOS Hyprland, dev laptop |

---

## SSH Config (Mac: ~/.ssh/config)

```ssh-config
# GitHub
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

# Proxmox Node 1 - prox-book5
Host 192.168.2.250 prox-book5 book5
  HostName 192.168.2.250
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Proxmox Node 2 - prox-tower (management network)
Host 192.168.2.249 prox-tower tower
  HostName 192.168.2.249
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Proxmox Node 2 - prox-tower (2.5GbE primary network)
Host 192.168.1.249 prox-tower-fast tower-fast
  HostName 192.168.1.249
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 100 - Omarchy Desktop (ProxyJump through prox-book5)
Host 192.168.2.161 omarchy vm100
  HostName 192.168.2.161
  User jaded
  ProxyJump 192.168.2.250
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 101 - Ubuntu Server (on 1GbE vmbr0, ProxyJump through prox-tower)
Host 192.168.2.126 ubuntu-server ubuntu vm101
  HostName 192.168.2.126
  User jaded
  ProxyJump 192.168.2.249
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Raspberry Pi - magic-pihole
Host 192.168.2.131 pihole pi
  HostName 192.168.2.131
  User jaded
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Mac (macAir) - direct LAN access
Host mac macair macbook 192.168.2.226
  HostName 192.168.2.226
  User j
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Samsung S25 Ultra - Termux
Host s25ultra phone termux
  HostName 192.168.2.101    # or 192.168.1.96 depending on router
  User u0_a499
  Port 8022
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Note: Phone runs zsh with oh-my-zsh + powerlevel10k (configured Dec 20, 2025)
# Plugins: git, zoxide, fzf, docker, npm, python, colored-man-pages, jsontools, history, sudo

# Pi1 @ Elevated - Git backup mirror (via Windows PC port forward)
Host pi1 rpi1
  HostName 192.168.1.193
  User pi
  Port 2223
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Note: Pi1 (Raspberry Pi 1B+) gets internet via Windows ICS - requires PC to be on
# Services: Git backup mirror (15 repos, 4-hourly sync via cron)

# Pixelbook Go - CachyOS Hyprland (via Twingate)
Host go pixelbook
  HostName 192.168.1.244
  User jaded
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Note: Pixelbook Go runs CachyOS (Arch-based) with Hyprland DE
# Shell: zsh + oh-my-zsh + powerlevel10k | Terminal: kitty
# Twingate connector (Docker) provides remote access
```

---

## Access Scenarios

### Scenario 1: Working from Mac at Home (LAN)
```bash
# Direct access to everything on 192.168.2.x
ssh root@192.168.2.250      # prox-book5
ssh jaded@192.168.2.126     # Ubuntu Server (ProxyJump auto-applies)
```
- Twingate NOT required (same LAN)
- ProxyJump still routes VM traffic through Proxmox hosts

### Scenario 2: Working from Mac Remotely (Twingate)
```bash
# Connect Twingate first, then same commands
twingate status             # Verify connected
ssh root@192.168.2.250      # Works via Twingate
ssh jaded@192.168.2.126     # Works via ProxyJump through Twingate
```
- **Requires Twingate resources** for each Proxmox host (.249, .250)
- VMs accessible via ProxyJump (no separate Twingate resource needed)

### Scenario 3: Working from Homelab to Mac
```bash
# From prox-book5 or prox-tower (direct LAN)
ssh j@192.168.2.226
ssh mac                      # Using alias
```
- Direct LAN access (same 192.168.2.x subnet)
- No Twingate required when on local network

### Scenario 4: Working from Termux (Phone) to Mac
```bash
# Phone on 192.168.1.x network (fast router)
ssh mac                      # ProxyJump via tower-fast automatically
```
- Phone IP varies: 192.168.1.96 (fast) or 192.168.2.101 (management)
- Mac on 192.168.2.x not directly reachable from 192.168.1.x
- ProxyJump through tower-fast (192.168.1.249) bridges networks

### Scenario 5: Cross-Node Access (Proxmox to Proxmox)
```bash
# From prox-book5 to prox-tower
ssh root@192.168.2.249

# From prox-tower to prox-book5  
ssh root@192.168.2.250
```
- Direct LAN access (same subnet)
- No Twingate needed for inter-node communication

---

## Twingate Resources Required

| Resource Name | Address | Ports | Purpose |
|---------------|---------|-------|---------|
| prox-book5 SSH | 192.168.2.250 | 22 | SSH to Node 1 + ProxyJump base |
| prox-tower SSH | 192.168.2.249 | 22 | SSH to Node 2 + ProxyJump base |
| magic-pihole SSH | 192.168.2.131 | 22 | SSH to Pi |
| mac-ssh | 192.168.2.226 | 22 | SSH to Mac (LAN access, no Twingate needed locally) |
| homeLab Shared | 192.168.2.250 | 139, 445 | Samba file sharing |

**Note:** VMs (.161, .126) do NOT need separate Twingate resources - access them via ProxyJump through the Proxmox hosts.

---

## Troubleshooting

### SSH Timeout to VMs
```bash
# Test Proxmox host first
ssh root@192.168.2.250 "hostname"

# If that works but VM fails, check ProxyJump
ssh -v jaded@192.168.2.126  # Verbose output
```

### Twingate Not Connected
```bash
# Mac
twingate status
twingate connect

# Verify routes exist
ping 192.168.2.250
```

### Permission Denied
```bash
# Check SSH key is loaded
ssh-add -l

# Re-add if needed
ssh-add ~/.ssh/id_ed25519
```

### ProxyJump Not Working
```bash
# Test direct hop first
ssh root@192.168.2.250 "ssh jaded@192.168.2.126 hostname"

# Check SSH config syntax
ssh -G 192.168.2.126 | grep -i proxy
```

---

## Host Aliases (Short Names)

With the SSH config above, you can use short names:

```bash
ssh prox-book5    # → root@192.168.2.250
ssh prox-tower    # → root@192.168.2.249 (management)
ssh tower-fast    # → root@192.168.1.249 (2.5GbE)
ssh omarchy       # → jaded@192.168.2.161 (via ProxyJump)
ssh vm100         # → jaded@192.168.2.161 (via ProxyJump)
ssh ubuntu-server # → jaded@192.168.2.126 (via ProxyJump, 1GbE)
ssh ubuntu        # → jaded@192.168.2.126 (via ProxyJump, 1GbE)
ssh vm101         # → jaded@192.168.2.126 (via ProxyJump, 1GbE)
ssh pihole        # → jaded@192.168.2.131
ssh pi            # → jaded@192.168.2.131
ssh mac           # → j@192.168.2.226
ssh macair        # → j@192.168.2.226
ssh etintake      # → joshua@192.168.1.193:2222
ssh wsl           # → joshua@192.168.1.193:2222
ssh pc            # → joshua@192.168.1.193:2222
ssh pi1           # → pi@192.168.1.193:2223 (via PC forward)
ssh rpi1          # → pi@192.168.1.193:2223 (via PC forward)
ssh go            # → jaded@192.168.1.244 (Pixelbook Go via Twingate)
ssh pixelbook     # → jaded@192.168.1.244 (Pixelbook Go via Twingate)
```

---

## Windows PC (etintake) Setup

**Completed January 7, 2026**

| Component | Details |
|-----------|---------|
| Hostname | etintake |
| Windows IP | 192.168.1.193 (DHCP) |
| WSL IP | Dynamic (172.20.x.x) |
| SSH Port | 2222 |
| User | joshua |
| Twingate | "Elevated" network, "PC" connector (Docker in WSL) |

**SSH Access:**
```bash
ssh etintake          # Uses aliases: etintake, wsl, pc
ssh -p 2222 joshua@192.168.1.193
```

**Architecture:**
```
Mac → Twingate → Windows:2222 → portproxy → WSL:2222 → SSH
```

**Auto-start:** `/etc/wsl.conf` runs `/etc/wsl-ssh-startup.sh` on WSL boot:
- Creates /run/sshd
- Removes /run/nologin
- Starts sshd
- Updates Windows port forwarding to current WSL IP

**Troubleshooting:**
- If SSH fails after reboot: Run `sudo /usr/local/bin/fix-wsl-ssh` in WSL
- If Windows IP changed: Update Twingate resource in admin console

---

## Pi1 @ Elevated (Git Backup Mirror)

**Completed January 9, 2026**

| Component | Details |
|-----------|---------|
| Hostname | raspberrypi |
| Hardware | Raspberry Pi 1 Model B+ (ARMv6, 700MHz, 512MB RAM) |
| OS | Raspberry Pi OS (Legacy) Bookworm Lite |
| Pi IP | 192.168.137.123 (Windows ICS subnet) |
| SSH Port | 2223 (via Windows port forward) |
| User | pi (passwordless sudo) |
| Storage | 8GB SD card (~4.4GB free, 152MB used by mirrors) |
| Internet Speed | ~40 Mbps via Windows ICS NAT |

**SSH Access:**
```bash
ssh pi1               # Uses aliases: pi1, rpi1
ssh -p 2223 pi@192.168.1.193
```

**Architecture:**
```
Mac → PC:2223 → Windows portproxy → Pi:22 (192.168.137.123)
Pi → Windows ICS NAT → PC WiFi → Internet
```

**Git Backup Mirror:**
- 15 repositories mirrored from GitHub (bare repos)
- Location: `~/git-mirrors/*.git`
- Sync script: `~/git-mirrors/sync-mirrors.sh`
- Schedule: Every 4 hours via cron
- Log: `~/git-mirrors/sync.log`

**Common Commands:**
```bash
# Manual sync
ssh pi1 "~/git-mirrors/sync-mirrors.sh"

# Check sync log
ssh pi1 "tail -20 ~/git-mirrors/sync.log"

# List mirrored repos
ssh pi1 "ls ~/git-mirrors/*.git"

# Check disk usage
ssh pi1 "du -sh ~/git-mirrors/"

# Run speedtest
ssh pi1 "speedtest-cli"
```

**Important Notes:**
- Pi internet requires Windows PC to be powered on (ICS dependency)
- Windows port forward: `netsh interface portproxy` rule on port 2223
- GitHub SSH key: "Pi1 Backup" in github.com/settings/keys

---

## Pixelbook Go (CachyOS Hyprland)

**Completed January 12-13, 2026**

| Component | Details |
|-----------|---------|
| Hostname | pixelbook-go |
| Hardware | Google Pixelbook Go (Intel Core m3, 8GB RAM) |
| OS | CachyOS Linux (Arch-based) |
| Kernel | 6.12.65-2-cachyos-lts |
| DE | Hyprland 0.53.1 |
| IP | 192.168.1.244 |
| User | jaded (passwordless sudo) |
| Shell | zsh + oh-my-zsh + powerlevel10k |
| Terminal | kitty (default), alacritty (alternate) |

**SSH Access:**
```bash
ssh go                # Uses aliases: go, pixelbook
ssh jaded@192.168.1.244
```

**Twingate Setup:**
- Connector: Docker container on the Pixelbook
- Network: jaded423
- Allows remote SSH access from Mac/other devices

**Installed Software:**
| Package | Purpose |
|---------|---------|
| neovim | Text editor (config from nvimConfig repo) |
| zsh | Shell |
| oh-my-zsh | Zsh framework |
| powerlevel10k | Zsh theme |
| ttf-meslo-nerd | Nerd font for terminal icons |
| waybar | Status bar |
| hyprlauncher | Application launcher |
| kitty | Terminal emulator |
| zoxide | Smart directory navigation |
| fzf | Fuzzy finder |

**Hyprland Keybindings:**
| Keys | Action |
|------|--------|
| SUPER + Q | Open terminal (kitty) |
| SUPER + R | Open launcher (hyprlauncher) |
| SUPER + 1-9 | Switch workspace |
| SUPER + SHIFT + 1-9 | Move window to workspace |
| SUPER + C | Close window |
| SUPER + E | File manager (thunar) |
| 3-finger swipe | Switch workspaces |

**Configuration Files:**
- Hyprland: `~/.config/hypr/hyprland.conf`
- Kitty: `~/.config/kitty/kitty.conf`
- Neovim: `~/.config/nvim` (cloned from nvimConfig repo)
- Zsh: `~/.zshrc` (Arch-adapted version)

**Issues Fixed During Setup:**
1. **Phantom Monitor**: `Unknown-1` ghost monitor disabled in hyprland.conf
2. **Gesture Syntax**: Updated to Hyprland 0.53+ syntax
3. **Default Shell**: Changed from fish to zsh for SSH sessions

---

## Quick Copy Commands

**Copy file TO Ubuntu Server:**
```bash
scp file.txt jaded@192.168.2.126:~/
# Or use alias:
scp file.txt ubuntu-server:~/
```

**Copy file FROM Ubuntu Server:**
```bash
scp jaded@192.168.2.126:~/file.txt ./
# Or use alias:
scp ubuntu-server:~/file.txt ./
```

**Rsync to Ubuntu Server:**
```bash
rsync -avz ./folder/ jaded@192.168.2.126:~/folder/
# Or use alias:
rsync -avz ./folder/ ubuntu-server:~/folder/
```

**Execute remote command:**
```bash
ssh jaded@192.168.2.126 "docker ps"
# Or use alias:
ssh ubuntu-server "docker ps"
```
