# Home Lab Expansion Plans

**Last Updated:** November 23, 2025
**Server:** cachyos-jade @ 192.168.2.250

## Infrastructure Evolution

This document tracks the progression of the home lab infrastructure from its current state to future expansion plans, with clear milestones and budget considerations.

---

## ✅ Completed Milestones

### Phase 1: Foundation (Completed November 2025)

- [x] **CachyOS Laptop Server** - Main compute node @ 192.168.2.250
  - [x] Ollama with 7 LLMs (Intel Arc GPU accelerated)
  - [x] Docker infrastructure
  - [x] SSH and Samba file sharing
  - [x] Twingate secure remote access
  - [x] Google Drive integration (2 accounts via rclone)
  - [x] Hyprland desktop environment (Osaka-Jade theme)
  - [x] Always-on configuration with power management
  - [x] Battery health management (80% charge limit)

- [x] **Raspberry Pi 2 Consolidation** - Multi-service node @ 192.168.2.131
  - [x] Pi-hole DNS (network-wide ad blocking)
  - [x] Twingate backup connector
  - [x] Portainer Docker management UI
  - [x] Homarr dashboard
  - [x] MagicMirror kiosk with 6x4" touchscreen

- [x] **Media & Security Infrastructure**
  - [x] Jellyfin media server (port 8096)
  - [x] qBittorrent torrent client (port 8080)
  - [x] ClamAV automated virus scanning
  - [x] Automated download security workflow

- [x] **Development Services**
  - [x] Odoo 17 ERP development environment
  - [x] RustDesk remote desktop server

- [x] **Network Improvements**
  - [x] Personal router for full network control
  - [x] 192.168.2.x subnet configuration
  - [x] Pi-hole DNS working properly

**Investment to date:** ~$0 (repurposed existing hardware)
**Power consumption:** ~55-105W (~$8-16/month)

---

## 🔄 In Progress

### Twingate Expansion
- [ ] Install Twingate connector on work PC
- [ ] Configure bidirectional access (Mac ↔ Home Lab ↔ Work PC)
- [ ] Test RustDesk access through Twingate
- [ ] Document expansion in `~/rustdesk-setup.md` Part 6

---

## 📋 Planned Phases

### Phase 2A: Raspberry Pi 5 Consolidation (Next Month - $185)

**Hardware:** Raspberry Pi 5 with 16GB RAM

**Services to migrate from Pi 2:**
- [ ] Pi-hole DNS (from Pi 2)
- [ ] MagicMirror dashboard (from Pi 2)
- [ ] Twingate backup connector (from Pi 2)
- [ ] Portainer (from Pi 2)
- [ ] Homarr dashboard (from Pi 2)

**New services to add:**
- [ ] Uptime Kuma (service monitoring)
- [ ] Homepage dashboard (alternative to Homarr)
- [ ] Home Assistant (optional - home automation)
- [ ] Wireguard VPN server
- [ ] Grafana + Prometheus monitoring stack

**Old Pi repurposing:**
- **Pi 2:** Testing environment or IoT gateway
- **Pi 1 B+ (already retired):** Small test projects or sensor node

**Expected benefits:**
- Better performance (16GB RAM vs 1GB)
- More services on single device
- Lower total power consumption
- Simplified management

---

### Phase 2B: Storage Server (3-6 Months - $200-300)

**Hardware options:**
- Dell Precision T3600 Tower
- HP Z420 Tower
- Similar enterprise workstation

**Storage configuration:**
- [ ] 2-3x 4TB HDDs (used ~$40-60 each)
- [ ] RAID configuration for redundancy
- [ ] TrueNAS or OpenMediaVault OS

**Services to implement:**
- [ ] NAS file storage
- [ ] Time Machine backup target for Macs
- [ ] Automated backups from CachyOS server
- [ ] Plex/Jellyfin media library storage
- [ ] Photo backup and organization
- [ ] Document archive

**Integration:**
- [ ] 10GbE networking (if budget allows)
- [ ] Automated backup scripts
- [ ] Snapshot scheduling
- [ ] Off-site backup to cloud

---

### Phase 3: AI Workstation (6-12 Months - Only if needed)

**Trigger conditions (implement if any occur):**
- Need to run 13B+ parameter models
- Model training/fine-tuning requirements
- Stable Diffusion image generation needs
- Multiple concurrent AI workloads

**Hardware options:**
1. **Budget option:** Dell T7810 + RTX 3060 12GB (~$400-500)
2. **Performance option:** Dell T7810 + Tesla P40 24GB (~$600-800)
3. **Future-proof option:** Custom build with RTX 4090 24GB (~$2000+)

**Use cases:**
- [ ] Large LLMs (13B, 30B, 70B models)
- [ ] Model training and fine-tuning
- [ ] Stable Diffusion XL
- [ ] Video generation models
- [ ] Keep laptop for lightweight models (1B-7B)

**Software stack:**
- [ ] Ubuntu or CachyOS
- [ ] CUDA toolkit
- [ ] Ollama for inference
- [ ] Automatic1111 for Stable Diffusion
- [ ] Jupyter notebooks for development
- [ ] MLflow for experiment tracking

---

## 💡 Future Ideas (Not Yet Planned)

### Potential Services
- **Nextcloud** - Private cloud storage
- **GitLab/Gitea** - Self-hosted git
- **Vaultwarden** - Password manager
- **Immich** - Photo management like Google Photos
- **Paperless-ngx** - Document management
- **Calibre-web** - E-book library
- **Matrix/Element** - Private chat server
- **Minecraft server** - For family/friends
- **PiKVM** - Remote KVM over IP

### Infrastructure Improvements
- **UPS** - Uninterruptible power supply
- **Rack mount** - Organize equipment properly
- **10GbE networking** - High-speed local transfers
- **Backup internet** - 5G failover connection
- **Smart home integration** - Home Assistant ecosystem

---

## Architecture Progression

### Current State (Phase 1)
```
55-105W Total Power
│
├── CachyOS Laptop @ 192.168.2.250
│   └── Main compute and services
│
└── Raspberry Pi 2 @ 192.168.2.131
    └── DNS, monitoring, dashboard
```

### After Phase 2A (Pi 5)
```
60-115W Total Power
│
├── CachyOS Laptop @ 192.168.2.250
│   └── Main compute and services
│
└── Raspberry Pi 5 16GB @ 192.168.2.xxx
    └── All network services consolidated
```

### After Phase 2B (Storage)
```
160-215W Total Power
│
├── CachyOS Laptop @ 192.168.2.250
│   └── Compute and services
│
├── Raspberry Pi 5 16GB @ 192.168.2.xxx
│   └── Network services
│
└── Storage Tower @ 192.168.2.xxx
    └── 8-16TB NAS array
```

### Full Build (Phase 3)
```
210-265W Total Power (~$34-42/month)
│
├── CachyOS Laptop @ 192.168.2.250
│   └── Light compute, development
│
├── Raspberry Pi 5 16GB @ 192.168.2.xxx
│   └── Network services, monitoring
│
├── Storage Tower @ 192.168.2.xxx
│   └── Data storage, backups
│
└── AI Workstation @ 192.168.2.xxx
    └── Heavy ML/AI workloads
```

---

## Budget Tracking

| Phase | Item | Estimated Cost | Status |
|-------|------|---------------|---------|
| **Phase 1** | Existing hardware | $0 | ✅ Complete |
| **Phase 2A** | Raspberry Pi 5 16GB Kit | $185 | 📋 Planned |
| **Phase 2B** | Storage server + HDDs | $200-300 | 📋 Planned |
| **Phase 3** | AI workstation (if needed) | $400-2000 | 💭 Maybe |
| | **Total (without Phase 3)** | **$385-485** | |
| | **Total (with budget Phase 3)** | **$785-985** | |

---

## Power Consumption Estimates

| Configuration | Wattage | Monthly Cost |
|--------------|---------|--------------|
| **Current** | 55-105W | $8-16 |
| **+ Pi 5** | 60-115W | $9-18 |
| **+ Storage** | 160-215W | $25-35 |
| **+ AI (budget GPU)** | 210-265W | $34-42 |
| **+ AI (high-end GPU)** | 310-365W | $50-58 |

*Estimates based on $0.15/kWh electricity rate*

---

## Decision Criteria

### When to Move to Next Phase

**Phase 2A (Pi 5) triggers:**
- Pi 2 showing performance issues
- Need for more network services
- Want better monitoring capabilities
- Black Friday/sales opportunity

**Phase 2B (Storage) triggers:**
- Running low on laptop storage (<200GB free)
- Need reliable backup solution
- Want to expand media library
- Multiple devices need central storage

**Phase 3 (AI Workstation) triggers:**
- Regularly hitting RAM limits with current models
- Need to run 13B+ parameter models
- Want to train/fine-tune models
- Image generation becomes regular workflow

---

## What NOT to Buy

❌ **Dell R630/R730 rack servers** - Too loud and power-hungry for home use
❌ **High-end GPU immediately** - Current Intel Arc handles 7B models well
❌ **Replacement laptop** - Current one working perfectly as server
❌ **All hardware at once** - Grow based on actual bottlenecks
❌ **Enterprise networking gear** - Overkill for current needs
❌ **Expensive new hardware** - Used enterprise gear offers better value

---

## Guiding Principles

1. **Distributed by function** - Each device optimized for its role
2. **Scalable** - Add components only when needed
3. **Efficient** - Keep total power under 300W even fully built
4. **Budget-conscious** - Under $500 for capable infrastructure
5. **Practical** - Solve real problems, not hypothetical ones
6. **Maintainable** - Simple enough to troubleshoot and repair
7. **Quiet** - Suitable for home environment
8. **Documented** - Every change tracked and explained

---

## Notes

- All IP addresses use 192.168.2.x subnet
- Pi-hole at 192.168.2.131 serves as network DNS
- Twingate provides secure remote access without port forwarding
- Power consumption measured at the wall with Kill-a-Watt
- Used enterprise hardware offers best performance per dollar
- Each phase is independent - can stop at any point
- Regular review of actual vs planned usage before purchases