# Home Lab Documentation

**Primary Server:** Proxmox VE @ 192.168.2.250 (formerly cachyos-jade)
**Last Updated:** November 29, 2025 (Major infrastructure migration to Proxmox with VM-based architecture)

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

**🎉 MAJOR UPDATE (Nov 28-29, 2025):** Migrated from bare-metal CachyOS to Proxmox VE with VM-based architecture!

### Network Architecture

**Router Configuration:** Personal router added to bypass Spectrum limitations
- **Network Subnet:** 192.168.2.0/24 (changed from 192.168.1.x)
- **Purpose:** Enable Pi-hole DNS and full network control
- **Gateway:** 192.168.2.1

### Active Devices

| Device | IP Address | Purpose | Power Usage | Status |
|--------|------------|---------|-------------|---------|
| **Proxmox Host** | 192.168.2.250 | Type 1 hypervisor (3 VMs) | 50-100W | ✅ Active |
| **└─ VM 100: Omarchy** | (bridged) | Arch Linux desktop (DHH's Omarchy distro) | - | ✅ Auto-start |
| **└─ VM 101: Ubuntu Desktop** | (bridged) | Ubuntu 24.04 Desktop with GPU passthrough | - | ⚠️ Manual start |
| **└─ VM 102: Ubuntu Server** | 192.168.2.126 | Ubuntu 24.04 Server (all services) | - | ✅ Auto-start |
| **Raspberry Pi 2** | 192.168.2.131 | Pi-hole DNS, Twingate backup, MagicMirror kiosk | 3-4W | ✅ Active |

**Total Power:** ~55-105W (~$8-16/month electricity)

### Architecture Diagram

```
New Proxmox-Based Homelab Infrastructure (Nov 2025)
│
├── Proxmox VE Host @ 192.168.2.250 (Samsung Galaxy Book5 Pro)
│   ├── Hardware: 16GB RAM, Intel Arc GPU, 952GB NVMe
│   ├── ZFS RAID0 storage
│   ├── IOMMU/VT-d enabled for GPU passthrough
│   ├── Lid-close handling (stays running, screen off)
│   │
│   ├── VM 100: Omarchy Desktop (8GB RAM, 4 cores, 120GB disk)
│   │   ├── SeaBIOS boot (legacy BIOS for compatibility)
│   │   ├── VirtIO display (accessible via Proxmox web console)
│   │   ├── Arch Linux + Hyprland (DHH's Omarchy distro)
│   │   ├── SSH enabled (remote access via jaded@192.168.2.161)
│   │   ├── Auto-mount Samba share with Google Drive access (via fstab)
│   │   └── Auto-starts on boot ✅
│   │
│   ├── VM 101: Ubuntu Desktop 24.04 (8GB RAM, 4 cores, 120GB disk)
│   │   ├── UEFI boot
│   │   ├── Intel Arc GPU passthrough (displays on laptop screen)
│   │   ├── Kernel 6.14 with Intel Arc drivers
│   │   ├── ⚠️ GPU display works, keyboard/mouse needs USB passthrough
│   │   └── Manual start (not needed for server operations)
│   │
│   └── VM 102: Ubuntu Server 24.04 @ 192.168.2.126 (6GB RAM, 3 cores, 200GB disk)
│       ├── UEFI boot, SSH enabled
│       ├── Docker + All Services:
│       │   ├── Twingate connector (secure remote access)
│       │   ├── Jellyfin media server (port 8096)
│       │   ├── qBittorrent torrent client (port 8080)
│       │   ├── ClamAV antivirus (port 3310)
│       │   ├── Open WebUI (Ollama interface, port 3000)
│       │   └── Ollama with 10 LLMs (port 11434, ~47GB models)
│       ├── Samba file sharing (ports 445, 139) with Google Drive access ✅
│       ├── rclone + Google Drive mounts (2 accounts, auto-mount on boot) ✅
│       └── Auto-starts on boot ✅
│
└── Raspberry Pi 2 @ 192.168.2.131
    ├── Pi-hole DNS (network-wide ad blocking)
    ├── Twingate connector (backup)
    ├── Portainer (Docker UI, port 9000)
    ├── Homarr dashboard (port 7575)
    └── MagicMirror kiosk (port 8080, 6x4" touchscreen)
        ├── Weather (Wylie, TX)
        ├── Pi system stats (°C)
        ├── Server stats via SSH (°C)
        └── Pi-hole query stats
```

**Future Expansion:**
- [homelab-expansion.md](homelab-expansion.md) - Planned single-site upgrades and completed milestones
- [homelab-multi-site-expansion.md](homelab-multi-site-expansion.md) - Multi-site Proxmox architecture with CompTIA certification learning path

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

**Access from Work Mac:**
```bash
ssh jaded@192.168.2.250
```

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
**Deployment:** Docker container with host networking
**Network:** jaded423
**Status Check:** `docker ps | grep twingate`

**Configuration Files:**
- `~/setup/docker-compose.yml` - Container config
- `~/setup/.env` - Access tokens (sensitive, chmod 600)
- `~/setup/twingate-tokens.sh` - Token export script

**Container Settings:**
- Network mode: host
- Log level: 3 (debug)
- Auto-restart: enabled
- Image: twingate/connector:latest

**Service Management:**
```bash
cd ~/setup
docker-compose ps              # Check status
docker-compose restart         # Restart connector
docker-compose logs -f         # View logs
docker-compose pull            # Update to latest version
docker-compose up -d           # Start with new version
```

**Admin Console:** https://jaded423.twingate.com

**Setup Script:** `~/setup/install-twingate-docker.sh`

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

### rclone FUSE Mounts

**Tool:** rclone with VFS caching
**Mount Type:** FUSE (Filesystem in Userspace)

### First Drive (Personal)

**Remote Name:** gdrive
**Mount Point:** `/home/jaded/GoogleDrive/`
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

### Second Drive (Elevated)

**Remote Name:** elevated
**Mount Point:** `/home/jaded/elevatedDrive/`
**Service:** `~/.config/systemd/user/rclone-elevated.service`

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

### Usage

**Access mounted drives:**
```bash
ls ~/GoogleDrive/       # First drive
ls ~/elevatedDrive/     # Second drive

# Copy files to either drive
cp file.txt ~/GoogleDrive/
cp document.pdf ~/elevatedDrive/

# Edit files directly (changes sync automatically)
nano ~/GoogleDrive/document.txt
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

### 2025-11-29 - Git Backup Scripts Updated for Proxmox Architecture

**Changes:**
- Updated `~/scripts/bin/ollamaSummary.py` to connect to VM 102 (192.168.2.126) instead of Proxmox host
- Updated `~/scripts/bin/gitBackup.sh` SSH connections to target Ubuntu Server VM at 192.168.2.126
- Added `.update.lock` to scripts/.gitignore to prevent spurious backup triggers
- Scripts now correctly target the VM running Ollama service (VM 102)

**Impact:**
- Git backup automation now works with Proxmox architecture
- AI-powered commit message generation restored (connects to correct Ollama instance)
- Eliminates false backup triggers from Claude Code lock files
- All automated backup scripts operational again

**Technical Details:**
- Changed OLLAMA_SERVER from `jaded@192.168.2.250` to `jaded@192.168.2.126`
- Updated all SSH health checks in gitBackup.sh to use VM 102 IP
- Server memory/disk checks now query Ubuntu Server VM, not Proxmox host

**Files Modified:**
- `~/scripts/bin/ollamaSummary.py` (line 28)
- `~/scripts/bin/gitBackup.sh` (lines 55, 67, 71, 77)
- `~/scripts/.gitignore` (added .update.lock)

---

### 2025-11-29 - Google Drive Integration & VM Automount Complete

**Changes:**
- ✅ Completed rclone installation on VM 102 (Ubuntu Server)
- ✅ Restored Google Drive OAuth tokens from backup
- ✅ Configured `--allow-other` flag for rclone FUSE mounts (enables Samba access)
- ✅ Both Google Drive accounts now accessible via Samba:
  - Personal: `smb://192.168.2.126/Shared/GoogleDrive`
  - Work: `smb://192.168.2.126/Shared/ElevatedDrive`
- ✅ Enabled SSH on VM 100 (Omarchy) for remote troubleshooting
- ✅ Configured automatic Samba mount on VM 100 via /etc/fstab
- ✅ Google Drive access verified and auto-mounts on reboot

**Impact:**
- VM 100 (Omarchy) can now access both Google Drive accounts through Samba
- Auto-mount configured - share available immediately after boot
- Single rclone instance serves multiple VMs (no duplicate OAuth tokens needed)
- All changes persist across VM reboots

**Technical Details:**
- rclone services updated with `--allow-other` flag
- /etc/fuse.conf configured with `user_allow_other`
- VM 100 fstab configured with credentials file and systemd automount
- Home directory permissions adjusted for symlink traversal

---

### 2025-11-29 - Major Infrastructure Migration to Proxmox VE

**BREAKING CHANGE:** Migrated entire home lab from bare-metal CachyOS to Proxmox VE 9.1 hypervisor with VM-based architecture.

**Migration Timeline:** November 28-29, 2025 (started 6:00 PM CST Nov 28, completed 2:00 AM CST Nov 29)

**What Changed:**
- **Hypervisor:** Replaced CachyOS Linux with Proxmox VE 9.1 (Debian Trixie-based)
- **Architecture:** Migrated from bare-metal to Type 1 hypervisor with 3 VMs
- **Storage:** ZFS RAID0 filesystem (952GB NVMe)
- **Networking:** Ethernet via ThinkPad dock (WiFi Intel BE201 unsupported by Proxmox kernel)
- **GPU:** Intel Arc configured for VFIO passthrough (available to VMs)
- **IP Address:** Unchanged (192.168.2.250) for seamless network integration

**New Infrastructure:**

**Proxmox Host:**
- Version: Proxmox VE 9.1-1
- Filesystem: ZFS RAID0
- IOMMU: Enabled (`intel_iommu=on iommu=pt`)
- GPU Passthrough: vfio-pci drivers loaded for Intel Arc (8086:64a0)
- Power Management: Lid close ignored (server stays running, screen turns off)
- Auto-start VMs: Configured for VM 100 and VM 102

**VM 100 - Omarchy Desktop:**
- OS: Omarchy (DHH's Arch Linux + Hyprland distro)
- Specs: 8GB RAM, 4 cores, 120GB disk
- Boot: SeaBIOS (legacy BIOS for bootloader compatibility)
- Display: VirtIO (accessible via Proxmox web console)
- SSH: Enabled (jaded@192.168.2.161)
- Samba: Auto-mount configured via fstab with Google Drive access
- Purpose: Desktop environment experimentation
- Status: ✅ Working, auto-starts on boot

**VM 101 - Ubuntu Desktop 24.04:**
- OS: Ubuntu Desktop 24.04 LTS
- Specs: 8GB RAM, 4 cores, 120GB disk, UEFI boot
- Display: Intel Arc GPU passthrough (shows on laptop physical screen)
- Drivers: Kernel 6.14 with Intel Arc graphics drivers
- Known Issues: GPU displays correctly but keyboard/mouse non-functional (requires USB controller passthrough)
- Purpose: Desktop environment with GPU acceleration
- Status: ⚠️ Partial (display works, input doesn't), manual start

**VM 102 - Ubuntu Server 24.04:**
- OS: Ubuntu Server 24.04 LTS
- Specs: 6GB RAM, 3 cores, 200GB disk, UEFI boot
- IP: 192.168.2.126 (DHCP, can be made static later)
- SSH: Enabled with public key authentication
- Purpose: All server services (Docker, Ollama, file sharing)
- Status: ✅ Working, auto-starts on boot

**Services Migrated to Ubuntu Server VM:**

**Docker Containers (All Restored):**
- ✅ Twingate connector - Secure remote access (from backup docker-compose)
- ✅ Jellyfin - Media server on port 8096 (new deployment)
- ✅ qBittorrent - Torrent client on port 8080 (new deployment)
- ✅ ClamAV - Antivirus scanner on port 3310 (new deployment)
- ✅ Open WebUI - Ollama web interface on port 3000 (new deployment)

**Ollama LLM Service:**
- ✅ Installed and running on port 11434
- ✅ All 10 models pulled successfully (~47GB total):
  - llama3.2:1b, gemma2:2b, llama3.2:3b, phi3.5:3.8b
  - deepseek-coder:6.7b, qwen2.5:7b, qwen2.5-coder:7b
  - phi4:14b, qwen3:14b, tavernari/git-commit-message:sp_commit_pro
- Note: CPU-only inference (no GPU acceleration in VM currently)

**File Sharing:**
- ✅ Samba installed and configured
- ✅ Config restored from CachyOS backup
- ✅ Share symlinks created (Music, Pictures, Documents, Videos, GoogleDrive, ElevatedDrive)
- ⚠️ **Pending:** Samba password needs to be set (`sudo smbpasswd -a jaded` on VM 102)

**Google Drive Integration:**
- ✅ rclone v1.72.0 installed
- ✅ OAuth tokens restored from backup
- ✅ Both Google Drive accounts mounted (gdrive and elevated)
- ✅ Systemd services configured for auto-mount on boot
- ✅ Accessible to other VMs via Samba symlinks

**Pending Tasks:**
- ⏳ Static IP configuration for Ubuntu Server (currently DHCP at .126)
- ⏳ Firewall configuration (UFW with appropriate ports)
- ⏳ Ubuntu Desktop input fix (USB controller passthrough)

**What Was Backed Up (Before Migration):**
- All configuration files saved to Google Drive (`server files/` directory)
- Complete restoration guide created: `RESTORATION-GUIDE.md`
- Backup includes: Twingate configs, SSH keys, rclone OAuth tokens, Samba config, systemd services, Hyprland configs

**Benefits of New Architecture:**
- **Isolation:** Services isolated in VMs for better security and stability
- **Flexibility:** Can run multiple OSes simultaneously (Arch + Ubuntu)
- **Snapshots:** ZFS allows instant VM snapshots for backups
- **Learning:** Hands-on Proxmox experience for homelab skills
- **GPU Passthrough:** Ability to dedicate GPU to specific VMs
- **Scalability:** Easy to add more VMs or adjust resources

**Migration Challenges Solved:**
- WiFi unavailable → Used Ethernet via ThinkPad dock
- Omarchy UEFI bootloader issues → Switched to SeaBIOS
- GPU passthrough display conflicts → Removed VirtIO when using GPU
- Ollama models → Background download completed successfully overnight

**Performance Impact:**
- Minimal overhead from Proxmox (Type 1 hypervisor, bare-metal performance)
- Services running identically to before (Docker containers, Ollama, etc.)
- ZFS provides data integrity and snapshot capabilities
- Total VM allocation: 22GB RAM, 11 cores, 440GB disk (host has 16GB RAM, 8 cores, 952GB)

**Access Methods:**
- **Proxmox Web UI:** https://192.168.2.250:8006
- **SSH to Ubuntu Server:** `ssh jaded@192.168.2.126`
- **SSH to Proxmox Host:** `ssh root@192.168.2.250`
- **SSH to Omarchy:** `ssh jaded@192.168.2.161`
- **Omarchy:** Via Proxmox web console (VM 100 → Console)
- **All services:** Same ports as before (Jellyfin 8096, qBittorrent 8080, Ollama 11434, etc.)

**Files Created:**
- `/Users/joshuabrown/Library/CloudStorage/GoogleDrive-jaded423@gmail.com/My Drive/server files/RESTORATION-GUIDE.md`
- `/Users/joshuabrown/Library/CloudStorage/GoogleDrive-jaded423@gmail.com/My Drive/server files/PROXMOX-INSTALL-CHECKLIST.md`

**Documentation Updated:**
- `~/.claude/docs/homelab.md` (this file)
- `~/.claude/docs/projects.md` - Updated homelab entry

**Impact:**
- ✅ Server running 24/7 with all critical services restored
- ✅ Twingate remote access working
- ✅ All Docker containers operational
- ✅ Ollama with full model library ready
- ✅ Auto-start configured for essential VMs
- ✅ rclone and Google Drive mounts operational
- ⚠️ Some manual tasks remain (Samba password, static IP, firewall)

**What's Next:**
- Set Samba password on Ubuntu Server (`sudo smbpasswd -a jaded`)
- Configure firewall on Ubuntu Server
- Set static IP for predictable addressing
- Fine-tune GPU passthrough for Ubuntu Desktop input
- Consider Proxmox backup strategy (PBS or simple snapshots)

---

### 2025-11-25 - Ollama Model Update & Open WebUI

**Changes:**
- Installed Open WebUI for web-based model interaction (port 3000)
- Installed new high-quality 14B parameter models:
  - `phi4:14b` - Now default for git commit message generation
  - `qwen3:14b` - General reasoning and chat
  - `tavernari/git-commit-message:sp_commit_pro` - Specialized commit model
- Conducted comparative testing of three models for commit message quality
- Updated `~/scripts/bin/ollamaSummary.py` to use phi4:14b as default model

**Impact:**
- Better quality AI-generated git commit messages
- Open WebUI provides easy browser-based access to all models
- phi4:14b selected as best model for automation (clean output, accurate conventional commit format)
- qwen3:14b available but has "thinking" output mode not ideal for automation

**Testing Results:**
- phi4:14b: 9/10 - Clean output, excellent terminology, proper formatting
- tavernari/sp_commit_pro: 8/10 - Good but minor terminology issues
- qwen3:14b: 3/10 - Unusable for automation (outputs thousands of "thinking" tokens)

### 2025-11-24 - Raspberry Pi 2 Memory and SSH Configuration

**Changes:**
- Increased swap file from 512MB to 4GB on Raspberry Pi 2
- Configured CONF_SWAPSIZE=4096 and CONF_MAXSWAP=4096 in /etc/dphys-swapfile
- Set up SSH key authentication from Mac to Pi (jaded@192.168.2.131)
- Added Mac's ED25519 public key to Pi's authorized_keys

**Impact:**
- MagicMirror and other services have significantly more virtual memory available
- Improved performance for memory-intensive operations
- Passwordless SSH access now enabled from Mac to Pi
- Easier remote management and automation capabilities

**Configuration details:**
- Swap: 4GB at /var/swap (was 512MB)
- SSH: ED25519 key authentication enabled
- User: jaded@192.168.2.131

### 2025-11-23 - Consolidated Infrastructure & Documentation Unification

**Changes:**
- Consolidated Raspberry Pi infrastructure - Pi 1 B+ decommissioned
- Pi 2 now hosts Pi-hole DNS, Twingate backup, Portainer, Homarr, and MagicMirror
- Added MagicMirror kiosk dashboard with touchscreen display
- Network moved to 192.168.2.x subnet with personal router for full control
- Added new services: Odoo 17, RustDesk, Portainer, Homarr
- Unified documentation between Mac and server versions
- Created separate homelab-expansion.md for future plans

**Impact:**
- Simpler infrastructure with one less device to maintain
- Pi-hole DNS now working properly with personal router
- Better service consolidation on Pi 2
- Documentation now consistent across both machines

### 2025-11-17 - Fixed Twingate Remote Access with Power Management

**Changes:**
- Diagnosed and fixed automatic suspend causing Twingate disconnections
- Configured `/etc/systemd/logind.conf` to disable idle suspend (`IdleAction=ignore`)
- Created systemd service: `/etc/systemd/system/prevent-suspend.service`
- Service uses `systemd-inhibit` to actively block all sleep/suspend/idle actions
- Enabled prevent-suspend service to auto-start on boot

**Impact:**
- **Server stays always-on** - No more automatic suspension after idle periods
- **Twingate accessible 24/7** - Remote access works from anywhere, not just local network
- **Suspend blocked by default** - Active inhibitor lock prevents unintended sleep
- **Boot-persistent** - Configuration and service survive reboots
- **Manual override available** - Can still suspend manually with `systemctl suspend -i`

**Root Cause:**
Server was auto-suspending after idle periods. When suspended, Twingate connector went offline, making remote access fail. The issue was caused by systemd's default idle action (suspend after 30min).

**Files created:**
- `/etc/systemd/system/prevent-suspend.service` - Systemd service that runs systemd-inhibit to block sleep

**Files modified:**
- `/etc/systemd/logind.conf` - Added `IdleAction=ignore` to prevent automatic idle suspend

### 2025-11-16 - Automated Lid Monitor for Screen Power Management

**Changes:**
- Created systemd user service for monitoring laptop lid state
- Implemented automatic screen power management via Hyprland DPMS
- Service monitors `/proc/acpi/button/lid/LID0/state` and controls screen power

**Impact:**
- **Lid closed:** Screen turns off automatically (DPMS off), reducing power consumption
- **Lid open:** Screen turns back on automatically (DPMS on)
- System stays powered on regardless of lid state (no suspend/hibernate)
- Eliminates unnecessary screen power draw when laptop is closed as a server
- Service auto-starts on boot and runs continuously in background

**Files created:**
- `~/.config/systemd/user/lid-monitor.service` - Systemd user service definition
- `~/.config/hypr/scripts/lid-monitor.sh` - Bash script that monitors lid state and controls screen

**Technical details:**
- Polling interval: 1 second (minimal CPU impact)
- Uses Hyprland's native `hyprctl dispatch dpms [on|off]` commands
- Logs all lid state changes with timestamps for troubleshooting
- Respects existing systemd logind configuration (HandleLidSwitch=ignore)

### 2025-11-16 - Network Configuration Cleanup

**Changes:**
- Removed "Spaceballs" WiFi network from NetworkManager
- Switched primary connection to "homeLab" network
- Cleaned up network configuration to use only the main router

**Impact:**
- Simplified network management with single WiFi network
- System now automatically connects to homeLab router only
- Removed redundant network profile

**Files modified:**
- NetworkManager connection profiles (via `nmcli connection delete`)

### 2025-11-15 - Media Server and Automated Download Security System

**Changes:**
- Installed **Jellyfin media server** (Docker container, port 8096)
  - Configured with `~/jellyfin/config` for settings and `~/jellyfin/cache` for transcoding
  - Mounted `~/Videos` as media library location
  - Hardware acceleration support detected (CUDA, VAAPI, QSV)
- Installed **qBittorrent torrent client** (Docker container, port 8080)
  - Web UI accessible at http://192.168.2.250:8080
  - Downloads saved to `~/Downloads` directory
- Installed **ClamAV antivirus scanner** (Docker container, port 3310)
  - Auto-updates virus definitions daily (8.7+ million signatures)
  - Scans files via docker exec for virus detection
- Created **automated security scanning system**:
  - Script: `~/scripts/scan-and-move.sh` - Scans files with ClamAV + verifies file types
  - Script: `~/scripts/auto-scan-downloads.sh` - Wrapper for automated execution
  - Systemd timer: `download-scanner.timer` - Runs every minute
  - Systemd service: `download-scanner.service` - Executes scan workflow
  - Log file: `~/scan-log.txt` - Records all scan activity
- Created directory structure:
  - `~/Downloads` - qBittorrent download destination, monitored by scanner
  - `~/Videos` - Clean files moved here, scanned by Jellyfin
  - `~/quarantine` - Suspicious files quarantined here for manual review
- Created comprehensive documentation: `~/SECURITY-SYSTEM-README.md`

**Impact:**
- **Complete media server setup** - Download torrents, automatically scan for security, stream to TV via Jellyfin
- **Automated security workflow** - Every file downloaded is scanned within 1 minute
- **Zero-interaction security** - Files are automatically processed, user only reviews quarantined items
- **Hardware-accelerated transcoding** - Jellyfin can use Intel Arc GPU for efficient video conversion
- **Remote access ready** - All services accessible via Twingate for secure remote streaming

**Docker Containers:**
- `jellyfin` - Media server (jellyfin/jellyfin:latest)
- `qbittorrent` - Torrent client (linuxserver/qbittorrent:latest)
- `clamav` - Antivirus scanner (clamav/clamav:latest)

**Workflow:**
```
qBittorrent download → ~/Downloads
    ↓ (systemd timer, every minute)
ClamAV scan + File type check
    ↓
✅ Clean videos → ~/Videos → Jellyfin library
⚠️ Suspicious → ~/quarantine → Manual review
```

### 2025-11-14 - Simplified Battery Management

**Changes:**
- Removed battery-cycler.service systemd service
- Removed `/usr/local/bin/battery-cycler.sh` script
- Removed `/etc/battery-cycler.conf` configuration file
- Removed `/var/log/battery-cycler.log` log file
- Now using only Samsung's built-in 80% charge limit feature

**Impact:**
- Simpler, more maintainable battery management
- No service overhead or monitoring needed
- Battery still protected from staying at 100% charge
- Hardware-level charge control persists across reboots

**Rationale:**
The battery-cycler service added complexity by cycling between 50-80%. The built-in Samsung feature provides the same battery protection (limiting to 80%) without the need for custom scripts or services. Simpler is better for a server that should be low-maintenance.

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
