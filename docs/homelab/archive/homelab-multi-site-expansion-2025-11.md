# Home Lab Multi-Site Expansion & Certification Learning Path

**Last Updated:** November 28, 2025
**Purpose:** Plan multi-site infrastructure expansion aligned with CompTIA certification goals

---

## Overview

This document outlines the expansion of your home lab infrastructure across **two physical locations** (home and work) with a focus on hands-on learning for **CompTIA A+, Linux+, Network+, and Security+ certifications**.

**Learning Philosophy:** Build real infrastructure that serves dual purpose:
1. Practical certification exam preparation
2. Production-ready personal infrastructure

---

## Current & Planned Infrastructure

### Site 1: Home (Primary Compute)

**Existing:**
- **CachyOS Laptop Server** (cachyos-jade @ 192.168.2.250)
  - Ollama, Docker, SSH, Samba, Twingate
  - Currently running CachyOS Linux (not Proxmox yet)

**Planned Additions:**
1. **Main Laptop → Proxmox Node 1** (home-pve-01)
   - Convert current CachyOS laptop to Proxmox hypervisor
   - Migrate services to LXC containers and VMs
   - 16GB RAM, Intel Arc GPU

2. **Used Tower PC → Proxmox Node 2** (home-pve-02)
   - Second Proxmox node for HA cluster
   - Spec TBD based on available hardware

3. **Future Node 3** (home-pve-03)
   - Third node for full CEPH quorum
   - Enables high availability and distributed storage
   - Timeline: 6-12 months

**Home Network:**
- Subnet: 192.168.2.0/24
- Gateway: 192.168.2.1
- DNS: Pi-hole @ 192.168.2.131
- Raspberry Pi 5 (planned): Network services consolidation

### Site 2: Work (Access & Development)

**Existing:**
1. **Mac Air** (Primary work machine)
   - Twingate client for remote access
   - Development environment

2. **Old Mac Pro** (Potential Proxmox node)
   - Could run macOS + Docker OR Proxmox in VM
   - Or native Proxmox if willing to wipe macOS

3. **Old PC** (Potential Proxmox node)
   - Good candidate for Proxmox testing
   - Could run work-specific services

**Work Network:**
- Subnet: TBD (likely 192.168.1.0/24 or similar)
- Limited control over network infrastructure
- Twingate connector required for home access

---

## Multi-Site Architecture Strategy

### The Reality: Two Independent Sites

Based on our earlier discussion about CEPH and WAN limitations, here's the recommended approach:

```
┌─────────────────────────────────────────────────────────────────┐
│                    MULTI-SITE ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────────┘

HOME SITE (192.168.2.0/24)                 WORK SITE (TBD)
┌──────────────────────────┐               ┌─────────────────────┐
│  Proxmox Cluster (HA)    │               │  Standalone Nodes   │
│  ├─ home-pve-01 (laptop) │               │  ├─ work-pve-01 (PC)│
│  ├─ home-pve-02 (tower)  │◄─────────────►│  └─ Mac Pro (Docker)│
│  └─ home-pve-03 (future) │   Twingate   │                     │
│                          │   Secure     │                     │
│  CEPH Storage (3+ nodes) │   Tunnel     │  Local Storage      │
│  - Distributed storage   │               │  - ZFS or ext4      │
│  - High availability     │               │                     │
│  - Learning environment  │               │                     │
└──────────────────────────┘               └─────────────────────┘
         │                                          │
         │                                          │
         ├─ Production services (24/7)              ├─ Development
         ├─ Media server (Jellyfin)                 ├─ Testing VMs
         ├─ Network services (Pi-hole)              └─ Learning labs
         └─ Home automation
```

### Why Separate Clusters?

**Home (Full Proxmox Cluster with CEPH):**
- 3+ nodes in same location = low latency (<1ms)
- Perfect for CEPH distributed storage
- High availability for critical services
- 24/7 operation
- Learning environment for cluster technologies

**Work (Independent Nodes):**
- 1-2 standalone Proxmox nodes
- Local storage (ZFS recommended)
- Development and testing
- No HA requirements (work hours only)
- Can be powered off when not in use

**Cross-Site Connectivity:**
- **Twingate** for secure access between sites
- **Proxmox Replication** for disaster recovery (home → work or work → home)
- **ZFS send/receive** for periodic backups
- **SSH tunnels** for management

---

## Storage Strategy by Site

### Home Site Storage Architecture

**Option 1: CEPH Cluster (Recommended for Learning)**

**Minimum Requirements:**
- 3 Proxmox nodes (for quorum)
- 2+ disks per node (OS + OSD)
- 10GbE networking (highly recommended)
- 4GB+ RAM per OSD disk

**Disk Layout per Node:**
```
Node 1 (home-pve-01):
├─ nvme0n1 (500GB) - Proxmox OS
├─ sda (1TB) - CEPH OSD 1
└─ sdb (1TB) - CEPH OSD 2

Node 2 (home-pve-02):
├─ sda (250GB) - Proxmox OS
├─ sdb (1TB) - CEPH OSD 3
└─ sdc (1TB) - CEPH OSD 4

Node 3 (home-pve-03 - future):
├─ sda (250GB) - Proxmox OS
├─ sdb (1TB) - CEPH OSD 5
└─ sdc (1TB) - CEPH OSD 6
```

**CEPH Pool Configuration:**
- Replication: 3x (every object stored on 3 nodes)
- Usable storage: ~2TB (from 6x 1TB disks with 3x replication)
- Failure tolerance: Any single node can fail
- Learning benefit: Understand distributed systems, replication, quorum

**Option 2: ZFS (Simpler Alternative)**

**If you don't have 3 nodes yet:**
```
Node 1: ZFS mirror (2x 1TB)
Node 2: ZFS mirror (2x 1TB)
+ Proxmox replication between nodes
```

**Benefits:**
- Works with just 2 nodes
- Simpler to understand and manage
- Still provides redundancy
- Good for learning ZFS snapshots, send/receive

### Work Site Storage

**Recommended: Local ZFS**

```
work-pve-01:
├─ OS disk (NVMe)
└─ ZFS pool (data disks)
    ├─ Development VMs
    ├─ Testing containers
    └─ Local backups
```

**Why not CEPH at work:**
- Only 1-2 nodes (insufficient for quorum)
- Work environment may not allow 3+ systems
- Local storage sufficient for dev/test
- Can still practice ZFS, snapshots, replication

---

## Network Architecture

### Cross-Site Connectivity

**Twingate Setup:**

```
┌────────────┐                           ┌──────────────┐
│  Mac Air   │──┐                    ┌──│ home-pve-01  │
│ (client)   │  │                    │  │ home-pve-02  │
└────────────┘  │                    │  │ home-pve-03  │
                │   ┌──────────────┐ │  └──────────────┘
┌────────────┐  ├──►│   Twingate   │◄┤
│ work-pve-01│──┘   │   Network    │ │  ┌──────────────┐
│ (connector)│      │  (jaded423)  │ └─►│  Pi-hole DNS │
└────────────┘      └──────────────┘    │  @ .2.131    │
                                        └──────────────┘
```

**Resources to Configure:**
1. **Home Proxmox Cluster** (ports 8006, 22)
2. **Work Proxmox Nodes** (ports 8006, 22)
3. **File Shares** (Samba, NFS)
4. **Services** (Jellyfin, monitoring dashboards)

**Security Best Practices:**
- Each site runs its own Twingate connector
- Resource-based access control (not full network access)
- MFA enabled for Twingate authentication
- Separate user accounts for different access levels

### VLANs for Learning (Home Network)

**Future Network Segmentation:**

```
VLAN 10: Management (192.168.10.0/24)
├─ Proxmox web interfaces
├─ SSH access
└─ Monitoring dashboards

VLAN 20: Services (192.168.20.0/24)
├─ Production VMs/containers
├─ Media server
└─ Home automation

VLAN 30: IoT/Guest (192.168.30.0/24)
├─ Smart home devices
├─ Guest WiFi
└─ Untrusted devices

VLAN 40: Lab/Testing (192.168.40.0/24)
├─ Test VMs
├─ Learning labs
└─ Vulnerable systems for practice
```

**Learning Benefit:** Network+ and Security+ exam topics
- Subnetting and CIDR notation
- Inter-VLAN routing
- Firewall rules between VLANs
- Network segmentation best practices

---

## Certification Learning Roadmap

### Phase 1: CompTIA A+ (2-3 Months)

**Study Focus:** Hardware, troubleshooting, OS fundamentals

**Hands-On Labs with Your Infrastructure:**

1. **Hardware Installation & Configuration**
   - Physically install drives in tower PC for Proxmox node 2
   - Install RAM upgrades (practice ESD safety)
   - Configure BIOS/UEFI settings for virtualization (Intel VT-x, AMD-V)
   - Document hardware inventory with specs

2. **Operating System Fundamentals**
   - Install Proxmox (Debian-based) on nodes
   - Practice Linux command line via SSH
   - User/group management in Proxmox
   - File permissions and ownership

3. **Troubleshooting Practice**
   - Intentionally break services and fix them
   - Diagnose boot issues
   - Network connectivity troubleshooting
   - Performance monitoring (htop, iotop)

**A+ Topics Covered by Your Lab:**
- ✅ Hardware components (CPU, RAM, storage, GPU)
- ✅ BIOS/UEFI configuration
- ✅ Operating system installation
- ✅ Command line basics
- ✅ Networking fundamentals
- ✅ Troubleshooting methodology

**Real Infrastructure Tasks:**
- [ ] Install Proxmox on main laptop (backup CachyOS first!)
- [ ] Install Proxmox on tower PC
- [ ] Create hardware inventory spreadsheet
- [ ] Document BIOS settings for both systems
- [ ] Practice SSH access and basic Linux commands

### Phase 2: CompTIA Linux+ (2-3 Months)

**Study Focus:** Linux administration, shell scripting, system services

**Hands-On Labs:**

1. **System Administration**
   - Manage Proxmox host OS (Debian-based)
   - Create LXC containers with different distros (Ubuntu, Alpine, Rocky)
   - Configure systemd services
   - Schedule tasks with cron/systemd timers
   - Manage storage (LVM, ZFS, partitioning)

2. **Shell Scripting & Automation**
   - Write backup scripts for VMs
   - Automate Proxmox updates
   - Create monitoring scripts
   - Log parsing and analysis

3. **Networking on Linux**
   - Configure network bridges for Proxmox
   - Set up firewall rules (iptables/nftables)
   - Install and configure services (SSH, Samba, NFS)
   - Troubleshoot network issues

4. **Package Management**
   - apt for Proxmox/Debian
   - dnf/yum in Rocky Linux VMs
   - apk in Alpine containers
   - Compile software from source

**Linux+ Topics Covered:**
- ✅ Linux installation and configuration
- ✅ GNU/Linux commands (Proxmox CLI)
- ✅ File management and permissions
- ✅ Storage management (LVM, ZFS)
- ✅ systemd and service management
- ✅ Networking configuration
- ✅ Shell scripting and automation

**Real Infrastructure Tasks:**
- [ ] Migrate existing services to LXC containers
  - [ ] Ollama container (GPU passthrough)
  - [ ] Jellyfin container
  - [ ] qBittorrent container
  - [ ] Samba file server container
- [ ] Create automated backup script for VMs
- [ ] Set up ZFS pools on both Proxmox nodes
- [ ] Configure Proxmox replication between nodes
- [ ] Write system monitoring scripts

### Phase 3: CompTIA Network+ (2-3 Months)

**Study Focus:** Network protocols, topologies, security, troubleshooting

**Hands-On Labs:**

1. **VLAN Configuration**
   - Create VLANs on home network
   - Configure VLAN-aware bridges in Proxmox
   - Set up pfSense VM as router
   - Test inter-VLAN routing

2. **Network Services**
   - DNS server (Pi-hole already running, add redundancy)
   - DHCP server configuration
   - NFS and Samba file sharing
   - VPN setup (WireGuard, OpenVPN)

3. **Monitoring & Analysis**
   - Install Wireshark in VM
   - Capture and analyze network traffic
   - Set up Grafana + Prometheus for network metrics
   - Configure SNMP monitoring

4. **Subnetting Practice**
   - Plan IP address scheme for VLANs
   - Calculate subnet masks
   - Design network topology
   - Document network diagram

**Network+ Topics Covered:**
- ✅ Network topologies and types
- ✅ TCP/IP model and protocols
- ✅ IP addressing and subnetting
- ✅ Routing and switching concepts
- ✅ Network services (DNS, DHCP, NFS)
- ✅ VLANs and network segmentation
- ✅ Wireless networking (if you add WiFi AP)
- ✅ Network troubleshooting

**Real Infrastructure Tasks:**
- [ ] Deploy pfSense VM as network router
- [ ] Create 4 VLANs (management, services, IoT, lab)
- [ ] Configure VLAN tagging on Proxmox nodes
- [ ] Set up redundant DNS (Pi-hole + backup)
- [ ] Install network monitoring (Grafana/Prometheus)
- [ ] Create network topology diagram
- [ ] Document IP addressing scheme

### Phase 4: CompTIA Security+ (2-3 Months)

**Study Focus:** Security concepts, risk management, cryptography, compliance

**Hands-On Labs:**

1. **Network Security**
   - pfSense firewall rules
   - IDS/IPS with Suricata or Snort
   - VPN configuration (WireGuard, OpenVPN)
   - Network segmentation enforcement

2. **Access Control**
   - LDAP authentication server
   - Multi-factor authentication (Authelia)
   - SSH key management
   - Certificate authority (Let's Encrypt, self-signed)

3. **Vulnerability Assessment**
   - Set up vulnerable VMs (DVWA, Metasploitable)
   - Run vulnerability scanners (OpenVAS, Nessus)
   - Practice penetration testing basics
   - Document findings and remediation

4. **Logging & Monitoring**
   - Centralized logging (Graylog or ELK stack)
   - Security event monitoring
   - Intrusion detection alerts
   - Incident response procedures

5. **Hardening**
   - Secure Proxmox installation
   - Container security best practices
   - Regular security updates
   - Disable unnecessary services

**Security+ Topics Covered:**
- ✅ CIA triad implementation
- ✅ Authentication and authorization
- ✅ Cryptography (SSH keys, SSL/TLS)
- ✅ Network security (firewalls, VPNs, IDS)
- ✅ Security operations and monitoring
- ✅ Risk management (identify, assess, mitigate)
- ✅ Incident response procedures

**Real Infrastructure Tasks:**
- [ ] Implement firewall rules on pfSense
- [ ] Set up IDS/IPS with Suricata
- [ ] Deploy centralized logging (Graylog)
- [ ] Create security monitoring dashboard
- [ ] Set up 2FA for Proxmox access
- [ ] Configure automated security updates
- [ ] Create vulnerable VM lab environment
- [ ] Write incident response playbook

---

## CEPH Learning Path

### Why Learn CEPH?

**Career Relevance:**
- Used by enterprises for scale-out storage
- Powers OpenStack cloud deployments
- Key technology for understanding distributed systems
- Valuable for Linux+/cloud certifications

**Concepts You'll Learn:**
1. **Distributed Storage** - Data spread across multiple nodes
2. **Replication** - Multiple copies for redundancy
3. **Quorum** - Cluster consensus mechanisms
4. **OSD Management** - Object storage daemons
5. **Pools & Placement Groups** - Data organization
6. **Performance Tuning** - Optimizing distributed systems

### CEPH Implementation Timeline

**Prerequisite: 3 Proxmox Nodes at Home**

**Month 1-2: Proxmox Cluster Foundation**
- [ ] Install Proxmox on all 3 home nodes
- [ ] Create Proxmox cluster
- [ ] Configure networking (cluster network + public network)
- [ ] Test cluster quorum and HA features

**Month 3: CEPH Installation**
- [ ] Add second disk to each node (for OSD)
- [ ] Install CEPH via Proxmox GUI
- [ ] Create monitors on each node
- [ ] Create OSDs on data disks
- [ ] Configure CEPH network (separate from cluster network if possible)

**Month 4: CEPH Configuration**
- [ ] Create CEPH pools
- [ ] Configure replication (size=3, min_size=2)
- [ ] Create RBD storage in Proxmox
- [ ] Test VM creation on CEPH storage
- [ ] Monitor CEPH health and performance

**Month 5: Advanced CEPH**
- [ ] Practice failure scenarios (shut down 1 node)
- [ ] Monitor rebalancing and recovery
- [ ] Add additional OSD to expand storage
- [ ] Configure CRUSH map for custom placement
- [ ] Performance benchmarking with fio

**Month 6: Production Use**
- [ ] Migrate critical VMs to CEPH storage
- [ ] Set up automated backups
- [ ] Monitor long-term performance
- [ ] Document lessons learned

### CEPH Learning Resources

**Official Documentation:**
- [Proxmox CEPH Documentation](https://pve.proxmox.com/wiki/Ceph_Server)
- [CEPH Official Docs](https://docs.ceph.com/)

**Courses:**
- Linux Academy: "CEPH Fundamentals"
- YouTube: Proxmox + CEPH tutorials

**Books:**
- "Mastering CEPH" by Nick Fisk
- "Learning CEPH" by Karan Singh

---

## Hardware Shopping List

### Immediate (Month 1-2): Second Proxmox Node

**Used Tower PC Requirements:**
- CPU: Intel Core i5/i7 or AMD Ryzen 5/7 (with VT-x/AMD-V)
- RAM: 16GB minimum, 32GB ideal
- Storage:
  - 250GB SSD for Proxmox OS
  - 2x 1TB+ for CEPH OSDs (later)
- Network: Gigabit ethernet (10GbE card optional)
- Budget: $150-300 used

**Where to Buy:**
- eBay - Dell Precision, HP Z-series workstations
- Local university surplus sales
- Facebook Marketplace
- Craigslist

### Future (Month 4-6): Third Node + CEPH Disks

**Third Proxmox Node:**
- Similar specs to node 2
- Budget: $150-300 used

**CEPH Disks (for all 3 nodes):**
- 6x 1TB SSD (2 per node)
- Budget: $200-400 ($30-60 per drive)
- Consider used enterprise SSDs (Dell/HP pulls)

### Networking Upgrades (Optional - Month 6+)

**10GbE Networking:**
- 3x Intel X520-DA2 dual-port 10GbE cards (~$30-50 each used)
- Mikrotik CRS305 10GbE switch (~$150)
- DAC cables (~$10-20 each)
- Total: ~$350-400

**Benefits:**
- 10x faster CEPH replication
- Better VM live migration
- Improved distributed storage performance
- Good for Network+ lab exercises

---

## Migration Plan: CachyOS → Proxmox

### Current State
- CachyOS laptop with many services
- Need to preserve services while migrating to Proxmox

### Migration Strategy

**Option 1: In-Place Migration (Recommended)**

```
Week 1: Preparation
- [ ] Full backup of CachyOS system
- [ ] Document all running services
- [ ] Export important configurations
- [ ] Test Proxmox on tower PC first

Week 2: Install Proxmox
- [ ] Boot from Proxmox ISO
- [ ] Install Proxmox on main laptop
- [ ] Configure network bridges
- [ ] Join Proxmox cluster (if node 2 ready)

Week 3: Migrate Services to Containers
- [ ] Create LXC containers for each service
- [ ] Migrate Samba → LXC container
- [ ] Migrate Ollama → LXC with GPU passthrough
- [ ] Migrate Docker services → LXC or VM

Week 4: Testing & Validation
- [ ] Test all services
- [ ] Verify remote access (Twingate)
- [ ] Confirm backups working
- [ ] Document new architecture
```

**Option 2: Parallel Migration (Safer)**

```
Phase 1: Set up tower PC as Proxmox first
Phase 2: Migrate services to tower PC
Phase 3: Convert laptop to Proxmox once services running
Phase 4: Migrate services back or distribute across both
```

### Service Migration Checklist

**Services to Migrate:**
- [ ] SSH (built into Proxmox)
- [ ] Samba file server → LXC container
- [ ] Twingate connector → Docker on Proxmox host or LXC
- [ ] Ollama + models → LXC with GPU passthrough
- [ ] Jellyfin → LXC container
- [ ] qBittorrent → LXC container
- [ ] ClamAV → LXC container
- [ ] Google Drive mounts → Proxmox host or LXC
- [ ] Odoo 17 → LXC container
- [ ] RustDesk → LXC container

**Configuration Backups:**
- [ ] /home/jaded/ (entire home directory)
- [ ] /etc/samba/smb.conf
- [ ] ~/.config/ (all configs)
- [ ] Docker volumes
- [ ] Ollama models (~30GB)

---

## Budget & Timeline Summary

### 6-Month Plan

| Month | Focus | Hardware | Budget | Certification |
|-------|-------|----------|--------|---------------|
| **1** | A+ Study + Node 2 Setup | Used tower PC | $200-300 | CompTIA A+ |
| **2** | A+ Exam + Proxmox Migration | - | $250 (exam) | A+ Complete ✅ |
| **3** | Linux+ Study | CEPH disks (2x) | $100-200 | Linux+ Study |
| **4** | Linux+ Exam + Node 3 | Third node + disks | $300-400 | Linux+ Complete ✅ |
| **5** | Network+ Study + CEPH | - | $250 (exam) | Network+ |
| **6** | Network+ Exam | Networking gear | $200-400 | Network+ Complete ✅ |
| **7-9** | Security+ Study | - | $400 (exam) | Security+ |

**Total Investment:**
- Hardware: $800-1300
- Exams: $1,150 (4 exams)
- **Grand Total: $1,950-2,450**

**ROI:** CompTIA certs significantly increase job prospects in IT

---

## Best Practices

### Documentation
- **Keep a lab notebook** - Document every configuration change
- **Network diagrams** - Use draw.io or similar
- **Configuration backups** - Git repository for configs
- **Incident logs** - Track problems and solutions

### Learning Approach
1. **Read theory** (study guides, videos)
2. **Practice on lab** (hands-on with real hardware)
3. **Break things intentionally** (learn troubleshooting)
4. **Document everything** (reinforce learning)
5. **Take practice exams** (identify weak areas)

### Time Management
- **Study time:** 10-15 hours/week
- **Lab time:** 5-10 hours/week
- **Practice exams:** 2-3 hours/week
- **Total:** 17-28 hours/week for accelerated path

### Cost Savings
- **Buy used enterprise hardware** (Dell, HP pulls)
- **eBay, university surplus** for hardware
- **Open source software** for all services
- **Student discounts** on exam vouchers (if applicable)
- **Exam bundles** (buy exam + retake voucher)

---

## Multi-Site Use Cases

### Development Workflow

**Scenario:** Working from work location, need home resources

```
1. Connect to Twingate (work Mac)
2. Access Proxmox web UI (home cluster)
3. Start development VM
4. Code via SSH or VS Code Remote
5. Test against services running at home
6. Commit code to git (synced via GitHub)
```

### Disaster Recovery

**Scenario:** Home site disaster (fire, flood, theft)

```
1. Critical VMs replicated to work site
2. Start replicated VMs on work Proxmox
3. Update DNS/Twingate to point to work location
4. Continue operations from work site
5. Rebuild home site when possible
```

### Learning Labs

**Scenario:** Testing destructive changes safely

```
1. Clone production VM
2. Move clone to VLAN 40 (lab network)
3. Test risky changes
4. Document results
5. Apply to production if successful
6. Delete clone
```

---

## Troubleshooting Common Issues

### Proxmox Installation Problems
**Issue:** Virtualization not enabled in BIOS
**Solution:** Enable Intel VT-x or AMD-V in BIOS/UEFI

**Issue:** Network not working after install
**Solution:** Check bridge configuration, ensure physical NIC is added to vmbr0

### CEPH Issues
**Issue:** Cluster unhealthy (HEALTH_WARN)
**Solution:** Check `ceph -s`, review OSD status, ensure all monitors reachable

**Issue:** Slow performance
**Solution:** Check network (10GbE recommended), review pool PG count, check OSD utilization

### Cross-Site Connectivity
**Issue:** Can't access home from work
**Solution:** Verify Twingate connector running, check resource assignments, test direct connectivity

---

## Next Steps

### This Week
- [ ] Read this document thoroughly
- [ ] Decide on migration strategy (in-place vs parallel)
- [ ] Order used tower PC for node 2
- [ ] Start CompTIA A+ study materials
- [ ] Backup current CachyOS system

### This Month
- [ ] Complete A+ study (220-1101 and 220-1102)
- [ ] Set up tower PC with Proxmox
- [ ] Create Proxmox cluster (laptop + tower)
- [ ] Begin migrating services to containers
- [ ] Schedule A+ exam

### This Quarter
- [ ] Complete A+ certification
- [ ] Migrate all services to Proxmox
- [ ] Begin Linux+ study
- [ ] Order third node hardware
- [ ] Plan CEPH deployment

---

## Resources

### Proxmox
- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [Proxmox Forums](https://forum.proxmox.com/)
- [r/Proxmox](https://reddit.com/r/Proxmox)

### CompTIA Certifications
- [Professor Messer](https://www.professormesser.com/) - Free video courses
- [CompTIA Official Site](https://www.comptia.org/)
- [r/CompTIA](https://reddit.com/r/CompTIA) - Study tips and exam experiences

### Home Lab Community
- [r/homelab](https://reddit.com/r/homelab)
- [r/selfhosted](https://reddit.com/r/selfhosted)
- [ServeTheHome Forums](https://forums.servethehome.com/)

### Learning Platforms
- [Linux Academy / A Cloud Guru](https://acloudguru.com/)
- [Pluralsight](https://www.pluralsight.com/)
- [YouTube](https://youtube.com/) - Countless free tutorials

---

## Changelog

### 2025-11-28 - Initial Creation
- Created comprehensive multi-site expansion plan
- Mapped infrastructure to CompTIA certification learning path
- Detailed CEPH learning progression
- Budgeted 6-month timeline with hardware and exam costs
- Documented migration strategy from CachyOS to Proxmox
