# Raspberry Pi 1 - Git Backup Mirror

**Device**: Raspberry Pi 1 Model B+
**Hostname**: raspberrypi
**OS**: Raspberry Pi OS (Legacy) Bookworm Lite
**Setup Date**: January 9, 2026

---

## Quick Access

```bash
# From Mac (via Windows PC ProxyJump)
ssh pi1             # Alias
ssh rpi1            # Alias

# Direct (if on ICS subnet)
ssh pi@192.168.137.123
```

---

## Hardware

| Component | Details |
|-----------|---------|
| Model | Raspberry Pi 1 Model B+ |
| CPU | ARM1176JZF-S (ARMv6, 700MHz single-core) |
| RAM | 512MB |
| Storage | 8GB SD card (~4.4GB free) |
| Network | 10/100 Ethernet |
| Power | 5V micro-USB |

---

## Network Architecture

Pi1 has no direct internet access - it routes through Windows PC via ICS (Internet Connection Sharing).

```
Mac → PC:2223 → Windows portproxy → Pi:22 (192.168.137.123)
Pi → Windows ICS NAT (192.168.137.1) → PC WiFi → Internet
```

| Interface | IP | Purpose |
|-----------|-----|---------|
| eth0 | 192.168.137.123 | Static IP on ICS subnet |
| Gateway | 192.168.137.1 | Windows PC ethernet adapter |
| SSH Port | 2223 | Via Windows port forward |

**Important**: Pi internet requires Windows PC to be powered on.

---

## SSH Configuration

### On Mac (`~/.ssh/config`)

```ssh-config
Host pi1 rpi1
  HostName 192.168.1.193
  User pi
  Port 2223
  ProxyJump pc
  IdentityFile ~/.ssh/id_ed25519
```

### On Pi (`~/.ssh/authorized_keys`)

Contains Mac's public key for passwordless access.

---

## Shell Configuration

| Component | Details |
|-----------|---------|
| Shell | zsh |
| Framework | Oh My Zsh |
| Theme | Powerlevel10k |
| Plugins | git, zoxide, history, sudo |

Config mirrors Mac terminal setup (configured January 2026).

**Fun fact**: Has `doom-ascii` installed (`doom` alias) - because it can run DOOM.

---

## Git Backup Mirror

Primary purpose: Offline backup of all GitHub repositories.

| Property | Value |
|----------|-------|
| Location | `~/git-mirrors/*.git` |
| Repos | 15 bare repositories |
| Size | ~152MB |
| Schedule | Every 4 hours (cron) |
| Log | `~/git-mirrors/sync.log` |

### Mirrored Repositories

```
promptLibrary.git    nvimConfig.git       zshConfig.git
odooReports.git      scripts.git          n8nDev.git
n8nProd.git          graveyard.git        loom.git
(+ 6 more)
```

### Sync Script

**Location**: `~/git-mirrors/sync-mirrors.sh`

```bash
#!/bin/bash
LOG=~/git-mirrors/sync.log
echo "=== Sync started $(date) ===" >> $LOG

for repo in ~/git-mirrors/*.git; do
    name=$(basename "$repo")
    echo "Syncing $name..." >> $LOG
    cd "$repo" && git fetch --all >> $LOG 2>&1
done

echo "=== Sync completed $(date) ===" >> $LOG
```

### Cron Schedule

```bash
crontab -l
# 0 */4 * * * ~/git-mirrors/sync-mirrors.sh
```

---

## Common Commands

```bash
# Manual sync
ssh pi1 "~/git-mirrors/sync-mirrors.sh"

# Check sync log
ssh pi1 "tail -20 ~/git-mirrors/sync.log"

# List mirrored repos
ssh pi1 "ls ~/git-mirrors/*.git"

# Check disk usage
ssh pi1 "du -sh ~/git-mirrors/"

# Run speedtest
ssh pi1 "speedtest-cli"

# Check internet connectivity
ssh pi1 "ping -c 3 github.com"
```

---

## Performance

| Metric | Value |
|--------|-------|
| Internet Speed | ~40 Mbps (via ICS NAT) |
| SSH Response | ~200ms (through PC proxy) |
| Sync Time | ~2-3 minutes for all repos |

---

## Troubleshooting

### No internet / sync failing

1. Check Windows PC is powered on
2. Check ICS is enabled on PC ethernet adapter
3. Test from Pi:
   ```bash
   ping 192.168.137.1    # Gateway
   ping 8.8.8.8          # Internet
   ping github.com       # DNS
   ```

### SSH connection refused

1. Check port forward on PC:
   ```powershell
   netsh interface portproxy show v4tov4
   ```
2. Should show: `2223 → 192.168.137.123:22`

### Disk full

```bash
# Check disk usage
df -h

# Check mirror sizes
du -sh ~/git-mirrors/*.git | sort -h

# Clear old logs
> ~/git-mirrors/sync.log
```

### Permission denied (publickey)

Ensure Mac's public key is in Pi's `~/.ssh/authorized_keys`:

```bash
# From Mac
ssh-copy-id -p 2223 pi@192.168.1.193
```

---

## GitHub SSH Key

**Key Name**: "Pi1 Backup" in github.com/settings/keys

Pi has its own SSH key for read-only GitHub access:
- Location: `~/.ssh/id_ed25519`
- Permissions: Read-only (can fetch, cannot push)

---

## Related Docs

- [pc.md](pc.md) - Windows PC (provides internet via ICS)
- [../ssh-access-cheatsheet.md](../ssh-access-cheatsheet.md) - SSH quick reference
