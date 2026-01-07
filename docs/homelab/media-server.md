# Media Server Organization

Plex/Jellyfin media library structure and automation.

---

## Storage Location

**Primary:** `/media-pool/media/` on prox-tower (ZFS HDD)
**NFS Mount on VM 101:** `/mnt/media-pool/`
**Previous:** `/srv/media/` on prox-book5 (migrated Jan 6, 2026)

---

## Directory Structure

### TV Shows (Serials)
**Path:** `/media-pool/media/Serials/`
**Structure:** `Show Name/Season XX/episodes...`

```
Serials/
├── Friends/
│   └── Season 01-10/
├── Futurama/
│   └── Season 01-08/
└── Stranger Things/
    └── Season 01-04/
```

### Movies
**Path:** `/media-pool/media/Movies/`
**Structure:** Standalone at root, franchises in folders

```
Movies/
├── Evan Almighty (2007) [1080p]/
├── Futurama/
│   ├── Benders Big Score (2007) [1080p].mkv
│   ├── Benders Game (2008) [1080p].mkv
│   ├── Into the Wild Green Yonder (2009) [1080p].mkv
│   └── The Beast with a Billion Backs (2008) [1080p].mkv
└── Star Wars/
    ├── 01 - Episode I - The Phantom Menace (1999)/
    ├── 02 - Episode II - Attack of the Clones (2002)/
    ... (chronological order 01-11)
```

**Star Wars Order:** Numbered by in-universe chronology:
- 01-03: Prequel Trilogy (Episodes I-III)
- 04-05: Anthology (Solo, Rogue One)
- 06-08: Original Trilogy (Episodes IV-VI)
- 09-11: Sequel Trilogy (Episodes VII-IX)

---

## Download Automation

### scan-and-move.sh

**Location:** VM 101 `~/scripts/scan-and-move.sh`
**Status:** Cron disabled (Dec 27, 2025) - needs rework

**What it does:**
- Scans `/home/jaded/downloads/` for completed downloads
- Queries qBittorrent API to verify completion
- Runs ClamAV virus scan
- Auto-organizes TV shows into `Show/Season XX/` structure
- Copies to media folder via NFS mount

**Key Functions:**
- `refresh_qb_cache()` - Fetch qBittorrent torrent info
- `is_torrent_incomplete()` - Check completion status
- `is_file_valid()` - Validate MKV/MP4 headers
- `safe_move()` - Copy → verify → delete pattern
- `extract_show_name()` - Parse show names
- `extract_season_number()` - Get season numbers
- `organize_tv_show()` - Place in Show/Season structure

**Known Issues:**
- Return value logic bugs in `is_download_complete()`
- Script proceeds even when logging "SKIPPING"
- Needs full rework

### qBittorrent Settings

**Web UI:** http://192.168.1.126:8080
**Config:** `/var/lib/docker/volumes/qbit-config/_data/qBittorrent/qBittorrent.conf`

**Optimized Settings (Dec 27, 2025):**
- Removed 1 MB/s speed limit
- Enabled UPnP and port forwarding
- Max connections: 500

---

## Media Servers

### Plex
**Port:** 32400
**Web UI:** http://192.168.1.126:32400/web

### Jellyfin
**Port:** 8096
**Web UI:** http://192.168.1.126:8096
**Status:** Backup media server

---

## NFS Configuration

**Export from prox-tower:**
```bash
/media-pool/media  192.168.1.0/24(rw,sync,no_subtree_check)
/media-pool/ollama 192.168.1.0/24(rw,sync,no_subtree_check)
```

**Mount on VM 101:**
```bash
192.168.1.249:/media-pool/media /mnt/media-pool nfs defaults 0 0
192.168.1.249:/media-pool/ollama /mnt/ollama nfs defaults 0 0
```

---

## Maintenance

### Check Library Size
```bash
ssh root@192.168.2.249 "du -sh /media-pool/media/*"
```

### Verify NFS Mounts
```bash
ssh jaded@192.168.1.126 "df -h | grep media-pool"
```

### Scan Library (Plex)
```bash
# Trigger via Plex web UI or API
curl -X POST "http://localhost:32400/library/sections/1/refresh?X-Plex-Token=YOUR_TOKEN"
```
