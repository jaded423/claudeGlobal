# SSH Access Cheat Sheet

Quick reference for accessing all machines in the multi-location network.

**Last Updated:** January 19, 2026 (Unified tunnel architecture for all roaming devices)

---

## Unified Tunnel Architecture

All roaming devices (Mac, Go, Phone, PC) use **reverse SSH tunnels** through book5 as the primary access method. This works from anywhere because book5 is always reachable via Twingate.

**Pattern:**
- `ssh device` → Uses reverse tunnel through book5 (works from anywhere)
- `ssh device-local` → Direct/mDNS access (same network only)

**Tunnel Ports on book5:**
| Port | Device | User |
|------|--------|------|
| 2244 | Pixelbook Go | jaded |
| 2245 | Windows PC (PowerShell) | joshu |
| 2246 | Mac | j |
| 2247 | Phone (Termux) | u0_a499 |
| 2248 | WSL Ubuntu | joshua |

---

## Quick Access Commands

### Roaming Devices (Tunnel-Based Primary)

```bash
# Pixelbook Go - CachyOS Hyprland
ssh go                     # Via tunnel (works anywhere)
ssh go-local               # Direct mDNS (same network only)

# Windows PC - PowerShell
ssh pc                     # Via tunnel (works anywhere)
ssh pc-local               # Direct (same network only)

# Mac
ssh mac                    # Via tunnel (from other devices)
ssh mac-local              # Direct mDNS (same network only)

# Phone - Termux (Samsung S25 Ultra)
ssh phone                  # Via tunnel (works anywhere)
ssh phone-local            # Direct (same network only, port 8022)

# WSL Ubuntu (on Windows PC)
ssh wsl                    # Via tunnel through book5
ssh wsl-local              # Direct (same network only, port 2222)
```

### Homelab (Direct Access)

```bash
# Proxmox Hosts
ssh book5                  # prox-book5 (Node 1) - 192.168.2.250
ssh tower                  # prox-tower (Node 2) - 192.168.2.249

# VMs (auto ProxyJump configured)
ssh omarchy                # VM 100 - Arch Desktop (via book5)
ssh ubuntu                 # VM 101 - Ubuntu Server (via tower)

# Raspberry Pi
ssh pihole                 # magic-pihole - 192.168.2.131

# Pi1 @ Elevated (via PC tunnel)
ssh pi1                    # Git backup mirror (requires PC to be on)
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
┌───────────────────────────────┐    ┌─────────────────────────────────┐
│ prox-book5 (TUNNEL HUB)       │    │ prox-tower (DUAL-NIC)           │
│ 192.168.2.250                 │    │ Management: 192.168.2.249 (1G)  │
│ Proxmox Node 1 | User: root   │    │ Primary:    192.168.1.249 (2.5G)│
├───────────────────────────────┤    │ Proxmox Node 2 | User: root     │
│ REVERSE TUNNELS LISTENING:    │    ├─────────────────────────────────┤
│ :2244 ← Pixelbook Go          │    │ └─ VM 101 (on 1GbE vmbr0)       │
│ :2245 ← Windows PC            │    │    192.168.2.126                │
│ :2246 ← Mac                   │    │    Ubuntu Server                │
│ :2247 ← Phone (Termux)        │    │    User: jaded                  │
│ :2248 ← WSL Ubuntu            │    └─────────────────────────────────┘
├───────────────────────────────┤
│ └─ VM 100                     │
│    192.168.2.161              │
│    Omarchy | User: jaded      │
└───────────────────────────────┘
        ▲
        │ (Outbound SSH with -R flag)
        │
┌───────────────────────────────────────────────────────────────────────┐
│                      ROAMING DEVICES                                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐     │
│  │ Mac         │ │ Go          │ │ Phone       │ │ PC          │     │
│  │ :2246       │ │ :2244       │ │ :2247       │ │ :2245/:2248 │     │
│  │ LaunchAgent │ │ systemd     │ │ Termux:Boot │ │ Sched Task  │     │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘     │
│  All use Twingate CLIENT to reach book5, then reverse-forward port   │
└───────────────────────────────────────────────────────────────────────┘
```

**How it works:** Each roaming device maintains a persistent outbound SSH connection to book5 with a reverse port forward (`-R port:localhost:22`). Other devices can then SSH to `localhost:port` on book5 (via ProxyJump) to reach any roaming device.

**Why tunnels?** All devices roam between networks (home, work, mobile). Tunnels work from anywhere as long as book5 is reachable via Twingate.

---

## Device Reference Table

### Homelab (Static)

| Device | IP | User | Access | Services |
|--------|-----|------|--------|----------|
| **prox-book5** | 192.168.2.250 | root | Direct | Proxmox Node 1, Tunnel Hub, Twingate |
| **prox-tower** | 192.168.2.249 | root | Direct | Proxmox Node 2, Twingate |
| **VM 100 (Omarchy)** | 192.168.2.161 | jaded | ProxyJump via book5 | Arch Desktop |
| **VM 101 (Ubuntu)** | 192.168.2.126 | jaded | ProxyJump via tower | Docker, Ollama, Plex, Jellyfin, Frigate |
| **magic-pihole** | 192.168.2.131 | jaded | Direct | Pi-hole, Twingate, MagicMirror |
| **Pi1 (Elevated)** | 192.168.137.123 | pi | ProxyJump via pc | Git backup mirror (15 repos) |

### Roaming Devices (Tunnel-Based)

| Device | Tunnel Port | Local Access | User | Persistence |
|--------|-------------|--------------|------|-------------|
| **Mac** | 2246 | macair.local | j | LaunchAgent |
| **Pixelbook Go** | 2244 | go.local | jaded | systemd |
| **Phone (Termux)** | 2247 | 192.168.1.37:8022 | u0_a499 | Termux:Boot |
| **Windows PC** | 2245 | 192.168.1.193:22 | joshu | Scheduled Task |
| **WSL Ubuntu** | 2248 | 192.168.1.193:2222 | joshua | (via PC tunnel) |

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

### Roaming Devices (Tunnel = Primary)

```bash
# Pixelbook Go
ssh go            # → tunnel via book5:2244 (works anywhere)
ssh go-local      # → go.local (same network only)

# Mac
ssh mac           # → tunnel via book5:2246 (works anywhere)
ssh mac-local     # → macair.local (same network only)

# Phone (Termux)
ssh phone         # → tunnel via book5:2247 (works anywhere)
ssh phone-local   # → 192.168.1.37:8022 (same network only)

# Windows PC
ssh pc            # → tunnel via book5:2245 (works anywhere)
ssh pc-local      # → 192.168.1.193:22 (same network only)

# WSL Ubuntu
ssh wsl           # → tunnel via book5:2248 (works anywhere)
ssh wsl-local     # → 192.168.1.193:2222 (same network only)
```

### Homelab (Direct Access)

```bash
ssh book5         # → root@192.168.2.250
ssh tower         # → root@192.168.2.249
ssh omarchy       # → jaded@192.168.2.161 (via book5)
ssh ubuntu        # → jaded@192.168.2.126 (via tower)
ssh pihole        # → jaded@192.168.2.131
ssh pi1           # → pi@192.168.137.123 (via pc tunnel)
```

---

## Windows PC (etintake)

**Full docs**: [homelab/pc.md](homelab/pc.md)

| Component | Details |
|-----------|---------|
| Hostname | etintake |
| IP | 192.168.1.193 (when on same network) |
| Tunnel Port | 2245 (PowerShell), 2248 (WSL) |
| Users | joshu (PowerShell), joshua (WSL) |

**SSH Access:**
```bash
ssh pc              # Via tunnel (works anywhere)
ssh pc-local        # Direct (same network only)
ssh wsl             # Via tunnel (works anywhere)
ssh wsl-local       # Direct (same network only)
ssh pi1             # Pi1 via ProxyJump through pc
```

**Tunnel Persistence:** Windows Scheduled Task `Start SSH Tunnel to Proxmox` with boot+logon triggers runs `C:\Users\joshu\bin\start-tunnel.ps1` (auto-reconnect loop).

See [homelab/pc.md](homelab/pc.md) for full setup details.

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

**Full docs**: [homelab/go.md](homelab/go.md)

| Component | Details |
|-----------|---------|
| Hostname | go |
| Hardware | Google Pixelbook Go (Intel Core m3, 8GB RAM) |
| OS | CachyOS Linux (Arch-based), Hyprland DE |
| Tunnel Port | 2244 |
| User | jaded |

**SSH Access:**
```bash
ssh go                # Via tunnel (works anywhere)
ssh go-local          # Direct mDNS (same network only)
```

**Tunnel Persistence:** systemd service maintains tunnel with auto-reconnect. Twingate headless mode (service account) for non-interactive auth.

**Key Features:**
- zsh + oh-my-zsh + powerlevel10k
- Stays awake on AC with lid closed
- WiFi power save auto-toggles based on AC state

See [homelab/go.md](homelab/go.md) for full setup details.

---

## Phone (Samsung S25 Ultra - Termux)

| Component | Details |
|-----------|---------|
| Device | Samsung S25 Ultra |
| App | Termux (F-Droid) |
| Tunnel Port | 2247 |
| User | u0_a499 |

**SSH Access:**
```bash
ssh phone             # Via tunnel (works anywhere)
ssh phone-local       # Direct 192.168.1.37:8022 (same network only)
```

**Tunnel Persistence:** Termux:Boot runs `~/.termux/boot/start-services` on device boot, which starts sshd and `~/bin/start-tunnel.sh` (auto-reconnect loop).

**Key Features:**
- zsh + oh-my-zsh + powerlevel10k
- termux-wake-lock prevents sleep while tunnel runs

---

## Mac (macAir)

| Component | Details |
|-----------|---------|
| Hostname | macair |
| Tunnel Port | 2246 |
| User | j |

**SSH Access (from other devices):**
```bash
ssh mac               # Via tunnel (works anywhere)
ssh mac-local         # Direct mDNS macair.local (same network only)
```

**Tunnel Persistence:** LaunchAgent `com.user.mac-reverse-tunnel.plist` with KeepAlive maintains tunnel.

**Note:** Mac is the primary development machine. Other devices use tunnels to reach it.

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
