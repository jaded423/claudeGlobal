# Home Lab Documentation

**Primary Server:** cachyos-jade @ 192.168.1.228
**Last Updated:** November 14, 2025 (Updated battery charging thresholds to 50-80%, added Battery Management section, added sudo troubleshooting)

---

## Current Infrastructure Overview

### Active Devices

| Device | IP Address | Purpose | Power Usage | Status |
|--------|------------|---------|-------------|---------|
| **CachyOS Laptop** | 192.168.1.228 | Main compute server | 50-100W | ✅ Active |
| **Raspberry Pi 1 B+** | 192.168.1.191 | Pi-hole DNS ad-blocking | 2-3W | ✅ Active |
| **Raspberry Pi 2** | [Unknown] | Magic Mirror display | 3-4W | ✅ Active |

**Total Power:** ~55-107W (~$8-16/month electricity)

### Architecture Diagram

```
Current Homelab Infrastructure
│
├── CachyOS Laptop Server (cachyos-jade) @ 192.168.1.228
│   ├── Ollama with 7 LLMs (Intel Arc GPU accelerated)
│   ├── Docker (Twingate connector)
│   ├── SSH & Samba file sharing
│   ├── Google Drive mounts (2 accounts)
│   ├── Hyprland desktop environment
│   └── 16GB RAM + 22.7GB zram (37GB effective)
│
├── Raspberry Pi 1 B+
│   └── Pi-hole DNS ad-blocking (network-wide protection)
│
└── Raspberry Pi 2
    └── Magic Mirror with touch screen (info dashboard)
```

---

## CachyOS Server Details

**Server Name:** cachyos-jade
**Local IP:** 192.168.1.228
**User:** jaded
**OS:** CachyOS Linux (Arch-based, performance-optimized)
**Kernel:** 6.17.7-3-cachyos
**Hardware:** 16GB RAM, 952GB NVMe storage, Intel Arc Graphics 130V/140V

The home lab server provides secure remote access, file sharing, and personal infrastructure with both local high-speed access and remote access via Twingate Zero Trust network.

**Key Services:**
- SSH remote access (port 22)
- Samba file sharing (ports 445, 139)
- Twingate secure remote access
- Docker containerization
- Ollama local LLM inference (port 11434)
- Hyprland desktop environment
- Google Drive integration (2 accounts)
- System monitoring (Netdata port 19999, Glances port 61208)

**Access Methods:**
- **At Home:** Direct LAN access (192.168.1.228) - fastest
- **Remote:** Twingate network (jaded423) - secure tunnel

---

## Architecture

### Network Configuration

**Local Network:**
- IP Address: 192.168.1.228
- Subnet: 192.168.1.0/24
- Access: Direct LAN (60+ MB/s transfers)

**Remote Access (Twingate):**
- Network Name: jaded423
- Connector: Docker container (host networking)
- Resources:
  - SSH Access (port 22) - assigned to jaded user
  - File Sharing (ports 445, 139) - assigned to family members

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
│  - Twingate Connector (remote access)   │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│      Service Management Layer           │
│  - systemd (sshd, smb)                  │
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
ssh jaded@192.168.1.228
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
├── Music -> /home/jaded/Music
├── Pictures -> /home/jaded/Pictures
├── Documents -> /home/jaded/Documents
└── Videos -> /home/jaded/Videos
```

**Access Methods:**

*At Home (Mac):*
```bash
# Finder: Cmd+K, then enter:
smb://192.168.1.228/Shared
```

*At Home (Windows):*
```
\\192.168.1.228\Shared
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

#### Netdata
**Port:** 19999
**Status Check:** `systemctl status netdata`
**Access:** `http://192.168.1.228:19999` (local network)
**Features:**
- Real-time system metrics with beautiful graphs
- CPU, memory, disk, network monitoring
- Process tracking
- Alert capabilities
- Zero configuration required

**Service Management:**
```bash
systemctl status netdata         # Check status
sudo systemctl restart netdata   # Restart service
journalctl -u netdata -f         # View logs
```

#### Glances
**Port:** 61208 (web mode)
**Status Check:** `ps aux | grep glances`
**Access:** `http://192.168.1.228:61208` (web mode)
**Features:**
- Lightweight system monitor
- Terminal and web modes
- Similar to btop but with web interface option
- Lower resource usage than Netdata
- Perfect for Pi/low-power devices

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

**Note:** Due to current network communication issues (see Troubleshooting section), web access may require SSH tunneling:
```bash
# From Mac - forward Netdata
ssh -L 19999:localhost:19999 jaded@192.168.1.228

# From Mac - forward Glances
ssh -L 61208:localhost:61208 jaded@192.168.1.228
```

### 6. Battery Management

**Purpose:** Maintain optimal battery health by cycling charge between thresholds
**Service:** battery-cycler.service (systemd)
**Status Check:** `systemctl status battery-cycler`
**Configuration:** `/etc/battery-cycler.conf`

**Current Thresholds:**
- Lower threshold: 50% (charging resumes when battery drops to this level)
- Upper threshold: 80% (charging stops when battery reaches this level)

**How It Works:**
The battery-cycler service monitors battery level every 60 seconds and automatically manages charging to keep the battery between 50-80%. This prevents the battery from staying at 100% constantly (which degrades battery health) while ensuring it doesn't drain too low.

**Configuration File (`/etc/battery-cycler.conf`):**
```bash
LOWER_THRESHOLD=50    # Charge resumes at this level
UPPER_THRESHOLD=80    # Charging stops at this level
CHECK_INTERVAL=60     # Check battery every 60 seconds
ENABLED=true          # Service enabled
```

**Service Management:**
```bash
systemctl status battery-cycler     # Check status
journalctl -u battery-cycler -f     # View logs
sudo systemctl restart battery-cycler  # Restart service

# View current battery status
cat /sys/class/power_supply/BAT*/capacity
cat /sys/class/power_supply/BAT*/status
```

**Changing Thresholds:**
```bash
# Edit configuration
sudo nvim /etc/battery-cycler.conf

# Changes take effect automatically within 60 seconds (no restart needed)
```

**Script Location:** `/usr/local/bin/battery-cycler.sh`

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

**Installed Models (Total: ~20GB):**

*General Use Models:*

- **`llama3.2:3b`** (2.0GB)
  - **Best for:** General chat, summarization, Q&A, writing assistance
  - **Strengths:** Balanced performance, follows instructions well, good at reasoning
  - **Use when:** You need reliable general-purpose AI without specialized needs
  - **Speed:** Fast (3B parameters)

- **`phi3.5:3.8b`** (2.2GB)
  - **Best for:** Mathematical reasoning, logical problems, structured tasks
  - **Strengths:** Excellent at math/logic, very efficient for its size, low resource usage
  - **Use when:** Working with calculations, analysis, or need precise reasoning
  - **Speed:** Fast (3.8B parameters)

- **`qwen2.5:7b`** (4.7GB)
  - **Best for:** Multilingual tasks, coding help, complex reasoning
  - **Strengths:** Great with multiple languages, strong coding abilities, high quality responses
  - **Use when:** Need best balance of quality and speed, working with non-English text
  - **Speed:** Moderate (7B parameters)

*Coding-Focused Models:*

- **`qwen2.5-coder:7b`** (4.7GB)
  - **Best for:** Code generation, refactoring, algorithm design, debugging
  - **Strengths:** Trained specifically on code, understands 80+ languages, excellent at explaining code
  - **Use when:** Writing new code, converting between languages, understanding complex codebases
  - **Speed:** Moderate (7B parameters)

- **`deepseek-coder:6.7b`** (3.8GB)
  - **Best for:** Code completion, filling in code gaps, autocomplete-style suggestions
  - **Strengths:** Fill-in-the-middle capability, great for IDE-style completions
  - **Use when:** Need autocomplete suggestions, filling in missing code sections
  - **Speed:** Moderate (6.7B parameters)

*Ultra-Lightweight Models:*

- **`gemma2:2b`** (1.6GB)
  - **Best for:** Quick queries, simple tasks, running multiple instances
  - **Strengths:** Very low resource usage, surprisingly capable for size, fast responses
  - **Use when:** Testing prompts, simple Q&A, need instant responses, running on low resources
  - **Speed:** Very fast (2B parameters)

- **`llama3.2:1b`** (1.3GB)
  - **Best for:** Lightning-fast responses, basic chat, simple classifications
  - **Strengths:** Smallest model, fastest inference, minimal RAM usage
  - **Use when:** Need immediate responses, simple yes/no tasks, batch processing many simple queries
  - **Speed:** Extremely fast (1B parameters)

**Model Selection Guide:**
- **For coding:** Start with `qwen2.5-coder:7b` (best quality) or `deepseek-coder:6.7b` (good completions)
- **For general tasks:** Use `qwen2.5:7b` (best quality) or `llama3.2:3b` (faster)
- **For math/logic:** Use `phi3.5:3.8b`
- **For speed:** Use `gemma2:2b` or `llama3.2:1b`
- **For multilingual:** Use `qwen2.5:7b`

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

# Download new model
ollama pull modelname:tag

# Remove model to free space
ollama rm modelname:tag
```

**Performance Notes:**
- GPU acceleration enabled for 2-3x faster inference
- CPU-only mode available as fallback
- Models run efficiently with 16GB RAM + 22.7GB zram swap
- Best for: Code generation, text analysis, quick queries
- Not ideal for: Very large context windows, real-time streaming at scale

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
- Lid close behavior: **ignore** (laptop stays on with lid closed)
- Configuration: `/etc/systemd/logind.conf`
- Settings:
  - `HandleLidSwitch=ignore`
  - `HandleLidSwitchExternalPower=ignore`
- Allows server operation in closed, cool location
- Battery status accessible via: `cat /sys/class/power_supply/BAT*/capacity`

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
**IPv4:** 192.168.1.228
**Gateway:** 192.168.1.1 (likely)
**DNS:** (check `/etc/resolv.conf`)

---

## Access from Work Mac

### SSH Access

**Standard Access:**
```bash
ssh jaded@192.168.1.228
```

**Authentication:**
- Primary: SSH key (already installed)
- Fallback: Password

**SSH Config (optional):**
Add to `~/.ssh/config` on work Mac:
```
Host homelab
    HostName 192.168.1.228
    User jaded
    IdentityFile ~/.ssh/id_ed25519

Host homelab-short
    HostName 192.168.1.228
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
smb://192.168.1.228/Shared

# Or mount via command line:
mkdir -p ~/mnt/homelab
mount_smbfs //jaded@192.168.1.228/Shared ~/mnt/homelab
```

**SFTP/SCP (via SSH):**
```bash
# Copy file to server
scp file.txt jaded@192.168.1.228:~/

# Copy file from server
scp jaded@192.168.1.228:~/file.txt .

# Copy directory
scp -r jaded@192.168.1.228:~/Documents ./

# SFTP interactive session
sftp jaded@192.168.1.228
```

### Remote Development

**VS Code Remote SSH:**
1. Install "Remote - SSH" extension
2. Add host: `jaded@192.168.1.228`
3. Connect and develop directly on server

**rsync for Development:**
```bash
# Sync local changes to server
rsync -avz --exclude='.git' ~/local/project/ jaded@192.168.1.228:~/remote/project/

# Sync server changes to local
rsync -avz jaded@192.168.1.228:~/remote/project/ ~/local/project/
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
scp -r jaded@192.168.1.228:~/setup ~/backups/homelab-setup-$(date +%Y%m%d)

# Backup important configs
ssh jaded@192.168.1.228 'tar czf - ~/.config/hypr ~/.config/waybar ~/.ssh' > ~/backups/homelab-configs-$(date +%Y%m%d).tar.gz
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

**⚠️ Network Communication Issues**: If web services on the server are not accessible from Mac, see **[Network Troubleshooting Guide](/tmp/homelab-network-troubleshooting.md)** for detailed ARP/network diagnostics and solutions.

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

## Future Enhancements

### Potential Additions

1. **Docker Services:**
   - Portainer (Docker management UI)
   - Prometheus + Grafana (monitoring)
   - Pi-hole (network-wide ad blocking)
   - Home Assistant (home automation)

2. **Backup Automation:**
   - Automated backups to work Mac
   - Cloud backup integration
   - Rsnapshot for incremental backups

3. **Development Environment:**
   - Docker registry for custom images
   - CI/CD pipeline (Gitea + Drone)
   - Development databases (PostgreSQL, Redis)

4. **Media Server:**
   - Plex or Jellyfin media server
   - Transmission or qBittorrent
   - Sonarr/Radarr automation

5. **Documentation:**
   - CLAUDE.md with project-specific guidance
   - Automated documentation sync to work Mac
   - Wiki for detailed procedures

---

## Future Expansion Plans

### Phase 2A: Raspberry Pi 5 Consolidation (Next Month - $185)

**Hardware:** Raspberry Pi 5 with 16GB RAM
**Purpose:** Consolidate and expand lightweight services

**Migration Plan:**
```
Raspberry Pi 5 16GB (new)
├── Services to Migrate:
│   ├── Pi-hole DNS (from Pi 1 B+)
│   └── Magic Mirror (from Pi 2)
│
└── New Services to Add:
    ├── Uptime Kuma (monitoring)
    ├── Homepage dashboard
    ├── Home Assistant (optional)
    └── Wireguard VPN server
```

**Old Pi Repurposing:**
- **Pi 1 B+:** Sensor node, backup DNS, or retire (512MB RAM limited)
- **Pi 2:** Testing environment or IoT gateway

### Phase 2B: Storage Server (3-6 Months - $200-300)

**Hardware:** Dell Precision T3600 or HP Z420 Tower
**Purpose:** NAS and backup infrastructure

**Configuration:**
- 2-3x 4TB HDDs (used ~$40-60 each)
- TrueNAS or OpenMediaVault
- Time Machine target for Macs
- Automated backups from CachyOS server
- Optional: Plex/Jellyfin media server

### Phase 3: AI Workstation (6-12 Months - Only if needed)

**Hardware:** Dell T7810 dual socket tower
**GPU:** RTX 3060 12GB or Tesla P40 24GB
**Purpose:** Heavy AI/ML workloads

**Use Cases:**
- Larger LLMs (13B, 30B+ models)
- Model training/fine-tuning
- Stable Diffusion image generation
- Keep laptop for lightweight models

### Final Architecture Vision

```
Future Distributed Homelab (~$485 total investment)
│
├── CachyOS Laptop (cachyos-jade) - Compute Node
│   ├── Primary services
│   ├── Docker containers
│   ├── Ollama (smaller models)
│   └── Development environment
│
├── Raspberry Pi 5 16GB - Network Services
│   ├── All DNS/DHCP services
│   ├── Monitoring stack
│   ├── Home automation
│   └── VPN endpoint
│
├── Storage Tower - Data Node
│   ├── 8-16TB storage array
│   ├── Backup infrastructure
│   ├── Media services
│   └── Archive storage
│
└── Optional: AI Workstation - ML Node
    ├── Large LLM inference
    ├── Model training
    └── GPU compute tasks
```

**Projected Power Usage:**
- Current: ~55-107W ($8-16/month)
- With Pi 5: ~60-115W ($9-18/month)
- With Storage Tower: ~160-215W ($25-35/month)
- Full Build: ~210-265W ($34-42/month)

### Why This Architecture Works

1. **Distributed by Function:** Each device optimized for its role
2. **Scalable:** Add components only when needed
3. **Efficient:** Total power under 265W even fully built out
4. **Budget-Friendly:** Under $500 for capable infrastructure
5. **Already Started:** Pi-hole and services already running

### What NOT to Buy

❌ **Dell R630/R730 Rack Servers** - Too loud, power-hungry for current needs
❌ **High-end GPU immediately** - Current Intel Arc handling 7B models well
❌ **Replacement for laptop** - It's working perfectly
❌ **All hardware at once** - Grow based on actual bottlenecks

---

## Related Documentation

**Server-side:**
- `~/README.md` - Primary server setup documentation
- `~/setup/README.md` - Setup scripts documentation
- `~/.config/hypr/` - Hyprland configuration
- `~/.config/systemd/user/` - User service files

**Work Mac:**
- `~/.claude/CLAUDE.md` - Global Claude documentation (this reference)
- `~/.claude/docs/interconnections.md` - System dependency map
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
IP Address: 192.168.1.228
User: jaded
SSH: ssh jaded@192.168.1.228
Samba: smb://192.168.1.228/Shared
Twingate: jaded423
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
