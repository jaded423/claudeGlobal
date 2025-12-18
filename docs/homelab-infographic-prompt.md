# Home Lab Infographic Prompt

**Purpose:** Generate visual infographic of home lab infrastructure using Gemini or other AI image tools
**Last Updated:** December 18, 2025
**Tool Used:** Gemini Nano Banana (or similar)

---

## The Prompt

```
Create a professional, visually appealing infographic of my home lab infrastructure. The design should be clean and modern, using a dark theme (dark gray/black background) with accent colors for different components. Use icons where appropriate and make the SSH connection paths clearly visible with directional arrows.

## INFRASTRUCTURE OVERVIEW

**Cluster Name:** "home-cluster" (2-node Proxmox VE cluster with QDevice quorum)
**Total Power:** 105-185W (~$15-28/month)
**Remote Access:** Twingate zero-trust network (jaded423)

## NETWORK ARCHITECTURE

Two separate networks:

| Network | Subnet | Speed | Purpose |
|---------|--------|-------|---------|
| **Primary** | 192.168.1.0/24 | 2.5 Gbps | VMs, media streaming |
| **Management** | 192.168.2.0/24 | 1 Gbps | Twingate, remote access, cluster |

Gateway: 192.168.1.1 (Primary), 192.168.2.1 (Management)
DNS: Pi-hole at 192.168.2.131

## PHYSICAL DEVICES

### 1. Work Mac (External Client)
- **Role:** Development workstation, primary SSH client
- **User:** joshuabrown
- **Twingate:** Client (connects to home resources remotely)
- **Color suggestion:** Blue

### 2. prox-book5 (Proxmox Node 1)
- **Hardware:** Samsung Galaxy Book5 Pro laptop
- **IP:** 192.168.2.250
- **User:** root
- **Specs:** 16GB RAM, Intel Arc GPU, 952GB NVMe (ZFS)
- **Services:**
  - Twingate Connector (systemd)
  - Proxmox VE 9.1
- **Hosts:** VM 100
- **Color suggestion:** Green

### 3. prox-tower (Proxmox Node 2)
- **Hardware:** Lenovo ThinkStation 510 tower
- **IPs:**
  - 192.168.2.249 (Management, 1GbE Intel I218-LM)
  - 192.168.1.249 (Primary, 2.5GbE Realtek RTL8125)
- **User:** root
- **Specs:** 78GB RAM, 16-core Xeon E5-2683 v4, NVIDIA Quadro M4000
- **Services:**
  - Twingate Connector (systemd)
  - Proxmox VE 9.1
  - Intel AMT/vPro (out-of-band management)
- **Hosts:** VM 101
- **Note:** Dual-NIC with network bridging between subnets
- **Color suggestion:** Orange

### 4. Raspberry Pi 2 (magic-pihole)
- **IP:** 192.168.2.131
- **User:** jaded
- **Services:**
  - Pi-hole DNS (network-wide ad blocking)
  - Twingate Connector (backup, Docker)
  - Corosync QDevice (provides 3rd quorum vote)
  - MagicMirror kiosk (port 8080)
  - Portainer (port 9000)
- **Color suggestion:** Red/Pink

## VIRTUAL MACHINES

### VM 100: Omarchy Desktop
- **Host:** prox-book5
- **IP:** 192.168.2.161
- **User:** jaded
- **OS:** Arch Linux + Hyprland (DHH's Omarchy distro)
- **Specs:** 8GB RAM, 4 cores, 120GB disk
- **Access:** SSH via ProxyJump through prox-book5
- **Color suggestion:** Light green

### VM 101: Ubuntu Server
- **Host:** prox-tower
- **IP:** 192.168.1.126 (on 2.5GbE network)
- **User:** jaded
- **OS:** Ubuntu Server 24.04 LTS
- **Specs:** 40GB RAM, 6 cores, 300GB disk
- **Access:** SSH via ProxyJump through prox-tower
- **Docker Containers:**
  - Plex media server (port 32400)
  - qBittorrent (port 8080)
  - ClamAV antivirus
  - Open WebUI (port 3000)
- **Services:**
  - Ollama with 9 LLMs (port 11434)
  - NFS client (mounts book5 media storage)
  - Google Drive mounts (2 accounts via rclone)
- **Media Pipeline:** qBit → ClamAV scan → auto-sort → Plex
- **Color suggestion:** Light orange

## SSH CONNECTION PATHS (Show with arrows)

**Direct connections from Mac:**
```
Mac ─────────────────→ prox-book5 (192.168.2.250)
Mac ─────────────────→ prox-tower (192.168.2.249)
Mac ─────────────────→ prox-tower-fast (192.168.1.249)
Mac ─────────────────→ magic-pihole (192.168.2.131)
```

**ProxyJump connections (show as 2-hop):**
```
Mac ──→ prox-book5 ──→ VM 100 (192.168.2.161)
Mac ──→ prox-tower ──→ VM 101 (192.168.1.126)
```

**Cross-node (Proxmox to Proxmox):**
```
prox-book5 ←────────→ prox-tower (direct LAN)
```

**Twingate flow (for remote access):**
```
Mac (remote) → Twingate Cloud → Connectors (book5/tower/Pi) → Resources
```

## SSH ALIASES TABLE

| Alias | Target | User | Method |
|-------|--------|------|--------|
| `prox-book5`, `book5` | 192.168.2.250 | root | Direct |
| `prox-tower`, `tower` | 192.168.2.249 | root | Direct |
| `tower-fast` | 192.168.1.249 | root | Direct (2.5GbE) |
| `omarchy`, `vm100` | 192.168.2.161 | jaded | ProxyJump via .250 |
| `ubuntu`, `vm101` | 192.168.1.126 | jaded | ProxyJump via .249 |
| `pihole`, `pi` | 192.168.2.131 | jaded | Direct |

## DATA FLOWS TO VISUALIZE

1. **NFS Media Storage:**
   prox-book5 (/srv/media, 847GB) ──NFS──→ VM 101 (/mnt/book5-media)

2. **Google Drive Integration:**
   VM 101 (rclone mounts) ──SSHFS──→ prox-book5 & prox-tower (/mnt/elevated, /mnt/jaded)

3. **Cluster Quorum:**
   prox-book5 + prox-tower + Pi QDevice = 3 votes (need 2 for quorum)

4. **Routing between subnets:**
   192.168.1.x ←──prox-tower dual-NIC──→ 192.168.2.x

## TWINGATE RESOURCES TABLE

| Resource | Address | Ports | Connector |
|----------|---------|-------|-----------|
| prox-book5 SSH | 192.168.2.250 | 22 | book5 |
| prox-tower SSH | 192.168.2.249 | 22 | tower |
| magic-pihole SSH | 192.168.2.131 | 22 | Pi |
| Samba Shares | 192.168.2.250 | 139, 445 | book5 |
| Plex | 192.168.1.126 | 32400 | tower |

## VISUAL LAYOUT SUGGESTIONS

1. **Top section:** "home-cluster" banner with cluster stats
2. **Main area:** Physical devices arranged showing network topology
   - Left side: Management network (192.168.2.x)
   - Right side: Primary network (192.168.1.x)
   - prox-tower in center bridging both networks
3. **VMs:** Shown nested inside their Proxmox hosts
4. **Docker containers:** Shown as smaller boxes inside VM 101
5. **SSH paths:** Colored arrows (different colors for direct vs ProxyJump)
6. **Bottom section:** Quick reference tables (aliases, ports, Twingate resources)
7. **Legend:** Color coding for device types, connection types, network zones

## STYLE NOTES

- Modern, clean design suitable for technical documentation
- Dark theme with high contrast for readability
- Use consistent iconography (server icons, VM icons, container icons, network icons)
- Show dual-NIC on prox-tower clearly (two network interfaces)
- Emphasize the ProxyJump paths since those are the non-obvious SSH routes
- Include power consumption and cost info in corner
- Make it suitable for printing on letter/A4 paper in landscape orientation
```

---

## Usage Notes

**To regenerate the infographic:**
1. Copy the prompt above (everything inside the code block)
2. Paste into Gemini Nano Banana or similar AI image generator
3. Review output for accuracy against current infrastructure
4. Tweak specific values as infrastructure changes

**When to update this prompt:**
- Adding/removing VMs
- Changing IP addresses
- Adding new services or containers
- Hardware upgrades
- Network topology changes

**Related documentation:**
- [homelab.md](homelab.md) - Full technical documentation
- [ssh-access-cheatsheet.md](ssh-access-cheatsheet.md) - SSH connection details
- [homelab-expansion.md](homelab-expansion.md) - Future plans

## Changelog

| Date | Change |
|------|--------|
| 2025-12-18 | Initial prompt creation, generated first infographic |
