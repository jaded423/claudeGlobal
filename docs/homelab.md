# Home Lab Documentation

**Server Name:** cachyos-jade
**Local IP:** 192.168.1.228
**User:** jaded
**OS:** CachyOS Linux (Arch-based, performance-optimized)
**Kernel:** 6.17.7-3-cachyos
**Hardware:** 16GB RAM, 952GB NVMe storage
**Last Updated:** November 10, 2025 (Added monitoring tools and power management config)

---

## Overview

The home lab server provides secure remote access, file sharing, and personal infrastructure with both local high-speed access and remote access via Twingate Zero Trust network.

**Key Services:**
- SSH remote access (port 22)
- Samba file sharing (ports 445, 139)
- Twingate secure remote access
- Docker containerization
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

### 6. UFW Firewall

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

**CPU:** x86_64 (specifics: check `lscpu`)
**RAM:** 16GB total
- Used: ~3.6GB
- Available: ~11GB
- Swap: 15GB (minimal usage)

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
docker ps                              # Check containers
systemctl --user status rclone-*       # Check Drive mounts
sudo ufw status                        # Check firewall
```

### Log Viewing
```bash
journalctl -u sshd -f                  # SSH logs
journalctl -u smb -f                   # Samba logs
docker logs -f twingate-connector      # Twingate logs
journalctl --user -u rclone-gdrive -f  # Google Drive logs
```

### Important Paths
```
Setup scripts:     ~/setup/
Samba share:       /srv/samba/shared/
Hyprland config:   ~/.config/hypr/
Google Drives:     ~/GoogleDrive/ and ~/elevatedDrive/
Systemd services:  ~/.config/systemd/user/
```
