# SSH Access Cheat Sheet

Quick reference for accessing all machines in the multi-location network.

**Last Updated:** January 7, 2026 (Added Windows PC etintake - WSL Ubuntu SSH)

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
ssh jaded@192.168.1.126     # VM 101 - Ubuntu Server (via prox-tower, on 2.5GbE)

# Raspberry Pi
ssh jaded@192.168.2.131     # magic-pihole (Pi-hole, Twingate, MagicMirror)

# Mac (from homelab - direct LAN access)
ssh j@192.168.2.226                    # Mac direct (from book5, tower)
ssh mac                                # Using alias (works from book5, tower, termux)

# Windows PC - WSL Ubuntu (aliases: etintake, wsl, pc)
ssh etintake                           # Port 2222, user joshua
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
│ └─ VM 100         │          │ └─ VM 101 (on 2.5GbE network)   │
│    192.168.2.161  │          │    192.168.1.126                │
│    Omarchy        │          │    Ubuntu Server                │
│    User: jaded    │          │    User: jaded                  │
└───────────────────┘          └─────────────────────────────────┘
```

**Note (Dec 13, 2025):** prox-tower now has dual NICs - Intel I218-LM (1GbE, management/Twingate) and Realtek RTL8125 (2.5GbE, VMs/primary). VM 101 runs on the faster 2.5GbE network.

---

## Device Reference Table

| Device | IP | User | Access Method | Services |
|--------|-----|------|---------------|----------|
| **prox-book5** | 192.168.2.250 | root | Direct SSH | Proxmox Node 1, Twingate (systemd) |
| **prox-tower** | 192.168.2.249 (mgmt) | root | Direct SSH | Proxmox Node 2, Twingate (systemd) |
| **prox-tower** | 192.168.1.249 (2.5G) | root | Direct SSH | Primary network, VM bridge |
| **VM 100 (Omarchy)** | 192.168.2.161 | jaded | ProxyJump via .250 | Arch Desktop |
| **VM 101 (Ubuntu)** | **192.168.1.126** | jaded | ProxyJump via .249 | Docker, Ollama, Jellyfin (2.5GbE) |
| **magic-pihole** | 192.168.2.131 | jaded | Direct SSH | Pi-hole, Twingate, MagicMirror |
| **Mac (macAir)** | 192.168.2.226 | j | Direct (book5/tower), ProxyJump (termux) | Development |
| **etintake (Win PC)** | 192.168.1.193:2222 | joshua | Direct/Twingate | WSL Ubuntu, Twingate connector |

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

# VM 101 - Ubuntu Server (on 2.5GbE network, ProxyJump through prox-tower)
Host 192.168.1.126 ubuntu-server ubuntu vm101
  HostName 192.168.1.126
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
ssh ubuntu-server # → jaded@192.168.1.126 (via ProxyJump, 2.5GbE)
ssh ubuntu        # → jaded@192.168.1.126 (via ProxyJump, 2.5GbE)
ssh vm101         # → jaded@192.168.1.126 (via ProxyJump, 2.5GbE)
ssh pihole        # → jaded@192.168.2.131
ssh pi            # → jaded@192.168.2.131
ssh mac           # → j@192.168.2.226
ssh macair        # → j@192.168.2.226
ssh etintake      # → joshua@192.168.1.193:2222
ssh wsl           # → joshua@192.168.1.193:2222
ssh pc            # → joshua@192.168.1.193:2222
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

## Quick Copy Commands

**Copy file TO Ubuntu Server:**
```bash
scp file.txt jaded@192.168.1.126:~/
# Or use alias:
scp file.txt ubuntu-server:~/
```

**Copy file FROM Ubuntu Server:**
```bash
scp jaded@192.168.1.126:~/file.txt ./
# Or use alias:
scp ubuntu-server:~/file.txt ./
```

**Rsync to Ubuntu Server:**
```bash
rsync -avz ./folder/ jaded@192.168.1.126:~/folder/
# Or use alias:
rsync -avz ./folder/ ubuntu-server:~/folder/
```

**Execute remote command:**
```bash
ssh jaded@192.168.1.126 "docker ps"
# Or use alias:
ssh ubuntu-server "docker ps"
```
