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
- Triggers: System startup (30s delay) + At logon
- Restart on failure: 5 retries, 1 minute apart
- Script: `C:\Users\joshu\bin\start-tunnel.ps1` (infinite reconnect loop, 10s between attempts)
- SSH keepalive: 60s interval, disconnects after 3 failures (dead connection detection)
- Key: `C:\Users\joshu\.ssh\id_ed25519`

**Boot behavior**: ~70 second window after boot where Twingate stabilizes. Tunnel auto-reconnects.

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
| Auto-Mount Cron | WSL cron.d | Every 5 min - mounts H:/I: if not mounted |

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

**Root cause**: fstab mount failures (H:/I: drives not ready) leave `/var/run/nologin` in place.

**Permanent fix**: Use `nofail` in fstab (see WSL Google Drive Mounts section).

**Immediate fix** (if it happens):
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
H: /mnt/h drvfs defaults,nofail 0 0
I: /mnt/i drvfs defaults,nofail 0 0
```

**Important**: The `nofail` option is critical - without it, WSL boot fails if Google Drive isn't ready, leaving `/var/run/nologin` in place and blocking SSH logins.

**Note**: Mount points created but not usable for COA extraction due to permission issues with Google Drive's virtual file system. Production COA extraction runs on Windows Python instead.

### Auto-Mount Cron Job

**Script**: `/usr/local/bin/ensure-mounts.sh`
**Cron**: `/etc/cron.d/ensure-mounts` - runs every 5 minutes as root
**Log**: `/var/log/ensure-mounts.log`

Automatically mounts H: and I: if not already mounted. Ensures drives are available even if they weren't ready at boot.

```bash
# Check mount status
mountpoint /mnt/h && mountpoint /mnt/i

# View log
tail /var/log/ensure-mounts.log

# Manual run
sudo /usr/local/bin/ensure-mounts.sh
```

### Mount-on-Demand for Scripts

Scripts can also ensure mounts directly:

```python
# Python: ensure_wsl_mounts() in inventory_sync.py
import subprocess
for drive, mp in [("H:", "/mnt/h"), ("I:", "/mnt/i")]:
    result = subprocess.run(["mountpoint", "-q", mp], capture_output=True)
    if result.returncode != 0:
        subprocess.run(["sudo", "mount", "-t", "drvfs", drive, mp])
```

```bash
# Bash: Add to script start
mountpoint -q /mnt/h || sudo mount -t drvfs H: /mnt/h
mountpoint -q /mnt/i || sudo mount -t drvfs I: /mnt/i
```

---

## COA Script Sync System (Mac ↔ WSL)

### Overview

The COA extraction scripts (`extract_coa_data.py`) run on both Mac and WSL, but have different file paths for Google Drive access. To enable easy syncing of code changes while keeping machine-specific paths separate, we use a **local_config.py** pattern.

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SOURCE OF TRUTH: Mac                          │
│                                                                      │
│  ~/projects/coa/                    ~/projects/coaDax/               │
│  ├── extract_coa_data.py  ←─────────────────────────────────────┐   │
│  ├── local_config.py      (Mac paths, gitignored)               │   │
│  └── local_config.py.example (template, tracked)                │   │
│                                                                  │   │
└──────────────────────────────────────────────────────────────────┼───┘
                                                                   │
                              SCP/Copy                             │
                                                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           WSL (PC)                                   │
│                                                                      │
│  ~/projects/coa/                    ~/projects/coaDax/               │
│  ├── extract_coa_data.py  (synced from Mac)                         │
│  ├── local_config.py      (WSL paths, created locally)              │
│  └── local_config.py.example                                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### How It Works

1. **Main script** (`extract_coa_data.py`) imports paths from `local_config.py`
2. **local_config.py** is gitignored - each machine has its own version
3. **local_config.py.example** is tracked - serves as template for new machines
4. When code changes, only `extract_coa_data.py` needs to be copied

### Files Structure

| File | Tracked? | Purpose |
|------|----------|---------|
| `extract_coa_data.py` | Yes | Main script (synced between machines) |
| `local_config.py` | **No** | Machine-specific paths (never synced) |
| `local_config.py.example` | Yes | Template for creating local_config.py |

### Machine-Specific Paths

#### coa/ (Elevated Trading COA)

| Variable | Mac | WSL |
|----------|-----|-----|
| `COA_BASE` | `/Users/j/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/Shared drives/Elevated Trading, LLC/COA's` | `/mnt/h/Shared drives/Elevated Trading, LLC/COA's` |
| `CREDENTIALS_PATH` | `~/projects/odooReports/AR_AP/credentials.json` | `~/projects/odooReports/AR_AP/credentials.json` |
| `TOKEN_PATH` | `~/projects/odooReports/inventory/sheets_token.json` | `~/projects/odooReports/inventory/sheets_token.json` |

#### coaDax/ (Dax Distro COA)

| Variable | Mac | WSL |
|----------|-----|-----|
| `COA_FOLDER` | `/Users/j/joshua@daxdistro.com - Google Drive/My Drive/1 - THCa Flower COAs` | `/mnt/i/.shortcut-targets-by-id/1v9wlV4MbLRypk-PwGZNzI6KYrKN9qnpX/1 - THCa Flower COAs` |

### Syncing Scripts from Mac to WSL

When you update the COA extraction logic on Mac, sync to WSL:

```bash
# From Mac - sync both COA scripts to WSL
scp ~/projects/coa/extract_coa_data.py wsl:~/projects/coa/
scp ~/projects/coaDax/extract_coa_data.py wsl:~/projects/coaDax/

# Or use a single command for both:
scp ~/projects/coa/extract_coa_data.py wsl:~/projects/coa/ && \
scp ~/projects/coaDax/extract_coa_data.py wsl:~/projects/coaDax/
```

**Important**: Only copy `extract_coa_data.py`, NOT `local_config.py`.

### Setting Up WSL (First Time)

If WSL doesn't have `local_config.py` yet:

```bash
# SSH to WSL
ssh wsl

# For coa/
cd ~/projects/coa
cp local_config.py.example local_config.py
nano local_config.py  # Edit paths for WSL

# For coaDax/
cd ~/projects/coaDax
cp local_config.py.example local_config.py
nano local_config.py  # Edit paths for WSL
```

#### WSL local_config.py for coa/

```python
from pathlib import Path

COA_BASE = Path("/mnt/h/Shared drives/Elevated Trading, LLC/COA's")
CREDENTIALS_PATH = Path.home() / "projects" / "odooReports" / "AR_AP" / "credentials.json"
TOKEN_PATH = Path.home() / "projects" / "odooReports" / "inventory" / "sheets_token.json"
```

#### WSL local_config.py for coaDax/

```python
from pathlib import Path

COA_FOLDER = Path("/mnt/i/.shortcut-targets-by-id/1v9wlV4MbLRypk-PwGZNzI6KYrKN9qnpX/1 - THCa Flower COAs")
```

### Verifying the Setup

```bash
# On WSL - test coa config
cd ~/projects/coa
python3 -c "from local_config import COA_BASE; print(COA_BASE); print(COA_BASE.exists())"

# On WSL - test coaDax config
cd ~/projects/coaDax
python3 -c "from local_config import COA_FOLDER; print(COA_FOLDER); print(COA_FOLDER.exists())"
```

### Troubleshooting

#### "local_config.py not found" Error

```bash
# Create from template
cp local_config.py.example local_config.py
# Edit with correct paths
nano local_config.py
```

#### "Path does not exist" Error

1. Check Google Drive is mounted: `mountpoint /mnt/h && mountpoint /mnt/i`
2. Mount if needed: `sudo mount -t drvfs H: /mnt/h`
3. Verify path exists: `ls -la /mnt/h/Shared\ drives/`

#### Script Works on Mac but Not WSL

1. Verify `local_config.py` exists on WSL
2. Check paths are correct for WSL (not Mac paths)
3. Ensure Google Drive mounts are accessible

### Best Practices

1. **Always develop on Mac first** - test changes before syncing
2. **Only sync extract_coa_data.py** - never overwrite local_config.py
3. **Check paths after syncing** - run the verification commands
4. **Keep local_config.py.example updated** - if you add new config variables, update the template

### Related Files

| Location | Purpose |
|----------|---------|
| `~/projects/coa/` | Elevated Trading COA extraction |
| `~/projects/coaDax/` | Dax Distro COA extraction |
| `~/projects/odooReports/inventory/` | Inventory sync (also runs on WSL) |
| `C:\scripts\` | Windows-native COA scripts (legacy) |

---

## Related Docs

- [pi1.md](pi1.md) - Pi1 git backup mirror (connected via ICS)
- [../ssh-access-cheatsheet.md](../ssh-access-cheatsheet.md) - SSH quick reference
