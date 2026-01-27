# Windows PC - etintake

**Device**: Custom Desktop PC (Windows 11)
**Hostname**: etintake
**OS**: Windows 11 + WSL2 Ubuntu
**Setup Date**: January 7, 2026

---

## Quick Access

```bash
# From Mac (via reverse tunnel - works remotely)
ssh pc-tunnel       # PowerShell via book5:2245

# From Mac (direct - same network only, Twingate client conflict)
ssh pc              # PowerShell (port 22) - currently broken
ssh wsl             # WSL Ubuntu (port 2222) - currently broken

# Pi1 (via PC tunnel)
ssh pi1             # ProxyJump through pc-tunnel
```

**Note**: Direct SSH (192.168.1.193) doesn't work when Twingate client is running due to client/connector conflict. Use reverse tunnel instead.

---

## Hardware

| Component | Details |
|-----------|---------|
| CPU | Intel Core (details TBD) |
| RAM | 16GB+ |
| Storage | SSD + additional drives |
| Network | WiFi (192.168.1.x) + Ethernet (ICS to Pi1) |

---

## Network Configuration

| Interface | IP | Purpose |
|-----------|-----|---------|
| WiFi | 192.168.1.193 (DHCP) | Main network, Twingate |
| Ethernet | 192.168.137.1 | ICS gateway for Pi1 |

```
Mac → Twingate → PC:22 (PowerShell)
Mac → Twingate → PC:2222 → portproxy → WSL:22
Pi1 → PC:192.168.137.1 (ICS NAT) → WiFi → Internet
```

---

## SSH Configuration

### PowerShell (Port 22)

Native Windows OpenSSH server.

```bash
ssh pc                           # Aliases: pc, win-pc, windows, etintake
ssh joshu@192.168.1.193          # Direct
```

### WSL Ubuntu (Port 2222)

SSH server running inside WSL2, port-forwarded from Windows.

```bash
ssh wsl                          # Aliases: wsl
ssh -p 2222 joshua@192.168.1.193 # Direct
```

**Architecture:**
```
Mac → Twingate → Windows:2222 → netsh portproxy → WSL:22 → SSH
```

---

## WSL Configuration

### Auto-Start Script

**Location**: `/etc/wsl-ssh-startup.sh`

Runs on WSL boot via `/etc/wsl.conf`:

```bash
#!/bin/bash
mkdir -p /run/sshd
rm -f /run/nologin /etc/nologin
service ssh start

# Update Windows port forwarding to current WSL IP
WSL_IP=$(hostname -I | awk '{print $1}')
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0" 2>/dev/null
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=$WSL_IP"
```

### Manual Fix Script

**Location**: `/usr/local/bin/fix-wsl-ssh`

```bash
#!/bin/bash
# Run this if SSH fails after reboot
sudo mkdir -p /run/sshd
sudo rm -f /run/nologin /etc/nologin
sudo service ssh restart

WSL_IP=$(hostname -I | awk '{print $1}')
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0"
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=$WSL_IP"
echo "WSL IP: $WSL_IP, port forwarding updated"
```

---

## Reverse Tunnel (Remote Access)

PC runs Twingate **client** for outbound homelab access. Incoming SSH uses reverse tunnel through book5 (same pattern as Pixelbook Go).

```
Mac → Twingate → book5 → localhost:2245 → PC:22
```

**Scheduled Task**: "SSH Tunnel to book5"
- Runs at logon, background (no window)
- Auto-restarts on failure
- Key: `C:\Users\joshu\.ssh\id_ed25519`

```powershell
# Check status
Get-ScheduledTask -TaskName "SSH Tunnel to book5" | Select-Object State

# Restart
Start-ScheduledTask -TaskName "SSH Tunnel to book5"

# Stop
Stop-ScheduledTask -TaskName "SSH Tunnel to book5"
```

---

## Services

| Service | Location | Purpose |
|---------|----------|---------|
| Twingate Client | Windows | Outbound homelab access (jaded423 network) |
| Reverse SSH Tunnel | Scheduled Task | Inbound access via book5:2245 |
| RustDesk | Windows Service | Remote desktop (direct mode requires service running) |
| ICS (Internet Connection Sharing) | Ethernet adapter | Internet for Pi1 |
| Port Forward :2223 | netsh portproxy | SSH to Pi1 |
| COA Sync | Scheduled Task | Daily 6 AM - extracts COA data from Google Drive |
| Google Drive | H: and I: | H:=joshua@elevatedtrading.com, I:=joshua@daxdistro.com |

### Twingate Connector

Running in Docker inside WSL:

```bash
# Check status
docker ps | grep twingate

# Restart
docker restart twingate-connector
```

### Pi1 Port Forward

Windows routes port 2223 to Pi1:

```powershell
# View current rules
netsh interface portproxy show v4tov4

# Rule for Pi1
netsh interface portproxy add v4tov4 listenport=2223 listenaddress=0.0.0.0 connectport=22 connectaddress=192.168.137.123
```

---

## Troubleshooting

### RustDesk laggy/grainy

RustDesk service must be running AND firewall must allow TCP 53037 for direct LAN connections. If either is misconfigured, it falls back to Azure relay (high latency, grainy video).

```powershell
# Check service status
Get-Service RustDesk

# Start service
Start-Service RustDesk

# Verify firewall rule for direct connections exists
Get-NetFirewallRule -DisplayName '*RustDesk*53037*'

# If missing, create it:
New-NetFirewallRule -DisplayName 'RustDesk Direct TCP 53037' -Direction Inbound -Protocol TCP -LocalPort 53037 -Action Allow -Profile Any
```

**Verify from Mac** (during active session):
```bash
netstat -an | grep 192.168.1.193  # Should show direct connection
netstat -an | grep 21117          # If this shows instead, you're relayed
```

Direct connection: Mac → PC:53037 (TCP) + UDP:21119
Relay connection: Mac → Azure:21117 → PC (adds ~30ms latency, grainy)

### SSH fails after reboot

```bash
# In WSL
sudo /usr/local/bin/fix-wsl-ssh
```

### "System is booting up" error

```bash
sudo rm -f /run/nologin /etc/nologin
```

### WSL IP changed

The auto-start script handles this. If not working:

```bash
# Check current WSL IP
hostname -I

# Manually update port forward
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0"
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=$(hostname -I | awk '{print $1}')"
```

### Windows IP changed (DHCP)

Update Twingate resource in admin console, or set DHCP reservation on router.

### Can't reach Pi1

1. Check PC is powered on
2. Check ICS is enabled on ethernet adapter
3. Check port forward rule exists:
   ```powershell
   netsh interface portproxy show v4tov4
   ```

---

## Python & Automation Scripts

**Python**: 3.12 installed via winget (`C:\Users\joshu\AppData\Local\Programs\Python\Python312`)

**Scripts Directory**: `C:\scripts\`

```
C:\scripts\
├── gdrive_crawler.ps1      # Forces Google Drive to download PDFs locally
├── run_coa_sync.ps1        # Master script: crawler → Elevated COA → Dax COA
├── coa_sync.log            # Combined log file
├── coa\                    # Elevated Trading COA extraction
│   ├── extract_coa_data.py
│   ├── credentials.json
│   ├── sheets_token.json
│   └── logs\
└── coaDax\                 # Dax Distro COA extraction
    ├── extract_coa_data.py
    ├── credentials.json
    ├── token.json
    └── logs\
```

### COA Sync Scheduled Task

**Name**: "COA Sync"
**Schedule**: Daily at 6:00 AM
**Command**: `powershell -ExecutionPolicy Bypass -File C:\scripts\run_coa_sync.ps1`

```powershell
# Check status
schtasks /query /tn "COA Sync" /fo LIST /v

# Run manually
schtasks /run /tn "COA Sync"

# View log
Get-Content C:\scripts\coa_sync.log -Tail 50
```

### Google Drive Paths

| Drive | Account | Key Paths |
|-------|---------|-----------|
| H: | joshua@elevatedtrading.com | `H:\Shared drives\Elevated Trading, LLC\COA's\` |
| I: | joshua@daxdistro.com | `I:\.shortcut-targets-by-id\...\1 - THCa Flower COAs` |

**Note**: WSL cannot access Google Drive virtual folders due to drvfs permission restrictions. The crawler script reads first byte of each PDF to force local download, then Windows Python extracts data.

---

## WSL Google Drive Mounts

**fstab entries** (`/etc/fstab`):
```
H: /mnt/h drvfs defaults 0 0
I: /mnt/i drvfs defaults 0 0
```

**Note**: Mount points created but not usable for COA extraction due to permission issues with Google Drive's virtual file system. Production COA extraction runs on Windows Python instead.

---

## Related Docs

- [pi1.md](pi1.md) - Pi1 git backup mirror (connected via ICS)
- [../ssh-access-cheatsheet.md](../ssh-access-cheatsheet.md) - SSH quick reference
