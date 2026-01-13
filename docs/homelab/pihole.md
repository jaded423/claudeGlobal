# Raspberry Pi 2 - magic-pihole

**Device**: Raspberry Pi 2 Model B
**Hostname**: magic-pihole
**OS**: Raspberry Pi OS
**Role**: DNS server, cluster QDevice, MagicMirror

---

## Quick Access

```bash
# From Mac
ssh pihole          # Alias
ssh pi              # Alias
ssh jaded@192.168.2.131

# Pi-hole Admin
http://192.168.2.131/admin
```

---

## Hardware

| Component | Details |
|-----------|---------|
| Model | Raspberry Pi 2 Model B |
| CPU | ARM Cortex-A7 (900MHz quad-core) |
| RAM | 1GB |
| Storage | 16GB+ SD card |
| Network | 10/100 Ethernet |
| Display | HDMI (for MagicMirror) |

---

## Network Configuration

| Interface | IP | Purpose |
|-----------|-----|---------|
| eth0 | 192.168.2.131 | Static IP |
| Gateway | 192.168.2.1 | Router |

---

## Services

### Pi-hole DNS

Network-wide ad blocking DNS server.

| Property | Value |
|----------|-------|
| Admin UI | http://192.168.2.131/admin |
| DNS Port | 53 |
| Upstream DNS | Cloudflare (1.1.1.1) |

```bash
# Check status
pihole status

# Update blocklists
pihole -g

# View query log
pihole -t

# Restart
pihole restartdns
```

**Router Configuration**: Set DHCP to distribute 192.168.2.131 as DNS server.

### Corosync QDevice

Provides third vote for Proxmox cluster quorum.

| Property | Value |
|----------|-------|
| Cluster | home-cluster |
| Votes | 1 (tie-breaker) |
| Port | 5403 |

```bash
# Check QDevice status (on Proxmox)
ssh book5 "pvecm status"

# Should show: Qdevice /dev/qdevice/...
```

With QDevice:
- Cluster has 3 votes (book5=1, tower=1, QDevice=1)
- Can survive one node failure
- Without QDevice, cluster needs both nodes for quorum

### MagicMirror

Smart mirror display interface (runs on attached HDMI display).

| Property | Value |
|----------|-------|
| Port | 8080 (local) |
| Config | ~/MagicMirror/config/config.js |

```bash
# Start MagicMirror
cd ~/MagicMirror && npm start

# Check status
pm2 status

# Restart
pm2 restart MagicMirror
```

### Twingate Connector

Running in Docker for jaded423 network access.

```bash
# Check status
docker ps | grep twingate

# Restart
docker restart twingate-connector
```

---

## SSH Configuration

### On Mac (`~/.ssh/config`)

```ssh-config
Host 192.168.2.131 pihole pi magic-pihole
  HostName 192.168.2.131
  User jaded
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

### On Pi

User: `jaded` (passwordless sudo)

---

## Twingate Weekly Updates

**Schedule**: Sunday 3:30 AM (30 min after tower)
**Log**: `/var/log/twingate-upgrade.log`

```bash
# Skip before travel
OOO    # Creates skip file
```

---

## Quick Commands

```bash
# Pi-hole status
pihole status

# Check DNS queries
pihole -c    # Chronometer (live stats)

# Update gravity (blocklists)
pihole -g

# Check disk usage
df -h

# Check temperature
vcgencmd measure_temp

# Reboot
sudo reboot
```

---

## Troubleshooting

### DNS not resolving

```bash
# Check Pi-hole is running
pihole status

# Check DNS service
systemctl status pihole-FTL

# Restart DNS
pihole restartdns
```

### Cluster quorum issues

If Pi goes offline, cluster loses QDevice vote:
- Still operational if both Proxmox nodes are up
- Single node failure will cause quorum loss

```bash
# Check from Proxmox
ssh book5 "pvecm status"

# Manually adjust expected votes if needed
ssh book5 "pvecm expected 2"
```

### MagicMirror not displaying

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs MagicMirror

# Restart
pm2 restart MagicMirror
```

### High CPU/temperature

```bash
# Check temperature
vcgencmd measure_temp

# Check processes
top

# Pi-hole can be CPU-intensive during gravity updates
```

---

## Related Docs

- [book5.md](book5.md) - Proxmox Node 1 (cluster member)
- [tower.md](tower.md) - Proxmox Node 2 (cluster member)
