# Pixelbook Go - CachyOS Hyprland Setup

**Device**: Google Pixelbook Go (Intel Core m3, 8GB RAM)
**OS**: CachyOS Linux (Arch-based)
**Kernel**: 6.12.65-2-cachyos-lts
**DE**: Hyprland 0.53.1
**Setup Date**: January 12-13, 2026

---

## Quick Access

```bash
# From Mac (remote - via reverse tunnel)
ssh go

# From Mac (local - same network)
ssh go-local

# From Go to homelab
ssh book5      # Proxmox Node 1
ssh tower      # Proxmox Node 2
ssh ubuntu     # VM 101
ssh mac        # Mac (via mDNS)
```

---

## Network Architecture

Go sits on a separate network (192.168.1.x) from the homelab (192.168.2.x).

```
Mac → Twingate → book5 → reverse tunnel (port 2244) → Go
Go → Twingate Client → homelab (192.168.2.x)
```

**Why Reverse Tunnel?**
- Go needs Twingate **Client** to reach homelab
- Running both Client and Connector causes routing conflicts
- Solution: Reverse SSH tunnel replaces Connector for incoming access

---

## SSH Configuration

### On Go (`~/.ssh/config`)

```ssh-config
# Proxmox Node 1 - prox-book5
Host book5 prox-book5
  HostName 192.168.2.250
  User root

# Proxmox Node 2 - prox-tower
Host tower prox-tower
  HostName 192.168.2.249
  User root

# VM 101 - Ubuntu Server (via tower)
Host ubuntu ubuntu-server vm101
  HostName 192.168.2.126
  User jaded
  ProxyJump tower

# Mac (direct - mDNS)
Host mac macbook
  HostName macAir.local
  User j
```

### On Mac (`~/.ssh/config`)

```ssh-config
# Pixelbook Go - via reverse tunnel (works anywhere)
Host go pixelbook
  HostName localhost
  Port 2244
  User jaded
  ProxyJump book5

# Pixelbook Go - Direct mDNS (same network only)
Host go-local pixelbook-local
  HostName go.local
  User jaded
```

---

## Reverse Tunnel Service

Persistent systemd user service that maintains SSH tunnel to book5.

**Service File**: `~/.config/systemd/user/ssh-tunnel.service`

```ini
[Unit]
Description=Reverse SSH tunnel to book5
After=network-online.target

[Service]
ExecStart=/usr/bin/ssh -R 2244:localhost:22 root@192.168.2.250 -N -i /home/jaded/.ssh/id_ed25519 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

**Manage the tunnel:**
```bash
systemctl --user status ssh-tunnel   # Check status
systemctl --user restart ssh-tunnel  # Restart
journalctl --user -u ssh-tunnel -f   # View logs
```

**Requirements:**
1. Go's SSH key in book5's `~/.ssh/authorized_keys`
2. book5's SSH key in Go's `~/.ssh/authorized_keys`
3. Twingate client connected on Go

---

## Power Management

### Lid Behavior

**Config**: `/etc/systemd/logind.conf.d/lid-switch.conf`

```ini
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
```

| Condition | Behavior |
|-----------|----------|
| AC + lid closed | Stays awake, tunnel active |
| Battery + lid closed | Sleeps (saves battery) |
| After wake | Tunnel auto-reconnects |

### WiFi Power Save

Auto-toggles based on AC state to balance connection stability and battery life.

**Script**: `/usr/local/bin/wifi-power-manager`

```bash
#!/bin/bash
AC_ONLINE=$(cat /sys/class/power_supply/AC/online 2>/dev/null)
if [ "$AC_ONLINE" = "1" ]; then
    iw dev wlan0 set power_save off
else
    iw dev wlan0 set power_save on
fi
```

**Udev Rule**: `/etc/udev/rules.d/99-wifi-power.rules`

```
ACTION=="change", SUBSYSTEM=="power_supply", RUN+="/usr/local/bin/wifi-power-manager"
```

| Condition | WiFi Power Save |
|-----------|-----------------|
| On AC | OFF (stable connection) |
| On Battery | ON (saves power) |

---

## Installed Software

| Package | Purpose |
|---------|---------|
| neovim | Text editor (config from nvimConfig repo) |
| zsh | Shell |
| oh-my-zsh | Zsh framework |
| powerlevel10k | Zsh theme |
| ttf-meslo-nerd | Nerd font for terminal icons |
| waybar | Status bar |
| hyprlauncher | Application launcher |
| kitty | Terminal emulator (default) |
| alacritty | Terminal emulator (alternate) |
| zoxide | Smart directory navigation |
| fzf | Fuzzy finder |
| twingate | VPN client |
| acpid | ACPI event daemon |

---

## Hyprland Configuration

**Config**: `~/.config/hypr/hyprland.conf`

### Keybindings

| Keys | Action |
|------|--------|
| SUPER + Q | Open terminal (kitty) |
| SUPER + R | Open launcher (hyprlauncher) |
| SUPER + 1-9 | Switch workspace |
| SUPER + SHIFT + 1-9 | Move window to workspace |
| SUPER + C | Close window |
| SUPER + E | File manager (thunar) |
| 3-finger swipe | Switch workspaces |

### Fixes Applied

1. **Phantom Monitor**: `Unknown-1` disabled in config
2. **Gesture Syntax**: Updated to Hyprland 0.53+ format

---

## Shell Configuration

**Shell**: zsh + oh-my-zsh + powerlevel10k (Arch-adapted)

Config is standalone (not symlinked from zshConfig repo) because it's Arch-specific.

**Key differences from Mac config:**
- Removed: `brew`, `macos`, `copypath`, `copyfile` plugins
- Added: `archlinux` plugin
- Removed: Homebrew paths, rbenv, PostgreSQL paths
- Uses standard Linux paths

**Config locations:**
- Main: `~/.zshrc`
- Theme: `~/.p10k.zsh`
- Neovim: `~/.config/nvim` (cloned from nvimConfig repo)

---

## Troubleshooting

### Tunnel not connecting

```bash
# Check service status
systemctl --user status ssh-tunnel

# Check if Twingate is connected
twingate status

# Manual test
ssh -R 2244:localhost:22 root@192.168.2.250 -N -v
```

**Key Fix**: The service must specify `-i /home/jaded/.ssh/id_ed25519` explicitly because systemd services don't have access to SSH agent.

### WiFi drops when lid closed

```bash
# Check power save status
iw dev wlan0 get power_save

# Should be "off" when on AC
# Manually disable if needed
sudo iw dev wlan0 set power_save off
```

### Can't reach homelab from Go

```bash
# Check Twingate
twingate status

# If disconnected
twingate start
```

### mDNS not resolving

```bash
# Check avahi is running
systemctl status avahi-daemon

# Test resolution
avahi-resolve -n macAir.local
```

---

## Issues Fixed During Setup

1. **Phantom Monitor**: `Unknown-1` ghost monitor disabled in hyprland.conf
2. **Gesture Syntax**: Updated to Hyprland 0.53+ syntax
3. **Default Shell**: Changed from fish to zsh for SSH sessions
4. **Twingate Client/Connector Conflict**: Resolved with reverse tunnel approach
5. **Lid Close on AC**: Configured to stay awake for persistent tunnel
6. **WiFi Power Save**: Auto-toggles based on AC state via udev rule
