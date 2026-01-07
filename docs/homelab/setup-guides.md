# Homelab Setup Guides

Installation and configuration procedures.

---

## Proxmox Node CLI Setup

Standard CLI tools for all Proxmox nodes in the cluster.

### What Gets Installed

- **tmux** - Terminal multiplexer
- **zsh** - Advanced shell (set as default)
- **Oh My Zsh** - Zsh framework
- **Powerlevel10k** - Zsh theme
- **Neovim** - Modern vim editor
- **Node.js + npm** - For Mason LSP servers
- **deno** - JavaScript/TypeScript runtime
- **fzf** - Fuzzy finder
- **zoxide** - Smarter cd
- **Claude Code** - AI assistant

### Quick Install (All Steps)

```bash
# 1. Fix DNS (use Pi-hole)
echo '# Fixed DNS - use Pi-hole' > /etc/resolv.conf
echo 'nameserver 192.168.2.131' >> /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# 2. Install base packages
apt update
apt install -y tmux zsh neovim git curl unzip fzf build-essential make

# 3. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 4. Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# 5. Install deno, zoxide, Claude Code
curl -fsSL https://deno.land/install.sh | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash

# 6. Set zsh as default
chsh -s $(which zsh)

# 7. Copy configs from Mac (run on Mac)
scp ~/projects/zshConfig/zshrc root@<proxmox-ip>:~/.zshrc
scp ~/projects/zshConfig/p10k.zsh root@<proxmox-ip>:~/.p10k.zsh

# 8. Clone nvim config
git clone https://github.com/jaded423/nvimConfig.git ~/.config/nvim

# 9. Update PATH
echo 'export DENO_INSTALL="/root/.deno"' >> ~/.zshrc
echo 'export PATH="$DENO_INSTALL/bin:$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 10. Create symlinks for immediate access
ln -sf /root/.local/bin/zoxide /usr/local/bin/zoxide
ln -sf /root/.deno/bin/deno /usr/local/bin/deno
ln -sf /root/.local/bin/claude /usr/local/bin/claude
```

**Verify:**
```bash
which zoxide deno claude  # Should show /usr/local/bin
```

**Then logout and login to use zsh.**

### Notes

- **DNS Issues:** Twingate may manage `/etc/resolv.conf` with broken DNS. Set Pi-hole first.
- **PATH Issues:** Curl-installed tools go to `~/.local/bin`. Symlinks fix immediate access.
- **Claude Code:** Requires browser auth on first run. SSH from Mac to authenticate.
- **Nvim Plugins:** First open, Lazy.nvim auto-installs (~1 min).

### Currently Installed

- ✅ prox-tower (192.168.2.249) - Dec 2, 2025
- ✅ prox-book5 (192.168.2.250) - Dec 2, 2025

---

## Setup Scripts Reference

**Location:** `~/setup/` on home server

### Installation Scripts

| Script | Purpose |
|--------|---------|
| `install-docker.sh` | Install Docker + Compose |
| `install-twingate-docker.sh` | Install Twingate via Docker |
| `setup-ssh.sh` | Enable/configure SSH |
| `setup-samba.sh` | Install/configure Samba |

### Configuration Scripts

| Script | Purpose |
|--------|---------|
| `configure-firewall.sh` | Configure UFW |
| `update-samba-symlinks.sh` | Enable symlink support |

### Configuration Files

| File | Purpose | Permissions |
|------|---------|-------------|
| `docker-compose.yml` | Twingate container | 644 |
| `.env` | Twingate credentials | 600 |
| `twingate-tokens.sh` | Token export | 644 |

---

## Maintenance Tasks

### Daily
```bash
systemctl status sshd smb && docker ps
df -h /
```

### Weekly
```bash
sudo pacman -Syu                    # Update system
journalctl -p err -b                # Check errors
```

### Monthly
```bash
sudo ufw status verbose             # Review firewall
docker-compose pull && docker-compose up -d  # Update images
sudo pacman -Sc                     # Clean cache
```

---

## Backup Strategy

### Important Directories
- `~/setup/` - Setup scripts
- `~/.config/` - Desktop configs
- `~/.ssh/` - SSH keys
- `/etc/samba/` - Samba config

### Backup from Mac
```bash
# Backup setup
scp -r jaded@192.168.2.250:~/setup ~/backups/homelab-setup-$(date +%Y%m%d)

# Backup configs
ssh jaded@192.168.2.250 'tar czf - ~/.config/hypr ~/.config/waybar ~/.ssh' \
  > ~/backups/homelab-configs-$(date +%Y%m%d).tar.gz
```

---

## System Updates

```bash
# CachyOS/Arch
sudo pacman -Syu        # Full update
sudo pacman -Syyu       # Force refresh
yay -Syu                # AUR packages

# Docker
cd ~/setup
docker-compose pull
docker-compose up -d
```
