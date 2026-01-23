# VM 101 - Ubuntu Server

**Device**: Proxmox VM on prox-tower
**Hostname**: ubuntu-server
**OS**: Ubuntu Server 22.04 LTS
**Role**: Primary services host (Docker, Ollama, media servers)

---

## Quick Access

```bash
# From Mac
ssh ubuntu          # Alias
ssh vm101           # Alias
ssh jaded@192.168.2.126

# ProxyJump through tower (automatic via SSH config)
```

---

## VM Configuration

| Property | Value |
|----------|-------|
| VMID | 101 |
| Host | prox-tower |
| RAM | 48GB |
| vCPU | 28 cores |
| Disk | 100GB (on tower rpool) |
| Network | vmbr0 (192.168.2.x) |
| GPU | NVIDIA Quadro M4000 (8GB, passthrough) |

---

## Network Configuration

| Interface | IP | Purpose |
|-----------|-----|---------|
| eth0 | 192.168.2.126 | Management, services |
| Gateway | 192.168.2.1 | Router |

```
Mac → Twingate → tower → ProxyJump → ubuntu:22
```

---

## Storage Mounts

NFS mounts from prox-tower's media-pool:

| Mount Point | Source | Size | Purpose |
|-------------|--------|------|---------|
| /mnt/media-pool/media | tower:/media-pool/media | ~2TB | Plex/Jellyfin content |
| /mnt/media-pool/ollama | tower:/media-pool/ollama | ~50GB | LLM models |
| /mnt/media-pool/frigate | tower:/media-pool/frigate | ~1TB | NVR recordings |

```bash
# Check mounts
df -h | grep media-pool

# Remount if needed
sudo mount -a
```

---

## Services Overview

### Docker Containers

| Container | Port | Compose Location | Purpose |
|-----------|------|------------------|---------|
| plex | 32400 | ~/docker/plex/ | Media server |
| jellyfin | 8096 | ~/docker/ | Media server (backup) |
| qbittorrent | 8080 | ~/docker/ | Torrent client (Web UI) |
| frigate | 5000 | ~/docker/frigate/ | NVR - 2 cameras |
| mosquitto | 1883 | ~/docker/frigate/ | MQTT broker |
| open-webui | 3000 | ~/docker/open-webui/ | Ollama chat interface |
| odoo | 8069 | ~/docker/odoo/ | Business ERP |
| odoo-db | - | ~/docker/odoo/ | PostgreSQL for Odoo |
| gitea | 3001 (web), 2223 (ssh) | ~/docker/gitea/ | Self-hosted Git server |
| clamav | - | ~/docker/ | Antivirus scanning |
| portainer | 9000 | (docker run) | Docker management UI |

```bash
# Check all containers
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Restart a container
docker restart <container_name>

# View logs
docker logs -f <container_name>
```

### Systemd Services

| Service | Port | Purpose |
|---------|------|---------|
| ollama | 11434 | LLM inference API |

```bash
# Check Ollama
systemctl status ollama

# Restart
sudo systemctl restart ollama
```

### Open WebUI

Ollama chat interface at http://192.168.2.126:3000

```bash
# Upgrade
cd ~/docker/open-webui
docker compose pull
docker compose up -d

# Check logs
docker logs -f open-webui
```

---

### Gitea (Self-Hosted Git)

Private Git server at http://192.168.2.126:3001

```bash
# Manage
cd ~/docker/gitea
docker compose up -d
docker compose logs -f

# Clone via SSH (from Mac)
git clone ssh://git@192.168.2.126:2223/jaded/repo-name.git

# Create repo via API
curl -X POST "http://localhost:3001/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u 'user:pass' \
  -d '{"name":"repo-name","private":true}'
```

---

## Ollama LLMs

**Models stored on HDD** via NFS mount.
**GPU**: Quadro M4000 (8GB VRAM) - hybrid mode for large models.

| Model | Size | Best For | Speed |
|-------|------|----------|-------|
| qwen3-pure-hybrid | 18GB | Complex reasoning, coding | ~14 tok/s |
| qwen-gon-jinn-hybrid | 14GB | General tasks | ~12 tok/s |
| qwen2.5-coder:7b | 4.7GB | Code generation | Fast (full GPU) |
| llama3.2:3b | 2.0GB | Quick queries | Very fast |

**GPU Limits**: Models ≤18GB work in hybrid mode. 19GB+ crash, need CPU-only.

```bash
# List models
ollama list

# Run a model
ollama run qwen2.5-coder:7b

# Check GPU usage
nvidia-smi
```

---

## Frigate NVR

**Storage**: HDD via NFS (async mode, ~130 MB/s)
**Recording**: Continuous 24/7, 30-day retention
**Config**: `~/docker/frigate/docker-compose.yml`

| Camera | IP | Resolution | Codec |
|--------|-----|------------|-------|
| tapo_360_living_room | 192.168.1.245 | 2560x1440 (2K) | H.264 |
| tapo_porch | 192.168.1.129 | 3840x2160 (4K) | H.265 |

**Storage math**: ~35 GB/day → ~1 TB at 30 days

```bash
# Check Frigate
docker logs frigate

# Restart
cd ~/docker/frigate && docker compose restart frigate

# Web UI
http://192.168.2.126:5000
```

---

## Media Servers

### Plex

- **Port**: 32400
- **Web UI**: http://192.168.2.126:32400/web
- **Content**: /mnt/media-pool/media

### Jellyfin

- **Port**: 8096
- **Web UI**: http://192.168.2.126:8096
- **Content**: /mnt/media-pool/media

### qBittorrent

- **Port**: 8080
- **Web UI**: http://192.168.2.126:8080
- **Download path**: /mnt/media-pool/media/downloads

---

## Google Drive Mounts

rclone FUSE mounts for cloud storage access:

```bash
# Check mount status
mount | grep rclone

# Remount
rclone mount gdrive: /mnt/gdrive --daemon
```

See [google-drive.md](google-drive.md) for full configuration.

---

## SSH Configuration

### On Mac (`~/.ssh/config`)

```ssh-config
Host 192.168.2.126 ubuntu-server ubuntu vm101
  HostName 192.168.2.126
  User jaded
  ProxyJump 192.168.2.249
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

### On Ubuntu

User: `jaded` (passwordless sudo)

---

## Docker Compose Organization

All compose files are organized under `~/docker/`:

```
~/docker/
├── frigate/
│   ├── docker-compose.yml
│   ├── .env
│   ├── config/
│   └── mosquitto/
├── gitea/
│   ├── docker-compose.yaml
│   └── data/
├── odoo/
│   └── docker-compose.yml
├── open-webui/
│   └── docker-compose.yml
└── plex/
    └── docker-compose.yml
```

```bash
# Manage any service
cd ~/docker/<service> && docker compose up -d
cd ~/docker/<service> && docker compose logs -f
cd ~/docker/<service> && docker compose restart
```

---

## Quick Commands

```bash
# Docker status
docker ps

# Check GPU
nvidia-smi

# Check disk usage
df -h

# Check NFS mounts
mount | grep nfs

# Ollama models
ollama list
```

---

## Troubleshooting

### NFS mounts missing

```bash
# Check mount points
ls /mnt/media-pool/

# Remount
sudo mount -a

# Check fstab
cat /etc/fstab | grep media-pool
```

### GPU not available

```bash
# Check GPU visibility
nvidia-smi

# If not visible, may need VM reboot
# Or check passthrough on tower host
```

### Ollama out of memory

Large models (19GB+) exceed GPU VRAM. Options:
1. Use smaller model
2. Set `OLLAMA_NUM_GPU=0` for CPU-only (slow)

### Docker container won't start

```bash
# Check logs
docker logs <container>

# Check disk space
df -h

# Recreate container
docker compose up -d --force-recreate <container>
```

---

## Related Docs

- [tower.md](tower.md) - Host (prox-tower)
- [gpu-passthrough.md](gpu-passthrough.md) - Quadro M4000 setup
- [media-server.md](media-server.md) - Plex/Jellyfin organization
- [google-drive.md](google-drive.md) - rclone configuration
