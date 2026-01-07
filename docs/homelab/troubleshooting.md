# Homelab Troubleshooting Guide

Complete troubleshooting reference for common issues.

---

## SSH Issues

### Connection Refused
```bash
# Check SSH is running
systemctl status sshd

# Check firewall allows SSH
sudo ufw status | grep 22

# Verify SSH is listening
sudo ss -tlnp | grep :22

# Restart SSH
sudo systemctl restart sshd
```

### Permission Denied
```bash
# Fix key permissions on Mac
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Fix authorized_keys on server
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## Sudo Issues

### Sudo Not Accepting Password
```bash
# Refresh sudo credentials
sudo -v

# This will:
# - Prompt for password
# - Reset sudo timestamp
# - Give fresh 15-minute window
```

### If `sudo -v` Doesn't Fix It
```bash
# Check wheel group membership
groups | grep wheel

# Check sudo config
sudo -l

# View auth errors
journalctl -n 100 | grep -iE 'sudo|pam|auth'
```

---

## Samba Issues

### Share Not Accessible
```bash
# Check Samba running
systemctl status smb

# Check firewall
sudo ufw status | grep -E "445|139"

# Test config
testparm -s

# Restart
sudo systemctl restart smb
```

### Symlinks Not Showing
```bash
# Re-enable symlink support
~/setup/update-samba-symlinks.sh

# Verify symlinks
ls -la /srv/samba/shared/

# Check config
grep -E "follow symlinks|wide links" /etc/samba/smb.conf
```

### Slow Transfer Speeds
- Disconnect from Twingate (not needed on LAN)
- Use 5GHz WiFi if available
- Test with: `iperf3` between devices

---

## Twingate Issues

### After Reboot - Green But Can't Connect

**Problem:** Connectors show "Connected" but resources unreachable.

**Cause:** Mac client has stale routing tables.

**Fix:**
```bash
# Restart Twingate on Mac
killall Twingate && open -a Twingate

# Or via menu bar: Click icon → Quit → Reopen
```

**Note:** May take 5-10 minutes to re-establish routes.

### Connector Not Connecting
```bash
# Check container (Docker deployment)
docker ps -a | grep twingate
docker logs twingate-connector

# Check service (systemd deployment)
systemctl status twingate-connector
journalctl -u twingate-connector -f

# Restart
systemctl restart twingate-connector
```

### Can't Access Resources
- Ensure Twingate app connected on Mac
- Check resources assigned to your user in admin console
- Verify connector online: https://jaded423.twingate.com
- Try reconnecting Twingate app

---

## Google Drive Issues

### Mount Not Accessible
```bash
# Check services
systemctl --user status rclone-gdrive.service
systemctl --user status rclone-elevated.service

# View logs
journalctl --user -u rclone-gdrive.service -n 50
journalctl --user -u rclone-elevated.service -n 50

# Restart
systemctl --user restart rclone-gdrive.service
systemctl --user restart rclone-elevated.service
```

### Slow Sync
- Check internet: `ping 8.8.8.8`
- First access is slow (downloading from cloud)
- Frequently accessed files cached 24 hours

---

## Ollama Issues

### Service Not Running
```bash
systemctl status ollama
sudo systemctl restart ollama
journalctl -u ollama -f
```

### Slow Inference
```bash
# Verify GPU
lspci | grep -i vga

# Check CPU governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Monitor resources
htop  # or btop
```

### Out of Memory
```bash
# Check RAM/swap
free -h

# Check zram
zramctl

# Try smaller model
ollama run llama3.2:1b
```

### Model Not Found
```bash
ollama list
ollama pull modelname:tag
```

---

## CPU Watchdog Issues

### Check Status
```bash
systemctl status cpu-watchdog
tail -f /var/log/cpu-watchdog.log
top -bn1 | grep "Cpu(s)"
```

### Watchdog Suspended a VM
```bash
# List VMs
qm list

# Resume VM
qm resume <VMID>

# Check why
grep "suspending" /var/log/cpu-watchdog.log
```

### Disable Temporarily
```bash
systemctl stop cpu-watchdog
# Later:
systemctl start cpu-watchdog
```

### Adjust Threshold
```bash
nvim /usr/local/bin/cpu-watchdog.sh
# Change CPU_THRESHOLD=90
systemctl restart cpu-watchdog
```

---

## Desktop Environment Issues (Hyprland)

### Waybar Not Appearing
```bash
pgrep waybar
killall waybar && waybar &
waybar --log-level debug
```

### Wallpaper Not Changing
```bash
killall hyprpaper && hyprpaper &
cat ~/.config/hypr/hyprpaper.conf
```

### Reload Hyprland
```bash
hyprctl reload
```

---

## Known Hardware Issues

### Intel I218-LM NIC Bug (prox-tower)

**Problem:** TSO causes network hangs, requiring physical reboot.

**Symptoms:**
- Complete SSH loss
- Proxmox web UI unreachable
- Server unresponsive

**Fix Applied:**
```bash
# /etc/network/interfaces on prox-tower
iface nic0 inet manual
    post-up /usr/sbin/ethtool -K nic0 tso off gso off gro off
```

**Verify:**
```bash
ssh root@192.168.2.249 "ethtool -k nic0 | grep -E 'tcp-seg|generic'"
# Should show: off for all three
```

---

## GPU Passthrough Issues

### GPU Not Showing in VM
```bash
# On host: Check vfio binding
lspci -nnk -s 01:00

# Verify IOMMU
dmesg | grep -i dmar
```

### nvidia-smi Not Working
```bash
# Check GPU visible
lspci | grep -i nvidia

# Check driver loaded
lsmod | grep nvidia

# Reinstall
sudo apt install --reinstall nvidia-driver-535
```

### Network Broken After Passthrough
- q35 machine type changes interface names
- Check `ip link` for new name (e.g., `enp6s18` vs `ens18`)
- Update `/etc/netplan/*.yaml`
- Run `sudo netplan apply`

### 14B Models Crashing
- Quadro M4000 = 8GB VRAM
- Models >8GB will fail
- Use quantized versions or hybrid mode

---

## MagicMirror Kiosk (Raspberry Pi)

### Quick Reset
```bash
ssh jaded@192.168.2.131 "~/reset-kiosk.sh"
```

### Manual Restart
```bash
pkill -f chromium
pkill -f 'node.*server'
~/kiosk.sh
```

### Check Status
```bash
ps aux | grep -E 'chromium|node.*server' | grep -v grep
curl http://localhost:8080  # Should return HTML
```
