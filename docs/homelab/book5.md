# Proxmox Node 1 - prox-book5

**Device**: Samsung Galaxy Book5 Pro 360
**Hostname**: prox-book5
**OS**: Proxmox VE 8.x
**Role**: Proxmox cluster node 1, reverse tunnel endpoint

---

## Quick Access

```bash
# From Mac
ssh book5           # Alias
ssh root@192.168.2.250

# Web UI
https://192.168.2.250:8006
```

---

## Hardware

| Component | Details |
|-----------|---------|
| Model | Samsung Galaxy Book5 Pro 360 |
| CPU | Intel Core Ultra (details TBD) |
| RAM | 16GB |
| Storage | 880GB NVMe (ZFS) |
| Display | 15.6" AMOLED touchscreen (disabled for server use) |

### Network Interfaces

| Interface | Type | Speed | IP | Purpose |
|-----------|------|-------|-----|---------|
| USB-C Dock | Ethernet | 1 Gbps | 192.168.2.250 | Management (vmbr0) |
| Realtek RTL8156 | USB 3.0 | 2.5 Gbps | 10.10.10.1 | Inter-node link (vmbr1) |

---

## Network Configuration

| Network | IP | Bridge | Purpose |
|---------|-----|--------|---------|
| Management | 192.168.2.250 | vmbr0 | SSH, Twingate, VMs |
| Inter-Node | 10.10.10.1/30 | vmbr1 | Direct link to tower |

```
Mac → Twingate → book5:22 → SSH
book5 ◄─── 2.5 Gbps ───► tower (10.10.10.0/30)
```

---

## Proxmox Configuration

### Cluster

| Property | Value |
|----------|-------|
| Cluster Name | home-cluster |
| Node ID | 1 |
| Quorum | 3 votes (2 nodes + QDevice on Pi) |

### Storage

| Storage | Type | Size | Content |
|---------|------|------|---------|
| local | ZFS | 880GB | ISOs, templates |
| local-zfs | ZFS | 880GB | VM disks |

### VMs

| VMID | Name | IP | Status |
|------|------|-----|--------|
| 100 | Omarchy | 192.168.2.161 | Auto-start |

---

## Services

| Service | Type | Purpose |
|---------|------|---------|
| Twingate Connector | systemd | jaded423 network access |
| SSH (port 22) | Native | Remote management |
| Proxmox Web UI | Port 8006 | Cluster management |
| Samba | Native | File sharing |
| Reverse Tunnel :2244 | Listener | Pixelbook Go access |

### Twingate Connector

```bash
# Check status
systemctl status twingate-connector

# Restart
systemctl restart twingate-connector

# Logs
journalctl -u twingate-connector -f
```

### Samba Share

```bash
# From Mac Finder: Cmd+K
smb://192.168.2.250/Shared
```

### Reverse Tunnel (from Pixelbook Go)

Go maintains a persistent SSH tunnel to book5:2244. Mac connects to Go via:

```bash
ssh go    # → ProxyJump book5 → localhost:2244 → Go
```

---

## Cluster Commands

```bash
# Check cluster status
pvecm status

# Check quorum
pvecm expected 1    # View expected votes

# List nodes
pvecm nodes
```

---

## Twingate Weekly Updates

**Schedule**: Sunday 3:00 AM
**Log**: `/var/log/twingate-upgrade.log`

```bash
# Skip before travel
OOO    # Creates skip file

# Check skip status
ls /var/log/twingate-skip-upgrade
```

---

## SSH Configuration

### On Mac (`~/.ssh/config`)

```ssh-config
Host 192.168.2.250 prox-book5 book5
  HostName 192.168.2.250
  User root
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

### Authorized Keys

Contains keys from:
- Mac (for direct access)
- Pixelbook Go (for reverse tunnel)

---

## Troubleshooting

### Twingate not connecting after reboot

```bash
# On book5
systemctl restart twingate-connector

# On Mac
killall Twingate && open -a Twingate
# Wait 5-10 minutes for routes to re-establish
```

### Can't access VMs via ProxyJump

1. Check book5 is reachable: `ssh book5 hostname`
2. Check VM is running: `ssh book5 "qm status 100"`
3. Check VM network: `ssh book5 "qm guest cmd 100 network-get-interfaces"`

### Inter-node link down

```bash
# Check interface
ip addr show vmbr1

# Ping tower
ping 10.10.10.2

# Check cable/adapter
ethtool vmbr1
```

### Cluster quorum issues

```bash
# Check quorum status
pvecm status

# If QDevice offline, can still operate with both nodes
pvecm expected 2
```

---

## Related Docs

- [tower.md](tower.md) - Proxmox Node 2
- [omarchy.md](omarchy.md) - VM 100 on this host
- [go.md](go.md) - Pixelbook Go (reverse tunnel terminates here)
- [pihole.md](pihole.md) - QDevice host
