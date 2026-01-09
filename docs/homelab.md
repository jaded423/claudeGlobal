# Home Lab Documentation

**Last Updated:** January 9, 2026
**Cluster:** 2-node Proxmox "home-cluster" with QDevice quorum

**Detailed Docs:** See `homelab/` subdirectory for services, troubleshooting, and setup guides.

---

## Infrastructure Overview

### Network Architecture

| Network | Subnet | Gateway | Speed | Purpose |
|---------|--------|---------|-------|---------|
| **Management** | 192.168.2.0/24 | .2.1 | 1 Gbps | Proxmox hosts, VMs, Twingate |
| **Mac/PC** | 192.168.1.0/24 | .1.1 | 1 Gbps | Mac, Windows PC, other devices |
| **Inter-Node** | 10.10.10.0/30 | - | 2.5 Gbps | Direct link between Proxmox nodes |

### Active Devices

| Device | IP | Purpose | Status |
|--------|-----|---------|--------|
| **prox-book5** | 192.168.2.250 (vmbr0) / 10.10.10.1 (vmbr1) | Proxmox node 1 (Samsung Galaxy Book5 Pro, 16GB) | Active |
| └─ VM 100: Omarchy | 192.168.2.161 | Arch Linux desktop (Hyprland) | Auto-start |
| **prox-tower** | 192.168.2.249 (vmbr0) / 10.10.10.2 (vmbr1) | Proxmox node 2 (ThinkStation, 78GB, Xeon 16c/32t) | Active |
| └─ VM 101: Ubuntu Server | 192.168.2.126 | Docker, Ollama, Plex, Frigate (40GB RAM, 28 vCPU) | Auto-start |
| **Raspberry Pi 2** | 192.168.2.131 | Pi-hole DNS, QDevice, MagicMirror | Active |
| **etintake (Windows PC)** | 192.168.1.193 | WSL Ubuntu, Twingate connector (Docker) | Active |
| └─ **Pi1 (via ICS)** | 192.168.137.123 | Git backup mirror (Pi 1B+, 512MB) | Active |

**Storage:**
- prox-book5: 880GB NVMe (ZFS)
- prox-tower: 370GB SSD (ZFS) + 3.5TB HDD "media-pool" (ZFS, added Jan 2026)

### Architecture Diagram

```
Proxmox Cluster "home-cluster" (3 votes: 2 nodes + QDevice)
│
├── prox-book5 @ 192.168.2.250 (vmbr0) / 10.10.10.1 (vmbr1)
│   ├── Twingate Connector (systemd)
│   ├── Dual-NIC: 1GbE (USB-C dock) + 2.5GbE (Realtek RTL8156)
│   └── VM 100: Omarchy @ 192.168.2.161 (Arch + Hyprland)
│
├── prox-tower @ 192.168.2.249 (vmbr0) / 10.10.10.2 (vmbr1)
│   ├── Twingate Connector (systemd)
│   ├── Dual-NIC: Intel I218-LM (1GbE) + Realtek RTL8125 (2.5GbE)
│   ├── media-pool (4TB HDD): /media-pool/media/, /media-pool/ollama/
│   └── VM 101: Ubuntu Server @ 192.168.2.126
│       ├── Docker: Plex, Jellyfin, qBittorrent, ClamAV, Frigate, Mosquitto
│       ├── Ollama (6 LLMs, 40GB, GPU-accelerated via Quadro M4000)
│       └── Google Drive mounts (rclone FUSE)
│
├── Raspberry Pi @ 192.168.2.131
│   ├── Pi-hole DNS
│   ├── Corosync QDevice (cluster quorum)
│   └── MagicMirror kiosk
│
├── etintake (Windows PC) @ 192.168.1.193
│   ├── WSL Ubuntu (SSH on port 2222)
│   ├── Twingate Connector (Docker in WSL)
│   ├── RustDesk remote access
│   └── Pi1 @ 192.168.137.123 (via ICS on ethernet)
│       ├── Raspberry Pi 1 Model B+ (ARMv6, 512MB RAM)
│       ├── Git backup mirror (15 repos, 4-hourly sync)
│       └── SSH: `ssh pi1` (port 2223 via PC forward)
│
└── Direct 2.5G Inter-Node Link (10.10.10.0/30)
    prox-book5 (10.10.10.1) ◄─── 2.36 Gbps ───► prox-tower (10.10.10.2)
```

---

## SSH Access

### From Work Mac

```bash
# Proxmox hosts (direct)
ssh root@192.168.2.250          # prox-book5
ssh root@192.168.2.249          # prox-tower

# VMs (via ProxyJump - automatic)
ssh jaded@192.168.2.161         # VM 100 - Omarchy
ssh jaded@192.168.2.126         # VM 101 - Ubuntu Server (aliases: ubuntu, vm101)

# Windows PC - WSL Ubuntu (aliases: etintake, wsl, pc)
ssh etintake                    # Port 2222, user joshua
```

### SSH Config (~/.ssh/config on Mac)

VMs require ProxyJump due to Twingate routing. This config makes it automatic:

```ssh
# Proxmox Node 1
Host 192.168.2.250 prox-book5 book5
  User root
  IdentityFile ~/.ssh/id_ed25519

# Proxmox Node 2
Host 192.168.2.249 prox-tower tower
  User root
  IdentityFile ~/.ssh/id_ed25519

# VM 100 - Omarchy (ProxyJump through prox-book5)
Host 192.168.2.161 omarchy vm100
  User jaded
  ProxyJump 192.168.2.250
  IdentityFile ~/.ssh/id_ed25519

# VM 101 - Ubuntu Server (ProxyJump through prox-tower)
Host 192.168.2.126 ubuntu-server ubuntu vm101
  User jaded
  ProxyJump 192.168.2.249
  IdentityFile ~/.ssh/id_ed25519
```

### Remote Access (Twingate)

- **Network:** jaded423 + Elevated
- **Admin Console:** https://jaded423.twingate.com
- **Connectors:**
  - jaded423: prox-book5, prox-tower, magic-pihole
  - Elevated: PC (Docker in WSL on etintake)
- **Resources:** zWindows SSH (192.168.1.193, ports 22/2222/3389)
- **Critical:** Both Proxmox hosts must be Twingate resources for VM access to work

---

## Services Quick Reference

### VM 101 (Ubuntu Server) - Main Services Host

| Service | Port | Purpose |
|---------|------|---------|
| Plex | 32400 | Media server |
| Jellyfin | 8096 | Media server (backup) |
| qBittorrent | 8080 | Torrent client (Web UI) |
| Frigate | 5000 | NVR with AI detection |
| Open WebUI | 3000 | Ollama chat interface |
| Ollama API | 11434 | LLM inference |
| Mosquitto | 1883 | MQTT broker |

### Proxmox Hosts

| Service | Port | Location |
|---------|------|----------|
| Proxmox Web UI | 8006 | Both hosts |
| SSH | 22 | All devices |
| Twingate | N/A | systemd service |

### Other Services

| Service | Location | Purpose |
|---------|----------|---------|
| Pi-hole | 192.168.2.131 | DNS ad-blocking |
| Samba | 192.168.2.250 | File sharing (smb://192.168.2.250/Shared) |

### Pi1 @ Elevated (Git Backup Mirror)

| Property | Value |
|----------|-------|
| **Hardware** | Raspberry Pi 1 Model B+ (ARMv6, 700MHz, 512MB RAM) |
| **OS** | Raspberry Pi OS (Legacy) Bookworm Lite |
| **IP** | 192.168.137.123 (ICS subnet behind Windows PC) |
| **SSH** | `ssh pi1` (port 2223 via PC port forward) |
| **User** | pi (passwordless sudo) |
| **Storage** | 8GB SD card (~4.4GB free) |
| **Internet** | ~40 Mbps via Windows ICS |

**Services:**
- Git backup mirror: 15 repos (152MB) syncing every 4 hours
- Sync script: `~/git-mirrors/sync-mirrors.sh`
- Sync log: `~/git-mirrors/sync.log`

**Network Architecture:**
```
Mac → PC:2223 → Windows portproxy → Pi:22
Pi → Windows ICS NAT → PC WiFi → Internet
```

**Manual Commands:**
```bash
# SSH to Pi from Mac
ssh pi1

# Trigger manual sync
ssh pi1 "~/git-mirrors/sync-mirrors.sh"

# Check sync status
ssh pi1 "cat ~/git-mirrors/sync.log | tail -20"

# List mirrored repos
ssh pi1 "ls ~/git-mirrors/*.git"
```

**Note:** Pi1 internet depends on PC being powered on (ICS). If PC is off, Pi has no network access.

---

## Ollama LLMs (VM 101)

**Models stored on HDD** via NFS mount (`/mnt/ollama/models/`)
**GPU:** Quadro M4000 (8GB VRAM) - hybrid mode for 14B+ models

| Model | Size | Best For | Speed |
|-------|------|----------|-------|
| `qwen3-pure-hybrid` | 18GB | Complex reasoning, coding | ~14 tok/s |
| `qwen-gon-jinn-hybrid` | 14GB | General tasks, everyday use | ~12 tok/s |
| `qwen2.5-coder:7b` | 4.7GB | Code generation | Fast (full GPU) |
| `llama3.2:3b` | 2.0GB | Quick queries | Very fast |

**GPU Limits:** Models ≤18GB work in hybrid mode. 19GB+ models crash, need CPU-only (slow).

---

## Known Issues & Gotchas

### Intel I218-LM NIC Bug (prox-tower)

**Problem:** TSO enabled causes network hangs requiring physical reboot.
**Fix Applied:** TSO/GSO/GRO disabled in `/etc/network/interfaces`
**Verify:** `ethtool -k nic0 | grep -E 'tcp-seg|generic'` → all "off"

### Twingate After Reboot

**Problem:** After server reboot, Twingate shows green but can't connect.
**Fix:** Restart Twingate client on Mac: `killall Twingate && open -a Twingate`
**Note:** May take 5-10 min to fully re-establish routes.

### VM Access Requires ProxyJump

**Problem:** Twingate routing conflict prevents direct VM SSH.
**Fix:** Use ProxyJump config (see SSH section above).

### scan-and-move.sh (Media Automation)

**Status:** Cron disabled (Dec 27, 2025) - script needs rework
**Issue:** Return value logic bugs causing incomplete file moves
**Location:** VM 101 `~/scripts/scan-and-move.sh`

### Windows PC (etintake) SSH Issues

**Problem:** WSL IP changes on reboot, breaking port forwarding.
**Auto-Fix:** `/etc/wsl-ssh-startup.sh` runs on boot and updates port forwarding.
**Manual Fix (if needed):** Run in WSL: `sudo /usr/local/bin/fix-wsl-ssh`

**Problem:** Windows IP changes (DHCP).
**Fix:** Update Twingate resource in admin console, or set DHCP reservation on router.

**Problem:** SSH fails with "System is booting up" error.
**Fix:** `sudo rm -f /run/nologin /etc/nologin` (startup script handles this)

---

## Quick Commands

### Service Status
```bash
# VM 101 Docker containers
ssh jaded@192.168.2.126 "docker ps --format 'table {{.Names}}\t{{.Status}}'"

# Ollama
ssh jaded@192.168.2.126 "systemctl status ollama"

# Twingate (on Proxmox hosts)
ssh root@192.168.2.250 "systemctl status twingate-connector"
```

### Common Operations
```bash
# Check GPU usage
ssh jaded@192.168.2.126 "nvidia-smi"

# List Ollama models
ssh jaded@192.168.2.126 "ollama list"

# Restart Frigate
ssh jaded@192.168.2.126 "cd ~/frigate && docker compose restart frigate"

# Check cluster quorum
ssh root@192.168.2.250 "pvecm status"
```

### File Access
```bash
# Samba (from Mac Finder: Cmd+K)
smb://192.168.2.250/Shared

# SCP to VM 101
scp file.txt jaded@192.168.2.126:~/
```

---

## Twingate Weekly Updates

**Schedule:** Sundays 3:00/3:15/3:30 AM (staggered)
**Logs:** `/var/log/twingate-upgrade.log` on each node

**Skip before travel:**
```bash
OOO  # Creates skip files on all 3 nodes
```

---

## Related Documentation

**Detailed guides in `homelab/` subdirectory:**
- [services.md](homelab/services.md) - Full service configurations
- [troubleshooting.md](homelab/troubleshooting.md) - Complete troubleshooting guide
- [setup-guides.md](homelab/setup-guides.md) - Installation procedures
- [gpu-passthrough.md](homelab/gpu-passthrough.md) - Quadro M4000 passthrough setup
- [google-drive.md](homelab/google-drive.md) - rclone FUSE mount configuration
- [media-server.md](homelab/media-server.md) - Plex/Jellyfin organization

**Other docs:**
- [homelab-expansion.md](homelab-expansion.md) - Future upgrade plans
- [ssh-access-cheatsheet.md](ssh-access-cheatsheet.md) - Quick SSH reference

**Archived changelogs:** `backups/homelab-*.md`

---

## Changelog (Recent)

| Date | Change |
|------|--------|
| 2026-01-09 | Pi1 @ Elevated: Raspberry Pi 1B+ git backup mirror via Windows ICS, 15 repos, 4-hourly sync |
| 2026-01-07 | Windows PC (etintake) SSH setup: WSL Ubuntu, port 2222, auto port forwarding |
| 2026-01-06 | 4TB HDD ZFS pool, media migration to prox-tower, Ollama models to HDD |
| 2025-12-27 | scan-and-move.sh bug fixes, qBittorrent optimization, cron disabled |
| 2025-12-25 | Twingate automated weekly upgrades, OOO skip mechanism |
| 2025-12-20 | GPU passthrough complete (Quadro M4000 → VM 101) |
| 2025-12-13 | Dual-NIC setup, VM 101 migrated to 2.5GbE network |
| 2025-12-12 | Twingate → systemd, Intel NIC fix, storage renamed |

**Full history:** See `backups/homelab-20260106-*.md`
