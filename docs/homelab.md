# Home Lab Documentation

**Primary Infrastructure:** 2-node Proxmox Cluster "home-cluster" with QDevice quorum
**Last Updated:** December 13, 2025 (Dual-NIC setup, VM 101 migrated to 2.5GbE network)

---

## ⚠️ Important: Claude Cannot Run Sudo Commands

**When working on the home lab server**, Claude Code **cannot execute sudo commands** that require password authentication.

**If you see Claude trying to run sudo commands:**
- This is wasting time and tokens
- The command will fail every time
- Claude should have asked you to run it instead

**Correct pattern:**
Claude provides the commands and asks you to run them, then verifies the result:
```bash
# Claude asks you to run:
sudo systemctl restart smb
sudo ufw allow 445/tcp
```

See **[~/.claude/CLAUDE.md](../.claude/CLAUDE.md)** for full details on Claude Code limitations.

---

## Current Infrastructure Overview

**🎉 CLUSTER UPDATE (Dec 1, 2025):** Expanded to 2-node Proxmox cluster with VM migration to more powerful hardware!

**🎉 MAJOR UPDATE (Nov 28-29, 2025):** Migrated from bare-metal CachyOS to Proxmox VE with VM-based architecture!

### Network Architecture

**Dual-Network Configuration (Dec 13, 2025):**

| Network | Subnet | Router | Speed | Purpose |
|---------|--------|--------|-------|---------|
| **Primary** | 192.168.1.0/24 | Main router (gateway .1.1) | 2.5 Gbps | VMs, fast traffic, media |
| **Management** | 192.168.2.0/24 | Backup router (gateway .2.1) | 1 Gbps | Twingate, AMT, legacy |

**Why Two Networks:**
- Main router (192.168.1.x) has 2.5GbE port for high-speed traffic
- Backup router (192.168.2.x) connects to main router, provides management network
- Twingate connector runs on management network (192.168.2.249)
- VMs run on primary network (192.168.1.x) for faster media streaming
- Intel AMT will be configured on management network for out-of-band access

### Active Devices

| Device | IP Address | Purpose | Power Usage | Status |
|--------|------------|---------|-------------|---------|
| **Proxmox Cluster "home-cluster"** | | 2-node HA cluster | 100-180W | ✅ Active |
| **├─ prox-book5 (node 1)** | 192.168.2.250 | Samsung Galaxy Book5 Pro, 16GB RAM | 50-100W | ✅ Active |
| **│  └─ VM 100: Omarchy** | 192.168.2.161 | Arch Linux desktop (DHH's Omarchy distro) | - | ✅ Auto-start |
| **└─ prox-tower (node 2)** | 192.168.2.249 / 192.168.1.249 | ThinkStation 510, 78GB RAM, Xeon E5-2683 v4 (16c/32t), **Dual-NIC** | 50-80W | ✅ Active |
|    **├─ Twingate (systemd)** | (host) | Native systemd service (no container) | - | ✅ Auto-start |
|    **└─ VM 101: Ubuntu Server** | **192.168.1.126** | Ubuntu 24.04 Server (2.5GbE network) | - | ✅ Auto-start |
| **Raspberry Pi 2** | 192.168.2.131 | Pi-hole DNS, Twingate backup, MagicMirror kiosk | 3-4W | ✅ Active |

**Total Power:** ~105-185W (~$15-28/month electricity)

**Cluster Notes:**
- VM 101 (Ubuntu Desktop) deleted Dec 1 to free space on prox-book5
- VM 102 migrated from prox-book5 to prox-tower Dec 1 for better cooling/performance
- Both nodes run Twingate connectors for redundant remote access
- **QDevice added Dec 2:** Pi at .131 provides 3rd vote for quorum (2/3 votes required)
- Quorum: 3 votes (2 nodes + QDevice), HA-capable, survives single node failure
- **CPU protection:** VMs limited to 75% CPU with automatic watchdog suspension at 90%

### Architecture Diagram

```
Proxmox Cluster Infrastructure (Dec 2025) - "home-cluster"
│
├── NODE 1: prox-book5 @ 192.168.2.250 (Samsung Galaxy Book5 Pro)
│   ├── Hardware: 16GB RAM, Intel Arc GPU, 952GB NVMe
│   ├── ZFS RAID0 storage (~880GB available)
│   ├── IOMMU/VT-d enabled for GPU passthrough
│   ├── Lid-close handling (stays running, screen off)
│   ├── Cluster role: Node 1 (ID: 0x00000001)
│   ├── Twingate Connector (systemd) - Native host service, auto-start ✅
│   └── VM 100: Omarchy Desktop @ 192.168.2.161 (8GB RAM, 4 cores, 120GB disk)
│       ├── SeaBIOS boot (legacy BIOS for compatibility)
│       ├── VirtIO display (accessible via Proxmox web console)
│       ├── Arch Linux + Hyprland (DHH's Omarchy distro)
│       ├── SSH enabled (remote access via ProxyJump through .250)
│       ├── Auto-mount Samba share with Google Drive access (via fstab)
│       └── Auto-starts on boot ✅
│
├── NODE 2: prox-tower (ThinkStation 510) - DUAL-NIC SETUP
│   ├── Hardware: 78GB RAM, Xeon E5-2683 v4 (16c/32t), NVIDIA Quadro M4000
│   ├── Network (Dual-NIC Dec 13, 2025):
│   │   ├── vmbr0 @ 192.168.2.249 - Intel I218-LM (1GbE) - Management/Twingate/AMT
│   │   │   └── TSO/GSO/GRO disabled (see Known Issues)
│   │   └── vmbr1 @ 192.168.1.249 - Realtek RTL8125 (2.5GbE) - Primary/VMs
│   │       └── Connected to main router 2.5G port
│   ├── Intel AMT/vPro: Available on 192.168.2.x (needs MEBx config - see AMT section)
│   ├── ZFS storage (rpool-tower, ~370GB available) - converted from LVM Dec 12, 2025
│   ├── Twingate Connector (systemd) - Native host service, auto-start ✅
│   ├── Cluster role: Node 2 (ID: 0x00000002)
│   │
│   └── VM 101: Ubuntu Server 24.04 @ 192.168.1.126 (40GB RAM, 14 cores, 300GB disk)
│       └── On vmbr1 (2.5GbE) for fast media streaming
│       ├── CPU pinning: affinity 2-15,18-31 (host keeps cores 0-1)
│       ├── UEFI boot, SSH enabled
│       ├── Rebuilt Dec 12, 2025 (fresh install after storage conversion)
│       ├── Docker + All Services:
│       │   ├── Jellyfin media server (port 8096)
│       │   ├── qBittorrent torrent client (port 8080)
│       │   ├── ClamAV antivirus (scans downloads automatically)
│       │   ├── Open WebUI (Ollama interface, port 3000)
│       │   └── Ollama with 9 LLMs (port 11434)
│       ├── Media Pipeline: qBit downloads → ClamAV scan → auto-sort to Jellyfin
│       │   └── scan-and-move.sh (cron every 10min) → Movies/TV Shows/Music
│       ├── oh-my-zsh + powerlevel10k theme
│       ├── Configs restored: .zshrc, .p10k.zsh, nvim, rclone
│       └── Auto-starts on boot ✅
│
└── Raspberry Pi 2 @ 192.168.2.131
    ├── Pi-hole DNS (network-wide ad blocking)
    ├── Twingate connector (backup)
    ├── Portainer (Docker UI, port 9000)
    ├── MagicMirror kiosk (port 8080, 6x4" touchscreen) ✅ Auto-starts reliably
    │   ├── Weather (Wylie, TX)
    │   ├── Pi system stats (°C)
    │   ├── Server stats via SSH (°C)
    │   ├── Pi-hole query stats
    │   └── Reset script: `~/reset-kiosk.sh`
    └── **Corosync QDevice** (cluster quorum service, port 5403)
        └── Provides 3rd vote for Proxmox cluster quorum

Cluster Details:
- Name: home-cluster
- Nodes: 2/2 online + QDevice (192.168.2.131)
- Quorum: 3 votes total (2 Proxmox nodes + 1 QDevice), requires 2 for quorum
- HA Capable: Yes (survives single node failure, can distribute services)
- Remote Access: Twingate systemd services on both Proxmox hosts (no containers)
- CPU Protection: VMs limited to 75% CPU, watchdog auto-suspends at 90%
- Storage: local-zfs-book5 (node 1), local-zfs-tower (node 2) - renamed for clarity
```

**Future Expansion:**
- [homelab-expansion.md](homelab-expansion.md) - Planned single-site upgrades and completed milestones
- [homelab-multi-site-expansion.md](homelab-multi-site-expansion.md) - Multi-site Proxmox architecture with CompTIA certification learning path
- [dreamCluster.md](dreamCluster.md) - Dream 3-node Ceph cluster build (ideal homelab configuration)

---

## Proxmox Host Details

**Server Name:** proxmox-jade (formerly cachyos-jade)
**Local IP:** 192.168.2.250
**User:** root
**OS:** Proxmox VE 9.1 (Debian Trixie-based)
**Kernel:** 6.12+ (Proxmox kernel)
**Hardware:** 16GB RAM, 952GB NVMe storage (ZFS RAID0), Intel Arc Graphics 130V/140V

The home lab now runs as a Type 1 hypervisor with 3 VMs providing isolated services. All previous services migrated to Ubuntu Server VM (192.168.2.126), maintaining secure remote access, file sharing, and personal infrastructure.

**Ubuntu Server VM (VM 102) @ 192.168.2.126:**
**User:** jaded
**OS:** Ubuntu Server 24.04 LTS
**Specs:** 6GB RAM, 3 cores, 200GB disk
**Purpose:** All server services (Docker, Ollama, Samba, etc.)

**Key Services:**
- SSH remote access (port 22)
- Samba file sharing (ports 445, 139)
- Twingate secure remote access
- Docker containerization
- **Odoo 17 development (port 8069)** - ERP/business app learning environment
- **Jellyfin media server (port 8096)** - Stream movies/TV to devices
- **qBittorrent torrent client (port 8080)** - Download manager with web UI
- **ClamAV virus scanner (port 3310)** - Automated download security
- **RustDesk Remote Desktop (ports 21115-21119)** - Cross-platform remote access
- Ollama local LLM inference (port 11434)
- Hyprland desktop environment
- Google Drive integration (2 accounts)
- System monitoring (Netdata port 19999, Glances port 61208)

**Access Methods:**
- **At Home:** Direct LAN access (192.168.2.250) - fastest
- **Remote:** Twingate network (jaded423) - secure tunnel

---

## Architecture

### Network Configuration

**Local Network:**
- IP Address: 192.168.2.250
- Subnet: 192.168.2.0/24
- Gateway: 192.168.2.1
- Access: Direct LAN (60+ MB/s transfers)

**Remote Access (Twingate):**
- Network Name: jaded423
- Connector: Docker container (host networking)
- Resources:
  - SSH Access (port 22) - assigned to jaded user
  - File Sharing (ports 445, 139) - assigned to family members
  - RustDesk Remote Desktop (ports 21115-21119, 21116 UDP) - assigned to jaded user

**Firewall (UFW):**
- Default: Deny incoming
- Allowed Ports: 22 (SSH), 139 (NetBIOS), 445 (SMB)
- Status: Active and enabled

### Service Stack

```
┌─────────────────────────────────────────┐
│         User Access Layer               │
│  - SSH (port 22)                        │
│  - Samba (ports 445, 139)               │
│  - RustDesk (ports 21115-21119)         │
│  - Twingate Connector (remote access)   │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│      Service Management Layer           │
│  - systemd (sshd, smb, rustdesk)        │
│  - Docker (Twingate container)          │
│  - UFW (firewall)                       │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│         Storage Layer                   │
│  - /home/jaded/* (user files)           │
│  - /srv/samba/shared (symlinked shares) │
│  - rclone FUSE mounts (Google Drive)    │
└─────────────────────────────────────────┘
```

---

## Services Documentation

### 1. SSH Server (OpenSSH)

**Purpose:** Remote terminal access for system administration
**Port:** 22 (TCP)
**Status Check:** `systemctl status sshd`
**Configuration:** `/etc/ssh/sshd_config`

**Security Features:**
- Root login disabled
- Public key authentication enabled (work Mac key installed)
- Password authentication available as fallback

**⚠️ LOCAL vs REMOTE Access:**

**When at home (local network):**
- Direct access to all IPs (no Twingate needed)
- ProxyJump still works but not required
- All scripts and tools work directly

**When remote (work, travel, etc.):**
- **MUST have Twingate resources configured** for each Proxmox host you want to reach
- Twingate client must be connected and active
- If you can't SSH somewhere you could before: check Twingate resources!

**Access from Work Mac:**
```bash
# Proxmox Node 1 (prox-book5)
ssh root@192.168.2.250

# Proxmox Node 2 (prox-tower) - Management network
ssh root@192.168.2.249
# Or via 2.5GbE network (faster)
ssh root@192.168.1.249

# VM 100 - Omarchy Desktop (via automatic ProxyJump through prox-book5)
ssh jaded@192.168.2.161

# VM 101 - Ubuntu Server (on 2.5GbE network, via ProxyJump through prox-tower)
ssh jaded@192.168.1.126
```

**ProxyJump Configuration for VMs:**

Due to a routing conflict between Twingate running on both the Mac and Proxmox host, VMs cannot be accessed directly through Twingate. The Proxmox host has a route for its own IP (192.168.2.250) through the Twingate sdwan0 interface, which conflicts with direct routing to VMs on the same network (192.168.2.x/24).

**Solution:** SSH ProxyJump configured in `~/.ssh/config` on work Mac:

```ssh
# Proxmox Node 1 - prox-book5
Host 192.168.2.250
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Proxmox Node 2 - prox-tower (management network)
Host 192.168.2.249 prox-tower tower
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Proxmox Node 2 - prox-tower (2.5GbE primary network)
Host 192.168.1.249 prox-tower-fast tower-fast
  User root
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 100 - Omarchy Desktop (ProxyJump through prox-book5)
Host 192.168.2.161 omarchy vm100
  User jaded
  ProxyJump 192.168.2.250
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 101 - Ubuntu Server (on 2.5GbE network, ProxyJump through prox-tower)
Host 192.168.1.126 ubuntu-server ubuntu vm101
  User jaded
  ProxyJump 192.168.2.249
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

**How it works:**
- Both Proxmox hosts (.249 and .250) are configured as Twingate resources
- VM access uses ProxyJump: Mac → host → VM
  - VM 100: Mac → .250 (prox-book5) → .161 (192.168.2.x network)
  - VM 101: Mac → .249 (prox-tower) → 192.168.1.126 (2.5GbE network)
- prox-tower has dual NICs: management (.249) and primary (.1.249)
- Twingate connects via management network, then reaches VM on primary network
- Automated scripts (gitBackup.sh, ollamaSummary.py) work without modification
- **Critical:** Without Twingate resources configured, remote SSH will timeout!

**Service Management:**
```bash
systemctl status sshd           # Check status
systemctl restart sshd          # Restart service
journalctl -u sshd -f           # View logs
```

**Setup Script:** `~/setup/setup-ssh.sh`

### 2. Samba File Server

**Purpose:** Cross-platform file sharing (macOS, Windows, Linux)
**Ports:** 445 (SMB), 139 (NetBIOS) - TCP
**Status Check:** `systemctl status smb`
**Configuration:** `/etc/samba/smb.conf`

**Share Structure:**
```
/srv/samba/shared/
├── Documents -> /home/jaded/Documents
├── ElevatedDrive -> /home/jaded/elevatedDrive (Google Drive - work)
├── GoogleDrive -> /home/jaded/GoogleDrive (Google Drive - personal)
├── Music -> /home/jaded/Music
├── Pictures -> /home/jaded/Pictures
└── Videos -> /home/jaded/Videos
```

**Access Methods:**

*At Home (Mac):*
```bash
# Finder: Cmd+K, then enter:
smb://192.168.2.250/Shared
```

*At Home (Windows):*
```
\\192.168.2.250\Shared
```

*Remote (via Twingate):*
Same as local access (same IP after Twingate connection)

**Authentication:**
- Username: jaded
- Password: Samba password (set separately from system password)

**Service Management:**
```bash
systemctl status smb            # Check status
systemctl restart smb           # Restart service
journalctl -u smb -f            # View logs
testparm -s                     # Test configuration
```

**Setup Scripts:**
- `~/setup/setup-samba.sh` - Initial setup
- `~/setup/update-samba-symlinks.sh` - Enable symlink support

### 3. Twingate Connector

**Purpose:** Secure remote access without port forwarding or VPN
**Deployment:** Native systemd service on both Proxmox hosts
**Network:** jaded423
**Status Check:** `systemctl status twingate-connector`

**Architecture (Dec 12, 2025):**
- **prox-tower (192.168.2.249):** systemd service on host
- **prox-book5 (192.168.2.250):** systemd service on host
- **Previous:** LXC containers (CT 200, CT 201) with Docker - removed

**Configuration:**
- Config file: `/etc/twingate/connector.conf`
- Service: `/usr/lib/systemd/system/twingate-connector.service`
- Tokens: Stored in config file (auto-renewed)

**Service Management:**
```bash
# Check status
systemctl status twingate-connector

# Restart if needed
systemctl restart twingate-connector

# View logs
journalctl -u twingate-connector -f

# View config
cat /etc/twingate/connector.conf
```

**Admin Console:** https://jaded423.twingate.com

**Setup Documentation:** `/root/twin-connect-systemd.md` on prox-tower

**Why systemd instead of Docker:**
- Lower overhead (no container runtime)
- More robust automatic token renewal
- Starts on boot without Docker dependency
- Easier to manage with standard systemctl
- Config persists in `/etc/twingate/connector.conf`

**Expansion Plan - Dual Connector Architecture:**

Currently, this home lab runs one Twingate connector, allowing work Mac to access home resources remotely. **Planned expansion:** Add a second connector on work PC to enable bidirectional access.

**Planned Architecture:**
```
Mac (Client) → Twingate Cloud → Home Lab Connector → Home resources (SSH, Samba, RustDesk, Jellyfin, Odoo)
Mac (Client) → Twingate Cloud → Work PC Connector → Work resources (RustDesk, files, servers)
```

**Benefits:**
- Access work PC from home (RustDesk desktop, files)
- Access home lab from work (development, media, files)
- Both connectors on same Twingate network (jaded423)
- Mac client routes to appropriate connector based on resource
- No additional cost (free tier supports multiple connectors)

**See:** `~/rustdesk-setup.md` Part 6 for detailed expansion plan

### 4. Docker

**Purpose:** Container runtime for Twingate and future services
**Status Check:** `systemctl status docker`
**Socket:** `/var/run/docker.sock`

**Service Management:**
```bash
systemctl status docker         # Check status
systemctl restart docker        # Restart Docker daemon
docker ps -a                    # List all containers
docker images                   # List images
```

**User Configuration:**
- User `jaded` in docker group (no sudo needed for docker commands)
- Socket permissions: Allows group docker

**Setup Script:** `~/setup/install-docker.sh`

### 5. System Monitoring

**Purpose:** Real-time system monitoring and performance tracking

#### Netdata (DISABLED)
**Port:** 19999
**Status:** Stopped and disabled (Nov 17, 2025)
**Reason:** Power savings (~1.4W, 33% reduction) - not needed when Magic Mirror Pi2 is inactive
**Original Purpose:** Live data source for Magic Mirror Pi2 project
**Access (when enabled):** `http://192.168.2.250:19999` (local network)

**To Re-enable:**
```bash
sudo systemctl enable --now netdata  # Re-enable for Magic Mirror work
systemctl status netdata             # Check status
journalctl -u netdata -f             # View logs
```

#### Glances
**Port:** 61208 (web mode)
**Status Check:** `ps aux | grep glances`
**Access:** `http://192.168.2.250:61208` (web mode)
**Features:**
- Lightweight system monitor
- Terminal and web modes
- Similar to btop but with web interface option
- Lower resource usage than Netdata

**Usage:**
```bash
# Terminal mode (via SSH)
btop               # Interactive system monitor
glances            # Terminal mode

# Web server mode
glances -w --port 61208

# Check battery status
cat /sys/class/power_supply/BAT*/capacity
cat /sys/class/power_supply/BAT*/status
```

### 6. Battery Management

**Purpose:** Maintain optimal battery health by limiting charge to 80%
**Method:** Samsung's built-in charge threshold feature
**Status Check:** `cat /sys/class/power_supply/BAT1/charge_control_end_threshold`

**Current Configuration:**
- Charge limit: 80% (battery stops charging at this level)
- No lower threshold (battery can discharge naturally)

**Check Current Status:**
```bash
# View charge threshold (should show 80)
cat /sys/class/power_supply/BAT1/charge_control_end_threshold

# View current battery level
cat /sys/class/power_supply/BAT1/capacity

# View charging status
cat /sys/class/power_supply/BAT1/status
```

### 7. UFW Firewall

**Purpose:** Network security - deny all except necessary ports
**Status Check:** `sudo ufw status verbose`
**Configuration:** `/etc/ufw/`

**Active Rules:**
```
22/tcp    ALLOW    # SSH
139/tcp   ALLOW    # Samba NetBIOS
445/tcp   ALLOW    # Samba SMB
```

**Default Policy:**
- Incoming: Deny
- Outgoing: Allow
- Routed: Deny

**Firewall Management:**
```bash
sudo ufw status verbose         # View rules
sudo ufw allow 80/tcp           # Add rule
sudo ufw delete allow 80/tcp    # Remove rule
sudo ufw enable                 # Enable firewall
sudo ufw disable                # Disable firewall
```

**Setup Script:** `~/setup/configure-firewall.sh`

### 8. Ollama (Local LLM Inference)

**Purpose:** Run large language models locally for AI tasks without API costs
**Port:** 11434 (localhost only)
**Status Check:** `systemctl status ollama`
**API Endpoint:** `http://127.0.0.1:11434`
**Open WebUI:** http://192.168.2.250:3000 (web interface for model interaction)

**Installed Models (Total: ~30GB):**

*High-Quality Models (14B parameters):*

- **`phi4:14b`** (9.1GB) ⭐ **DEFAULT for git commits**
  - **Best for:** Git commit messages, code analysis, complex reasoning
  - **Speed:** Moderate (~15-20s for commits)
  - **Notes:** Clean output, accurate conventional commit format, excellent code understanding

- **`qwen3:14b`** (9.0GB)
  - **Best for:** General reasoning, chat, analysis
  - **Speed:** Moderate
  - **Notes:** Has "thinking" mode that outputs reasoning before answers (not ideal for automation)

*General Use Models:*

- **`llama3.2:3b`** (2.0GB)
  - **Best for:** General chat, summarization, Q&A, writing assistance
  - **Speed:** Fast (3B parameters)

- **`phi3.5:3.8b`** (2.2GB)
  - **Best for:** Mathematical reasoning, logical problems, structured tasks
  - **Speed:** Fast (3.8B parameters)

- **`qwen2.5:7b`** (4.7GB)
  - **Best for:** Multilingual tasks, coding help, complex reasoning
  - **Speed:** Moderate (7B parameters)

*Coding-Focused Models:*

- **`qwen2.5-coder:7b`** (4.7GB)
  - **Best for:** Code generation, refactoring, algorithm design, debugging
  - **Speed:** Moderate (7B parameters)

- **`deepseek-coder:6.7b`** (3.8GB)
  - **Best for:** Code completion, filling in code gaps, autocomplete-style suggestions
  - **Speed:** Moderate (6.7B parameters)

*Specialized Models:*

- **`tavernari/git-commit-message:sp_commit_pro`** (4.7GB)
  - **Best for:** Git commit message generation (specialized fine-tune)
  - **Speed:** Moderate
  - **Notes:** Good quality but phi4:14b produces more accurate terminology

*Ultra-Lightweight Models:*

- **`gemma2:2b`** (1.6GB)
  - **Best for:** Quick queries, simple tasks, running multiple instances
  - **Speed:** Very fast (2B parameters)

- **`llama3.2:1b`** (1.3GB)
  - **Best for:** Lightning-fast responses, basic chat, simple classifications
  - **Speed:** Extremely fast (1B parameters)

**Hardware Acceleration:**
- GPU: Intel Arc Graphics 130V/140V (integrated)
- Compute Runtime: Intel compute-runtime with OpenCL
- CPU Governor: Performance mode (turbo to 4.8GHz)

**Service Management:**
```bash
systemctl status ollama           # Check status
sudo systemctl restart ollama     # Restart service
journalctl -u ollama -f           # View logs
```

**Usage:**
```bash
# List installed models
ollama list

# Run a model interactively
ollama run llama3.2:3b
ollama run qwen2.5-coder:7b

# Run with API
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Why is the sky blue?"
}'
```

**Documentation:** [Ollama Docs](https://github.com/ollama/ollama)

---

## Desktop Environment

### Hyprland Window Manager

**Theme:** Osaka-Jade (Omarchy-based)
**Compositor:** Wayland

**Color Scheme:**
- Active border: `#71CEAD` (jade/teal)
- Background: `#11221C` (dark forest green)
- Foreground: `#e6d8ba` (warm beige)

**Configuration Files:**
- Main config: `~/.config/hypr/hyprland.conf`
- Wallpaper: `~/.config/hypr/hyprpaper.conf`
- Waybar: `~/.config/waybar/config` and `~/.config/waybar/style.css`

**Key Components:**
- Status bar: Waybar (delayed start for stability)
- Notifications: mako
- Wallpaper manager: hyprpaper
- Terminals: Kitty and Alacritty (85% opacity)

**Wallpapers:**
Located in `~/.config/hypr/backgrounds/`:
- 1-osaka-jade-bg.jpg
- 2-osaka-jade-bg.jpg
- 3-osaka-jade-bg.jpg

**Background Rotation:**
- Keybind: `SUPER + SHIFT + A`
- Script: `~/.config/hypr/scripts/rotate-background.sh`

**Key Bindings:**
- `SUPER + RETURN` - Terminal
- `SUPER + SPACE` - Application launcher
- `SUPER + W` - Close window
- `SUPER + F` - Fullscreen
- `SUPER + [1-9]` - Switch workspaces
- `SUPER + SHIFT + [1-9]` - Move window to workspace
- `SUPER + SHIFT + A` - Rotate wallpaper

**Autostart:**
```bash
exec-once = sleep 1 && waybar   # Status bar (delayed)
exec-once = mako                # Notifications
exec-once = hyprpaper           # Wallpaper
```

**Troubleshooting:**
```bash
# Reload Hyprland config
hyprctl reload

# Restart Waybar
killall waybar && waybar &

# Restart wallpaper manager
killall hyprpaper && hyprpaper &
```

---

## Google Drive Integration

### rclone FUSE Mounts (VM 102)

**Tool:** rclone with VFS caching
**Mount Type:** FUSE (Filesystem in Userspace)
**Location:** VM 102 (192.168.2.126)

**Directory Structure:**
```
/home/jaded/GoogleDrives/
├── elevated/           (joshua@elevatedtrading.com)
│   ├── MyDrive/       ← "My Drive" contents (includes Elevated Vault)
│   ├── SharedDrives/  ← Team/shared drives (empty placeholder)
│   └── OtherComputers/ ← Backup & Sync computers (empty placeholder)
└── jaded/             (jaded423@gmail.com)
    ├── MyDrive/       ← "My Drive" contents
    ├── SharedDrives/  ← Team/shared drives (empty placeholder)
    └── OtherComputers/ ← Backup & Sync computers (empty placeholder)

# Convenience symlinks
/home/jaded/elevatedDrive → /home/jaded/GoogleDrives/elevated
/home/jaded/GoogleDrive → /home/jaded/GoogleDrives/jaded
```

### First Drive (Personal - jaded423@gmail.com)

**Remote Name:** gdrive
**Mount Point:** `/home/jaded/GoogleDrives/jaded/MyDrive/`
**Symlink:** `/home/jaded/GoogleDrive/`
**Service:** `~/.config/systemd/user/rclone-gdrive.service`

**VFS Settings:**
- Cache mode: writes
- Cache max age: 24 hours
- Read chunk size: 128MB
- Buffer size: 64MB

**Service Management:**
```bash
systemctl --user status rclone-gdrive.service
systemctl --user restart rclone-gdrive.service
systemctl --user enable rclone-gdrive.service    # Auto-mount on login
journalctl --user -u rclone-gdrive.service -f    # View logs
```

### Second Drive (Work - joshua@elevatedtrading.com)

**Remote Name:** elevated
**Mount Point:** `/home/jaded/GoogleDrives/elevated/MyDrive/`
**Symlink:** `/home/jaded/elevatedDrive/`
**Service:** `~/.config/systemd/user/rclone-elevated.service`
**Contains:** Elevated Vault (Obsidian workspace)

**VFS Settings:**
- Cache mode: writes
- Cache max age: 24 hours
- Read chunk size: 128MB
- Buffer size: 64MB

**Service Management:**
```bash
systemctl --user status rclone-elevated.service
systemctl --user restart rclone-elevated.service
systemctl --user enable rclone-elevated.service    # Auto-mount on login
journalctl --user -u rclone-elevated.service -f    # View logs
```

### Proxmox Node Access (SSHFS Mounts)

Both **prox-book5** and **prox-tower** mount the Google Drives from VM 102 via SSHFS:

**Mount Points on Proxmox Nodes:**
- `/mnt/elevated/` - Work Google Drive (joshua@elevatedtrading.com)
  - `/mnt/elevated/MyDrive/Elevated Vault/` - Obsidian workspace
- `/mnt/jaded/` - Personal Google Drive (jaded423@gmail.com)

**Configuration:**
```bash
# Both nodes have these mounts in /etc/fstab
jaded@192.168.2.126:/home/jaded/GoogleDrives/elevated /mnt/elevated fuse.sshfs defaults,allow_other,_netdev,reconnect,IdentityFile=/root/.ssh/id_rsa 0 0
jaded@192.168.2.126:/home/jaded/GoogleDrives/jaded /mnt/jaded fuse.sshfs defaults,allow_other,_netdev,reconnect,IdentityFile=/root/.ssh/id_rsa 0 0
```

**SSH Keys:**
- prox-book5 → VM 102: SSH key already configured
- prox-tower → VM 102: SSH key configured Dec 2, 2025

**Obsidian.nvim Configuration:**
Both Proxmox nodes have obsidian.nvim configured to access the Elevated Vault:
```lua
-- ~/.config/nvim/lua/plugins/tools/obsidian.lua
path = "/mnt/elevated/MyDrive/Elevated Vault"
```

### Usage

**Access mounted drives (on VM 102):**
```bash
# Personal drive
ls ~/GoogleDrive/MyDrive/              # Browse "My Drive" contents
ls ~/GoogleDrives/jaded/MyDrive/       # Same, via real path

# Work drive
ls ~/elevatedDrive/MyDrive/            # Browse "My Drive" contents (includes Elevated Vault)
ls ~/GoogleDrives/elevated/MyDrive/    # Same, via real path

# Access Obsidian Vault
cd ~/elevatedDrive/MyDrive/Elevated\ Vault/

# Copy files to either drive
cp file.txt ~/GoogleDrive/MyDrive/
cp document.pdf ~/elevatedDrive/MyDrive/

# Edit files directly (changes sync automatically)
nano ~/GoogleDrive/MyDrive/document.txt
```

**Access from Proxmox nodes (prox-book5 or prox-tower):**
```bash
# Work drive
ls /mnt/elevated/MyDrive/              # Browse "My Drive" contents
ls /mnt/elevated/MyDrive/Elevated\ Vault/  # Access Obsidian workspace

# Personal drive
ls /mnt/jaded/MyDrive/                 # Browse "My Drive" contents

# Use with neovim/obsidian.nvim
nvim /mnt/elevated/MyDrive/Elevated\ Vault/  # Opens Obsidian vault
```

**rclone Commands:**
```bash
# List configured remotes
rclone listremotes

# Test connection
rclone lsd gdrive:
rclone lsd elevated:

# Copy without mounting
rclone copy /local/path gdrive:remote/path
rclone copy /local/path elevated:remote/path

# Check space usage
rclone about gdrive:
rclone about elevated:
```

**Access from Other VMs (via Samba):**

Both Google Drive accounts are accessible to other VMs through the Samba share:

```bash
# From VM 100 (Omarchy) or any other VM
# Install cifs-utils
sudo pacman -S cifs-utils  # Arch-based
sudo apt install cifs-utils  # Debian/Ubuntu-based

# Mount the Samba share
sudo mount -t cifs //192.168.2.126/Shared /mnt/shared -o user=jaded

# Access Google Drive through Samba
ls /mnt/shared/GoogleDrive/       # Personal Google Drive
ls /mnt/shared/ElevatedDrive/     # Work Google Drive
```

**Performance:**
- First access: slower (downloading from cloud)
- Frequently accessed: cached locally for 24 hours
- Writes: cached and uploaded in background
- Best for: documents, configs, backups
- Not ideal for: video editing, databases

---

## System Information

### Hardware

**CPU:** Intel Core Ultra 7 256V (Lunar Lake)
- Cores: 8 (8 threads)
- Base: 400MHz
- Turbo: 4.8GHz
- Governor: Performance mode (for optimal Ollama performance)

**GPU:** Intel Arc Graphics 130V/140V (integrated)
- OpenCL support enabled
- Used for: Ollama LLM acceleration, desktop compositing
- Compute Runtime: intel-compute-runtime

**RAM:** 16GB DDR5 total
- Physical: 16GB
- Swap (zram): 22.7GB (zstd compression, 1.5x RAM)
- Total effective: ~37GB available
- Typical usage: 4-6GB used, 10-12GB available

**Storage:**
- Device: /dev/nvme0n1p2
- Total: 952GB
- Used: 16GB (2%)
- Available: 936GB

### Operating System

**Distribution:** CachyOS Linux
**Base:** Arch Linux (performance-optimized)
**Kernel:** 6.17.7-3-cachyos
**Init System:** systemd
**Desktop:** Hyprland (Wayland)
**Shell:** fish (Oh My Fish)

**Power Management:**
- **Always-on server mode** - System never auto-suspends
- **Suspend prevention:** Active systemd-inhibit lock blocks sleep/idle
  - Service: `/etc/systemd/system/prevent-suspend.service`
  - Inhibitor: `sleep:idle` in block mode ("Home lab server - always on")
  - Verify: `systemd-inhibit --list | grep "always on"`
  - Auto-starts on boot, enabled by default
- **Idle action disabled:** `/etc/systemd/logind.conf`
  - `IdleAction=ignore` - prevents automatic idle suspend
  - `HandleLidSwitch=ignore` - prevents suspend/hibernate when lid closed
  - `HandleLidSwitchExternalPower=ignore`
- **Screen power management:** Lid Monitor Service (automated)
  - Service: `~/.config/systemd/user/lid-monitor.service`
  - Script: `~/.config/hypr/scripts/lid-monitor.sh`
  - Monitors: `/proc/acpi/button/lid/LID0/state`
  - **Lid closed:** `hyprctl dispatch dpms off` (screen off, reduces power)
  - **Lid open:** `hyprctl dispatch dpms on` (screen on)
  - Auto-starts on boot, enabled by default
- **Result:** Server runs 24/7, Twingate always accessible, lid can be closed
- Manual suspend still available with: `sudo systemctl suspend -i` (force ignore inhibitors)
- Battery status: `cat /sys/class/power_supply/BAT*/capacity`

**Package Manager:**
- pacman (Arch package manager)
- yay (AUR helper)

**Performance Optimizations:**
- CachyOS kernel (optimized for modern CPUs)
- Preempt dynamic scheduling
- Custom compilation flags

### Network

**Hostname:** cachyos-jade
**Primary Interface:** (check with `ip addr`)
**IPv4:** 192.168.2.250
**Gateway:** 192.168.2.1
**DNS:** Pi-hole at 192.168.2.131

---

## Access from Work Mac

### SSH Access

**Standard Access:**
```bash
ssh jaded@192.168.2.250
```

**Authentication:**
- Primary: SSH key (already installed)
- Fallback: Password

**SSH Config (optional):**
Add to `~/.ssh/config` on work Mac:
```
Host homelab
    HostName 192.168.2.250
    User jaded
    IdentityFile ~/.ssh/id_ed25519

Host homelab-short
    HostName 192.168.2.250
    User jaded
```

Then connect with:
```bash
ssh homelab
```

### File Access

**Samba Share:**
```bash
# From Finder: Cmd+K, then:
smb://192.168.2.250/Shared

# Or mount via command line:
mkdir -p ~/mnt/homelab
mount_smbfs //jaded@192.168.2.250/Shared ~/mnt/homelab
```

**SFTP/SCP (via SSH):**
```bash
# Copy file to server
scp file.txt jaded@192.168.2.250:~/

# Copy file from server
scp jaded@192.168.2.250:~/file.txt .

# Copy directory
scp -r jaded@192.168.2.250:~/Documents ./

# SFTP interactive session
sftp jaded@192.168.2.250
```

### Remote Development

**VS Code Remote SSH:**
1. Install "Remote - SSH" extension
2. Add host: `jaded@192.168.2.250`
3. Connect and develop directly on server

**rsync for Development:**
```bash
# Sync local changes to server
rsync -avz --exclude='.git' ~/local/project/ jaded@192.168.2.250:~/remote/project/

# Sync server changes to local
rsync -avz jaded@192.168.2.250:~/remote/project/ ~/local/project/
```

---

## Setup Scripts Reference

**Location:** `~/setup/` on home server

### Installation Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `install-docker.sh` | Install Docker and Docker Compose | Initial setup only |
| `install-twingate-docker.sh` | Install Twingate via Docker | Initial setup or reinstall |
| `setup-ssh.sh` | Enable and configure SSH | Initial setup only |
| `setup-samba.sh` | Install and configure Samba | Initial setup only |

### Configuration Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `configure-firewall.sh` | Configure UFW firewall | Initial setup or after reset |
| `update-samba-symlinks.sh` | Enable symlink support | After adding new symlinks |

### Configuration Files

| File | Purpose | Permissions |
|------|---------|-------------|
| `docker-compose.yml` | Twingate container config | 644 |
| `.env` | Twingate credentials | 600 (sensitive) |
| `twingate-tokens.sh` | Token export script | 644 |
| `README.md` | Setup documentation | 644 |

---

## Proxmox Node CLI Setup

**Purpose:** Standard CLI tools and configuration for all Proxmox nodes in the cluster

**When to use:** Setting up a new Proxmox node or standardizing an existing node

### What Gets Installed

**Core Tools:**
- **tmux** 3.5a - Terminal multiplexer
- **zsh** 5.9 - Advanced shell (set as default)
- **Oh My Zsh** - Zsh framework with plugins
- **Powerlevel10k** - Zsh theme (your custom config)
- **Neovim** 0.10.4 - Modern vim editor
- **build-essential + make** - Build tools (gcc, g++, etc.)
- **Node.js** 20.19.2 + **npm** - Required for Mason LSP servers
- **deno** 2.5.6 - JavaScript/TypeScript runtime
- **fzf** 0.60 - Fuzzy finder
- **zoxide** 0.9.8 - Smarter cd command
- **Claude Code** 2.0.56 - AI assistant

**Your Configs:**
- `.zshrc` from ~/projects/zshConfig
- `.p10k.zsh` Powerlevel10k config
- Full nvim config from nvimConfig repo

### Installation Commands

**Quick install (all steps):**
```bash
# 1. Fix DNS (use Pi-hole at 192.168.2.131)
echo '# Fixed DNS - use Pi-hole' > /etc/resolv.conf
echo 'nameserver 192.168.2.131' >> /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# 2. Install base packages
apt update
apt install -y tmux zsh neovim git curl unzip fzf build-essential make

# 3. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 4. Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# 5. Install deno, zoxide, and Claude Code
curl -fsSL https://deno.land/install.sh | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash

# 6. Set zsh as default shell
chsh -s $(which zsh)

# 7. Copy configs from Mac
# Run these on your Mac:
scp ~/projects/zshConfig/zshrc root@<proxmox-ip>:~/.zshrc
scp ~/projects/zshConfig/p10k.zsh root@<proxmox-ip>:~/.p10k.zsh

# 8. Clone nvim config
git clone https://github.com/jaded423/nvimConfig.git ~/.config/nvim

# 9. Update PATH
echo 'export DENO_INSTALL="/root/.deno"' >> ~/.zshrc
echo 'export PATH="$DENO_INSTALL/bin:$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 10. Create symlinks for immediate access (important!)
# Tools installed to ~/.local/bin aren't in PATH until shell restart
# Creating symlinks to /usr/local/bin makes them available immediately
ln -sf /root/.local/bin/zoxide /usr/local/bin/zoxide
ln -sf /root/.deno/bin/deno /usr/local/bin/deno
ln -sf /root/.local/bin/claude /usr/local/bin/claude
```

**Verify tools are accessible:**
```bash
which zoxide deno claude  # Should show /usr/local/bin for all three
```

**Then logout and log back in to use zsh with all tools.**

### Notes

**DNS Issues:** Proxmox nodes may have Twingate managing `/etc/resolv.conf` with non-working DNS servers (100.95.0.x). Always set Pi-hole (192.168.2.131) as primary DNS before running apt commands.

**PATH Issues:** Tools installed via curl scripts (deno, zoxide, Claude Code) go to `~/.local/bin` which isn't in root's default PATH. The symlinks to `/usr/local/bin` fix this immediately. Without symlinks, tools won't work until you logout/login or start a new zsh shell.

**Claude Code:** Requires browser authentication on first run. SSH into the node from your Mac to authenticate (can't auth from console).

**Nvim Plugins:** First time you open nvim, Lazy.nvim will automatically install all plugins (~1 minute). Mason will auto-install LSP servers (requires Node.js).

### Currently Installed

- ✅ **prox-tower** (192.168.2.249) - Full CLI suite installed Dec 2, 2025
- ✅ **prox-book5** (192.168.2.250) - Full CLI suite installed Dec 2, 2025

---

## Maintenance

### Regular Tasks

**Daily:**
- Check service status: `systemctl status sshd smb && docker ps`
- Monitor disk space: `df -h /`

**Weekly:**
- Update system: `sudo pacman -Syu`
- Check logs for errors: `journalctl -p err -b`
- Restart services if needed

**Monthly:**
- Review firewall rules: `sudo ufw status verbose`
- Update Docker images: `cd ~/setup && docker-compose pull && docker-compose up -d`
- Clean package cache: `sudo pacman -Sc`

### Backup Strategy

**Important Directories:**
- `~/setup/` - All setup scripts and configs
- `~/.config/` - Desktop environment configs
- `~/.ssh/` - SSH keys and config
- `/etc/samba/` - Samba configuration

**Backup Methods:**
1. **Google Drive sync:** Already configured via rclone
2. **Git repositories:** Store configs in git (consider dotfiles repo)
3. **Manual backup:** Copy setup directory to work Mac

**Recommended Backup Command (from work Mac):**
```bash
# Backup setup directory
scp -r jaded@192.168.2.250:~/setup ~/backups/homelab-setup-$(date +%Y%m%d)

# Backup important configs
ssh jaded@192.168.2.250 'tar czf - ~/.config/hypr ~/.config/waybar ~/.ssh' > ~/backups/homelab-configs-$(date +%Y%m%d).tar.gz
```

### System Updates

**Update System:**
```bash
sudo pacman -Syu                # Full system update
sudo pacman -Syyu               # Force refresh and update
```

**Update AUR packages:**
```bash
yay -Syu                        # Update AUR packages
```

**Update Docker containers:**
```bash
cd ~/setup
docker-compose pull             # Pull latest images
docker-compose up -d            # Recreate with new images
```

---

## Troubleshooting

### SSH Issues

**Connection refused:**
```bash
# Check SSH is running
systemctl status sshd

# Check firewall allows SSH
sudo ufw status | grep 22

# Verify SSH is listening
sudo ss -tlnp | grep :22

# Restart SSH
sudo systemctl restart sshd
```

**Permission denied:**
```bash
# Check key permissions on work Mac
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Check authorized_keys on server
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Sudo Issues

**Sudo appears locked out / not accepting password:**
```bash
# Refresh sudo credentials and clear stale authentication
sudo -v

# This will:
# - Prompt for your password
# - Reset the sudo timestamp
# - Fix most "sudo not working" issues
# - Give you a fresh 15-minute sudo window
```

**Why this happens:**
- Sudo credential cache can get into a weird/corrupted state
- Authentication timestamp expires or becomes stale
- `sudo -v` forces a clean re-authentication without running a command

**If `sudo -v` doesn't fix it:**
```bash
# Check if your user is in wheel group (required for sudo)
groups | grep wheel

# Check sudo configuration
sudo -l

# View recent authentication errors
journalctl -n 100 | grep -iE 'sudo|pam|auth'
```

### Samba Issues

**Share not accessible:**
```bash
# Check Samba is running
systemctl status smb

# Check firewall
sudo ufw status | grep -E "445|139"

# Test configuration
testparm -s

# Restart Samba
sudo systemctl restart smb
```

**Symlinks not showing:**
```bash
# Re-enable symlink support
~/setup/update-samba-symlinks.sh

# Verify symlinks exist
ls -la /srv/samba/shared/

# Check Samba config
grep -E "follow symlinks|wide links" /etc/samba/smb.conf
```

**Slow transfer speeds at home:**
- Disconnect from Twingate (not needed on local network)
- Check WiFi (use 5GHz if available)
- Test with: `iperf3` between devices

### Twingate Issues

**After server reboot - connectors show green but can't connect:**

**Problem:** After rebooting Proxmox or home lab server, Twingate connectors show as "Connected" (green) in the admin console, but you can't access any resources (SSH, web UI, etc.).

**Cause:** Mac Twingate client has stale connection state and routing tables. Even though connectors reconnected successfully, the client hasn't refreshed its connection.

**Fix - Restart Twingate Client on Mac:**
```bash
# Method 1: Via command line
killall Twingate && open -a Twingate

# Method 2: Via menu bar
# Click Twingate icon → Quit → Reopen Twingate from Applications
```

**Important:** After restarting the client, it may take several minutes (5-10 min) to fully re-establish connections and routing. Be patient - the first connection attempt may timeout, but subsequent attempts will succeed once sync completes.

**Prevention:** After rebooting any home lab server, immediately restart your Mac Twingate client to force a fresh connection state.

---

**Connector not connecting:**
```bash
# Check container status
docker ps -a | grep twingate

# View logs
docker logs twingate-connector

# Restart connector
cd ~/setup
docker-compose restart

# Verify tokens in admin console
# https://jaded423.twingate.com
```

**Can't access resources:**
- Ensure Twingate app is connected on work Mac
- Check resources are assigned to your user
- Verify connector is online in admin console
- Try reconnecting Twingate app

### Google Drive Issues

**Mount not accessible:**
```bash
# Check service status
systemctl --user status rclone-gdrive.service
systemctl --user status rclone-elevated.service

# View logs
journalctl --user -u rclone-gdrive.service -n 50
journalctl --user -u rclone-elevated.service -n 50

# Restart services
systemctl --user restart rclone-gdrive.service
systemctl --user restart rclone-elevated.service
```

**Slow sync:**
- Check internet connection: `ping 8.8.8.8`
- Monitor cache in logs
- Large files take time to upload (normal)

### Ollama Issues

**Service not running:**
```bash
# Check service status
systemctl status ollama

# Restart service
sudo systemctl restart ollama

# View logs
journalctl -u ollama -f
```

**Model inference slow:**
```bash
# Verify GPU acceleration is active
lspci | grep -i vga

# Check CPU governor is in performance mode
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Monitor resource usage during inference
htop
# or
btop
```

**Out of memory errors:**
```bash
# Check available RAM and swap
free -h

# Check zram status
zramctl

# Try smaller model (1b or 2b instead of 7b)
ollama run llama3.2:1b
ollama run gemma2:2b
```

**Model not found:**
```bash
# List installed models
ollama list

# Pull model if missing
ollama pull modelname:tag
```

### CPU Watchdog Issues

**Check watchdog status:**
```bash
# Check if watchdog is running
systemctl status cpu-watchdog

# View recent watchdog actions
tail -f /var/log/cpu-watchdog.log

# Check current CPU usage
top -bn1 | grep "Cpu(s)"
```

**Watchdog suspended a VM:**
```bash
# List all VMs and their status
qm list

# Resume a suspended VM
qm resume <VMID>

# Check why it was suspended (high CPU)
grep "suspending" /var/log/cpu-watchdog.log
```

**Disable watchdog temporarily:**
```bash
# Stop watchdog service
systemctl stop cpu-watchdog

# Start it again
systemctl start cpu-watchdog
```

**Adjust CPU threshold:**
```bash
# Edit the script to change threshold from 90%
nvim /usr/local/bin/cpu-watchdog.sh

# Change CPU_THRESHOLD=90 to desired value
# Then restart the service
systemctl restart cpu-watchdog
```

### Desktop Environment Issues

**Waybar not appearing:**
```bash
# Check if running
pgrep waybar

# Restart waybar
killall waybar && waybar &

# Check for errors
waybar --log-level debug
```

**Wallpaper not changing:**
```bash
# Restart hyprpaper
killall hyprpaper && hyprpaper &

# Check config
cat ~/.config/hypr/hyprpaper.conf
```

**Reload Hyprland:**
```bash
hyprctl reload
```

### Known Issues

#### prox-tower Intel I218-LM NIC (e1000e driver)

**Problem:** The onboard Intel I218-LM NIC has a known bug with the e1000e driver. When TCP Segmentation Offload (TSO) is enabled, the NIC can experience hardware hangs that freeze the entire network stack, requiring a physical reboot.

**Symptoms:**
- Complete loss of SSH access
- Proxmox web UI unreachable
- Server unresponsive on network
- Occurred: Dec 11, 2025 ~10:57 AM; Dec 12, 2025 ~11:28 AM

**Fix Applied:**
```bash
# /etc/network/interfaces on prox-tower
iface nic0 inet manual
    post-up /usr/sbin/ethtool -K nic0 tso off gso off gro off
```

**Verification:**
```bash
ssh root@192.168.2.249 "ethtool -k nic0 | grep -E 'tcp-segmentation|generic-segmentation|generic-receive'"
# Should show: off for all three
```

**Planned Permanent Fix:** Replace with TP-Link TX201 (2.5GbE, Realtek RTL8125) which doesn't have this bug.

**Documentation:** `/root/nic-upgrade-tplink-tx201.md` on prox-tower

---

### Hardware Upgrades (prox-tower)

| Component | Previous | Current | Status |
|-----------|----------|---------|--------|
| **CPU** | Xeon E5-1620 v4 (4c/8t) | Intel Xeon E5-2683 V4 (16c/32t, 40MB cache) | Ordered |
| **NIC** | Intel I218-LM only (1GbE, buggy) | **Dual-NIC: Intel I218-LM + Realtek RTL8125 (2.5GbE)** | ✅ Installed Dec 13, 2025 |

**NIC Upgrade Complete (Dec 13, 2025):**
- Installed TP-Link TX201 (Realtek RTL8125 2.5GbE) as secondary NIC
- Intel I218-LM retained for management/Twingate/AMT (with TSO disabled)
- New NIC connected to main router's 2.5G port
- VM 101 migrated to 2.5GbE network for faster media streaming

**Upgrade Documentation:** `/root/nic-upgrade-tplink-tx201.md` on prox-tower

---

### Intel AMT / Out-of-Band Management (prox-tower)

**Intel AMT provides remote access even when Proxmox is frozen/crashed:**

**Status:** Available but not yet configured (requires physical monitor)

**To Configure AMT (one-time setup):**
1. Connect monitor to prox-tower (HDMI or DisplayPort)
2. Reboot: `ssh root@192.168.2.249 reboot`
3. Watch for "Press Ctrl+P to enter MEBx" during boot
4. Press **Ctrl+P** to enter MEBx setup
5. Default password: `admin` (must change on first login)
6. Configure:
   - Activate Network Access
   - Set static IP (recommended: 192.168.2.248)
   - Enable Remote KVM
   - Enable Serial-over-LAN
7. Save and exit

**After Configuration:**
- Access via web: `https://192.168.2.248:16993`
- Use MeshCommander: https://www.meshcommander.com/meshcommander
- Can remotely power on/off/reboot
- Can access KVM (keyboard/video/mouse) even when OS is frozen
- Add AMT IP as Twingate resource for remote access

**MagicMirror Kiosk Reset (Raspberry Pi 2):**

**Quick reset:**
```bash
ssh jaded@192.168.2.131 "~/reset-kiosk.sh"
```

**Manual restart if needed:**
```bash
# Kill existing processes
pkill -f chromium
pkill -f 'node.*server'

# Restart
~/kiosk.sh
```

**Check if running:**
```bash
ps aux | grep -E 'chromium|node.*server' | grep -v grep
curl http://localhost:8080  # Should return HTML
```

---

## Security Considerations

### Current Security Measures

1. **Firewall (UFW):**
   - Active with default deny policy
   - Only necessary ports open (22, 139, 445)

2. **SSH Security:**
   - Root login disabled
   - Public key authentication preferred
   - Key-based auth from work Mac configured

3. **Samba Security:**
   - No guest access
   - User authentication required
   - Passwords set separately from system passwords

4. **Twingate Zero Trust:**
   - No ports exposed to internet
   - Resource-based access control
   - User/device authentication required

5. **Sensitive Files:**
   - Twingate tokens: chmod 600
   - SSH keys: chmod 600
   - Service credentials secured

### Security Best Practices

**SSH:**
- Keep private keys secure on work Mac
- Use strong passwords as fallback
- Consider disabling password auth (keys only)
- Monitor SSH logs: `journalctl -u sshd -f`

**Samba:**
- Use strong Samba passwords
- Regularly review share permissions
- Monitor access logs

**Twingate:**
- Review connector logs regularly
- Audit user access in admin console
- Keep connector updated

**System:**
- Apply security updates promptly
- Review firewall rules monthly
- Monitor system logs for suspicious activity
- Backup sensitive configurations

---


## Changelog

**Full changelog archived**: See `backups/homelab-2025-12-09-23-22-35.md` for complete history.

### Recent Updates (Summary)

| Date | Change |
|------|--------|
| 2025-12-19 | **VM 101 CPU pinning:** Increased cores 12→14, added CPU affinity (cores 2-15,18-31), host reserves cores 0-1 |
| 2025-12-14 | **Plex migration:** Replaced Jellyfin with Plex, fixed Twingate route conflict causing NFS hangs |
| 2025-12-13 | **NFS storage expansion:** Set up cross-subnet NFS from book5 (847GB) to VM 101 for Jellyfin, moved 22GB movies |
| 2025-12-13 | **Hardware benchmarks:** Verified CPU upgrade (16c Xeon E5-2683 v4), 78GB RAM, 2.5GbE (1.36 Gbps confirmed) |
| 2025-12-13 | **Dual-NIC setup:** Installed Realtek RTL8125 2.5GbE, configured dual-network (management + primary) |
| 2025-12-13 | **VM 101 migration:** Moved from 192.168.2.126 to 192.168.1.126 on 2.5GbE network |
| 2025-12-12 | **Twingate migration:** Moved both hosts from LXC/Docker to native systemd services |
| 2025-12-12 | **NIC fix:** Disabled TSO/GSO/GRO on prox-tower Intel I218-LM to prevent hangs |
| 2025-12-12 | **Storage rename:** local-zfs → local-zfs-book5/local-zfs-tower for cluster clarity |
| 2025-12-12 | **Media pipeline:** qBit→ClamAV→Jellyfin automation, scan-and-move script, expanded VM storage 100GB→297GB |
| 2025-12-12 | **Major rebuild:** prox-tower LVM→ZFS conversion, VM 101 fresh Ubuntu Server (40GB RAM, 6 cores), 9 ollama models, 4 Docker containers |
| 2025-12-10 | Created phi4.16k custom Ollama model (14B @ 16K ctx), pre-loaded for commits |
| 2025-12-09 | VM 102 resource upgrade: RAM 20→40GB, cores 3→6, swap 44→20GB |
| 2025-12-03 | Twingate connector architecture overhaul - moved to LXC containers |
| 2025-12-02 | Intel AMT discovery on prox-tower, QDevice quorum setup |
| 2025-12-01 | 2-node Proxmox cluster creation, VM migration to prox-tower |
| 2025-11-29 | Migrated from bare-metal CachyOS to Proxmox VE |
| 2025-11-28 | Personal router setup (192.168.2.x subnet) |

### 2025-12-14 - Plex Migration & Twingate Route Fix

**Jellyfin → Plex Migration:**
- Removed Jellyfin container and volumes (user had ongoing stability issues)
- Installed Plex (`lscr.io/linuxserver/plex:latest`) via docker-compose
- Plex accessible at `http://192.168.1.126:32400/web`

**Twingate Route Conflict (Critical Fix):**
- **Problem:** NFS mounts hanging, Docker containers wouldn't start
- **Root cause:** Twingate added host route `192.168.1.126 dev sdwan0` that overrode our network route
- Traffic was going through Twingate cloud (980ms latency!) instead of direct LAN (0.5ms)
- **Solution:** Created systemd service + cron job on book5 to override Twingate's route

**Files Created on book5:**
- `/etc/systemd/system/fix-vm101-route.service` - Runs after Twingate, fixes route
- `/etc/cron.d/fix-vm101-route` - Runs every 5 minutes as backup

**Route Fix Details:**
```bash
# Removes Twingate route, adds direct route
ip route del 192.168.1.126 dev sdwan0
ip route add 192.168.1.126 via 192.168.2.249 dev vmbr0
```

**Docker Compose Updated (VM 101):**
- `~/docker/docker-compose.yml` now uses Plex instead of Jellyfin
- Same volume mounts: `/home/jaded/media:/media` and `/mnt/book5-media:/media/book5`

**Impact:**
- Plex running stably (Jellyfin had persistent issues)
- NFS mount reliable with Twingate route override in place
- Media server accessible for streaming Star Wars collection

---

### 2025-12-13 - NFS Storage Expansion & Hardware Benchmarks

**Hardware Verification (prox-tower upgrades):**
- **CPU:** Intel Xeon E5-2683 v4 (16 cores, 32 threads @ 2.1GHz) - confirmed
- **RAM:** 78GB on host, 40GB allocated to VM 101 - confirmed
- **NIC:** 2.5GbE working - speed test showed **1.36 Gbps download** (ISP is bottleneck, not hardware)

**NFS Storage Setup (cross-subnet):**
- Created `/srv/media` on prox-book5 with **847GB available**
- Configured NFS export to 192.168.1.0/24 and 192.168.2.0/24 networks
- **Challenge:** VM 101 (192.168.1.126) couldn't reach book5 (192.168.2.250) - different subnets
- **Solution:** Set up routing through prox-tower (has interfaces on both networks):
  - Added iptables forwarding rules on prox-tower (vmbr0 ↔ vmbr1)
  - Added route on VM 101: `192.168.2.0/24 via 192.168.1.249` (persistent in netplan)
  - Added route on book5: `192.168.1.0/24 via 192.168.2.249`
- Mounted NFS on VM 101 at `/mnt/book5-media` (persistent in fstab)

**Jellyfin Docker Compose:**
- Created `~/docker/docker-compose.yml` on VM 101 for easier management
- Added new volume: `/mnt/book5-media:/media/book5`
- Migrated from `docker run` to `docker compose` for future maintainability

**Media Migration:**
- Moved **22GB of Star Wars movies** (9 films) from VM 101 to book5
- Transfer speed: ~380 MB/s over NFS
- Movies now accessible in Jellyfin at `/media/book5/Movies`
- TV Shows remain on VM 101 local storage

**Files Changed:**
- `/etc/exports` on book5 - NFS export configuration
- `/etc/netplan/00-installer-config.yaml` on VM 101 - added route to 192.168.2.0/24
- `/etc/network/interfaces` on book5 - added route to 192.168.1.0/24
- `/etc/network/if-pre-up.d/iptables-nfs` on prox-tower - iptables forwarding rules
- `~/docker/docker-compose.yml` on VM 101 - Jellyfin with NFS mount

**Impact:**
- VM 101 now has 847GB additional storage via NFS from book5
- Jellyfin can serve media from both local and NFS storage
- Future movies/media can go on book5, leaving VM 101 for shows and services

---

### 2025-12-13 - Dual-NIC Setup & VM Migration to 2.5GbE

**Hardware Installed:**
- TP-Link TX201 PCIe NIC (Realtek RTL8125 chipset)
- 2.5 Gbps Full Duplex, connected to main router's 2.5G port

**Network Configuration:**
- **vmbr0** (Intel I218-LM, 1GbE) @ 192.168.2.249
  - Management network, Twingate connector, future AMT
  - No default gateway (management only)
- **vmbr1** (Realtek RTL8125, 2.5GbE) @ 192.168.1.249
  - Primary network for VMs and fast traffic
  - Default gateway: 192.168.1.1 (main router)

**VM 101 Migration:**
- Changed VM network bridge: vmbr0 → vmbr1
- Updated IP: 192.168.2.126 → 192.168.1.126
- Updated gateway: 192.168.2.1 → 192.168.1.1
- Now benefits from 2.5 Gbps for Jellyfin media streaming

**Files Changed:**
- `/etc/network/interfaces` on prox-tower (added vmbr1 bridge)
- `/etc/netplan/00-installer-config.yaml` on VM 101 (new IP/gateway)
- `~/.ssh/config` on Mac (updated VM 101 to 192.168.1.126)
- Added prox-tower-fast alias for 192.168.1.249 SSH access

**Impact:**
- Media streaming now uses 2.5 Gbps link (was 1 Gbps)
- Remote access unchanged (Twingate still uses 192.168.2.249)
- SSH to VM 101 via ProxyJump through management network works seamlessly

---

### 2025-12-12 - Twingate Systemd Migration & NIC Fix

**Problem Investigated:**
- prox-tower lost SSH and Proxmox web UI access twice (Dec 11 ~10:57 AM, Dec 12 ~11:28 AM)
- Root cause: Intel I218-LM onboard NIC experiencing hardware hangs (e1000e driver TSO bug)

**Twingate Issues:**
- Docker container stuck in `Offline → Authentication → Error` loop since Dec 3
- Root cause: Connector was unregistered from Twingate admin console
- Solution: Migrated from Docker/LXC containers to native systemd services on both hosts

**Changes Made:**

**prox-tower (192.168.2.249):**
- Added `post-up /usr/sbin/ethtool -K nic0 tso off gso off gro off` to `/etc/network/interfaces`
- Removed Docker container `twingate-prox-tower`
- Removed LXC 201 (twingate-tower)
- Installed Twingate systemd service on host
- Updated VM 101 config: `local-zfs:` → `local-zfs-tower:`

**prox-book5 (192.168.2.250):**
- Installed Twingate systemd service on host (via SSH from tower)
- Removed LXC 200 (twingate-connector)
- Updated VM 100 config: `local-zfs:` → `local-zfs-book5:`

**Cluster-wide:**
- Renamed storage in `/etc/pve/storage.cfg`:
  - `local-zfs` (book5) → `local-zfs-book5`
  - `local-zfs` (tower) → `local-zfs-tower`

**Files Created on prox-tower:**
- `/root/twin-connect-systemd.md` - Twingate systemd setup instructions
- `/root/nic-upgrade-tplink-tx201.md` - Network card upgrade instructions

**Pending Hardware Upgrades:**
- CPU: Intel Xeon E5-2683 V4 (16 core)
- NIC: TP-Link TX201 (2.5GbE, Realtek RTL8125)

---

### 2025-12-12 - Media Pipeline Setup & Storage Expansion

**Changes:**
- Set up automated media scanning pipeline: qBittorrent → ClamAV → Jellyfin
- Recreated containers with proper volume mounts:
  - qBittorrent: Added `/media` mount for direct media folder access
  - ClamAV: Added `/scan/downloads` and `/scan/media` mounts
- Created `/home/jaded/scripts/scan-and-move.sh`:
  - Scans completed downloads with ClamAV (via `docker exec clamdscan`)
  - Auto-sorts into Movies, TV Shows, or Music based on filename patterns
  - Quarantines infected files to `/home/jaded/quarantine/`
  - Detection: S01E01/1x01 → TV Shows, .mp3/.flac → Music, else → Movies
- Set up cron job: `*/10 * * * *` runs scan-and-move every 10 minutes
- Expanded Ubuntu VM LVM storage from 100GB → 297GB (full disk allocation)
- Explained ZFS refreservation (thick provisioning) vs actual data usage

**Files created:**
- `/home/jaded/scripts/scan-and-move.sh` - Media scanning and sorting script
- `/home/jaded/scripts/scan.log` - Scan activity log

**Impact:**
- Downloads automatically scanned for viruses before reaching Jellyfin
- Media auto-sorted into correct folders (Movies/TV Shows/Music)
- VM now has 204GB free (was 30GB) - room for large media downloads

---

### 2025-12-12 - prox-tower Storage Conversion & VM 101 Rebuild

**Changes:**
- Converted prox-tower storage from LVM-thin to ZFS (rpool-tower, ~370GB)
- Recreated CT 201 (twingate-tower) LXC container with Twingate connector
- Built new VM 101 (ubuntu-server) replacing VM 102:
  - Ubuntu Server 24.04 @ 192.168.2.126
  - 40GB RAM, 6 cores, 300GB disk
  - UEFI boot with auto-start enabled
- Installed Docker with 4 containers:
  - open-webui (port 3000) - Ollama web interface
  - jellyfin (port 8096) - media server
  - qbittorrent (port 8080) - torrent client
  - clamav - antivirus scanner
- Installed ollama with 9 models:
  - phi4:14b, llama3.2:3b, qwen2.5-coder:7b (priority 1-2)
  - deepseek-coder:6.7b, qwen2.5:7b, qwen3:14b, phi3.5:3.8b
  - gemma2:2b, llama3.2:1b (lightweight)
- Restored configs from backup: .zshrc, .p10k.zsh, nvim, rclone
- Installed oh-my-zsh + powerlevel10k theme
- Created media folder structure: ~/media/{Movies,TV Shows,Music,Photos}
- Configured passwordless sudo for jaded user

**Impact:**
- ZFS storage provides better snapshots and data integrity
- VM 101 has more resources than previous VM 102 (40GB vs 20GB RAM, 6 vs 3 cores)
- All services restored and running
- Twingate connector online for remote access

**Note:** Docker volume backups from old VM were corrupted; containers set up fresh

---

## Related Documentation

**Server-side:**
- `~/README.md` - Primary server setup documentation
- `~/setup/README.md` - Setup scripts documentation
- `~/.config/hypr/` - Hyprland configuration
- `~/.config/systemd/user/` - User service files
- `~/rustdesk-setup.md` - RustDesk configuration

**Work Mac:**
- `~/.claude/CLAUDE.md` - Global Claude documentation
- `~/.claude/docs/interconnections.md` - System dependency map
- `~/.claude/docs/homelab-expansion.md` - Future expansion plans
- `~/.ssh/config` - SSH client configuration

**External Resources:**
- [Twingate Docs](https://docs.twingate.com/)
- [Twingate Admin Console](https://jaded423.twingate.com)
- [CachyOS Documentation](https://wiki.cachyos.org/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [rclone Documentation](https://rclone.org/docs/)

---

## Quick Reference

### Connection Info
```
IP Address: 192.168.2.250
User: jaded
SSH: ssh jaded@192.168.2.250
Samba: smb://192.168.2.250/Shared
Twingate: jaded423
Pi-hole: 192.168.2.131
```

### Service Status Commands
```bash
systemctl status sshd smb              # Check services
systemctl status ollama                # Check Ollama
docker ps                              # Check containers
systemctl --user status rclone-*       # Check Drive mounts
sudo ufw status                        # Check firewall
```

### Log Viewing
```bash
journalctl -u sshd -f                  # SSH logs
journalctl -u smb -f                   # Samba logs
journalctl -u ollama -f                # Ollama logs
docker logs -f twingate-connector      # Twingate logs
journalctl --user -u rclone-gdrive -f  # Google Drive logs
```

### Important Paths
```
Setup scripts:     ~/setup/
Samba share:       /srv/samba/shared/
Hyprland config:   ~/.config/hypr/
Google Drives:     ~/GoogleDrive/ and ~/elevatedDrive/
Ollama models:     /usr/share/ollama/.ollama/models/
Systemd services:  ~/.config/systemd/user/
```

---

## GPU Passthrough Setup (In Progress)

**Started:** December 19, 2025
**Status:** Waiting for BIOS VT-d enable (requires physical access)

### What's Done

1. ✅ **GRUB configured:** `intel_iommu=on iommu=pt` added to kernel params
2. ✅ **Nouveau blacklisted:** `/etc/modprobe.d/blacklist-nouveau.conf`
3. ✅ **VFIO configured:** `/etc/modprobe.d/vfio.conf` with GPU IDs `10de:13f1,10de:0fbb`
4. ✅ **Initramfs updated:** All kernels regenerated
5. ✅ **VFIO modules loading:** Confirmed `vfio_pci` loaded at boot

### Remaining Steps (When Home)

**Step 1: Enable VT-d in BIOS**
1. Reboot prox-tower, press **F1** during POST
2. Navigate to: **Security** → **Virtualization**
3. Enable **Intel VT-d Feature**
4. Save and exit (F10)

**Step 2: Verify IOMMU Groups**
```bash
ssh root@192.168.2.249 "dmesg | grep -i dmar | head -10"
# Should show: DMAR: Intel(R) Virtualization Technology for Directed I/O

# Check GPU is in its own IOMMU group
ssh root@192.168.2.249 "bash -c 'for g in /sys/kernel/iommu_groups/*/; do for d in \$g/devices/*; do echo \"\$(basename \$g): \$(lspci -nns \$(basename \$d))\"; done; done' | grep -i nvidia"
```

**Step 3: Verify GPU bound to vfio-pci**
```bash
ssh root@192.168.2.249 "lspci -nnk -s 01:00"
# Should show: Kernel driver in use: vfio-pci
```

**Step 4: Add GPU to VM 101**
```bash
# Option A: Via Proxmox Web UI
# VM 101 → Hardware → Add → PCI Device → Select 01:00.0 (Quadro M4000)
# Check "All Functions" to include audio device

# Option B: Via command line
ssh root@192.168.2.249 "qm set 101 -hostpci0 01:00,pcie=1"
```

**Step 5: Start VM and Install NVIDIA Drivers**
```bash
# Start VM
ssh root@192.168.2.249 "qm start 101"

# Wait for boot, then SSH to VM
ssh jaded@192.168.1.126

# Install NVIDIA drivers (in VM)
sudo apt update
sudo apt install -y nvidia-driver-535 nvidia-utils-535

# Reboot VM
sudo reboot
```

**Step 6: Verify GPU in VM**
```bash
ssh jaded@192.168.1.126 "nvidia-smi"
# Should show: Quadro M4000, 8GB VRAM
```

**Step 7: Configure Ollama for GPU**
```bash
# Ollama auto-detects NVIDIA GPUs, just restart it
ssh jaded@192.168.1.126 "sudo systemctl restart ollama"

# Test GPU inference
ssh jaded@192.168.1.126 "ollama run llama3.2:3b 'Hello, are you using GPU?' --verbose"
# Look for: "gpu" in the output stats
```

### GPU Specs (NVIDIA Quadro M4000)

- **VRAM:** 8GB GDDR5
- **CUDA Cores:** 1,664
- **Architecture:** Maxwell (GM204)
- **Expected speedup:** 10-20x for models ≤7B, 3-5x for 14B models

### Troubleshooting

**GPU not showing in VM:**
```bash
# Check if GPU is bound to vfio-pci on host
lspci -nnk -s 01:00

# If still using nouveau, manually unbind and rebind
echo "0000:01:00.0" > /sys/bus/pci/drivers/nouveau/unbind
echo "0000:01:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
```

**nvidia-smi not working in VM:**
```bash
# Check if GPU is visible
lspci | grep -i nvidia

# Check driver loaded
lsmod | grep nvidia

# Reinstall drivers if needed
sudo apt install --reinstall nvidia-driver-535
```

