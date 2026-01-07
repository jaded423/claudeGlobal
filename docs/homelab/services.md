# Homelab Services - Detailed Configuration

Reference for full service configuration, management, and troubleshooting.

---

## SSH Server (OpenSSH)

**Port:** 22 (TCP)
**Status Check:** `systemctl status sshd`
**Configuration:** `/etc/ssh/sshd_config`

**Security Features:**
- Root login disabled
- Public key authentication enabled
- Password authentication available as fallback

**Service Management:**
```bash
systemctl status sshd           # Check status
systemctl restart sshd          # Restart service
journalctl -u sshd -f           # View logs
```

---

## Samba File Server

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
```bash
# Mac (Finder: Cmd+K)
smb://192.168.2.250/Shared

# Windows
\\192.168.2.250\Shared

# CLI mount
mount_smbfs //jaded@192.168.2.250/Shared ~/mnt/homelab
```

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

---

## Twingate Connector

**Deployment:** Native systemd service on both Proxmox hosts
**Network:** jaded423
**Status Check:** `systemctl status twingate-connector`

**Connector Inventory (5 total):**

| Connector | Host | Type | Network |
|-----------|------|------|---------|
| Magic-pihole | 192.168.2.131 (Pi) | Docker | Homelab Network |
| prox-tower-systemd | 192.168.2.249 | systemd | Homelab Network |
| prox-book5-systemd | 192.168.2.250 | systemd | Homelab Network |
| mac-ssh | Mac | macOS | Mac-Remote |
| PC | Windows PC | Windows | Elevated |

**Configuration:**
- Config file: `/etc/twingate/connector.conf`
- Service: `/usr/lib/systemd/system/twingate-connector.service`
- Tokens: Stored in config file (auto-renewed)

**Service Management:**
```bash
systemctl status twingate-connector
systemctl restart twingate-connector
journalctl -u twingate-connector -f
cat /etc/twingate/connector.conf
```

**Admin Console:** https://jaded423.twingate.com

**Automated Weekly Updates:**

| Time (Sunday) | Connector | Script | Log |
|---------------|-----------|--------|-----|
| 3:00 AM | Magic-pihole | `/home/jaded/scripts/twingate-upgrade.sh` | `/var/log/twingate-upgrade.log` |
| 3:15 AM | prox-tower | `/root/scripts/twingate-upgrade.sh` | `/var/log/twingate-upgrade.log` |
| 3:30 AM | prox-book5 | `/root/scripts/twingate-upgrade.sh` | `/var/log/twingate-upgrade.log` |

**Skip Next Upgrade (OOO):**
```bash
# From Mac: Skip next Sunday's upgrades on all 3 nodes
OOO

# Manual skip (individual nodes)
ssh root@192.168.2.250 "touch /tmp/skip-twingate-upgrade"  # book5
ssh root@192.168.2.249 "touch /tmp/skip-twingate-upgrade"  # tower
ssh jaded@192.168.2.131 "touch /tmp/skip-twingate-upgrade" # magic-pi
```

---

## Docker

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
- User `jaded` in docker group (no sudo needed)

---

## Ollama (Local LLM Inference)

**Port:** 11434 (localhost)
**Status Check:** `systemctl status ollama`
**API Endpoint:** `http://127.0.0.1:11434`
**Open WebUI:** http://192.168.1.126:3000

**Storage Location:** `/mnt/ollama/models/` (NFS mount from prox-tower HDD)
**Configuration:** Systemd override sets `OLLAMA_MODELS=/mnt/ollama/models`

**Installed Models (~40GB total):**

| Model | Size | Purpose | Speed |
|-------|------|---------|-------|
| `qwen3-pure-hybrid` | 18GB | Complex reasoning | ~14 tok/s |
| `Qwen3-Pure` | 18GB | Base for hybrid | ~10 tok/s |
| `qwen-gon-jinn-hybrid` | 14GB | General tasks | ~12 tok/s |
| `qwen-gon-jinn` | 14GB | Base for hybrid | - |
| `qwen2.5-coder:7b` | 4.7GB | Code generation | Fast |
| `llama3.2:3b` | 2.0GB | Quick queries | Very fast |

**GPU Limits (Quadro M4000 - 8GB VRAM):**
- ≤18GB models: Hybrid GPU+CPU mode (~10-14 tok/s)
- 19GB+ models: CUDA crashes, need CPU-only (num_gpu 0)
- CPU-only: 70B=1.47 tok/s, 32B=2.64 tok/s (slow but usable)

**Service Management:**
```bash
systemctl status ollama
sudo systemctl restart ollama
journalctl -u ollama -f
```

**Usage:**
```bash
ollama list                           # List models
ollama run llama3.2:3b               # Interactive chat
ollama run qwen2.5-coder:7b          # Code assistant

# API request
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Why is the sky blue?"
}'
```

---

## Frigate NVR

**Port:** 5000 (Web UI), 8554 (RTSP), 8555 (WebRTC), 1883 (MQTT)
**Location:** VM 101 (192.168.1.126)
**Status Check:** `docker ps | grep frigate`
**Web UI:** http://192.168.1.126:5000

**Cameras:**

| Camera | Model | IP | Location |
|--------|-------|-----|----------|
| tapo_360_living_room | TP-Link Tapo C210 | 192.168.1.245 | Living Room |

**Detection Objects:** person, dog, cat, car

**Configuration Files:**
```
~/frigate/
├── docker-compose.yml
├── .env                  # RTSP credentials (chmod 600)
├── config/config.yml     # Frigate config
├── media/                # Recordings
└── mosquitto/config/mosquitto.conf
```

**Recording Settings:**
- Continuous: 7 days retention
- Events: 30 days retention
- Storage: ~/frigate/media (~200GB)

**Management:**
```bash
docker ps | grep -E 'frigate|mosquitto'
docker logs frigate -f
cd ~/frigate && docker compose restart frigate

# Update camera credentials
nano ~/frigate/.env
docker compose up -d --force-recreate frigate
```

**Adding New Cameras:**
1. Enable Camera Account in Tapo app
2. Note IP and RTSP credentials
3. Add to `~/frigate/config/config.yml`
4. `docker compose restart frigate`

**RTSP URL Format (Tapo):**
- High: `rtsp://user:pass@camera-ip:554/stream1`
- Low: `rtsp://user:pass@camera-ip:554/stream2`

---

## System Monitoring

### Glances
**Port:** 61208 (web mode)
**Access:** `http://192.168.2.250:61208`

```bash
btop               # Interactive (SSH)
glances            # Terminal mode
glances -w --port 61208  # Web server
```

### Netdata (DISABLED)
**Port:** 19999
**Status:** Stopped (power savings)
**Re-enable:** `sudo systemctl enable --now netdata`

---

## Battery Management (prox-book5)

**Method:** Samsung charge threshold
**Limit:** 80%

```bash
# Check threshold
cat /sys/class/power_supply/BAT1/charge_control_end_threshold

# Check current level
cat /sys/class/power_supply/BAT1/capacity

# Check status
cat /sys/class/power_supply/BAT1/status
```

---

## UFW Firewall

**Status Check:** `sudo ufw status verbose`

**Active Rules:**
```
22/tcp    ALLOW    # SSH
139/tcp   ALLOW    # Samba NetBIOS
445/tcp   ALLOW    # Samba SMB
```

**Management:**
```bash
sudo ufw status verbose
sudo ufw allow 80/tcp
sudo ufw delete allow 80/tcp
sudo ufw enable/disable
```
