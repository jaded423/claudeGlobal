# Home Lab Documentation

**Last Updated:** January 13, 2026
**Cluster:** 2-node Proxmox "home-cluster" with QDevice quorum

---

## Network Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              TWINGATE CLOUD                                          │
│                            (jaded423 network)                                        │
└───────────────┬─────────────────────┬─────────────────────┬────────────────────────┘
                │                     │                     │
    ┌───────────▼───────────┐ ┌───────▼───────────┐ ┌───────▼───────────┐
    │   CONNECTOR 1         │ │   CONNECTOR 2     │ │   CONNECTOR 3     │
    │   prox-book5          │ │   prox-tower      │ │   magic-pihole    │
    │   (systemd)           │ │   (systemd)       │ │   (Docker)        │
    └───────────┬───────────┘ └───────┬───────────┘ └───────┬───────────┘
                │                     │                     │
┌───────────────▼─────────────────────▼─────────────────────▼───────────────────────┐
│                        MANAGEMENT NETWORK: 192.168.2.0/24                          │
│                              Gateway: 192.168.2.1                                  │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────┐         ┌─────────────────────┐         ┌──────────────┐ │
│  │ prox-book5          │  2.5G   │ prox-tower          │         │ magic-pihole │ │
│  │ 192.168.2.250       │◄───────►│ 192.168.2.249       │         │ 192.168.2.131│ │
│  │ Samsung Galaxy Book5│ Direct  │ ThinkStation P510   │         │ Raspberry Pi2│ │
│  │ 16GB RAM, 880GB SSD │  Link   │ 78GB RAM, Xeon 16c  │         │ 1GB RAM      │ │
│  │                     │10.10.10.│ 370GB+4TB, Quadro   │         │              │ │
│  │ └─ VM 100: Omarchy  │  0/30   │ └─ VM 101: Ubuntu   │         │ • Pi-hole DNS│ │
│  │    192.168.2.161    │         │    192.168.2.126    │         │ • QDevice    │ │
│  │    Arch + Hyprland  │         │    Docker, Ollama   │         │ • MagicMirror│ │
│  │                     │         │    Plex, Frigate    │         │              │ │
│  │ ◄── Reverse SSH ────┤         │                     │         │              │ │
│  │     Tunnel :2244    │         │                     │         │              │ │
│  └──────────▲──────────┘         └─────────────────────┘         └──────────────┘ │
│             │                                                                      │
└─────────────┼──────────────────────────────────────────────────────────────────────┘
              │ (Twingate Client)
              │
┌─────────────▼──────────────────────────────────────────────────────────────────────┐
│                          MAC/PC NETWORK: 192.168.1.0/24                            │
│                              Gateway: 192.168.1.1                                  │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────┐         ┌─────────────────────┐         ┌──────────────┐ │
│  │ MacBook Air M2      │         │ Windows PC          │  ICS    │ Pi1          │ │
│  │ 192.168.2.226 (LAN) │         │ 192.168.1.193       │◄───────►│ 192.168.137. │ │
│  │ macAir.local (mDNS) │         │ etintake            │  NAT    │ 123          │ │
│  │ Primary workstation │         │                     │         │ Pi 1B+ 512MB │ │
│  │                     │         │ • PowerShell :22    │         │              │ │
│  │ • Twingate Client   │         │ • WSL Ubuntu :2222  │         │ Git backup   │ │
│  │ • Claude Code       │         │ • Twingate (Docker) │         │ mirror       │ │
│  │ • Development       │         │ • Pi1 forward :2223 │         │ 15 repos     │ │
│  └─────────────────────┘         └─────────────────────┘         └──────────────┘ │
│                                                                                    │
│  ┌─────────────────────┐         ┌─────────────────────┐                          │
│  │ Pixelbook Go        │         │ Samsung S25 Ultra   │                          │
│  │ 192.168.1.244       │         │ 192.168.1.96        │                          │
│  │ go.local (mDNS)     │         │ Termux              │                          │
│  │ CachyOS + Hyprland  │         │                     │                          │
│  │                     │         │ • SSH :8022         │                          │
│  │ • Twingate Client   │         │ • zsh + p10k        │                          │
│  │ • Reverse tunnel    │         │                     │                          │
│  └─────────────────────┘         └─────────────────────┘                          │
│                                                                                    │
└────────────────────────────────────────────────────────────────────────────────────┘

                              PROXMOX CLUSTER
                           ┌─────────────────┐
                           │  home-cluster   │
                           │  3 votes total  │
                           ├─────────────────┤
                           │ book5    = 1    │
                           │ tower    = 1    │
                           │ QDevice  = 1    │
                           └─────────────────┘
```

---

## Node Reference

### Proxmox Cluster

| Node | IP | Hardware | Docs |
|------|-----|----------|------|
| **prox-book5** | 192.168.2.250 | Samsung Galaxy Book5 Pro, 16GB | [book5.md](homelab/book5.md) |
| **prox-tower** | 192.168.2.249 | ThinkStation P510, 78GB, Xeon | [tower.md](homelab/tower.md) |
| **magic-pihole** | 192.168.2.131 | Raspberry Pi 2, QDevice | [pihole.md](homelab/pihole.md) |

### Virtual Machines

| VM | Host | IP | Purpose | Docs |
|----|------|-----|---------|------|
| **VM 100: Omarchy** | book5 | 192.168.2.161 | Arch Linux desktop | [omarchy.md](homelab/omarchy.md) |
| **VM 101: Ubuntu** | tower | 192.168.2.126 | Docker, Ollama, media | [ubuntu.md](homelab/ubuntu.md) |

### Client Devices

| Device | IP | Purpose | Docs |
|--------|-----|---------|------|
| **MacBook Air** | 192.168.2.226 | Primary workstation | [mac.md](homelab/mac.md) |
| **Pixelbook Go** | 192.168.1.244 | CachyOS dev laptop | [go.md](homelab/go.md) |
| **Windows PC** | 192.168.1.193 | WSL, Twingate | [pc.md](homelab/pc.md) |
| **Pi1** | 192.168.137.123 | Git backup mirror | [pi1.md](homelab/pi1.md) |

---

## Quick SSH Access

```bash
# Proxmox hosts
ssh book5                    # Node 1
ssh tower                    # Node 2

# VMs (ProxyJump automatic)
ssh ubuntu                   # VM 101 - services
ssh omarchy                  # VM 100 - desktop

# Other devices
ssh go                       # Pixelbook Go (via reverse tunnel)
ssh pc                       # Windows PowerShell
ssh wsl                      # Windows WSL Ubuntu
ssh pi1                      # Git backup Pi
ssh pihole                   # DNS/QDevice Pi
```

---

## Services Quick Reference

### VM 100 (Omarchy) - Tower Guardian

| Service | Port | Purpose |
|---------|------|---------|
| n8n | 5678 | Workflow automation (health monitoring) |
| Ollama | 11434 | Local LLM (Llama 3.1 8B) |

**Details**: See [omarchy.md](homelab/omarchy.md#tower-guardian---proxmox-health-monitor)

### VM 101 (Ubuntu Server)

| Service | Port | Purpose |
|---------|------|---------|
| Plex | 32400 | Media server |
| Jellyfin | 8096 | Media server (backup) |
| qBittorrent | 8080 | Torrent client |
| Frigate | 5000 | NVR - 2 cameras |
| Ollama | 11434 | LLM inference |
| Open WebUI | 3000 | Ollama chat |

### Infrastructure

| Service | Location | Purpose |
|---------|----------|---------|
| Pi-hole | 192.168.2.131 | DNS ad-blocking |
| Samba | 192.168.2.250 | File sharing |
| Twingate | All nodes | Remote access |

---

## Storage

| Location | Type | Size | Content |
|----------|------|------|---------|
| book5 | ZFS (NVMe) | 880GB | VMs, ISOs |
| tower rpool | ZFS (SSD) | 370GB | System, VM disks |
| tower media-pool | ZFS (HDD) | 3.5TB | Media, Ollama, Frigate |

---

## Twingate Configuration

| Network | Connectors |
|---------|------------|
| jaded423 | prox-book5, prox-tower, magic-pihole |
| Elevated | Windows PC (headless service) |

**Admin Console**: https://jaded423.twingate.com

**Weekly Updates**: Sundays 3:00/3:15/3:30 AM (staggered)

```bash
# Skip before travel
OOO    # Creates skip files on all nodes
```

---

## Special Configurations

### Pixelbook Go Reverse Tunnel

Go uses Twingate **Client** (not connector) to reach homelab. Mac reaches Go via reverse SSH tunnel through book5:

```
Mac → Twingate → book5 → localhost:2244 → Go
```

See [go.md](homelab/go.md) for details.

### Pi1 Internet via Windows ICS

Pi1 has no direct internet - routes through Windows PC via ICS:

```
Pi1 → Windows:192.168.137.1 (ICS) → PC WiFi → Internet
```

See [pi1.md](homelab/pi1.md) for details.

---

## Related Documentation

### Node-Specific Docs (`homelab/` subdirectory)

| Doc | Content |
|-----|---------|
| [book5.md](homelab/book5.md) | Proxmox Node 1, reverse tunnel endpoint |
| [tower.md](homelab/tower.md) | Proxmox Node 2, GPU passthrough, media storage |
| [ubuntu.md](homelab/ubuntu.md) | VM 101, Docker services, Ollama |
| [omarchy.md](homelab/omarchy.md) | VM 100, Arch Linux desktop |
| [pihole.md](homelab/pihole.md) | Pi-hole DNS, QDevice, MagicMirror |
| [mac.md](homelab/mac.md) | MacBook Air, primary workstation |
| [go.md](homelab/go.md) | Pixelbook Go, CachyOS Hyprland |
| [pc.md](homelab/pc.md) | Windows PC, WSL, Twingate |
| [pi1.md](homelab/pi1.md) | Git backup mirror |

### Service Guides

| Doc | Content |
|-----|---------|
| [gpu-passthrough.md](homelab/gpu-passthrough.md) | Quadro M4000 passthrough |
| [google-drive.md](homelab/google-drive.md) | rclone FUSE mounts |
| [media-server.md](homelab/media-server.md) | Plex/Jellyfin organization |

### Planning & Other

| Doc | Content |
|-----|---------|
| [homelab/expansion-plans.md](homelab/expansion-plans.md) | Future upgrade plans |
| [ssh-access-cheatsheet.md](ssh-access-cheatsheet.md) | SSH quick reference |

---

## Changelog (Recent)

| Date | Change |
|------|--------|
| 2026-01-16 | PC health monitoring: n8n heartbeats, IFTTT power cycle, Twingate headless |
| 2026-01-13 | Reorganized homelab docs into per-node files |
| 2026-01-12-13 | Pixelbook Go: CachyOS Hyprland, reverse tunnel, power management |
| 2026-01-10 | Pixelbook Go: Initial Twingate connector setup |
| 2026-01-09 | Frigate: Added porch camera, moved to HDD, 30-day retention |
| 2026-01-09 | Pi1: Git backup mirror via Windows ICS |
| 2026-01-07 | Windows PC: WSL SSH setup, Twingate connector |
| 2026-01-06 | 4TB HDD ZFS pool, media migration |
