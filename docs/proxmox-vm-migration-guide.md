# Proxmox VM Migration Guide
## Moving from Laptop to Tower Server

**Last Updated:** November 30, 2025
**Current Setup:** Samsung laptop (16GB RAM) → Tower PC (32GB RAM, upgradeable to 256GB)
**Target VM:** VM 102 (Ubuntu Server with Ollama + Docker services)

---

## Table of Contents
1. [Migration Options Overview](#migration-options-overview)
2. [Option 1: Backup & Restore (Simple)](#option-1-backup--restore)
3. [Option 2: Proxmox Cluster (Recommended)](#option-2-proxmox-cluster)
4. [Option 3: CEPH Storage Cluster (Future)](#option-3-ceph-storage-cluster)
5. [Pre-Migration Checklist](#pre-migration-checklist)
6. [Post-Migration Steps](#post-migration-steps)
7. [Testing & Validation](#testing--validation)

---

## Migration Options Overview

| Method | Downtime | Complexity | Best For | Keeps Models? |
|--------|----------|------------|----------|---------------|
| **Backup & Restore** | 30-60 min | Low | One-time migration | ✅ Yes |
| **Proxmox Cluster** | 0-5 min | Medium | Ongoing flexibility | ✅ Yes |
| **Manual Disk Copy** | 30-60 min | High | Special cases | ✅ Yes |
| **CEPH Cluster** | 0 min | High | 3+ node clusters | ✅ Yes |

---

## Option 1: Backup & Restore

**Best for:** Simple one-time migration, no need to run both servers simultaneously.

### Step 1: Create Backup on Laptop

```bash
# SSH to Proxmox host (laptop)
ssh root@192.168.2.250

# Stop VM 102 for consistent backup
qm stop 102

# Create compressed backup (uses zstd compression)
vzdump 102 \
  --storage local \
  --mode snapshot \
  --compress zstd \
  --notes-template "Migration backup for tower server"

# Backup file created at:
# /var/lib/vz/dump/vzdump-qemu-102-2025_11_30-*.vst.zst
# Expected size: ~50-70GB (includes all Ollama models)

# List backups to confirm
ls -lh /var/lib/vz/dump/
```

### Step 2: Transfer Backup to Tower

**Option A: Direct network transfer (fastest if both on same network)**
```bash
# From laptop Proxmox host
scp /var/lib/vz/dump/vzdump-qemu-102-*.vst.zst root@<tower-ip>:/var/lib/vz/dump/

# Or use rsync for resumable transfer
rsync -avP --compress \
  /var/lib/vz/dump/vzdump-qemu-102-*.vst.zst \
  root@<tower-ip>:/var/lib/vz/dump/
```

**Option B: External drive (if servers not on same network)**
```bash
# Mount external drive on laptop
mkdir -p /mnt/backup
mount /dev/sdb1 /mnt/backup

# Copy backup
cp /var/lib/vz/dump/vzdump-qemu-102-*.vst.zst /mnt/backup/

# Unmount, move drive to tower, mount, and copy to Proxmox dump directory
```

### Step 3: Restore on Tower

```bash
# SSH to tower Proxmox host
ssh root@<tower-ip>

# Verify backup file exists
ls -lh /var/lib/vz/dump/

# Restore VM 102 (use same VM ID)
qmrestore /var/lib/vz/dump/vzdump-qemu-102-*.vst.zst 102

# Or restore with different ID if 102 is taken
qmrestore /var/lib/vz/dump/vzdump-qemu-102-*.vst.zst 202

# Increase RAM allocation (you have 32GB now!)
qm set 102 --memory 16384  # 16GB for VM

# Increase CPU cores if you have more
qm set 102 --cores 6

# Start the VM
qm start 102

# Monitor boot
qm status 102
```

### Step 4: Update Mac Scripts

```bash
# Find new IP address
ssh root@<tower-ip>
qm guest cmd 102 network-get-interfaces | grep ip-address

# Update scripts on Mac
# Edit ~/scripts/bin/ollamaSummary.py
# Change: OLLAMA_SERVER = "jaded@192.168.2.126"
# To:     OLLAMA_SERVER = "jaded@<new-tower-vm-ip>"

# Edit ~/scripts/bin/gitBackup.sh
# Replace all instances of jaded@192.168.2.126

# Test connection
ssh jaded@<new-tower-vm-ip> "ollama list"
```

**Pros:**
- ✅ Simple, well-tested process
- ✅ No cluster setup required
- ✅ All data preserved (Ollama models, Docker, configs)
- ✅ Clean separation - can wipe laptop after verification

**Cons:**
- ❌ 30-60 minutes downtime
- ❌ Manual process
- ❌ No ongoing flexibility between hosts

---

## Option 2: Proxmox Cluster

**Best for:** Running both servers long-term, easy VM migration between hosts, high availability.

### Understanding Proxmox Clusters

A Proxmox cluster allows:
- **Live migration** of VMs between nodes (zero downtime!)
- **Shared configuration** across all nodes
- **High availability** (automatic VM restart on node failure)
- **Centralized management** (manage all nodes from one web UI)
- **Distributed storage** (when combined with CEPH)

**Requirements:**
- Minimum 2 nodes (you have laptop + tower)
- All nodes must be on same network
- Unique hostnames for each node
- Working DNS or /etc/hosts entries
- NTP synchronized time

### Step 1: Prepare Both Nodes

**On Laptop:**
```bash
ssh root@192.168.2.250

# Set hostname (if not already done)
hostnamectl set-hostname proxmox-laptop

# Verify network connectivity to tower
ping <tower-ip>

# Ensure time is synchronized
timedatectl status

# Update /etc/hosts with tower info
echo "<tower-ip> proxmox-tower" >> /etc/hosts
```

**On Tower:**
```bash
ssh root@<tower-ip>

# Set hostname
hostnamectl set-hostname proxmox-tower

# Update /etc/hosts with laptop info
echo "192.168.2.250 proxmox-laptop" >> /etc/hosts

# Verify can reach laptop
ping 192.168.2.250
```

### Step 2: Create Cluster

**On Laptop (Master Node):**
```bash
# Create cluster named "homelab-cluster"
pvecm create homelab-cluster

# Verify cluster status
pvecm status

# Expected output:
# Cluster information
# Name:             homelab-cluster
# Config Version:   1
# Cluster Id:       xxxxx
# Quorum:           1 Active
```

### Step 3: Add Tower to Cluster

**On Tower (Join Node):**
```bash
# Join the cluster
pvecm add 192.168.2.250

# Enter root password for laptop when prompted
# This will:
# - Copy cluster configuration
# - Join the cluster
# - Sync node information

# Verify cluster membership
pvecm status

# Expected output:
# Name:             homelab-cluster
# Config Version:   2
# Cluster Id:       xxxxx
# Quorum:           2 Active
# Nodes:            2
```

**On Laptop (Verify):**
```bash
# List cluster nodes
pvecm nodes

# Expected output:
# Membership information
# Node  ID  Votes  Name
#    1    1      proxmox-laptop
#    2    1      proxmox-tower
```

### Step 4: Migrate VM Between Nodes

**Now you can migrate VMs easily!**

**Online Migration (Zero Downtime):**
```bash
# From either node's web UI or CLI
qm migrate 102 proxmox-tower --online

# This performs live migration:
# - VM stays running during move
# - Memory state transferred
# - Storage synced
# - Network reconfigured
# - Usually takes 2-5 minutes
```

**Offline Migration (Faster, requires downtime):**
```bash
# Stop VM first
qm stop 102

# Migrate (much faster without memory transfer)
qm migrate 102 proxmox-tower

# Start on new node
qm start 102
```

**Via Web UI:**
1. Select VM 102
2. Click "Migrate"
3. Choose destination node (proxmox-tower)
4. Check "Online" for live migration
5. Click "Migrate"
6. Watch progress in task log

### Step 5: Configure Shared Storage (Optional but Recommended)

For the smoothest migrations, set up shared storage:

**Option A: NFS Share (Simple)**
```bash
# On laptop, share VM storage via NFS
apt install nfs-kernel-server
echo "/var/lib/vz *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -a

# On tower, mount NFS
apt install nfs-common
mkdir -p /mnt/pve/laptop-storage
mount 192.168.2.250:/var/lib/vz /mnt/pve/laptop-storage

# Add to Proxmox storage
pvesm add nfs laptop-storage \
  --server 192.168.2.250 \
  --export /var/lib/vz \
  --content images,vztmpl,iso
```

**Option B: Wait for CEPH (Better, but needs 3 nodes)**
See Option 3 below.

### Cluster Management Tips

**View cluster status:**
```bash
pvecm status          # Cluster health
pvecm nodes           # List all nodes
ha-manager status     # High availability status
```

**Migrate all VMs from laptop to tower:**
```bash
# List VMs on laptop
qm list

# Migrate each one
for vmid in 100 101 102; do
  qm migrate $vmid proxmox-tower --online
done
```

**Set VM to prefer tower node:**
```bash
# This makes VM 102 prefer to run on tower
ha-manager add vm:102 --group tower-preferred
```

**Pros:**
- ✅ Zero downtime migrations
- ✅ Centralized management
- ✅ Can migrate VMs back and forth easily
- ✅ Foundation for high availability
- ✅ Easy to add more nodes later

**Cons:**
- ❌ More complex setup
- ❌ Requires both servers running
- ❌ Needs good network between nodes
- ❌ Uses some RAM/CPU for cluster services

---

## Option 3: CEPH Storage Cluster

**Best for:** 3+ node clusters, distributed storage, maximum reliability.

### What is CEPH?

CEPH is a distributed storage system that:
- **Replicates data** across multiple nodes (no single point of failure)
- **Allows live migration** without shared storage
- **Self-heals** when drives fail
- **Scales horizontally** (add more nodes = more storage + performance)

### Minimum Requirements

- **3 nodes minimum** (for proper redundancy)
- **3 OSDs (disks) per node recommended**
- **10Gbps network highly recommended**
- **Dedicated network for CEPH traffic** (separate from VM network)
- **At least 4GB RAM per OSD**

### Your Future Setup (When You Have 3+ Nodes)

**Planned Architecture:**
```
Proxmox Cluster with CEPH
├── Node 1: Laptop (16GB RAM, 2 disks)
├── Node 2: Tower (32GB RAM, 4 disks)
└── Node 3: Future server (32GB+ RAM, 4 disks)

CEPH Storage:
- Replication: 3 (each VM disk exists on 3 nodes)
- Minimum size: 2 (need 2 copies to write)
- Total usable: ~66% of raw storage
```

### CEPH Setup Steps (When Ready)

**1. Install CEPH on all nodes:**
```bash
# Run on each node
pveceph install --version quincy
```

**2. Initialize CEPH on first node:**
```bash
# On laptop
pveceph init --network 192.168.2.0/24
```

**3. Create monitors on all nodes:**
```bash
# On each node
pveceph mon create
```

**4. Create OSD (storage) on each disk:**
```bash
# List available disks
pveceph disk list

# Create OSD on each disk
pveceph osd create /dev/sdb
pveceph osd create /dev/sdc
# Repeat for all disks on all nodes
```

**5. Create CEPH pool for VMs:**
```bash
pveceph pool create vm-pool \
  --size 3 \
  --min_size 2 \
  --pg_num 128

# Add pool to Proxmox storage
pvesm add rbd ceph-vm-storage \
  --pool vm-pool \
  --content images,rootdir
```

**6. Migrate VMs to CEPH:**
```bash
# Move VM 102 disk to CEPH storage
qm move-disk 102 scsi0 ceph-vm-storage --delete

# VM is now replicated across all 3 nodes!
```

### Benefits with CEPH

**Live migration becomes trivial:**
- No need to transfer disk data
- VM disk already exists on all nodes
- Migration takes seconds instead of minutes
- Can migrate even without network storage

**Self-healing:**
```bash
# Node 2 goes down? No problem:
# - CEPH automatically uses replicas on Node 1 and 3
# - VMs keep running
# - When Node 2 comes back, CEPH resyncs automatically
```

**Adding Nodes:**
```bash
# Add Node 4 to cluster
pvecm add 192.168.2.250  # From Node 4

# Install CEPH
pveceph install

# Create monitor
pveceph mon create

# Add OSDs
pveceph osd create /dev/sdb
# Storage automatically rebalances!
```

### CEPH Performance Considerations

**Network Requirements:**
- **1Gbps:** Minimum (works but slow)
- **10Gbps:** Recommended (smooth operation)
- **25Gbps+:** Optimal (for many VMs)

**Separate CEPH network:**
```bash
# Configure dedicated CEPH network on 10Gbps NICs
# Edit /etc/pve/ceph.conf
[global]
    public_network = 192.168.2.0/24    # Management network
    cluster_network = 10.0.0.0/24       # CEPH replication network (10Gbps)
```

**Your Future Tower Setup:**
- 32GB RAM: ~24GB for VMs, ~8GB for CEPH overhead
- With 256GB RAM: Could run ~40 OSDs comfortably

**Pros:**
- ✅ Maximum reliability (survives node failures)
- ✅ No single point of failure
- ✅ Scales infinitely
- ✅ Instant migrations
- ✅ Self-healing storage

**Cons:**
- ❌ Requires 3+ nodes
- ❌ Complex setup
- ❌ Needs good network (10Gbps ideal)
- ❌ Storage overhead (3x replication = 33% efficiency)
- ❌ RAM overhead for CEPH services

---

## Pre-Migration Checklist

**Before migrating VM 102 to tower:**

### Document Current State

```bash
# On laptop, gather info about VM 102
ssh root@192.168.2.250

# VM configuration
qm config 102 > ~/vm-102-config.txt

# Current IP address
qm guest cmd 102 network-get-interfaces > ~/vm-102-network.txt

# Running services
ssh jaded@192.168.2.126 "docker ps -a && systemctl status ollama" > ~/vm-102-services.txt

# Ollama models
ssh jaded@192.168.2.126 "ollama list" > ~/vm-102-models.txt
```

### Backup Everything

```bash
# Create backup even if doing cluster migration (safety!)
vzdump 102 --storage local --compress zstd

# Backup VM config
cp /etc/pve/qemu-server/102.conf ~/vm-102-backup.conf

# Test restore on laptop (verify backup works)
qmrestore /var/lib/vz/dump/vzdump-qemu-102-*.vst.zst 999 --test
```

### Update Documentation

- [ ] Update `~/.claude/docs/homelab.md` with migration date
- [ ] Document tower hostname and IP
- [ ] Note which migration method used
- [ ] Save network configuration details

### Verify Mac Scripts

```bash
# List all scripts that reference old IP
grep -r "192.168.2.126" ~/scripts/
grep -r "192.168.2.250" ~/scripts/

# Scripts to update after migration:
# - ~/scripts/bin/ollamaSummary.py (line 28)
# - ~/scripts/bin/gitBackup.sh (multiple locations)
```

### Test Tower Proxmox

```bash
# Verify tower Proxmox is accessible
ssh root@<tower-ip>

# Check available storage
pvesm status

# Check available RAM
free -h

# Verify network connectivity from laptop
ping <tower-ip>
```

---

## Post-Migration Steps

### 1. Verify VM Boot

```bash
# On tower
ssh root@<tower-ip>

# Check VM status
qm status 102

# View console (if issues)
qm terminal 102

# Check boot logs
qm guest exec 102 -- journalctl -b
```

### 2. Find New IP Address

```bash
# Method 1: Proxmox guest agent
qm guest cmd 102 network-get-interfaces

# Method 2: From console
qm terminal 102
# Then: ip addr show

# Method 3: Check DHCP leases on router
# Look for hostname "ubuntu-serv"
```

### 3. Test Services

```bash
# SSH to VM
ssh jaded@<new-ip>

# Verify Ollama
ollama list
ollama run qwen2.5-coder:7b "test"

# Verify Docker containers
docker ps -a

# Check services
systemctl status ollama
systemctl status smb
systemctl --user status rclone-gdrive
systemctl --user status rclone-elevated

# Test Samba from Mac
# Finder → Cmd+K → smb://<new-ip>/Shared
```

### 4. Update Mac Scripts

```bash
# On Mac
cd ~/scripts

# Update ollamaSummary.py
nano bin/ollamaSummary.py
# Change OLLAMA_SERVER = "jaded@<new-ip>"

# Update gitBackup.sh
nano bin/gitBackup.sh
# Replace all jaded@192.168.2.126 with jaded@<new-ip>

# Test backup script
/bin/bash bin/gitBackup.sh
```

### 5. Increase Resources (Tower has more!)

```bash
# On tower Proxmox
ssh root@<tower-ip>

# Increase RAM to 16GB (from 8GB)
qm set 102 --memory 16384

# Increase cores (if you have 6+ cores)
qm set 102 --cores 6

# Restart VM to apply
qm shutdown 102 && qm start 102
```

### 6. Test Bigger Ollama Models

```bash
# SSH to VM
ssh jaded@<new-ip>

# Pull phi4:14b (now it won't get OOM killed!)
ollama pull phi4:14b

# Test it
ollama run phi4:14b "Generate a commit message for adding user authentication"

# Pull 32B model (now possible with 16GB VM RAM!)
ollama pull qwen2.5:32b

# Update default model in scripts
# Edit ~/scripts/bin/ollamaSummary.py on Mac
# Change DEFAULT_MODEL = "phi4:14b"
```

### 7. Update Documentation

```bash
# On Mac
nano ~/.claude/docs/homelab.md

# Add to changelog:
# ### 2025-XX-XX - Migrated VM 102 to Tower Server
# - Migrated using [backup/cluster/CEPH] method
# - New IP: <new-ip>
# - Increased RAM: 8GB → 16GB
# - Updated scripts: ollamaSummary.py, gitBackup.sh
# - Now running larger models: phi4:14b, qwen2.5:32b
```

### 8. Configure Static IP (Recommended)

**On VM 102:**
```bash
ssh jaded@<new-ip>

# Using netplan (Ubuntu Server)
sudo nano /etc/netplan/00-installer-config.yaml

# Add static IP:
network:
  version: 2
  ethernets:
    ens18:
      addresses:
        - 192.168.2.126/24  # Keep same IP as before!
      routes:
        - to: default
          via: 192.168.2.1
      nameservers:
        addresses:
          - 192.168.2.131  # Pi-hole
          - 8.8.8.8

# Apply
sudo netplan apply

# Verify
ip addr show
```

**Benefits:**
- No need to update scripts (same IP as before!)
- Consistent access
- Easier to manage

---

## Testing & Validation

### Comprehensive Test Checklist

**After migration, test everything:**

#### Ollama Service
```bash
ssh jaded@<vm-ip>

# Test Ollama API
curl http://localhost:11434/api/tags

# Test model inference
ollama run qwen2.5-coder:7b "Hello"

# Test from Mac
ssh jaded@<vm-ip> "ollama run gemma2:2b 'test'"
```

#### Docker Containers
```bash
# All containers should be running
docker ps

# Expected containers:
# - twingate-connector
# - jellyfin
# - qbittorrent
# - clamav
# - open-webui

# Test Jellyfin (from Mac browser)
# http://<vm-ip>:8096

# Test Open WebUI (from Mac browser)
# http://<vm-ip>:3000
```

#### Samba File Sharing
```bash
# From Mac Finder: Cmd+K
# smb://<vm-ip>/Shared

# Should see:
# - GoogleDrive
# - ElevatedDrive
# - Documents, Music, Pictures, Videos
```

#### Google Drive Mounts
```bash
ssh jaded@<vm-ip>

# Check both drives mounted
ls ~/GoogleDrive/
ls ~/elevatedDrive/

# Check systemd services
systemctl --user status rclone-gdrive
systemctl --user status rclone-elevated
```

#### Automated Git Backups
```bash
# On Mac
cd ~/scripts

# Run manual backup test
/bin/bash bin/gitBackup.sh

# Should see AI-generated commit message
git log -1

# Check model used (should be qwen2.5-coder:7b or better)
```

#### Network Performance
```bash
# From Mac to VM
ping <vm-ip>

# Test transfer speed
scp ~/Downloads/testfile.bin jaded@<vm-ip>:~/

# Should see 60+ MB/s on gigabit network
```

### Performance Benchmarks

**Compare before/after migration:**

**Ollama Inference Speed:**
```bash
# Test commit message generation time
time ssh jaded@<vm-ip> "ollama run qwen2.5-coder:7b 'Generate commit message'"

# With 16GB VM RAM, should be faster:
# - First run (cold): ~8-12 seconds
# - Warm model: ~3-5 seconds
```

**Docker Container Resources:**
```bash
ssh jaded@<vm-ip>
docker stats --no-stream

# Should have more headroom with 16GB total
```

**CEPH Performance (if using cluster):**
```bash
# On Proxmox tower
ceph status
ceph osd pool stats

# Test write speed
rados bench -p vm-pool 10 write --no-cleanup

# Expected: 100+ MB/s on 1Gbps, 500+ MB/s on 10Gbps
```

---

## Troubleshooting

### VM Won't Boot After Restore

```bash
# Check boot order
qm config 102 | grep boot

# Fix if needed
qm set 102 --boot order=scsi0

# Check VM logs
qm guest exec 102 -- journalctl -b

# Access console
qm terminal 102
```

### Can't SSH to New IP

```bash
# Verify IP from Proxmox
qm guest cmd 102 network-get-interfaces

# Check firewall
ssh jaded@<vm-ip> "sudo ufw status"

# Check SSH service
ssh root@<tower-ip> "qm guest exec 102 -- systemctl status sshd"
```

### Ollama Models Missing

```bash
# Models should be in the disk backup
ssh jaded@<vm-ip>
ollama list

# If missing, check disk space
df -h

# Models are in:
ls -lh /usr/share/ollama/.ollama/models/

# If truly missing (shouldn't happen), re-pull:
ollama pull qwen2.5-coder:7b
```

### Cluster Issues

**Split brain (nodes can't see each other):**
```bash
# Check network
ping proxmox-tower  # From laptop
ping proxmox-laptop # From tower

# Check cluster status
pvecm status

# If cluster is broken, might need to recreate
# (only as last resort - seek help first!)
```

**Quorum lost:**
```bash
# If one node is down and cluster thinks it needs both
pvecm expected 1

# This tells cluster to work with 1 node temporarily
```

### CEPH Warnings

```bash
# Check CEPH health
ceph status

# Common warnings and fixes:
# - "clock skew" → Fix NTP: timedatectl set-ntp true
# - "too few PGs" → Increase PG count
# - "nearfull" → Add more OSDs or delete old data
```

---

## Future Expansion Path

### Phase 1: Laptop + Tower (Current Plan)
- [x] Migrate VM 102 to tower
- [ ] Set up 2-node Proxmox cluster
- [ ] Test live migrations
- [ ] Configure shared NFS storage (optional)

### Phase 2: Add Third Node (Enables CEPH)
- [ ] Purchase 3rd server (old PC, NUC, or another tower)
- [ ] Join to cluster with `pvecm add`
- [ ] Install CEPH on all 3 nodes
- [ ] Migrate VMs to CEPH storage
- [ ] Test node failover

### Phase 3: Multi-Site (See homelab-multi-site-expansion.md)
- [ ] Add node at different location (work/family's house)
- [ ] Set up WireGuard VPN between sites
- [ ] Extend cluster across sites
- [ ] Configure CEPH replication between sites
- [ ] Disaster recovery: survive site failure

### Phase 4: Production-Grade (Ultimate Goal)
- [ ] 6+ nodes across 2+ sites
- [ ] CEPH with 3-way replication
- [ ] Automated failover
- [ ] Monitoring with Prometheus/Grafana
- [ ] Backup automation with Proxmox Backup Server
- [ ] Load balancing with HAProxy

---

## Related Documentation

**See also:**
- `~/.claude/docs/homelab.md` - Current home lab setup
- `~/.claude/docs/homelab-expansion.md` - Single-site expansion plans
- `~/.claude/docs/homelab-multi-site-expansion.md` - Multi-site architecture
- `/var/lib/vz/dump/` - Proxmox backup location
- [Proxmox Cluster Documentation](https://pve.proxmox.com/wiki/Cluster_Manager)
- [CEPH Documentation](https://docs.ceph.com/)

---

## Quick Command Reference

**Backup & Restore:**
```bash
vzdump 102 --storage local --compress zstd        # Create backup
qmrestore /path/to/backup.vst.zst 102            # Restore backup
qm clone 102 103 --full                           # Clone VM
```

**Cluster Management:**
```bash
pvecm create cluster-name           # Create cluster
pvecm add <master-ip>                # Join cluster
pvecm status                         # Check cluster health
pvecm nodes                          # List nodes
pvecm delnode <nodename>             # Remove node
```

**VM Migration:**
```bash
qm migrate 102 target-node --online  # Live migration
qm migrate 102 target-node           # Offline migration
qm move-disk 102 scsi0 storage-name  # Move disk to different storage
```

**CEPH:**
```bash
pveceph install                      # Install CEPH
pveceph init --network 192.168.2.0/24 # Initialize CEPH
pveceph mon create                   # Create monitor
pveceph osd create /dev/sdb          # Create OSD
ceph status                          # Check CEPH health
ceph osd pool create poolname 128    # Create storage pool
```

**Resource Management:**
```bash
qm set 102 --memory 16384            # Set RAM (MB)
qm set 102 --cores 6                 # Set CPU cores
qm resize 102 scsi0 +50G             # Increase disk size
qm config 102                        # Show VM config
```

---

**Good luck with your migration! You're building a serious homelab! 🚀**
