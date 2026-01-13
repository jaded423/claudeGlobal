# Windows PC - etintake

**Device**: Custom Desktop PC (Windows 11)
**Hostname**: etintake
**OS**: Windows 11 + WSL2 Ubuntu
**Setup Date**: January 7, 2026

---

## Quick Access

```bash
# From Mac
ssh pc              # PowerShell (port 22)
ssh wsl             # WSL Ubuntu (port 2222)

# Pi1 (via PC)
ssh pi1             # ProxyJump through PC
```

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

## Services

| Service | Location | Purpose |
|---------|----------|---------|
| Twingate Connector | Docker in WSL | "Elevated" network, "PC" connector |
| RustDesk | Windows | Remote desktop access |
| ICS (Internet Connection Sharing) | Ethernet adapter | Internet for Pi1 |
| Port Forward :2223 | netsh portproxy | SSH to Pi1 |

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

## Related Docs

- [pi1.md](pi1.md) - Pi1 git backup mirror (connected via ICS)
- [../ssh-access-cheatsheet.md](../ssh-access-cheatsheet.md) - SSH quick reference
