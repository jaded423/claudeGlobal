# Proxmox Node 2 - prox-tower

**Device**: Lenovo ThinkStation P510
**Hostname**: prox-tower
**OS**: Proxmox VE 8.x
**Role**: Primary compute node, media server host

---

## Quick Access

```bash
# From Mac
ssh tower           # Alias (management network)
ssh root@192.168.2.249

# Web UI
https://192.168.2.249:8006
```

---

## Hardware

| Component | Details |
|-----------|---------|
| Model | Lenovo ThinkStation P510 |
| CPU | Intel Xeon E5-2667 v4 (16 cores / 32 threads, 3.2GHz) |
| RAM | 78GB DDR4 ECC |
| GPU | NVIDIA Quadro M4000 (8GB VRAM) - passed to VM 101 |
| Storage | 370GB SSD (ZFS) + 4TB HDD (media-pool) |
| Form Factor | Tower workstation |

### RAM Allocation

| Use | Amount |
|-----|--------|
| VM 101 | 48GB |
| ZFS ARC | 18GB |
| Host/overhead | 12GB |

### Network Interfaces

| Interface | Type | Speed | IP | Bridge | Purpose |
|-----------|------|-------|-----|--------|---------|
| Intel I218-LM | Onboard | 1 Gbps | 192.168.2.249 | vmbr0 | Management, Twingate |
| Realtek RTL8125 | PCIe | 2.5 Gbps | 10.10.10.2 | vmbr1 | Inter-node link |

**Note**: Intel I218-LM has TSO bug - see Known Issues below.

---

## Network Configuration

| Network | IP | Bridge | Purpose |
|---------|-----|--------|---------|
| Management | 192.168.2.249 | vmbr0 | SSH, Twingate, VM bridge |
| Inter-Node | 10.10.10.2/30 | vmbr1 | Direct link to book5 |

```
Mac → Twingate → tower:22 → SSH
tower ◄─── 2.5 Gbps ───► book5 (10.10.10.0/30)
```

---

## Storage

### ZFS Pools

| Pool | Devices | Size | Purpose |
|------|---------|------|---------|
| rpool | 370GB SSD | 370GB | System, VM disks |
| media-pool | 4TB HDD | 3.5TB usable | Media, Ollama models, Frigate |

### Media Pool Mounts

```
/media-pool/
├── media/       # Plex/Jellyfin content
├── ollama/      # LLM models
└── frigate/     # NVR recordings
```

Exported to VM 101 via NFS (async mode, ~130 MB/s).

---

## Proxmox Configuration

### Cluster

| Property | Value |
|----------|-------|
| Cluster Name | home-cluster |
| Node ID | 2 |
| Quorum | 3 votes (2 nodes + QDevice on Pi) |

### VMs

| VMID | Name | IP | RAM | vCPU | Status |
|------|------|-----|-----|------|--------|
| 101 | Ubuntu Server | 192.168.2.126 | 48GB | 28 | Auto-start |

### GPU Passthrough

Quadro M4000 passed through to VM 101 for Ollama acceleration:

```bash
# Check passthrough status
lspci -nnk | grep -A3 NVIDIA

# Should show: Kernel driver in use: vfio-pci
```

---

## Services

| Service | Type | Purpose |
|---------|------|---------|
| Twingate Connector | systemd | jaded423 network access |
| SSH (port 22) | Native | Remote management |
| Proxmox Web UI | Port 8006 | Cluster management |
| NFS Server | Native | media-pool exports to VM 101 |

### Twingate Connector

```bash
# Check status
systemctl status twingate-connector

# Restart
systemctl restart twingate-connector

# Logs
journalctl -u twingate-connector -f
```

### NFS Exports

```bash
# View exports
cat /etc/exports

# Example:
# /media-pool/media 192.168.2.126(rw,async,no_subtree_check)
# /media-pool/ollama 192.168.2.126(rw,async,no_subtree_check)
# /media-pool/frigate 192.168.2.126(rw,async,no_subtree_check)
```

---

## Known Issues

### Intel I218-LM TSO Bug

**Problem**: TCP Segmentation Offload causes network hangs requiring physical reboot.

**Fix Applied** in `/etc/network/interfaces`:

```
post-up ethtool -K nic0 tso off gso off gro off
```

**Verify fix:**
```bash
ethtool -k nic0 | grep -E 'tcp-seg|generic'
# All should show "off"
```

---

## Twingate Weekly Updates

**Schedule**: Sunday 3:15 AM (15 min after book5)
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
Host 192.168.2.249 prox-tower tower
  HostName 192.168.2.249
  User root
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

---

## Quick Commands

```bash
# Check ZFS pool status
zpool status media-pool

# Check disk usage
zfs list

# Check NFS clients
showmount -a

# Check GPU passthrough
lspci -nnk | grep -A3 NVIDIA

# Check cluster status
pvecm status
```

---

## Troubleshooting

### Network hangs (Intel NIC)

If network becomes unresponsive:
1. Physical reboot required (power cycle)
2. Verify TSO is disabled after boot:
   ```bash
   ethtool -k nic0 | grep tso
   ```

### NFS not mounting in VM

```bash
# Check exports
exportfs -v

# Check NFS service
systemctl status nfs-server

# Restart if needed
systemctl restart nfs-server
```

### GPU not available in VM

```bash
# Check VFIO binding on host
lspci -nnk | grep -A3 NVIDIA

# Should show: Kernel driver in use: vfio-pci
# If not, check /etc/modprobe.d/vfio.conf
```

---

## Related Docs

- [book5.md](book5.md) - Proxmox Node 1
- [ubuntu.md](ubuntu.md) - VM 101 on this host
- [pihole.md](pihole.md) - QDevice host
- [gpu-passthrough.md](gpu-passthrough.md) - Quadro M4000 setup
