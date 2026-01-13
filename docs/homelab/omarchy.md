# VM 100 - Omarchy

**Device**: Proxmox VM on prox-book5
**Hostname**: omarchy
**OS**: Arch Linux
**DE**: Hyprland
**Role**: Linux desktop environment

---

## Quick Access

```bash
# From Mac
ssh omarchy         # Alias
ssh vm100           # Alias
ssh jaded@192.168.2.161

# ProxyJump through book5 (automatic via SSH config)
```

---

## VM Configuration

| Property | Value |
|----------|-------|
| VMID | 100 |
| Host | prox-book5 |
| RAM | 8GB |
| vCPU | 4 cores |
| Disk | 32GB (on book5 local-zfs) |
| Network | vmbr0 (192.168.2.x) |
| Display | VirtIO GPU |

---

## Network Configuration

| Interface | IP | Purpose |
|-----------|-----|---------|
| eth0 | 192.168.2.161 | Management, desktop use |
| Gateway | 192.168.2.1 | Router |

```
Mac → Twingate → book5 → ProxyJump → omarchy:22
```

---

## System Configuration

| Component | Details |
|-----------|---------|
| OS | Arch Linux (rolling release) |
| Kernel | linux-lts |
| DE | Hyprland |
| Shell | zsh |
| Terminal | kitty |
| Editor | neovim |

---

## Hyprland Desktop

### Keybindings

| Keys | Action |
|------|--------|
| SUPER + Q | Open terminal (kitty) |
| SUPER + R | Open launcher |
| SUPER + C | Close window |
| SUPER + 1-9 | Switch workspace |
| SUPER + SHIFT + 1-9 | Move window to workspace |
| SUPER + E | File manager |

### Configuration Files

| File | Purpose |
|------|---------|
| ~/.config/hypr/hyprland.conf | Hyprland config |
| ~/.config/kitty/kitty.conf | Terminal config |
| ~/.config/nvim/ | Neovim config |
| ~/.zshrc | Shell config |

---

## Installed Software

| Package | Purpose |
|---------|---------|
| hyprland | Window manager |
| kitty | Terminal emulator |
| neovim | Text editor |
| zsh | Shell |
| oh-my-zsh | Zsh framework |
| powerlevel10k | Zsh theme |
| waybar | Status bar |
| thunar | File manager |
| firefox | Web browser |

---

## SSH Configuration

### On Mac (`~/.ssh/config`)

```ssh-config
Host 192.168.2.161 omarchy vm100
  HostName 192.168.2.161
  User jaded
  ProxyJump 192.168.2.250
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

### On Omarchy

User: `jaded` (passwordless sudo)

---

## Package Management

```bash
# Update system
sudo pacman -Syu

# Install package
sudo pacman -S <package>

# Search packages
pacman -Ss <query>

# Clean cache
sudo pacman -Sc
```

---

## Troubleshooting

### Can't SSH in

1. Check VM is running: `ssh book5 "qm status 100"`
2. Start VM: `ssh book5 "qm start 100"`
3. Check network: `ssh book5 "qm guest cmd 100 network-get-interfaces"`

### Hyprland not starting

Check logs:
```bash
journalctl --user -u hyprland
cat ~/.local/share/hyprland/hyprland.log
```

### No display after boot

VM may need console access via Proxmox Web UI:
1. Go to https://192.168.2.250:8006
2. Select VM 100
3. Click Console tab

---

## Related Docs

- [book5.md](book5.md) - Host (prox-book5)
- [go.md](go.md) - Similar Hyprland setup on Pixelbook Go
