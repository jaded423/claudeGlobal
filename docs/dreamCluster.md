# Dream Ceph Cluster - Ideal Homelab Configuration

**Last Updated:** December 2, 2025

This document describes the ideal 3-node Proxmox + Ceph cluster configuration for a serious homelab setup. This represents the "production-quality homelab" goal - not enterprise-grade, but a robust, reliable distributed storage system for learning and real-world use.

---

## Overview

**Cluster Type:** 3-node Proxmox cluster with Ceph distributed storage
**Purpose:** High-availability homelab with distributed storage, fault tolerance, and hands-on learning
**Key Feature:** Can survive complete failure of any single node

---

## Current vs. Proposed vs. Ideal

### Current Setup (December 2025)
```
2-node Proxmox cluster "home-cluster"
- prox-book5: 16GB RAM, 512GB NVMe (single drive)
- prox-tower: 32GB RAM, 500GB storage (single drive)
- Total: 48GB RAM, ~1TB storage
- Ceph status: Not deployed (insufficient resources)
```

### Proposed 3-Node Entry (Viable for Learning)
```
3 nodes:
- ThinkStation: 32GB RAM, 500GB drive
- Samsung Book5: 16GB RAM, 1TB drive
- i5-14400 PC: 16GB RAM, 512GB drive
- Total: 64GB RAM, ~2TB raw → 680GB usable (3x replication)
- Ceph: Minimal viable (1 OSD per node, tight RAM)
```

### Dream Cluster Configuration (Production Homelab)
```
3 nodes with:
- 32-64GB RAM each
- 3-4× 8TB drives per node
- 10GbE networking (dedicated storage network)
- Separate boot drives
- Total: 96-192GB RAM, 72-96TB raw → 24-32TB usable
```

---

## Ideal Node Specifications

### Per-Node Hardware Requirements

| Component | Minimum | Better | Best | Why |
|-----------|---------|--------|------|-----|
| **RAM** | 32GB | 64GB | 128GB | 1GB per TB + 16GB overhead for monitors/managers |
| **CPU** | 6-core | 8-12 core | 16+ core | OSD processes are CPU-intensive |
| **OSDs (drives)** | 3× drives | 4-6× drives | 6-8× drives | More OSDs = better performance & distribution |
| **Drive Size** | 4-10TB | 8-12TB | 10-14TB | Sweet spot for price/performance |
| **Drive Type** | HDD (7200rpm) | SATA SSD | NVMe SSD | Depends on workload (VMs = SSD, media = HDD) |
| **Network** | 10GbE | 2× 10GbE (bonded) | 25GbE | Dedicated cluster network essential |
| **Boot Drive** | 120GB SSD | 256GB NVMe | 512GB NVMe | Separate from OSD drives |

### Recommended "Sweet Spot" Configuration

**Per Node:**
- **RAM:** 64GB DDR4
- **CPU:** 8-core (Intel Xeon or AMD Ryzen)
- **Boot:** 256GB NVMe (Proxmox OS + system)
- **OSDs:** 4× 8TB SATA SSDs (or HDDs for media storage)
- **Network:** 10GbE NIC (dedicated storage VLAN)
- **Power:** 600W+ PSU (for multi-drive setup)

**3-Node Cluster Total:**
- **RAM:** 192GB total
- **Storage:** 96TB raw → 32TB usable (3x replication)
- **OSDs:** 12 total (4 per node)
- **Cost:** ~$3,000-4,000 (used/refurb workstations)

---

## Storage Calculations

### Replication Math

**Ceph Default:** 3x replication (each object stored on 3 different nodes)

```
Raw Storage Calculation:
- 3 nodes × 4 drives × 8TB = 96TB raw
- Usable with 3x replication: 96TB ÷ 3 = 32TB
- Effective redundancy: Can lose any 1 node completely

Example with smaller drives:
- 3 nodes × 3 drives × 4TB = 36TB raw
- Usable: 36TB ÷ 3 = 12TB
```

### Why 3x Replication?

- **Node failure:** Lose 1 node, data still on 2 others
- **Drive failure:** Lose 1 drive, data distributed across cluster
- **Rebuild safety:** During rebuild, data still has 2 copies
- **Performance:** Read operations can use any of 3 replicas

### Alternative: Erasure Coding (Advanced)

For even more usable space (at cost of performance):
```
k=4, m=2 erasure coding:
- 96TB raw → ~64TB usable (vs 32TB with replication)
- Requires 6+ OSDs total
- Slower writes, better space efficiency
- Good for cold storage/backups
```

---

## Network Architecture

### Why 10GbE is Critical

**1GbE bottlenecks:**
- Maximum throughput: ~125 MB/s
- 3 nodes × 3x replication = 375 MB/s needed (3× bottleneck!)
- VM migrations take hours instead of minutes

**10GbE benefits:**
- Maximum throughput: ~1,250 MB/s
- Handles replication traffic + client I/O + migrations
- Essential for real Ceph performance

### Recommended Network Setup

**Dual-Network Architecture:**

```
Public Network (1GbE or 10GbE):
- VM/container traffic
- Management access (Proxmox web UI)
- Internet gateway
- VLAN: 192.168.1.0/24

Cluster Network (10GbE):
- Ceph replication traffic (OSD ↔ OSD)
- Ceph client traffic (VM ↔ Ceph)
- Isolated VLAN for security
- VLAN: 10.0.0.0/24
```

**Required Hardware:**
- 3× 10GbE switches (or 1× 24-port 10GbE switch) - ~$300-500 used
- 3× 10GbE NICs per node (or dual-port 10GbE) - ~$50-100 each used
- Cat6a or fiber optic cables

**Budget Alternative:**
- Single 10GbE network for everything
- Works but less ideal (no traffic separation)
- Still 10× better than 1GbE

---

## RAM Requirements Deep Dive

### Ceph RAM Rule of Thumb

**Base Formula:**
```
RAM needed = (Total OSD storage in TB × 1GB) + Overhead

Per Node Example (4× 8TB drives):
- OSD RAM: 32GB (4 drives × 8TB × 1GB/TB)
- Monitor/Manager: 4-8GB
- Proxmox host: 4GB
- Total: 40-44GB minimum
- Recommended: 64GB (leaves headroom)
```

### Why 32GB is Minimum, 64GB is Better

**32GB per node:**
- Can run 3-4× 8TB OSDs
- Tight but workable
- Little room for VMs on same node
- Monitor processes may swap under load

**64GB per node:**
- Can run 6-8× 8TB OSDs
- Comfortable headroom for Ceph
- Can run VMs alongside Ceph
- Better performance (less memory pressure)

**128GB per node:**
- Can run 10-12× 8TB OSDs
- Heavy VM workloads alongside Ceph
- Future-proof for expansion

### 3-Node Cluster RAM Tiers

| Total Cluster RAM | OSDs | Storage Capacity | Use Case |
|-------------------|------|------------------|----------|
| 96GB (3× 32GB) | 9-12 | 72-96TB raw | Minimum production homelab |
| 192GB (3× 64GB) | 12-18 | 96-144TB raw | Comfortable homelab, VMs + Ceph |
| 384GB (3× 128GB) | 18-24 | 144-192TB raw | Prosumer/small business |

---

## Drive Selection Guide

### Drive Count Per Node

**Why 3-4 drives per node?**
- CRUSH algorithm distributes data across OSDs
- More OSDs = better distribution
- 3 drives = minimum for good distribution
- 4-6 drives = sweet spot for homelab
- 8+ drives = diminishing returns (power, heat, management)

### Drive Size Considerations

| Size | Pros | Cons | Best For |
|------|------|------|----------|
| **2-4TB** | Cheap, fast rebuilds | Need many drives | Testing, learning |
| **8-10TB** | Best price/GB, good rebuild times | - | **Recommended for homelab** |
| **12-14TB** | Maximum capacity | Slow rebuilds (days), expensive | Media storage, cold data |
| **16TB+** | Highest density | Very slow rebuilds, costly | Enterprise only |

### HDD vs. SSD for Ceph OSDs

**SATA SSDs (Recommended for VMs):**
- Price: ~$80-120 per 1TB
- Speed: 500+ MB/s sequential, 50k+ IOPS
- Use case: VM storage, databases, high I/O
- Example: Samsung 870 EVO, Crucial MX500

**HDDs (Good for Media/Bulk Storage):**
- Price: ~$15-20 per TB
- Speed: 150-200 MB/s sequential, 100-200 IOPS
- Use case: Media storage, backups, archives
- Example: WD Red, Seagate IronWolf (NAS-optimized)

**NVMe SSDs (Overkill for Homelab):**
- Price: ~$100-150 per 1TB
- Speed: 3000+ MB/s, 200k+ IOPS
- Use case: Only if you need extreme performance
- Network becomes bottleneck before NVMe does

**Hybrid Approach (Advanced):**
- NVMe for Ceph journal/WAL (small, fast writes)
- SATA SSD for OSDs (bulk storage)
- Best of both worlds, complex setup

---

## Budget Tiers & Shopping Guide

### Budget Tier (~$1,500-2,000)

**Goal:** Working Ceph cluster for learning, light use

**Per Node:**
- Used Dell Precision 3620 or HP Z240 workstation (~$200-400)
- Upgrade to 32GB RAM ($80-100)
- Add 3× 4TB SATA SSDs ($40-60 each = $120-180)
- 10GbE NIC ($50-80)
- Node cost: ~$450-760

**Network:**
- Used Cisco SG300-10 10GbE switch (~$150-250)

**Total: ~$1,500-2,500**

**Result:**
- 96GB RAM, 36TB raw → 12TB usable
- Good for learning, light VM workloads

---

### Sweet Spot Tier (~$3,000-4,000)

**Goal:** Serious homelab, production-quality

**Per Node:**
- Refurb Dell PowerEdge T140/T340 or HP ML110 Gen10 (~$500-800)
- Upgrade to 64GB RAM ($150-200)
- Add 4× 8TB SATA SSDs ($80-120 each = $320-480)
- 10GbE NIC (if not included)
- Node cost: ~$1,000-1,500

**Network:**
- Ubiquiti USW-Enterprise-24-PoE (10GbE ports) (~$500-700)
- Or used enterprise switch (~$300-500)

**Total: ~$3,000-4,500**

**Result:**
- 192GB RAM, 96TB raw → 32TB usable
- Comfortable for VMs + Ceph, room to grow

---

### Enthusiast Tier (~$6,000-8,000)

**Goal:** Prosumer/small business setup

**Per Node:**
- Purpose-built workstation or refurb 2U server (~$1,200-2,000)
- 128GB RAM ($300-500)
- 6× 8TB NVMe SSDs ($100-150 each = $600-900)
- Dual 10GbE NICs (bonded for redundancy)
- Node cost: ~$2,100-3,400

**Network:**
- Managed 10GbE switch with LAG support (~$500-1,000)

**Total: ~$6,800-11,200**

**Result:**
- 384GB RAM, 144TB raw → 48TB usable
- Enterprise-lite performance

---

## Hardware Recommendations (December 2025)

### Best Used Workstation Platforms

**Dell Precision Series:**
- **T3620/T3640:** ATX tower, expandable, 4-6 drive bays (~$200-400 used)
- **T5810/T5820:** Dual CPU capable, 8+ bays (~$400-700 used)

**HP Z-Series:**
- **Z240/Z440:** Compact, 4 bays, Xeon support (~$250-450 used)
- **Z640:** Dual CPU, 8+ bays (~$500-900 used)

**Lenovo ThinkStation:**
- **P320/P520:** Expandable, good thermals (~$300-600 used)
- **P720:** Dual CPU, rack-mountable (~$700-1,200 used)

### Where to Buy (Used/Refurb)

- **TechMikeNY** - Refurb enterprise gear, warranties
- **eBay** - Search "Dell Precision Xeon" or "HP Z workstation"
- **Craigslist/FB Marketplace** - Local deals, no shipping
- **r/homelabsales** - Reddit community, good prices

### What to Look For

**Must-haves:**
- Xeon or Ryzen CPU (ECC RAM support preferred)
- 4+ SATA ports + room for more
- ATX or larger (for expandability)
- Decent PSU (600W+ for multi-drive)

**Avoid:**
- Proprietary motherboards (Dell Optiplex, HP Compaq)
- Small form factor (limited drive bays)
- Very old CPUs (pre-2015, inefficient)

---

## Software Configuration

### Proxmox Installation

**Per Node Setup:**
1. Install Proxmox VE (latest version)
2. Configure networking (public + cluster VLANs)
3. Create Proxmox cluster (first node)
4. Join other nodes to cluster
5. Verify quorum (all nodes online)

### Ceph Installation

**Cluster-wide Setup:**
1. Install Ceph via Proxmox UI or CLI
2. Create monitors (1-3 monitors, odd number)
3. Create manager (active/standby for HA)
4. Create OSDs (all drives across all nodes)
5. Create pools (RBD for VMs, CephFS for files)
6. Configure CRUSH rules (replication across nodes)

### Recommended Pool Configuration

**For VMs (Block Storage - RBD):**
```bash
# Create VM storage pool
ceph osd pool create vm_pool 128 128
ceph osd pool set vm_pool size 3         # 3x replication
ceph osd pool set vm_pool min_size 2     # Survive 1 node failure
ceph osd pool application enable vm_pool rbd
```

**For Files (Shared Filesystem - CephFS):**
```bash
# Create file storage pool
ceph osd pool create cephfs_data 64 64
ceph osd pool create cephfs_metadata 32 32
ceph fs new cephfs cephfs_metadata cephfs_data
ceph osd pool set cephfs_data size 3
ceph osd pool set cephfs_data min_size 2
```

### CRUSH Map Configuration

**Ensure data distributes across nodes (not just disks):**
```bash
# View current CRUSH hierarchy
ceph osd tree

# Verify rule distributes across hosts
ceph osd crush rule dump

# Create custom rule if needed (replicas on different nodes)
ceph osd crush rule create-replicated replicated_rule default host
```

---

## Performance Expectations

### What to Expect (4× 8TB SATA SSDs per node, 10GbE network)

**Sequential Read/Write:**
- Single VM: 300-500 MB/s (limited by VM vCPU)
- Multiple VMs: 1,000-2,000 MB/s aggregate
- Bottleneck: Network (10GbE = 1,250 MB/s max)

**Random I/O (4K blocks):**
- Single VM: 10k-20k IOPS
- Multiple VMs: 50k-100k IOPS aggregate
- Bottleneck: CPU and network latency

**VM Boot Times:**
- Ubuntu Server: 15-30 seconds
- Windows 10: 30-60 seconds
- Similar to local SSD storage

**Rebuild Performance:**
- 8TB OSD failure: 4-8 hours to rebuild
- Cluster remains operational during rebuild
- I/O performance reduced ~30% during rebuild

---

## Fault Tolerance & Failure Scenarios

### What Can Fail Without Data Loss?

**Any 1 Node (Complete Failure):**
- ✅ Cluster remains online
- ✅ All VMs continue running (on other 2 nodes)
- ✅ All data accessible (2 copies still exist)
- ⚠️ Performance degraded (less OSDs available)
- ⚠️ No redundancy until node returns (only 2 copies)

**Any 1 Drive (OSD Failure):**
- ✅ Cluster remains fully functional
- ✅ Data automatically rebuilds to other OSDs
- ⚠️ Slight performance impact during rebuild

**Network Partition (1 Node Isolated):**
- ✅ Quorum maintained (2/3 nodes)
- ✅ Cluster continues operating
- ⚠️ Isolated node goes read-only (safety)

### What Causes Data Loss?

**2+ Simultaneous Node Failures:**
- ❌ Quorum lost (1/3 nodes remaining)
- ❌ Cluster goes read-only or offline
- ❌ Possible data loss if same data was on both nodes

**2+ Simultaneous Drive Failures (Same Data):**
- ❌ If 2+ copies of same object lost
- ❌ Rare with 3x replication across nodes
- ❌ Protect with backups (3-2-1 rule)

### Backup Strategy (Even with Ceph)

**Ceph is NOT a backup!**
- Protects against hardware failure
- Does NOT protect against: user error, ransomware, corruption

**Recommended:**
- **On-site backup:** Proxmox Backup Server (PBS) on separate hardware
- **Off-site backup:** Cloud backup (Backblaze B2, Wasabi)
- **3-2-1 Rule:** 3 copies, 2 different media, 1 off-site

---

## Upgrade Path from Current Setup

### Phase 1: Add Third Node (Immediate)
**Current:** 2-node cluster (prox-book5 + prox-tower)
**Add:** i5-14400 PC (16GB RAM, 512GB drive)
**Result:** 3-node cluster, minimal Ceph deployment possible
**Cost:** $0 (hardware on hand)

### Phase 2: Expand Storage (~$300-600)
**Per Node:** Add 2-3× 4-8TB SATA SSDs
**Result:** 9-12 OSDs, 36-96TB raw storage
**Cost:** ~$100-200 per node

### Phase 3: RAM Upgrade (~$200-400)
**Upgrade:** Book5 and i5-14400 to 32GB (16GB → 32GB)
**Result:** 96GB total cluster RAM (comfortable for Ceph)
**Cost:** ~$50-80 per node × 2 nodes

### Phase 4: Network Upgrade (~$500-800)
**Add:** 10GbE NICs (3×) + 10GbE switch
**Result:** Proper Ceph performance, fast VM migrations
**Cost:** NICs ~$50-80 each, switch ~$300-500

### Phase 5: Replace Nodes (Long-term, ~$1,500-3,000)
**Replace:** All 3 nodes with proper workstations
**Result:** Unified hardware, better expandability, 64GB+ RAM per node
**Cost:** ~$500-1,000 per node

**Total Upgrade Cost:** ~$2,500-5,000 over time

---

## Learning Resources

### Official Documentation
- [Proxmox VE Ceph Documentation](https://pve.proxmox.com/wiki/Deploy_Hyper-Converged_Ceph_Cluster)
- [Ceph Documentation](https://docs.ceph.com/en/latest/)
- [Ceph Architecture Guide](https://docs.ceph.com/en/latest/architecture/)

### Community Resources
- **r/Proxmox** - Reddit community for Proxmox questions
- **r/Ceph** - Ceph-specific discussions
- **Proxmox Forum** - Official support forum
- **YouTube:** TechnoTim, NetworkChuck, Craft Computing (Ceph tutorials)

### Hands-On Learning
- **Start small:** 3-node cluster with 1 OSD per node
- **Break things:** Test node failures, drive failures, network issues
- **Monitor everything:** Learn Ceph health commands, dashboards
- **Iterate:** Expand storage, adjust pools, tune performance

---

## Common Pitfalls to Avoid

### Don't Do This

**❌ Mixed drive sizes in same pool**
- Ceph uses smallest drive as baseline
- Wastes space on larger drives

**❌ Running Ceph without 10GbE**
- 1GbE is painful for anything beyond testing
- You'll hate the experience

**❌ Skimping on RAM**
- 16GB per node barely works
- OSD daemons will OOM (out of memory)
- Cluster instability

**❌ Single NIC for everything**
- Replication traffic floods network
- VMs suffer, cluster suffers

**❌ No backups**
- "RAID is not a backup"
- Neither is Ceph
- Always have external backups

**❌ Ignoring CRUSH rules**
- Default may put replicas on same node
- Defeats entire purpose of Ceph

### Do This Instead

**✅ Match drive sizes** (all 8TB or all 4TB in pool)
**✅ Get 10GbE early** (makes everything better)
**✅ Start with 32GB+ RAM per node**
**✅ Separate networks** (public + cluster)
**✅ Test backups regularly**
**✅ Verify CRUSH distribution** (replicas on different hosts)

---

## Why This Matters

### Real-World Homelab Benefits

**High Availability:**
- Run VMs across cluster, survive hardware failures
- Practice HA configurations (load balancing, failover)
- Learn production skills

**Distributed Storage:**
- Understand how enterprises handle storage
- Hands-on with CRUSH algorithm, replication, erasure coding
- Resume-worthy experience

**Performance at Scale:**
- Learn what bottlenecks (network, CPU, IOPS)
- Tune and optimize real systems
- Understand trade-offs (performance vs. redundancy)

**Skill Development:**
- Proxmox certification preparation
- Kubernetes persistent volumes (Ceph RBD)
- Enterprise storage concepts

---

## Conclusion

**Minimum Viable Ceph Cluster (Learning):**
- 3 nodes, 32GB RAM each, 1 OSD per node
- Works for learning, limited practical use

**Recommended Homelab Ceph Cluster (Production):**
- 3 nodes, 64GB RAM each, 4× 8TB OSDs per node
- 10GbE networking (dedicated cluster network)
- ~32TB usable storage, real-world performance
- Cost: ~$3,000-4,000 (used hardware)

**Dream Scenario:**
- 3 nodes, 128GB RAM each, 6× 8TB NVMe OSDs per node
- 2× 10GbE bonded, separate public/cluster networks
- ~48TB usable, enterprise-lite performance
- Cost: ~$6,000-10,000

**Your Current Path (Realistic):**
1. **Now:** Add i5-14400 as 3rd node, deploy minimal Ceph for learning
2. **Phase 2:** Add more drives (3-4 per node) → real storage
3. **Phase 3:** Upgrade RAM to 32GB per node → stability
4. **Phase 4:** Add 10GbE networking → performance
5. **Future:** Replace nodes as budget allows

**The sweet spot for serious homelab:** 3× refurb workstations, 64GB RAM each, 4× 8TB SSDs, 10GbE switch = ~$3,500 total.

Start small, learn the concepts, expand incrementally. Ceph is complex but incredibly rewarding to master.

---

## Related Documentation

- **[homelab.md](homelab.md)** - Current homelab infrastructure
- **[homelab-expansion.md](homelab-expansion.md)** - Near-term expansion plans
- **[homelab-multi-site-expansion.md](homelab-multi-site-expansion.md)** - Multi-site Proxmox architecture

---

**Next Steps:** Document in homelab.md, begin planning Phase 1 (add 3rd node).
