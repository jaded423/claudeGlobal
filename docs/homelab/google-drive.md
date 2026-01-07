# Google Drive Integration

rclone FUSE mounts for Google Drive access.

---

## Overview

**Tool:** rclone with VFS caching
**Mount Type:** FUSE (Filesystem in Userspace)
**Location:** VM 101 (192.168.1.126)

---

## Directory Structure

```
/home/jaded/GoogleDrives/
├── elevated/           (joshua@elevatedtrading.com)
│   ├── MyDrive/       ← "My Drive" (includes Elevated Vault)
│   ├── SharedDrives/  ← Team drives
│   └── OtherComputers/
└── jaded/             (jaded423@gmail.com)
    ├── MyDrive/       ← "My Drive"
    ├── SharedDrives/
    └── OtherComputers/

# Convenience symlinks
/home/jaded/elevatedDrive → /home/jaded/GoogleDrives/elevated
/home/jaded/GoogleDrive → /home/jaded/GoogleDrives/jaded
```

---

## Personal Drive (jaded423@gmail.com)

**Remote Name:** gdrive
**Mount Point:** `/home/jaded/GoogleDrives/jaded/MyDrive/`
**Symlink:** `/home/jaded/GoogleDrive/`
**Service:** `~/.config/systemd/user/rclone-gdrive.service`

**VFS Settings:**
- Cache mode: writes
- Cache max age: 24 hours
- Read chunk size: 128MB
- Buffer size: 64MB

**Service Management:**
```bash
systemctl --user status rclone-gdrive.service
systemctl --user restart rclone-gdrive.service
systemctl --user enable rclone-gdrive.service
journalctl --user -u rclone-gdrive.service -f
```

---

## Work Drive (joshua@elevatedtrading.com)

**Remote Name:** elevated
**Mount Point:** `/home/jaded/GoogleDrives/elevated/MyDrive/`
**Symlink:** `/home/jaded/elevatedDrive/`
**Service:** `~/.config/systemd/user/rclone-elevated.service`
**Contains:** Elevated Vault (Obsidian workspace)

**Service Management:**
```bash
systemctl --user status rclone-elevated.service
systemctl --user restart rclone-elevated.service
systemctl --user enable rclone-elevated.service
journalctl --user -u rclone-elevated.service -f
```

---

## Proxmox Node Access (SSHFS)

Both Proxmox nodes mount Google Drives from VM 101 via SSHFS.

**Mount Points:**
- `/mnt/elevated/` - Work Google Drive
- `/mnt/jaded/` - Personal Google Drive

**fstab Configuration:**
```bash
jaded@192.168.1.126:/home/jaded/GoogleDrives/elevated /mnt/elevated fuse.sshfs defaults,allow_other,_netdev,reconnect,IdentityFile=/root/.ssh/id_rsa 0 0
jaded@192.168.1.126:/home/jaded/GoogleDrives/jaded /mnt/jaded fuse.sshfs defaults,allow_other,_netdev,reconnect,IdentityFile=/root/.ssh/id_rsa 0 0
```

**Obsidian.nvim Configuration:**
```lua
-- ~/.config/nvim/lua/plugins/tools/obsidian.lua
path = "/mnt/elevated/MyDrive/Elevated Vault"
```

---

## Usage

### On VM 101
```bash
# Personal drive
ls ~/GoogleDrive/MyDrive/

# Work drive
ls ~/elevatedDrive/MyDrive/

# Obsidian Vault
cd ~/elevatedDrive/MyDrive/Elevated\ Vault/

# Copy files
cp file.txt ~/GoogleDrive/MyDrive/
cp document.pdf ~/elevatedDrive/MyDrive/

# Edit directly (auto-syncs)
nano ~/GoogleDrive/MyDrive/document.txt
```

### On Proxmox Nodes
```bash
# Work drive
ls /mnt/elevated/MyDrive/
ls /mnt/elevated/MyDrive/Elevated\ Vault/

# Personal drive
ls /mnt/jaded/MyDrive/

# Obsidian with nvim
nvim /mnt/elevated/MyDrive/Elevated\ Vault/
```

### From Other VMs (via Samba)
```bash
# Install cifs-utils
sudo pacman -S cifs-utils    # Arch
sudo apt install cifs-utils  # Debian/Ubuntu

# Mount Samba share
sudo mount -t cifs //192.168.1.126/Shared /mnt/shared -o user=jaded

# Access Google Drives
ls /mnt/shared/GoogleDrive/
ls /mnt/shared/ElevatedDrive/
```

---

## rclone Commands

```bash
# List remotes
rclone listremotes

# Test connection
rclone lsd gdrive:
rclone lsd elevated:

# Copy without mounting
rclone copy /local/path gdrive:remote/path

# Check space
rclone about gdrive:
rclone about elevated:
```

---

## Performance Notes

- **First access:** Slower (downloading from cloud)
- **Cached files:** Fast for 24 hours
- **Writes:** Cached and uploaded in background
- **Best for:** Documents, configs, backups
- **Not ideal for:** Video editing, databases
