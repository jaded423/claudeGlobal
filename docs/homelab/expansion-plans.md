# Home Lab Expansion Plans

**Created:** January 13, 2026
**Current State:** [homelab.md](../homelab.md)

---

## Current Infrastructure Summary

### What We Have

| Resource | Details |
|----------|---------|
| **Proxmox Cluster** | 2 nodes + QDevice (3-vote quorum) |
| **Compute** | book5 (16GB) + tower (78GB, Xeon 16c/32t) |
| **GPU** | Quadro M4000 8GB (passthrough to VM 101) |
| **Storage** | 880GB NVMe (book5) + 370GB SSD + 3.5TB HDD (tower) |
| **Networking** | 1GbE management + 2.5GbE inter-node link |
| **Services** | Plex, Jellyfin, Ollama, Frigate NVR, Pi-hole, qBittorrent |
| **Remote Access** | Twingate (3 connectors) + reverse SSH tunnel |
| **Backup** | Pi1 git mirror (15 repos, 4-hourly) |

### What's Working Well

- Proxmox cluster stable with QDevice quorum
- GPU passthrough for Ollama acceleration
- Frigate NVR with 30-day retention on HDD
- Remote access from anywhere via Twingate
- Pixelbook Go as mobile dev machine with reverse tunnel
- Automated git backups on Pi1

---

## Potential Upgrades

### Raspberry Pi 5 AI Node (Under Consideration)

**Status:** Researching | **Budget:** $731.82

| Component | Cost |
|-----------|------|
| Raspberry Pi 5 16GB | $177.99 |
| Hailo-8L M.2 AI Accelerator (26 TOPS) | $210.00 |
| Pironman 5-MAX Case (dual M.2, OLED, RGB, tower cooler) | $94.99 |
| 2TB Crucial NVMe SSD | $191.99 |
| Shipping | $55.85 |
| **Total** | **$731.82** |

**Note:** Pironman 5-MAX required (not standard) for dual M.2 slots - runs both NVMe + Hailo simultaneously via PCIe switch.

**What Hailo-8L is good for:**
- Real-time object detection (YOLO, SSD) at 26 TOPS
- Frigate has native Hailo support - could offload detection from GPU
- Edge AI inference without cloud dependencies
- Low power (~5W for AI workloads)

**Potential roles:**

| Role | Benefit |
|------|---------|
| **Frigate coral replacement** | Dedicated AI detection, free up Quadro for Ollama |
| **Third Proxmox node** | True HA cluster (2TB local storage) |
| **Dedicated AI inference** | Edge detection, home automation triggers |
| **Replace magic-pihole** | Pi-hole + QDevice + AI in one device |

**Comparison to current setup:**

| Task | Current | With Pi 5 + Hailo |
|------|---------|-------------------|
| Frigate detection | Quadro M4000 (shared with Ollama) | Hailo-8L (dedicated) |
| LLM inference | Quadro M4000 | Quadro M4000 (100% available) |
| Object detection speed | ~15-20 FPS | ~30+ FPS (Hailo optimized) |

**Questions to resolve:**
- [ ] Does Pironman 5 case fit AI HAT+ or is it either/or?
- [ ] Can run Proxmox or better as dedicated Frigate/AI device?
- [ ] Power consumption vs benefit for always-on use

**Decision:** Worth it if Frigate detection is bottlenecking Ollama, or want dedicated edge AI.

---

### Storage Expansion

**Current:** 3.5TB usable on tower HDD

| Option | Cost | Benefit |
|--------|------|---------|
| Add 2nd 4TB HDD to tower | ~$80 | ZFS mirror for redundancy |
| Add NVMe to tower | ~$100 | Faster VM storage |
| Dedicated NAS device | $300-500 | Separate storage from compute |

**Triggers:**
- Media library exceeds 2TB
- Need redundancy for critical data
- Frigate retention needs expansion

---

### Third Proxmox Node

**Current:** 2 nodes + QDevice

| Option | Cost | Benefit |
|--------|------|---------|
| Raspberry Pi 5 (8GB) | ~$100 | Lightweight third node, true HA |
| Mini PC (N100) | ~$150 | Better compute, low power |
| Used workstation | ~$200 | Full compute node |

**Triggers:**
- Need true HA (survive node failure with VMs running)
- Want to experiment with CEPH
- QDevice Pi becomes unreliable

**Note:** Current setup works fine for home use. Third node is "nice to have" not "need to have."

---

### Networking Upgrade (Under Consideration)

**Status:** Researching | **Budget:** ~$300-350

**Current pain points:**
- Spectrum ISP router/modem combo
- Not enough ethernet ports
- Cannot configure (locked down)
- No VLANs, no port forwarding control, no QoS

**Proposed:** TP-Link Deco BE63 (Deco 7 Pro) - 2 Pack

| Feature | Details |
|---------|---------|
| WiFi Standard | WiFi 7 (BE10000) Tri-Band |
| Ports | 4x 2.5GbE per unit (8 total) |
| Backhaul | Wired 2.5GbE or wireless |
| Security | HomeShield, VPN server/client |
| Coverage | ~5,500 sq ft (2-pack) |
| Price | ~$300-350 |

**What this enables:**

| Capability | Current | With Deco 7 Pro |
|------------|---------|-----------------|
| Ethernet ports | ~4 (shared with ISP) | 8x 2.5GbE |
| WiFi speed | WiFi 5/6 (ISP) | WiFi 7 |
| Port forwarding | None (locked) | Full control |
| VPN | Twingate only | Native + Twingate |
| QoS | None | Full control |
| Guest network | Maybe | Yes, isolated |
| Device grouping | No | Yes |

**Network architecture with Deco:**

```
Internet → Spectrum Modem (bridge mode) → Deco 7 Pro (router)
                                              │
                    ┌─────────────┬───────────┼───────────┬─────────────┐
                    │             │           │           │             │
                 book5        tower       pihole        Mac          Go
              (2.5GbE)      (2.5GbE)     (1GbE)      (WiFi 7)    (WiFi 7)
```

**Questions to resolve:**
- [ ] Can Spectrum modem be put in bridge mode? (most can)
- [ ] 2-pack enough or need 3 for coverage?
- [ ] Keep 2.5GbE inter-node direct link or route through Deco?

**Verdict:** High priority - network control is foundational for homelab. 2.5GbE ports match existing inter-node speed.

---

### GPU Upgrade for Ollama (Under Consideration)

**Status:** Researching | **Current:** Quadro M4000 (8GB VRAM)

**Goal:** Run larger LLMs (30B+ parameters) fully in VRAM

| Option | VRAM | Cost | Pros | Cons |
|--------|------|------|------|------|
| **Tesla P40** | 24GB | ~$200-250 + $30 cooling | Best VRAM/dollar, runs 30B+ | Datacenter card, needs cooling |
| **RTX A4000** | 16GB | ~$350-400 | Pro card, quiet, single slot | Less VRAM, pricier |

**Recommended: Tesla P40 + Cooling Kit**

| Component | Cost |
|-----------|------|
| Tesla P40 24GB (used) | ~$200-250 |
| Cooling kit (shroud + fan) | ~$30-40 |
| **Total** | **~$230-290** |

**P40 Cooling Options:**
- **Commercial kit** (Amazon/eBay): 3D printed shroud + 40mm server fan (~$30-40)
- **DIY**: 3D print shroud + Noctua fans (~$30-50, quieter)
- **Simple**: 120mm case fan pointed at heatsink (~$15)

Users report temps dropping from 85°C → 51°C with cooling kits.

**Alternative: RTX A4000**

| Component | Cost |
|-----------|------|
| RTX A4000 16GB (used) | ~$350-400 |
| **Total** | **~$350-400** |

Pros: Quiet, single-slot, no cooling mods needed. Cons: 16GB vs 24GB, ~$100-150 more.

**Combined AI Strategy:**

```
Object Detection  → Pi 5 + Hailo-8L (26 TOPS, dedicated)
LLM Inference     → Tower + Tesla P40 (24GB) or A4000 (16GB)
```

This separates concerns: Frigate detection no longer competes with Ollama for GPU.

---

### Services to Consider

| Service | Purpose | Complexity |
|---------|---------|------------|
| **Uptime Kuma** | Service monitoring | Easy |
| **Grafana + Prometheus** | Metrics/dashboards | Medium |
| **Vaultwarden** | Self-hosted passwords | Easy |
| **Immich** | Photo management | Medium |
| **Paperless-ngx** | Document management | Medium |
| **Home Assistant** | Home automation | Medium |
| **Nextcloud** | Private cloud storage | Medium |
| **Gitea** | Self-hosted git | Easy |

---

### Remote Site Considerations

**Current remote devices:**
- Windows PC (etintake) - WSL + Twingate connector
- Pi1 - Git backup mirror via ICS

**Potential:**
- Second Proxmox node at remote site for DR
- Automated backup replication (ZFS send/receive)
- Cross-site VM failover

**Triggers:**
- Critical services need offsite backup
- Want disaster recovery capability

---

## Not Planned (And Why)

| Item | Reason |
|------|--------|
| **Rack mount** | Overkill for 2 nodes, noise concerns |
| **Dell R630/R730** | Too loud, power hungry for home |
| **Full CEPH cluster** | ZFS + NFS working fine, CEPH needs 3+ nodes |
| **Kubernetes** | Docker Compose sufficient for current needs |
| **Multiple VLANs** | Current flat network works, added complexity |

---

## Decision Framework

**Before buying anything, ask:**

1. **What problem does this solve?** (Not "what could it do")
2. **Is current setup actually limiting me?** (Measure, don't assume)
3. **What's the total cost?** (Hardware + power + time)
4. **Does it add complexity?** (More to maintain/break)

**Guiding principles:**
- Grow based on actual bottlenecks, not hypothetical ones
- Used enterprise hardware offers best value
- Keep total power consumption reasonable (<300W)
- Prefer simple solutions over "proper" complex ones
- Document everything before and after changes

---

## Budget Guidelines

### Active Consideration

| Item | Cost | Priority | Status |
|------|------|----------|--------|
| TP-Link Deco 7 Pro (2-pack) | ~$320 | High | Researching |
| Raspberry Pi 5 + Hailo + Pironman 5-MAX + 2TB NVMe | $731.82 | Medium | Researching |
| Tesla P40 24GB + Cooling Kit | ~$250-290 | Medium | Researching |
| *(or)* RTX A4000 16GB | ~$350-400 | Medium | Alternative |
| **Total (Deco + Pi5 + P40)** | **~$1,300** | | |
| **Total (Deco + Pi5 + A4000)** | **~$1,450** | | |

### General Guidelines

| Priority | Budget | Examples |
|----------|--------|----------|
| **High** | $0-100 | Software changes, minor upgrades |
| **Medium** | $100-300 | Storage expansion, GPU upgrade |
| **Low** | $300+ | Major hardware, networking overhaul |

**Current monthly costs:**
- Power: ~$15-25 (estimated)
- Twingate: Free tier
- Domain/services: ~$0

---

## Archive

Previous expansion plans (historical reference):
- [archive/homelab-expansion-2025-11.md](archive/homelab-expansion-2025-11.md)
- [archive/homelab-multi-site-expansion-2025-11.md](archive/homelab-multi-site-expansion-2025-11.md)
