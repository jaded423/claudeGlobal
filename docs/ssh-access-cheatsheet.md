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
│ └─ VM 100         │          │ └─ VM 101 (on 1GbE vmbr0)       │
│    192.168.2.161  │          │    192.168.2.126                │
│    Omarchy        │          │    Ubuntu Server                │
│    User: jaded    │          │    User: jaded                  │
├───────────────────┤          └─────────────────────────────────┘
│                   │
│ ◄──REVERSE SSH────┤
│    TUNNEL :2244   │
│                   │
└───────────────────┘
        ▲
        │ (Twingate Client)
        │
┌───────────────────┐
│ Pixelbook Go      │
│ 192.168.1.244     │
│ CachyOS Hyprland  │
│ User: jaded       │
│ (separate network)│
└───────────────────┘
```

**Note:** Pixelbook Go uses Twingate CLIENT (not connector) to reach homelab.
Mac reaches Go via reverse SSH tunnel through book5:2244, not direct Twingate.

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

# Pixelbook Go - CachyOS Hyprland (via reverse tunnel through book5)
Host go pixelbook
  HostName localhost
  Port 2244
  User jaded
  ProxyJump book5
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Pixelbook Go - Direct mDNS (same network only)
Host go-local pixelbook-local
  HostName go.local
  User jaded
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
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
ssh go            # → jaded@localhost:2244 (via reverse tunnel through book5)
ssh pixelbook     # → jaded@localhost:2244 (alias for go)
ssh go-local      # → jaded@go.local (direct mDNS, same network only)
```

---

## Windows PC (etintake)

**Completed January 7, 2026** | **Full docs**: [homelab/pc.md](homelab/pc.md)

| Component | Details |
|-----------|---------|
| Hostname | etintake |
| IP | 192.168.1.193 (DHCP) |
| Users | joshu (PowerShell), joshua (WSL) |

**SSH Access:**
```bash
ssh pc              # PowerShell (port 22)
ssh wsl             # WSL Ubuntu (port 2222)
ssh pi1             # Pi1 via ProxyJump
```

**Architecture:** WSL Ubuntu with port forwarding, Twingate connector in Docker.

See [homelab/pc.md](homelab/pc.md) for full setup, auto-start config, and troubleshooting.

---

## Pi1 @ Elevated (Git Backup Mirror)

**Completed January 9, 2026** | **Full docs**: [homelab/pi1.md](homelab/pi1.md)

| Component | Details |
|-----------|---------|
| Hostname | raspberrypi |
| Hardware | Raspberry Pi 1 Model B+ (512MB RAM) |
| IP | 192.168.137.123 (via Windows ICS) |
| User | pi |

**SSH Access:**
```bash
ssh pi1             # Via Windows PC ProxyJump
ssh rpi1            # Alias
```

**Purpose:** Offline git backup mirror - 15 repos syncing every 4 hours.

**Note:** Requires Windows PC to be powered on (ICS dependency).

See [homelab/pi1.md](homelab/pi1.md) for git mirror details, sync commands, and troubleshooting.

---

## Pixelbook Go (CachyOS Hyprland)

**Completed January 12-13, 2026** | **Full docs**: [homelab/go.md](homelab/go.md)

| Component | Details |
|-----------|---------|
| Hostname | go |
| Hardware | Google Pixelbook Go (Intel Core m3, 8GB RAM) |
| OS | CachyOS Linux (Arch-based), Hyprland DE |
| IP | 192.168.1.244 (local network) |
| User | jaded |

**SSH Access:**
```bash
ssh go                # Via reverse tunnel through book5 (works anywhere)
ssh go-local          # Direct mDNS (same network only)
```

**Architecture:** Go uses Twingate **Client** to reach homelab, with a reverse SSH tunnel through book5:2244 for incoming connections (avoids client/connector routing conflicts).

**Key Features:**
- zsh + oh-my-zsh + powerlevel10k (Arch-adapted config)
- Stays awake on AC with lid closed (tunnel remains active)
- WiFi power save auto-toggles based on AC state

See [homelab/go.md](homelab/go.md) for full setup details, troubleshooting, and configuration files.

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
