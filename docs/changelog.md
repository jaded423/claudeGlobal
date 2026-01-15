# Global Claude Code Configuration - Changelog

This file contains the complete version history of the global Claude Code configuration system.

---

## 2026-01-15 - Open WebUI Docker Compose Migration + Upgrade

Migrated open-webui on VM101 from `docker run` to docker-compose and upgraded to v0.7.2, with configuration now declarative and version-controllable.

## 2026-01-15 - Open WebUI Docker Compose Migration + Upgrade

**What changed:**
- Migrated open-webui on VM101 from `docker run` to docker-compose
- Created `/home/jaded/open-webui/docker-compose.yml` with proper configuration
- Upgraded from Dec 2, 2025 image to v0.7.2 (2026-01-10, build 2b26355)
- Container uses existing named volume `open-webui` (data preserved)

**Why:**
- Docker Compose is industry standard for managing containers
- Configuration is now declarative, version-controllable, and self-documenting
- Future upgrades simplified to: `docker compose pull && docker compose up -d`
- Previous `docker run` command was not documented anywhere

**Compose configuration:**
```yaml
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    environment:
      - TZ=America/Chicago
      - OLLAMA_BASE_URL=http://host.docker.internal:11434
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
      - open-webui:/app/backend/data

volumes:
  open-webui:
    external: true
```

**Files created on VM101:**
- `/home/jaded/open-webui/docker-compose.yml` - New compose file

**Files modified:**
- `docs/homelab/ubuntu.md` - Moved open-webui from "Systemd Services" to Docker containers table, added compose location column, added upgrade instructions

**v0.7.2 release notes:**
- Fixed database connection timeouts under high concurrency
- Fixed workspace prompts editor errors
- Fixed local Whisper speech-to-text
- Improved Evaluations page loading speed
- Fixed Settings tab i18n labels

---

## 2026-01-15 - Version 2.1.7 Release

This release includes 14 bug fixes and improvements, including enhanced security, better Windows compatibility, and improved performance. It also updates OAuth and API Console URLs and enables MCP tool search auto mode by default.

## 2026-01-14 - Odoo Inventory Sheet Sync Implementation Plan

Added comprehensive implementation plan for syncing Odoo inventory data to Google Sheets, including phases for data exploration, API setup, script development, and column mapping.

## 2026-01-14 - Updated marketplace and stats data

Updated the last updated timestamp for the claude-plugins-official marketplace and refreshed user activity statistics in stats-cache.json to reflect new data from January 13, 2026.

## 2026-01-13 - Updated marketplace last updated timestamp

Updated the lastUpdated timestamp for the claude-plugins-official marketplace to reflect the latest sync time.

## 2026-01-13 - Homelab Documentation Cleanup

Removed 2 documentation files related to homelab infrastructure and updated changelog format.

## 2026-01-12 - Updated marketplace last updated timestamp

Updated the lastUpdated timestamp for the claude-plugins-official marketplace from 2026-01-12T17:07:30.398Z to 2026-01-12T19:58:45.123Z in the known_marketplaces.json file.

## 2026-01-12 - OdooReports Automation Migration and Plugin Update

Updated OdooReports project to run cron jobs on WSL for reliable 24/7 execution, and updated the known marketplaces plugin timestamp.

## 2026-01-12 - Updated marketplace last updated timestamp

Updated the lastUpdated timestamp in known_marketplaces.json to reflect the latest sync time.

## 2026-01-12 - Background Task Control and Stats Updates

Added new environment variable to disable background tasks and fixed OAuth refresh logic. Updated stats cache with new daily activity and model usage metrics from the past few days.

## 2026-01-10 - Pixelbook Go Homelab Integration + Claude Bridge Technique

**What changed:**
- Added Pixelbook Go (Chrome OS + Crostini Linux) to homelab with full SSH access
- Installed Twingate connector inside Crostini to bypass Chrome OS port forwarding limitations
- Configured bidirectional SSH: Mac ↔ Pixelbook Go
- Installed Claude Code on Pixelbook Go for local troubleshooting
- Documented "Claude Bridge" technique for cross-machine AI collaboration

**Network setup:**
- SSH runs on port 2222 (Chrome OS restricts ports < 1024)
- Twingate connector routes traffic to Crostini internal IP (100.115.92.198)
- SSH alias: `ssh go` or `ssh pixelbook`

**Claude Bridge technique:**
When two Claude instances can't directly reach each other but both can SSH to a shared server:
1. Create tmux session on shared server: `tmux new-session -d -s bridge`
2. Both Claudes send/read messages via `tmux send-keys` and `tmux capture-pane`
3. Used this to exchange SSH keys and debug connectivity between Mac and Pixelbook

**Files modified:**
- `~/.ssh/config` - Added `go` / `pixelbook` host entry (port 2222, user jaded423)
- `~/.ssh/authorized_keys` - Added Pixelbook Go's public key for reverse access
- `docs/homelab.md` - Added Pixelbook Go to devices table, architecture diagram, SSH section, changelog
- `docs/troubleshooting.md` - Added "Claude Bridge: Cross-Machine AI Collaboration via Shared tmux" section

**Technical notes:**
- Chrome OS port forwarding only works for local/Android apps, not external devices
- Twingate connector inside Crostini punches through this limitation
- SSH initially failed with "kex_exchange_identification" - key wasn't in authorized_keys
- Used tmux bridge on prox-book5 for Mac Claude and Go Claude to collaborate on fix

---

## 2026-01-10 - Pi1 SSH Access via Windows PowerShell ProxyJump

**What changed:**
- Changed Windows OpenSSH default shell from WSL to PowerShell
- Added Mac SSH key to Windows `C:\ProgramData\ssh\administrators_authorized_keys`
- Updated Mac `~/.ssh/config` with new SSH aliases:
  - `ssh pc` → Windows PowerShell (port 22)
  - `ssh wsl` → WSL Ubuntu (port 2222)
  - `ssh pi1` → Pi via ProxyJump through Windows PowerShell

**Why:**
- Windows `netsh interface portproxy` wasn't reliably forwarding port 2223 to the Pi
- WSL cannot reach the Pi's ICS subnet (192.168.137.x) directly
- Windows PowerShell CAN reach the Pi, so ProxyJump through PowerShell works

**Network path (new):**
```
Mac → Windows:22 (PowerShell) → Pi:22 (ProxyJump)
```

**Network path (old, deprecated):**
```
Mac → PC:2223 → Windows portproxy → Pi:22 (unreliable)
```

**Files modified:**
- `~/.ssh/config` - Updated SSH host entries for pc, wsl, pi1
- Windows registry `HKLM:\SOFTWARE\OpenSSH\DefaultShell` - Set to PowerShell
- Windows `C:\ProgramData\ssh\administrators_authorized_keys` - Added Mac's SSH key

**Technical notes:**
- Windows admin users require keys in `administrators_authorized_keys`, not user's `.ssh/authorized_keys`
- Old port 2223 forwarding rule still exists but is no longer used
- WSL access unchanged on port 2222

---

## 2026-01-10 - Updated marketplace last updated timestamp

Updated the lastUpdated timestamp for the claude-plugins-official marketplace from 2026-01-10T06:10:41.388Z to 2026-01-10T15:25:25.075Z in known_marketplaces.json.

## 2026-01-10 - VM Performance & Marketplace Updates

Updated documentation and scripts to address slow Ollama performance on VM101 by adding systemd keepalive and pre-warming on boot. Also updated the known marketplaces JSON with a new timestamp.

## 2026-01-10 - Claude Code v2.1.3 Release + Homelab Updates

Released version 2.1.3 with improved slash command handling, enhanced permission rule detection, and VSCode integration improvements. Updated homelab documentation to reflect new Frigate camera, HDD storage, and RAM optimization changes.

## 2026-01-09 - Frigate Expansion: Second Camera, HDD Storage, RAM Optimization

**What changed:**
- Added second Tapo camera (porch) to Frigate at 192.168.1.129
- Migrated Frigate storage from SSD to HDD (media-pool) - 105GB transferred
- Optimized NFS for async mode + nconnect=8 (130 MB/s vs ~15 MB/s before)
- Changed Frigate recording mode from motion-based to continuous 24/7
- Changed retention from 7 days to 30 days for all recordings
- Reallocated prox-tower RAM: VM 101 = 48GB, ZFS ARC = 18GB, Host = 12GB

**Camera specs discovered:**
- tapo_360_living_room: 2560x1440 (2K), H.264, 20fps, ~2.0 Mbps
- tapo_porch: 3840x2160 (4K), H.265 (HEVC), 30fps, ~1.3 Mbps

**Storage analysis:**
- Combined bitrate: ~3.3 Mbps (~35 GB/day continuous)
- 30-day retention: ~1 TB
- HDD capacity: 3.3 TB free (95+ days possible)

**NFS optimization details:**
- Server-side: Changed /etc/exports from `sync` to `async`
- Client-side: Updated /etc/fstab with `nconnect=8`
- Result: 892 MB/s benchmark (writes to cache, ZFS syncs to disk)

**RAM reallocation:**
- VM 101: 40GB → 48GB
- ZFS ARC: 3GB → 18GB max (persistent in /etc/modprobe.d/zfs.conf)
- Host OS: ~35GB → 12GB (plenty for Proxmox hypervisor)

**Why:**
- Second camera for porch coverage
- HDD better for continuous writes (no SSD wear, more capacity)
- RAM was underutilized - ZFS ARC now caches media reads
- Preparing for Plex + Frigate stress test over weekend

**Files modified on prox-tower:**
- `/etc/exports` - Changed to async mode
- `/etc/modprobe.d/zfs.conf` - ZFS ARC max set to 18GB
- `/etc/pve/qemu-server/101.conf` - VM memory increased to 49152

**Files modified on VM 101:**
- `~/frigate/config/config.yml` - Added tapo_porch camera, changed to continuous recording
- `~/frigate/docker-compose.yml` - Changed media path to /mnt/media-pool/frigate
- `/etc/fstab` - Added nconnect=8 to NFS mount

**Technical notes:**
- Attempted virtiofs for direct HDD access but virtiofsd crashed (InvalidParam error)
- NFS with async mode ended up being simpler and fast enough (~130 MB/s)
- ZFS ARC will auto-fill to 18GB as media is accessed, reducing HDD seeks for Plex

---

## 2026-01-09 - Mac Battery Optimization + Passwordless Sudo

**What changed:**
- Diagnosed battery drain on MacBook Air M4 (Mac16,12)
- Identified RustDesk as primary drain (40% CPU, blocking display sleep)
- Identified ClickUp as secondary drain (1.4GB RAM)
- Enabled Low Power Mode on battery (`sudo pmset -b lowpowermode 1`)
- Configured passwordless sudo for user j via `/etc/sudoers.d/j-nopasswd`

**Why:**
- User experiencing poor battery life on new MacBook Air
- RustDesk was preventing display sleep and using excessive CPU even when idle
- Passwordless sudo allows Claude to run system commands directly

**System state after changes:**
- Battery health: 100% capacity, 40 cycles, Normal condition
- RustDesk server (background): 0.2% CPU, 39MB RAM - fine to leave running
- Low Power Mode: Enabled on battery
- Sudo: Works without password for user j

**Files modified:**
- `/etc/sudoers.d/j-nopasswd` - Created with `j ALL=(ALL) NOPASSWD: ALL`
- `~/.claude/CLAUDE.md` - Updated sudo limitations section

---

## 2026-01-09 - Stats and marketplace update

Updated statistics cache with new daily activity and model usage data for January 9th, and refreshed the last updated timestamp for the Claude plugins marketplace.

## 2026-01-09 - Pi1 Terminal Setup + DOOM ASCII

Configured Raspberry Pi 1 Model B+ with zsh, Oh My Zsh, Powerlevel10k, fzf, zoxide, vim, and installed doom-ascii terminal DOOM game.

## 2026-01-09 - Pi1 Terminal Setup + DOOM ASCII

**What changed:**
- Configured Raspberry Pi 1 Model B+ (pi1) with Mac-like terminal environment
- Installed: zsh, Oh My Zsh, Powerlevel10k theme, fzf, zoxide, vim
- Created Pi-compatible ~/.zshrc (Linux adaptations, no Mac-specific plugins)
- Created ~/.zsh/functions/ with: git-functions.zsh, ssh-functions.zsh, utils.zsh
- Created ~/.ssh/config (Linux-compatible, removed UseKeychain)
- Set zsh as default shell via `chsh`
- Added Mac aliases: sz, vz, ll, la, doom, etc.
- Built doom-ascii from source (~17 min compile time on 700MHz ARM11)
- Installed DOOM shareware WAD for terminal-based ASCII DOOM

**Why:**
- User wanted same terminal feel on Pi1 as on Mac
- Pi1 is headless (no display), accessed via SSH through PC port forward
- DOOM was a fun "can it run DOOM?" challenge for the 2014 hardware

**Pi1 Specs:**
- Raspberry Pi Model B Plus Rev 1.2 (2014)
- ARMv6 700MHz single-core, 427MB RAM
- Raspbian Bookworm (Debian 12)
- Access: `ssh pi1` (port 2223 via PC)

**Files created on Pi1:**
- `~/.zshrc` - Oh My Zsh + Powerlevel10k config
- `~/.zsh/functions/*.zsh` - 3 function files
- `~/.ssh/config` - SSH shortcuts (Linux-compatible)
- `~/doom-ascii/` - DOOM ASCII game (compiled from source)

**Performance notes:**
- zsh source takes 15-22 seconds on Pi1 (Oh My Zsh + P10k overhead)
- DOOM ASCII playable at `-scaling 6` (lower res for performance)
- Braille mode (-chars braille) caused rendering issues, reverted to ASCII

**Commands added:**
- `doom` - Run DOOM ASCII in terminal
- `sysinfo` - Show Pi system stats including CPU temp
- `gitall` - Check status of all repos in ~/projects

---

## 2026-01-08 - Proxmox Network Reconfiguration (Direct 2.5G Inter-Node Link)

**What changed:**
- Reconfigured Proxmox cluster networking: 2.5GbE now used for direct inter-node link instead of VM traffic
- VM 101 moved from 192.168.1.126 (2.5GbE vmbr1) to 192.168.2.126 (1GbE vmbr0)
- Created direct 2.5G link between prox-book5 and prox-tower on private 10.10.10.0/30 subnet
- Both nodes now have 1GbE to router (internet) + 2.5GbE direct to each other (inter-node)
- Updated 10 documentation files with new VM 101 IP
- Updated ~/.ssh/config: changed VM 101 IP, removed tower-fast entry
- Updated NFS exports on tower: 192.168.1.126 → 192.168.2.126
- Updated NFS mounts on VM 101 fstab: 192.168.1.249 → 192.168.2.249
- Configured vmbr1 on book5 with 10.10.10.1/30 for direct link

**Why:**
- User adding 2.5GbE adapter to book5 but router only has one 2.5G port
- Direct inter-node link provides 2.36 Gbps for VM migrations and storage replication
- Plan to get 2.5G mesh WiFi system later; this is interim solution
- Internet limited to 1GbE per node but cluster traffic gets full 2.5G speed

**Network topology now:**
```
┌─────────────────┐     Direct 2.5G Link     ┌─────────────────┐
│   prox-book5    │      (2.36 Gbps)         │   prox-tower    │
│  vmbr1: 10.10.10.1 ◄──────────────────────► vmbr1: 10.10.10.2 │
│  vmbr0: 192.168.2.250                       vmbr0: 192.168.2.249 │
└────────┬────────┘                          └────────┬────────┘
         │ 1GbE                                       │ 1GbE
         └──────────────┬─────────────────────────────┘
                        │
                   ┌────┴────┐
                   │ Router  │
                   └─────────┘
```

**Files modified:**
- `~/.ssh/config` - Updated VM 101 IP, removed tower-fast entry
- `CLAUDE.md` - Updated VM 101 SSH reference
- `docs/homelab.md` - Updated IP references
- `docs/ssh-access-cheatsheet.md` - Updated IPs and 2.5GbE→1GbE notes
- `docs/projects.md` - Updated VM 101 reference
- `docs/mac.md` - Updated VM 101 reference
- `docs/homelab/media-server.md` - Updated Web UI URLs, NFS exports
- `docs/homelab/services.md` - Updated service locations
- `docs/homelab/google-drive.md` - Updated mount paths
- `docs/homelab/gpu-passthrough.md` - Updated SSH commands
- Tower `/etc/exports` - Updated NFS export IPs
- VM 101 `/etc/fstab` - Updated NFS mount IPs
- Tower `/etc/network/interfaces` - Added gateway to vmbr0, changed vmbr1 to 10.10.10.2/30
- Book5 `/etc/network/interfaces` - Added vmbr1 with 10.10.10.1/30

**Speed test results:**
- Direct inter-node link: **2.36 Gbps** (verified with iperf3)
- Internet per node: ~940 Mbps (1GbE limit)

**Technical notes:**
- VM 101's network bridge changed from vmbr1 to vmbr0 (qm set 101 --net0)
- VM 101 netplan updated: 192.168.1.126/24 → 192.168.2.126/24, gateway .1.1 → .2.1
- ProxyJump still required for SSH to VM 101 (Mac on 192.168.1.x, VM on 192.168.2.x)
- NFS mounts remounted successfully after IP changes

---

## 2026-01-09 - Updated metrics and marketplace timestamp

Added new performance metrics entry to ollamaLog-metrics.csv and updated the lastUpdated timestamp for the claude-plugins-official marketplace in known_marketplaces.json.

---


## 2026-01-07 - PC WSL Fixes and nvim Downgrade

**What changed:**
- Fixed WSL startup error by removing invalid Z: drive mount from `/etc/fstab`
- Installed ascii-image-converter to `/usr/local/bin/` for nvim snacks dashboard
- Downgraded nvim from 0.12.0-dev to 0.11.5 (AppImage at `~/.local/bin/nvim`)
- Pinned nvim-treesitter to commit 42fc28ba (master branch, matches Mac)
- Updated snacks.lua to use `vim.fn.exepath()` for cross-platform binary lookup
- Created convenience symlinks: `~/C` → `/mnt/c`, `~/Documents` → `/mnt/c/Users/joshu/Documents`
- Added `~/.local/bin` to PATH in `~/.zshenv`
- Added ls alias to suppress Windows system file permission errors

**Why:**
- fstab had stale Z: drive mount causing "mount -a failed" on WSL startup
- nvim 0.12.0-dev (nightly) had breaking changes with treesitter
- snacks dashboard couldn't find ascii-image-converter (PATH issue in spawned shells)
- Needed quick access to Windows C: drive and Documents from WSL

**Technical notes:**
- nvim 0.11.5 installed via AppImage, takes precedence over apt-installed 0.12-dev
- nvim-treesitter removed `configs.lua` module in main branch; pinned to last master commit
- Windows system files (hiberfil.sys, pagefile.sys, etc.) cause permission errors in WSL - normal behavior
- `vim.fn.exepath()` resolves full binary path at runtime, works cross-platform

**PC now has:**
- nvim 0.11.5 (matches Mac)
- ascii-image-converter for dashboard snake art
- Symlinks: ~/C, ~/Documents
- Clean ls output (suppresses permission errors)

---

## 2026-01-08 - Core Service and Plugin Updates

**What changed:**
- Updated official Claude plugin marketplace with new commit and last updated timestamp
- Stats cache updated to reflect new daily activity and token usage for 2026-01-08
- Updated Atlassian MCP integration to use a more reliable default configuration (streamable HTTP)
- Changed "Interrupted" message color from red to grey for a less alarming appearance
- Removed permission prompt when entering plan mode - users can now enter plan mode without approval
- Removed underline styling from image reference links

**Why:**
- The plugin marketplace update ensures users have access to the latest official plugins
- The stats cache update reflects daily usage and token consumption for the new date
- The Atlassian MCP integration change improves reliability of HTTP streaming
- The UI/UX refinements improve user experience by reducing unnecessary prompts and visual clutter

**Files modified:**
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp for claude-plugins-official marketplace
- `plugins/marketplaces/claude-plugins-official` - Updated submodule commit
- `stats-cache.json` - Updated daily activity and token usage for 2026-01-08
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp for claude-plugins-official marketplace
- `plugins/marketplaces/claude-plugins-official` - Updated submodule commit
- `stats-cache.json` - Updated daily activity and token usage for 2026-01-08
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp for claude-plugins-official marketplace
- `plugins/marketplaces/claude-plugins-official` - Updated submodule commit
- `stats-cache.json` - Updated daily activity and token usage for 2026-01-08

---


## 2026-01-08 - Updated lastUpdated timestamp for claude-plugins-official marketplace

**What changed:**
- Updated the `lastUpdated` timestamp in `plugins/known_marketplaces.json` for the claude-plugins-official marketplace
- The timestamp was updated from "2026-01-08T22:31:40.600Z" to "2026-01-08T22:52:51.844Z"

**Why:**
- This change reflects the most recent update time for the claude-plugins-official marketplace, ensuring accurate tracking of when the marketplace metadata was last modified

**Files modified:**
- `plugins/known_marketplaces.json` - Updated the `lastUpdated` field for the claude-plugins-official marketplace entry

---


                                                                                                                                                                                                                                                                                                                                                                                                                           ```changelog
## 2026-01-08 - Image Cache and Documentation Updates

**What changed:**
- Updated image cache handling for PNG files in `image-cache/` directory
- Added documentation for smart routing of changes between `CLAUDE.md` and `changelog.md`
- Added new section for "SMART DOCUMENTATION ROUTING" with clear categorization
- Updated `projects.md` with recent changes summary

**Why:**
- The image cache system now properly handles PNG files and includes metadata
- Documentation improvements to clarify how changes should be categorized and stored
- Better organization of project documentation to improve maintainability

**Files modified:**
- `image-cache/1783392b-9963-4632-ac36-5134b175e29e/10.png` - Added PNG file with metadata
- `docs/changelog.md` - Added new changelog entry and documentation
- `docs/CLAUDE.md` - Added smart documentation routing logic
- `docs/projects.md` - Updated with recent changes summary

---


                                                                                                                 ```changelog
## 2026-01-08 - Image cache directory added

**What changed:**
- New directory `image-cache/1783392b-9963-4632-ac36-5134b175e29e/` created
- Directory contains image cache files for a specific image ID

**Why:**
- Image caching functionality has been implemented to improve performance
- The system now stores processed images in a timestamped directory structure
- This change supports the image processing pipeline and reduces redundant processing

**Files modified:**
- `image-cache/1783392b-9963-4632-ac36-5134b175e29e/` - New cache directory with image files

---


## 2026-01-08 - Swift LSP Plugin Installation and Enablement

**What changed:**
- Installed and enabled the `swift-lsp@claude-plugins-official` plugin
- Updated `installed_plugins.json` to include the new plugin with its installation details
- Updated `settings.json` to enable the plugin in the current configuration

**Why:**
- To provide Swift language server support for Claude's plugin system
- The plugin was installed and configured to be active in the current setup

**Files modified:**
- `plugins/installed_plugins.json` - Added entry for swift-lsp plugin with version, install path, and git commit
- `settings.json` - Enabled the swift-lsp plugin in the enabledPlugins configuration

---


                                                                                                               ```changelog
## 2026-01-08 - Image cache directory added

**What changed:**
- Added new directory `image-cache/4caf8946-37cc-46eb-ac47-ed68d56f3505/`
- Directory contains image cache data for a specific service or process

**Why:**
- This appears to be a new image cache directory created by a service or process
- Likely related to image processing or caching functionality in the system
- The UUID-based directory name suggests this is part of an automated image caching system

**Files modified:**
- `image-cache/4caf8946-37cc-46eb-ac47-ed68d56f3505/` - New directory added

---


## 2026-01-08 - Repository State and Stats Updates

**What changed:**
- Removed cached image file `image-cache/1783392b-9963-4632-ac36-5134b175e29e/1.png`
- Updated `plugins/known_marketplaces.json` with new timestamp for marketplace
- Updated `stats-cache.json` with new date entry for 2026-01-07 and updated usage statistics

**Why:**
- The removed image cache likely reflects cleanup of obsolete or unused assets
- The marketplace timestamp update indicates a recent plugin or marketplace sync
- The stats update reflects daily usage metrics and updated token usage statistics

**Files modified:**
- `image-cache/1783392b-9963-4632-ac36-5134b175e29e/1.png` - File deleted
- `plugins/known_marketplaces.json` - Timestamp updated
- `stats-cache.json` - Date entry added and usage statistics updated

---


## 2026-01-07 - Image cache cleanup and marketplace update

**What changed:**
- Deleted image cache files for session 5ce70ade-69b8-4b61-a0b0-0a9c117a5831 (1.png and 2.png)
- Updated lastUpdated timestamp in plugins/known_marketplaces.json
- Updated subproject commit for claude-plugins-official marketplace

**Why:**
- The image cache files were likely outdated or no longer needed, triggering their deletion
- The marketplace metadata was updated to reflect the current state of the official Claude plugins repository
- The subproject commit was updated to point to the latest version of the claude-plugins-official repository

**Files modified:**
- `image-cache/5ce70ade-69b8-4b61-a0b0-0a9c117a5831/1.png` - Deleted
- `image-cache/5ce70ade-69b8-4b61-a0b0-0a9c117a5831/2.png` - Deleted
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp
- `plugins/marketplaces/claude-plugins-official` - Updated subproject commit

---


## 2026-01-07 - Image cache cleanup and marketplace metadata update

**What changed:**
- Deleted stale image cache file `image-cache/631bd273-a9bf-46e4-8e20-8a1d40b91da6/1.png`
- Updated lastUpdated timestamp in `plugins/known_marketplaces.json` from 2026-01-07T20:46:06.830Z to 2026-01-07T21:33:29.011Z

**Why:**
- The deleted image cache file was likely a stale or obsolete cached asset that is no longer needed
- The timestamp update reflects the latest state of marketplace plugin metadata, ensuring proper version tracking for plugin management

**Files modified:**
- `image-cache/631bd273-a9bf-46e4-8e20-8a1d40b91da6/1.png` - Removed stale cache file
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp for marketplace plugin metadata

---


## 2026-01-07 - Updated Claude Configuration and Image Cache Cleanup

**What changed:**
- Updated shell configuration to explicitly use zsh instead of bash in CLAUDE.md
- Removed three image cache files (1.png, 2.png, 3.png) from the image-cache directory
- Updated lastUpdated timestamp in plugins/known_marketplaces.json

**Why:**
- Clarified that all systems use zsh, ensuring proper configuration file updates
- Cleaned up stale image cache entries that are no longer needed
- Updated marketplace plugin timestamp to reflect recent changes

**Files modified:**
- `CLAUDE.md` - Added shell configuration note
- `image-cache/df22ef64-0bdf-47fa-a3eb-ac2b1c6b5fc7/1.png` - Deleted
- `image-cache/df22ef64-0bdf-47fa-a3eb-ac2b1c6b5fc7/2.png` - Deleted
- `image-cache/df22ef64-0bdf-47fa-a3eb-ac2b1c6b5fc7/3.png` - Deleted
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp

---


## 2026-01-07 - PC WSL Fixes and nvim Downgrade

**What changed:**
- Fixed WSL startup error by removing invalid Z: drive mount from `/etc/fstab`
- Installed ascii-image-converter to `/usr/local/bin/` for nvim snacks dashboard
- Downgraded nvim from 0.12.0-dev to 0.11.5 (AppImage at `~/.local/bin/nvim`)
- Pinned nvim-treesitter to commit 42fc28ba (master branch, matches Mac)
- Updated snacks.lua to use `vim.fn.exepath()` for cross-platform binary lookup
- Created convenience symlinks: `~/C` → `/mnt/c`, `~/Documents` → `/mnt/c/Users/joshu/Documents`
- Added `~/.local/bin` to PATH in `~/.zshenv`
- Added ls alias to suppress Windows system file permission errors

**Why:**
- fstab had stale Z: drive mount causing "mount -a failed" on WSL startup
- nvim 0.12.0-dev (nightly) had breaking changes with treesitter
- snacks dashboard couldn't find ascii-image-converter (PATH issue in spawned shells)
- Needed quick access to Windows C: drive and Documents from WSL

**Files modified:**
- `docs/changelog.md` - Added detailed entry for WSL fixes
- `docs/machine-context.md` - Added Windows PC entry to machine table
- `docs/projects.md` - Updated nvimConfig and zshConfig entries with PC sync info

---


## 2026-01-07 - Synced nvim and zsh Configs to Windows PC (WSL)

**What changed:**
- Copied full nvim config from Mac to PC (`~/.config/nvim/`)
- Upgraded nvim on PC from 0.9.5 to 0.12.0 (via neovim-ppa/unstable)
- Installed deno and built peek.nvim for markdown preview
- Installed fd-find (symlinked as `fd`) and ripgrep for telescope.nvim
- Copied and adapted zshrc from Mac to PC with Linux-specific changes
- Created `~/.zsh/functions/` on PC with adapted function files:
  - `claude.zsh` - Claude Code wrapper
  - `fzf.zsh` - FZF config (pbcopy → xclip)
  - `ssh-functions.zsh` - SSH machine aliases
  - `git-functions.zsh` - gitall, commits (date -v → date -d)
  - `utils.zsh` - docxdiff, xlsxdiff
- Copied p10k.zsh config for consistent prompt styling
- Installed powerlevel10k in oh-my-zsh custom themes

**Why:**
- User wanted consistent development environment across Mac and PC
- Telescope.nvim requires fd and rg for file finding
- peek.nvim requires deno for markdown preview
- zsh functions needed Linux adaptations (clipboard, date syntax)

**Technical notes:**
- PC access via `ssh pc` (configured in earlier session via Twingate)
- Mac-specific items removed: brew plugin, macos plugin, homebrew paths, Vault path
- Linux adaptations: `pbcopy` → `xclip -selection clipboard`, `date -v-1d` → `date -d "1 day ago"`
- fd-find on Ubuntu installs as `fdfind`, symlinked to `~/.local/bin/fd`

**PC now has:**
- nvim 0.12.0 with full plugin config
- zsh with oh-my-zsh + powerlevel10k
- Same prompt styling as Mac
- SSH aliases (book5, tower, omarchy, ubuntu)
- Git status functions (gitall, commits)

---

## January 6, 2026 - Documentation System Overhaul

**Summary:**
Major restructure of homelab documentation and revamp of /log command to prevent future doc bloat.

**What changed:**

1. **Homelab Documentation Restructure:**
   - Reduced homelab.md from 2,282 lines to 271 lines (88% reduction)
   - Created `docs/homelab/` subdirectory with 6 detailed reference files:
     - `services.md` (295 lines) - Full service configurations
     - `troubleshooting.md` (344 lines) - Complete troubleshooting guide
     - `setup-guides.md` (173 lines) - Installation procedures
     - `gpu-passthrough.md` (192 lines) - Quadro M4000 passthrough docs
     - `google-drive.md` (174 lines) - rclone FUSE mount configuration
     - `media-server.md` (142 lines) - Plex/Jellyfin organization
   - Archived original to `docs/backups/homelab-20260106-*.md`

2. **Revamped /log Command:**
   - Smart routing: current state → CLAUDE.md, details → changelog.md
   - Separate changelog.md files per project (append-only paper trail)
   - Document health checks with size warnings
   - Clear categorization rules (Category A/B/C)
   - Anti-patterns to avoid (no journey narratives in main docs)

**Why:**
- Original homelab.md exceeded Claude's read limit (25K tokens)
- Documentation was mixing "current state" with "journey/history"
- No systematic approach to prevent bloat
- User kept forgetting to run /sum

**New documentation pattern:**
```
project/
├── CLAUDE.md           # Current state ONLY (200-400 lines)
├── docs/
│   ├── changelog.md    # Append-only history (paper trail)
│   └── [topic].md      # Detailed reference docs
```

**Files modified:**
- `docs/homelab.md` - Complete rewrite (lean version)
- `docs/homelab/*.md` - 6 new detailed reference files
- `commands/log.md` - Complete rewrite with smart routing
- `docs/changelog.md` - This entry

---

## 2026-01-07 - Windows PC SSH Access Setup and Documentation Update

**What changed:**
- Added documentation for accessing Windows PC via SSH through Twingate
- Updated `ssh` configuration to support Windows PC access via Twingate
- Introduced automated startup script (`/etc/wsl-ssh-startup.sh`) for WSL SSH server
- Updated `known_marketplaces.json` with new timestamp

**Why:**
- To enable secure remote access to Windows PC via SSH through Twingate
- To automate WSL SSH server startup and port forwarding on boot
- To maintain accurate documentation of remote access setup

**Files modified:**
- `docs/ssh.md` - Added Windows PC SSH access instructions and configuration
- `docs/changelog.md` - Updated with new entry for Windows PC SSH setup
- `docs/known_issues.md` - Added note about WSL SSH access gotchas
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp
- `image-cache/...` - Removed image cache files (likely temporary or obsolete)

---


## 2026-01-07 - Updated marketplace timestamp and cleaned image cache

**What changed:**
- Updated the `lastUpdated` timestamp in `plugins/known_marketplaces.json` to reflect the latest update time
- Removed an image file from the cache directory (`image-cache/c7218a46-43c8-484e-9d4d-8c7ab055a52e/1.png`)

**Why:**
- The timestamp update ensures that the marketplace plugin's last update time is correctly recorded
- The image file deletion indicates cleanup or migration of cached assets, likely related to a refresh or update in the image handling system

**Files modified:**
- `plugins/known_marketplaces.json` - Updated the `lastUpdated` field to reflect the current timestamp
- `image-cache/c7218a46-43c8-484e-9d4d-8c7ab055a52e/1.png` - File was removed from the cache

---


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ```changelog
## 2026-01-06 - Updated documentation structure and routing rules

**What changed:**
- Restructured global documentation directory layout
- Updated CLAUDE.md with new directory structure and command definitions
- Added SMART DOCUMENTATION ROUTING guidelines
- Updated slash command definitions and usage patterns
- Improved tmux session usage instructions
- Enhanced persistent session management for system-changing operations

**Why:**
- Standardized documentation structure for better maintainability
- Clarified when and where changes should be documented
- Improved consistency across all projects using the CLAUDE.md pattern
- Enhanced transparency for system-changing operations via tmux sessions
- Streamlined global command definitions and usage

**Files modified:**
- `~/.claude/CLAUDE.md` - Updated with new structure and routing rules
- `~/.claude/commands/init.md` - Updated with lean structure pattern
- `~/.claude/commands/log.md` - Updated with new documentation routing
- `~/.claude/commands/sum.md` - Updated with new archive patterns
- `~/.claude/docs/homelab/` - Updated with new homelab documentation structure
- `~/.claude/docs/` - Added new documentation categories and files

---


## December 20, 2025 - Phone Terminal Setup (oh-my-zsh + powerlevel10k)

**Summary:**
Configured phone (Samsung S25 Ultra / Termux) terminal to match Mac's oh-my-zsh + powerlevel10k setup.

**Changes Made (on phone via SSH from Mac):**

Packages Installed:
- `zsh` (5.9) - Modern shell
- `zoxide` - Already installed, smart directory navigation
- `fzf` - Already installed, fuzzy finder

Software Configured:
- **oh-my-zsh** - Cloned to `~/.oh-my-zsh`
- **powerlevel10k** - Theme cloned to `~/.oh-my-zsh/custom/themes/powerlevel10k`
- **~/.zshrc** - New config with powerlevel10k theme and Termux-compatible plugins
- **~/.p10k.zsh** - Copied from Mac for identical prompt styling
- **Default shell** - Changed to zsh via `chsh -s zsh`

Plugins Enabled:
- git, zoxide, fzf, docker, npm, python, colored-man-pages, jsontools, history, sudo

Aliases Configured:
- `vim`/`vi` → nvim
- `vz` → edit .zshrc
- `sz` → source .zshrc

**Files on Phone:**
- `~/.zshrc` - New zsh configuration
- `~/.p10k.zsh` - Copied from Mac (~/projects/zshConfig/p10k.zsh)
- `~/.oh-my-zsh/` - oh-my-zsh installation
- `~/.oh-my-zsh/custom/themes/powerlevel10k/` - Theme
- `~/.termux/shell` - Symlink to `/data/data/com.termux/files/usr/bin/zsh`

**Impact:**
- Phone terminal now matches Mac's prompt appearance
- Consistent experience across devices
- zoxide provides smart `z` navigation on phone
- Git integration in prompt shows repo status

---

## December 20, 2025 - Unified SSH Access to Mac from All Machines

**Summary:**
Set up reliable SSH access to Mac (192.168.2.226) from all homelab machines, replacing the previous `host.docker.internal` Twingate-based approach with direct LAN access.

**Changes Made:**

Mac Configuration:
- Added SSH public keys to `~/.ssh/authorized_keys` for:
  - `root@prox-tower` (ssh-rsa)
  - `jaded@ubuntu-server` (ssh-ed25519, newly generated)
  - `termux@s25ultra` (ssh-ed25519)

Remote Machine SSH Configs Updated:
- **book5** (`~/.ssh/config`) - Mac entry: `192.168.2.226`, user `j`
- **tower** (`~/.ssh/config`) - Cleaned duplicate entries, Mac entry: `192.168.2.226`, user `j`
- **termux** (`~/.ssh/config`) - Mac entry with `ProxyJump tower-fast` for cross-network access

Key Generation:
- Generated new ed25519 SSH key on ubuntu-server (didn't have one)

**Network Architecture:**
- Mac at 192.168.2.226 (management network)
- Direct access from book5, tower (same 192.168.2.x subnet)
- Termux (phone) on 192.168.1.x requires ProxyJump through tower-fast (192.168.1.249)

**Working SSH Access:**
| Source | Method | Status |
|--------|--------|--------|
| book5 | Direct | ✅ |
| tower | Direct | ✅ |
| termux | ProxyJump via tower-fast | ✅ |
| ubuntu-server | Not needed (VM) | Skipped |
| omarchy | Not needed (VM) | Skipped |

**Impact:**
- Consistent `ssh mac` command works from all homelab machines
- No longer dependent on Twingate `host.docker.internal` for local access
- Phone can SSH to Mac even when on different subnet (via ProxyJump)

**Files Modified:**
- `~/.ssh/authorized_keys` (Mac) - Added 3 new public keys
- `~/.ssh/config` (book5) - Updated Mac entry
- `~/.ssh/config` (tower) - Cleaned up, updated Mac entry
- `~/.ssh/config` (termux) - Added Mac with ProxyJump
- `~/.claude/docs/ssh-access-cheatsheet.md` - Updated Mac access documentation

**Note:** omarchy VM was unreachable at session start (encrypted disk needed login after reboot). SSH from VMs to Mac deemed unnecessary since user can ProxyJump through parent Proxmox hosts.

---

## December 20, 2025 - Mac Power Management & Documentation Split

**Changes:**
- Created `docs/mac.md` for Mac-specific configuration documentation
- Configured always-on power management to fix Twingate disconnect issues
- Separated Mac configs from homelab.md for cleaner organization

**Power Settings Applied:**
```bash
sudo pmset -a sleep 0           # System never sleeps
sudo pmset -a disablesleep 1    # Including lid close
sudo pmset -a displaysleep 10   # Display sleeps after 10 min
sudo pmset -a lowpowermode 0    # Low Power Mode off
```

**Problem Solved:**
- Mac was sleeping after 1 minute on battery (6,466+ sleep/wake cycles)
- Each sleep caused Twingate disconnect/reconnect emails
- Now Mac stays awake 24/7, display sleeps after 10 min

**Files created:**
- `docs/mac.md` - New Mac-specific configuration docs

**Files modified:**
- `CLAUDE.md` - Added mac.md to docs listing

---

## December 17, 2025 - Removed Unused Plugins (greptile, context7)

**Changes:**
- Uninstalled `greptile@claude-plugins-official` plugin
- Uninstalled `context7@claude-plugins-official` plugin
- Removed both plugins from enabledPlugins in settings.json

**Impact:**
- Reduced plugin overhead by removing unused extensions
- Remaining plugins: ralph-wiggum, commit-commands, plugin-dev

**Files modified:**
- `plugins/installed_plugins.json` - Removed greptile and context7 entries
- `settings.json` - Removed greptile and context7 from enabledPlugins

---

## December 17, 2025 - Plugin Marketplace Refresh & Cleanup

**Changes:**
- Plugin marketplace timestamp automatically updated during routine refresh
- Removed unused `logs/log-command-metrics.csv` (empty file with only header row)

**Impact:**
- No functional changes; standard metadata update and cleanup

**Files modified:**
- `plugins/known_marketplaces.json` - lastUpdated timestamp refreshed

**Files deleted:**
- `logs/log-command-metrics.csv` - Unused metrics template removed

---

## December 15, 2025 - Token Usage Tracking for /log Command

**Changes:**
- Added step 7 to `/log` command for token usage tracking
- Created `~/.claude/logs/log-command-tokens.csv` for analysis
- CSV format: timestamp, project, tokens_used

**Impact:**
- Can now analyze average token consumption per `/log` invocation
- Data available for optimizing documentation workflows
- Easy analysis with awk/spreadsheet tools

**Files modified:**
- `~/.claude/commands/log.md` - Added token logging step

**Files created:**
- `~/.claude/logs/log-command-tokens.csv` - Token usage log (CSV)

---

## December 15, 2025 - Removed /save and /bye Commands (Non-functional)

**What happened:**
- Created `/save` and `/bye` commands to auto-document before exit/clear
- Discovered Claude Code cannot programmatically invoke `/clear` or `/exit`
- Commands were useless — moved to graveyard

**Lesson learned:**
- Slash commands can run `/log` but can't trigger CLI commands like `/clear` or `/exit`
- No hook-based solution exists for "auto-log before exit" with full LLM analysis

**Files moved to graveyard:**
- `~/projects/graveyard/claude-global/save.md`
- `~/projects/graveyard/claude-global/bye.md`

---

## December 12, 2025 - Homelab Twingate Systemd Migration & NIC Fix

**Summary:**
Major infrastructure changes to home lab Proxmox cluster - migrated Twingate connectors from LXC containers to native systemd services and fixed Intel NIC hardware hang bug.

**Problem Investigated:**
- prox-tower lost SSH and Proxmox web UI access twice (Dec 11 ~10:57 AM, Dec 12 ~11:28 AM)
- Root cause: Intel I218-LM onboard NIC experiencing hardware hangs (e1000e driver TSO bug)
- Twingate connector stuck in authentication loop since Dec 3 (connector was unregistered from admin console)

**Changes Made:**

Infrastructure:
- **prox-tower:** Added TSO/GSO/GRO disable to `/etc/network/interfaces`, installed Twingate systemd service, removed LXC 201 and Docker container
- **prox-book5:** Installed Twingate systemd service (via SSH from tower), removed LXC 200
- **Cluster-wide:** Renamed ZFS storage pools (`local-zfs` → `local-zfs-book5` / `local-zfs-tower`)

Documentation Updated:
- `docs/homelab.md` - Complete rewrite of Twingate section, added Known Issues section, added Pending Hardware Upgrades table
- `docs/ssh-access-cheatsheet.md` - Updated network diagram (systemd instead of LXC), fixed VM numbering (VM 101 not VM 102)

Files Created on prox-tower:
- `/root/twin-connect-systemd.md` - Twingate systemd setup instructions
- `/root/nic-upgrade-tplink-tx201.md` - Network card upgrade instructions

**Pending Hardware Upgrades:**
- CPU: Intel Xeon E5-2683 V4 (16 core, 40MB cache)
- NIC: TP-Link TX201 (2.5GbE, Realtek RTL8125)

**Impact:**
- Twingate connectors now more reliable (systemd vs Docker/LXC)
- Network stability improved with offloading disabled
- Storage naming clearer for multi-node cluster
- Documentation accurately reflects current infrastructure

---

## December 5, 2025 - Cross-Machine Conversation History Sync

**Changes:**
- Merged Claude Code conversation histories from Mac (1,286 conversations) and Server (122 conversations)
- Removed 127 duplicate conversations, resulting in 1,281 unique conversations sorted chronologically
- Removed `history.jsonl` from `.gitignore` to enable git tracking
- Created `claudegit` alias for syncing history before launching Claude Code
- Updated `.gitignore` on both Mac and Server to track history.jsonl
- Added Python merge script (`/tmp/merge-history.py`) for future manual history merges

**Impact:**
- Unified conversation history accessible from any machine
- No more "which machine did I have that conversation on?" confusion
- Automatic sync via hourly git backup system
- `claudegit` command pulls latest history before launching Claude

**Files created:**
- `/tmp/merge-history.py` - Python script to merge JSONL history files by timestamp

**Files modified:**
- `~/.claude/.gitignore` (Mac & Server) - Now tracks history.jsonl (commented out line 8)
- `~/.claude/history.jsonl` (Mac & Server) - Merged and synchronized (1,281 conversations)
- `~/projects/zshConfig/zshrc` (Mac) - Added `claudegit` alias at line 98
- `/root/.zshrc` (Server) - Added `claudegit` alias after existing aliases section

**Technical implementation:**
- History files merged by timestamp using Python script
- Duplicate detection based on (timestamp, project, display text)
- Git commit `e90bda7` pushed to `github.com:jaded423/claudeGlobal.git`
- Server initialized as git repo and pulled from GitHub
- Alias runs: `cd ~/.claude && git pull && cd - > /dev/null && claude`
- Hourly backup handles pushing new conversations to GitHub

**Workflow:**
1. Use Claude on any machine → conversation saved to local history.jsonl
2. Hourly backup commits and pushes to GitHub
3. On any other machine: `claudegit` pulls latest history before launching
4. All machines have access to complete conversation history

## November 23, 2025 - Grand Synchronization Project Phase 1 Complete

**Changes:**
- Created unified `homelab.md` documentation merging Mac and server versions
- Standardized all IP addresses to 192.168.2.x subnet (from mixed 192.168.1.x/192.168.2.x)
- Created `homelab-expansion.md` documenting infrastructure expansion plans
- Implemented automated GitHub → Server sync infrastructure
- Created `sync-project.md` documenting the grand synchronization project

**Impact:**
- Home lab documentation now consistent across both machines
- Automated hourly sync prevents documentation drift
- Clear roadmap for infrastructure expansion
- Foundation established for syncing all documentation

**Files created:**
- `docs/homelab-expansion.md` - Infrastructure expansion plans and checklist
- `docs/sync-project.md` - Grand synchronization project documentation
- `~/scripts/sync-claude-global.sh` (on server) - Sync script
- `~/.config/systemd/user/claude-sync.service` (on server) - Systemd service
- `~/.config/systemd/user/claude-sync.timer` (on server) - Hourly timer

**Files modified:**
- `docs/homelab.md` - Unified with correct 192.168.2.x network
- `CLAUDE.md` - Added references to new documentation files

**Technical implementation:**
- Mac pushes to GitHub hourly via existing gitBackup.sh
- Server pulls from GitHub hourly via new systemd timer
- Conflict resolution: Server hard resets to origin (Mac is source of truth)
- Successfully tested end-to-end sync workflow

## November 14, 2025 - [MINOR] Documentation System Enhancements

**Changes**:
- Created template system with 3 starter templates
- Implemented documentation dashboard with health metrics
- Added enhanced skills: doc-optimizer and session-historian
- Enhanced /init command to use templates
- Added doc-check and doc-metrics functions to .zshrc
- Improved interconnections.md with visual dependency graphs
- Created detect-context command for machine awareness
- Standardized changelog format with semantic versioning

**Impact**:
- Improved documentation consistency across projects
- Real-time documentation health monitoring
- Better dependency visualization and understanding
- Automated context detection for appropriate workflows

## November 7, 2025 - [MAJOR] System-Wide Lean Documentation Structure Refactoring

**Major Changes**: Refactored all project CLAUDE.md files to follow a lean structure pattern with `docs/` subdirectories, establishing a consistent documentation standard across the entire system.

**Projects Refactored** (9 total):
1. **promptLibrary** - 222 lines → 147 lines main file + 5 docs files
2. **nvimConfig** - 804 lines → 144 lines main file + 5 docs files
3. **odooReports** - 789 lines → 257 lines main file + 4 docs files
4. **scripts** - 445 lines → 128 lines main file + 5 docs files
5. **dotfilesPrivate** - 239 lines → 93 lines main file + 4 docs files
6. **graveyard** - 90 lines → 75 lines main file + 1 docs file
7. **n8nDev** - 400 lines → 98 lines main file + 6 docs files
8. **n8nProd** - 445 lines → 73 lines main file + 7 docs files
9. **Global ~/.claude/** - Already using this pattern (template for others)

**New Standard Structure**:

Main CLAUDE.md (100-150 lines):
- Overview and purpose
- Directory structure
- Quick reference with essential commands
- Links to detailed docs: `**📚 Detailed Documentation**: See docs/`
- Version requirements
- Reference to changelog: `**Full changelog**: [docs/changelog.md](docs/changelog.md)`

docs/ subdirectory with specialized files:
- **architecture.md** - Technical design, system components, implementation details
- **workflows.md** - Development workflows, common tasks, how-tos
- **commands.md** - Comprehensive command reference (when applicable)
- **troubleshooting.md** - Common issues and solutions
- **changelog.md** - Complete version history (ready for `/sum` archiving)
- **Additional project-specific files** - integrations.md, configuration.md, backup.md, etc.

**Documentation Added to Global CLAUDE.md**:
- Added "Lean CLAUDE.md Structure for `/init`" section to User Preferences
- Includes complete pattern specification with example markdown
- Documents benefits: manageable size, topic organization, easier maintenance
- Lists all 9 projects already using this pattern

**Impact**:

Immediate Benefits:
- **82% average reduction** in main file size (nvimConfig: 804→144 lines)
- **Consistent navigation** - users know exactly where to find information
- **Easier maintenance** - smaller, focused files reduce merge conflicts
- **Better organization** - architecture separate from workflows separate from troubleshooting
- **Multi-AI compatible** - works seamlessly with CLAUDE.md/GEMINI.md/AGENTS.md symlinks

Long-term Benefits:
- **Scalability** - projects can grow documentation without bloating main file
- **`/sum` compatibility** - changelog.md can be archived separately when it gets large
- **Onboarding** - new developers can quickly scan main file, dive deep as needed
- **Future `/init`** - all new projects will automatically use this structure

**Files Modified**:

Global Configuration:
- `~/.claude/CLAUDE.md` - Added lean structure pattern documentation to User Preferences

Project Main Files (refactored to lean structure):
- `~/projects/promptLibrary/CLAUDE.md`
- `~/projects/nvimConfig/CLAUDE.md`
- `~/projects/odooReports/CLAUDE.md`
- `~/projects/scripts/CLAUDE.md`
- `~/projects/dotfilesPrivate/CLAUDE.md`
- `~/projects/graveyard/CLAUDE.md`
- `~/projects/n8nDev/CLAUDE.md`
- `~/projects/n8nProd/CLAUDE.md`

New Documentation Files Created (37 total):
- promptLibrary: docs/architecture.md, workflows.md, changelog.md
- nvimConfig: docs/architecture.md, commands.md, workflows.md, troubleshooting.md, changelog.md
- odooReports: docs/architecture.md, workflows.md, troubleshooting.md, changelog.md
- scripts: docs/architecture.md, configuration.md, workflows.md, troubleshooting.md, changelog.md
- dotfilesPrivate: docs/architecture.md, workflows.md, troubleshooting.md, changelog.md
- graveyard: docs/changelog.md
- n8nDev: docs/architecture.md, commands.md, workflows.md, integrations.md, troubleshooting.md, changelog.md
- n8nProd: docs/architecture.md, commands.md, workflows.md, integrations.md, backup.md, troubleshooting.md, changelog.md

**Rationale**:

The global `~/.claude/` documentation already used this lean pattern successfully (CLAUDE.md + docs/ subdirectory). Extending this pattern to all projects provides:

1. **Consistency** - Same structure everywhere reduces cognitive load
2. **Discoverability** - Know where to look for specific information
3. **Maintainability** - Update individual topics without touching main file
4. **Future-proofing** - `/init` command now documented to create this structure automatically

**Standard Established**: All future projects initialized with `/init` will automatically follow this lean documentation pattern, preventing the need for future refactoring.

## November 6, 2025 - [MINOR] Removed Auto-Commit from `/log` Command

**Changes:**
- Modified `/log` command to remove all git operations (commands/log.md)
- `/log` now only updates documentation files, does not commit or push
- Changed workflow: documentation updates saved locally, hourly backup handles commits
- Updated command guidelines to reflect new "No auto-commit" policy
- Modified example workflows to show changes saved without commit/push

**Impact:**
- Dramatically reduces commit frequency (from 97 commits in November to ~24/month)
- AI-generated commit messages now have better context from accumulated changes
- Multiple sessions' changes batched into single meaningful commits
- Hourly backup script's AI summary can analyze larger diffs for better messages
- Commit history becomes more readable and meaningful

**Files modified:**
- `~/.claude/commands/log.md` - Removed steps 7-8 about git operations, updated guidelines

**Rationale:**
User was committing every time they ran `/log`, resulting in 97 commits in November alone. With hourly backups now using AI-generated commit messages via Claude Sonnet API, it's better to let changes accumulate between sessions so the AI has more context for meaningful commit messages.

## November 6, 2025 - [MINOR] odooReports Phase 1 Complete + Graveyard System

**Changes:**
- Completed Phase 1: Docker containerization for odooReports (hybrid n8n architecture)
- Created graveyard system at `~/projects/graveyard/` for obsolete file archival (6-month retention)
- Added global email testing policy: tests only to joshua@elevatedtrading.com
- Cleaned up odooReports: removed 7 obsolete files, 38 PDF backups, streamlined AR/AP report

**Impact:**
- odooReports ready for Phase 2 (n8n workflows)
- Graveyard available for all future project cleanups
- Email testing policy prevents stakeholder spam across all projects
- Container uses volume mounts - edit host code, container sees changes instantly

**Files:**
- `~/projects/graveyard/CLAUDE.md` - Graveyard log and documentation
- `~/projects/odooReports/Dockerfile`, `docker-compose.yml` - Container setup
- Updated User Preferences with email testing policy

## November 5, 2025 - [MAJOR] Moved Global Config to Version Control with Automated Backups

**Changes:**
- **Moved `~/.claude` to `~/projects/.claude`** for version control
- **Created symlink** `~/.claude` → `~/projects/.claude` (Claude Code continues to work normally)
- **Merged settings.local.json** - Added `Bash(zsh:*)` permission from pre-existing file
- **Created .gitignore** - Excludes session data (debug/, file-history/, todos/, projects/)
- **Initialized git repository** - Tracking essential config files only (15 files)
- **Created GitHub repository** - Private repo at `github.com/jaded423/claudeGlobal`
- **Added to automated backups** - Updated `~/scripts/gitBackup.sh` to include Claude Global
- **Created `/log` command** - Autonomous documentation of Claude's session changes
- **Created `docs/project-logs/`** - Directory structure for detailed cross-project session logs

**Impact:**
- Global Claude Code configuration now version controlled and backed up hourly
- All global documentation, agents, commands, and settings protected
- `/log` command enables automatic documentation of Claude's work across all projects
- Symlink approach means zero disruption to Claude Code functionality
- Now backing up 6 repositories total (added Claude Global to the list)

**Files created:**
- `.gitignore` - Excludes session-specific data
- `commands/log.md` - Autonomous session documentation command
- `docs/project-logs/README.md` - Directory for cross-project logs

**Files modified:**
- `CLAUDE.md` - Updated directory structure, added `/log` documentation
- `~/scripts/gitBackup.sh` - Added Claude Global to REPOS array (line 14)
- `settings.local.json` - Merged `Bash(zsh:*)` permission

**Git/GitHub:**
- Repository: `github.com/jaded423/claudeGlobal`
- Initial commit: "Initial commit: Global Claude Code configuration"
- Subsequent commits: `/log` command creation and updates

**Rationale:**
Global configuration is critical infrastructure that should be version controlled and backed up. Moving to `~/projects/.claude` with symlink provides best of both worlds: version control + Claude Code compatibility. The `/log` command ensures Claude's work is properly documented across the entire system.

## November 4, 2025 - Documentation Restructure for Efficiency

**Changes:**
- **Restructured documentation** to prevent hallucinations and improve efficiency
- **Created `~/.claude/docs/` directory** for detailed documentation
- **Extracted detailed sections** into separate files:
  - `docs/projects.md` - All active project descriptions
  - `docs/interconnections.md` - System dependency map and movement checklists
  - `docs/troubleshooting.md` - Common issues and solutions
- **Compacted main CLAUDE.md** from 1100+ lines to ~300 lines
- **Added clear references** to detailed docs throughout main file
- Main file now focuses on: overview, user preferences, slash commands, quick references

**Impact:**
- Reduced token usage for context loading
- Easier to scan and find information quickly
- Less prone to hallucinations with smaller context
- Detailed information still accessible when needed
- Better organization for maintaining documentation

**Rationale:**
Large context files (1000+ lines) increase hallucination risk and make it harder for Claude to focus on relevant information. By splitting into focused documents, each interaction uses only necessary context.

## November 4, 2025 - Comprehensive Auto-Approval Permissions for Frictionless /init

**Changes:**
- Added comprehensive permissions configuration to `settings.json`
- Auto-approve reading ANY file ANYWHERE
- Auto-approve all search operations
- Auto-approve git operations and GitHub repo creation

**Impact:**
- `/init` workflow now COMPLETELY frictionless - zero permission prompts
- Streamlined development workflow across all projects

## November 4, 2025 - User Preferences for Fully Autonomous Execution

**Changes:**
- Added User Preferences section documenting completely autonomous workflow execution
- `/init` workflow now includes end-to-end automation: from empty directory → documented → version controlled → backed up hourly
- Established policy: NO questions asked except for genuinely ambiguous technical decisions

**Impact:**
- Clear expectations for autonomous behavior
- Eliminated unnecessary confirmation prompts
- Faster workflow execution

## November 3, 2025 - Major Documentation Expansion

**Changes:**
- Added comprehensive Skills documentation section
- Added Global Agents documentation
- Expanded Global Slash Commands section
- Added Settings Configuration section
- Enhanced Troubleshooting section

**Impact:**
- More comprehensive documentation for all Claude Code features
- Better guidance for customization and configuration

## November 3, 2025 - Switched to Symlinks

**Changes:**
- Removed `/sync-ai-docs` command (no longer needed)
- Switched from file copying to symlinks for GEMINI.md and AGENTS.md
- Simplified workflow - no manual sync commands required

**Impact:**
- Automatic synchronization through filesystem symlinks
- Eliminated manual sync step from workflow
- Single source of truth maintained automatically

---

## 2026-01-06 - Fixed NFS Export for ZFS Child Datasets + Plex Media Path Update

**What changed:**
- Added `crossmnt` option to NFS export on prox-tower (`/etc/exports`)
- Remounted NFS on VM 101 to pick up changes
- Updated Plex docker-compose to use new mount path `/mnt/media-pool:/media/tower`
- Recreated Plex container with new volume mapping

**Why:**
- User moved Plex media from prox-book5 (`/srv/media/`) to prox-tower's new 4TB HDD (`/media-pool/media/`)
- ZFS child datasets (`media-pool/media/Movies`, `media-pool/media/Serials`) weren't visible via NFS
- Root cause: NFS exports of parent ZFS dataset don't automatically include child datasets
- `crossmnt` option tells NFS to traverse child filesystem mount points

**Files modified:**
- prox-tower `/etc/exports` - Added `crossmnt` to media-pool export
- VM 101 `~/docker/docker-compose.yml` - Changed `/mnt/book5-media:/media/book5` → `/mnt/media-pool:/media/tower`

**Technical notes:**
- ZFS creates separate mount points for child datasets (unlike traditional directories)
- Without `crossmnt`, NFS clients see empty directories where child datasets mount
- New Plex library paths: `/media/tower/Movies/`, `/media/tower/Serials/`
- User still needs to update Plex library paths in web UI

