# Samsung S25 Ultra (Phone)

**Last Updated:** January 17, 2026
**IP Address:** 192.168.1.96 (home WiFi) / 192.168.2.101 (via Twingate)
**Network:** 192.168.1.0/24 (Mac/PC network)
**SSH Port:** 8022
**User:** u0_a499

---

## Overview

Samsung Galaxy S25 Ultra running Termux for SSH access and homelab connectivity. Uses Twingate client for secure access to 192.168.2.x homelab network.

---

## Termux Configuration

### SSH Server
- **Port:** 8022
- **Shell:** zsh + Oh My Zsh + Powerlevel10k
- **Access from Mac:** `ssh -p 8022 192.168.1.96`

### SSH Keys
- `~/.ssh/id_ed25519` - Primary key (termux@s25ultra)
- `~/.ssh/id_rsa` - RSA fallback

### Key Distribution
Phone's SSH key is authorized on:
- prox-tower (root)
- prox-book5 (root)
- omarchy (jaded)
- ubuntu (jaded)

---

## SSH Config (~/.ssh/config)

```bash
# Proxmox Node 2 - prox-tower (via Twingate)
Host 192.168.2.249 prox-tower tower
  HostName 192.168.2.249
  User root
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Proxmox Node 1 - prox-book5 (via tower)
Host 192.168.2.250 prox-book5 book5
  HostName 192.168.2.250
  User root
  ProxyJump tower
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 100 - Omarchy Desktop (via book5)
Host 192.168.2.161 omarchy vm100
  HostName 192.168.2.161
  User jaded
  ProxyJump book5
  ServerAliveInterval 60
  ServerAliveCountMax 3

# VM 101 - Ubuntu Server (via tower)
Host 192.168.2.126 ubuntu-server vm101 ubuntu
  HostName 192.168.2.126
  User jaded
  ProxyJump tower
  ServerAliveInterval 60
  ServerAliveCountMax 3

# MacBook Air (via tower)
Host 192.168.2.226 mac macbook
  HostName 192.168.2.226
  User j
  ProxyJump tower
  ServerAliveInterval 60
  ServerAliveCountMax 3

# Pi-hole (via tower)
Host 192.168.2.131 pihole magic-pihole
  HostName 192.168.2.131
  User pi
  ProxyJump tower
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

**Route:** Phone → Twingate → tower → (book5 →) destination

---

## SSH Tunnels (Homelab Services via localhost)

The phone uses SSH tunnels to access homelab services securely via `localhost`. This avoids the n8n secure cookie issue and provides encrypted access.

### Tunnel Architecture

```
Phone Browser → localhost:PORT → SSH Tunnel → Twingate → Homelab Service
```

**Key benefit:** Only tunneled ports route through homelab. All other phone traffic uses normal WiFi/LTE.

### Omarchy Tunnels (tmux session: `tunnels`)

| localhost | Remote | Service |
|-----------|--------|---------|
| :5678 | omarchy:5678 | n8n |
| :11434 | omarchy:11434 | Ollama |
| :8000 | omarchy:8000 | tapo-rest |

### Ubuntu Tunnels (tmux session: `ubuntu-tunnels`)

| localhost | Remote | Service |
|-----------|--------|---------|
| :32400 | ubuntu:32400 | Plex |
| :5000 | ubuntu:5000 | Frigate |
| :8080 | ubuntu:8080 | qBittorrent |
| :3000 | ubuntu:3000 | Open WebUI |

---

## Auto-Start Configuration

Tunnels start automatically when Termux opens via `~/.zshrc`:

```bash
# Auto-start homelab tunnels on Termux launch
start_tunnels() {
  # Omarchy services (n8n, Ollama, tapo-rest)
  if ! tmux has-session -t tunnels 2>/dev/null; then
    tmux new-session -d -s tunnels 'ssh -N \
      -L 5678:localhost:5678 \
      -L 11434:localhost:11434 \
      -L 8000:localhost:8000 \
      -o ServerAliveInterval=60 -o ServerAliveCountMax=3 omarchy'
    echo "Omarchy tunnels started"
  fi

  # Ubuntu services (Plex, Frigate, qBittorrent, Open WebUI)
  if ! tmux has-session -t ubuntu-tunnels 2>/dev/null; then
    tmux new-session -d -s ubuntu-tunnels 'ssh -N \
      -L 32400:localhost:32400 \
      -L 5000:localhost:5000 \
      -L 8080:localhost:8080 \
      -L 3000:localhost:3000 \
      -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ubuntu'
    echo "Ubuntu tunnels started"
  fi
}
start_tunnels
```

### Termux:Boot (Device Boot)

SSH server starts automatically when phone boots via Termux:Boot app:

**Location:** `~/.termux/boot/start-sshd.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
sshd
```

**Boot sequence:**
1. Phone boots → Android starts Termux:Boot
2. Termux:Boot runs `~/.termux/boot/start-sshd.sh`
3. SSH server available on port 8022
4. First shell login triggers `start_tunnels` via `.zshrc`

---

## Tunnel Management

### `mole` Command (Health Check & Auto-Repair)

The `mole` function checks tunnel health and auto-repairs dead/zombie tunnels:

```bash
mole() {
  echo "🔍 Checking tunnel health..."

  local omarchy_dead=0
  local ubuntu_dead=0

  # Test omarchy tunnel (n8n on 5678)
  if ! curl -s -o /dev/null --connect-timeout 3 http://localhost:5678 2>/dev/null; then
    echo "⚠️  Omarchy tunnel appears dead"
    omarchy_dead=1
  else
    echo "✅ Omarchy tunnel healthy (n8n responding)"
  fi

  # Test ubuntu tunnel (Frigate on 5000)
  if ! curl -s -o /dev/null --connect-timeout 3 http://localhost:5000 2>/dev/null; then
    echo "⚠️  Ubuntu tunnel appears dead"
    ubuntu_dead=1
  else
    echo "✅ Ubuntu tunnel healthy (Frigate responding)"
  fi

  # Auto-repair dead tunnels
  if [ $omarchy_dead -eq 1 ]; then
    echo "🔫 Killing zombie omarchy SSH processes..."
    pkill -f "ssh.*omarchy" 2>/dev/null
    tmux kill-session -t tunnels 2>/dev/null
    sleep 1
    echo "🔧 Recreating omarchy tunnel..."
    tmux new-session -d -s tunnels 'ssh -N -L 5678:localhost:5678 \
      -L 11434:localhost:11434 -L 8000:localhost:8000 \
      -o ServerAliveInterval=60 -o ServerAliveCountMax=3 omarchy'
    sleep 2
    echo "✅ Omarchy tunnel restored!"
  fi

  if [ $ubuntu_dead -eq 1 ]; then
    echo "🔫 Killing zombie ubuntu SSH processes..."
    pkill -f "ssh.*ubuntu" 2>/dev/null
    tmux kill-session -t ubuntu-tunnels 2>/dev/null
    sleep 1
    echo "🔧 Recreating ubuntu tunnel..."
    tmux new-session -d -s ubuntu-tunnels 'ssh -N -L 32400:localhost:32400 \
      -L 5000:localhost:5000 -L 8080:localhost:8080 -L 3000:localhost:3000 \
      -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ubuntu'
    sleep 2
    echo "✅ Ubuntu tunnel restored!"
  fi

  if [ $omarchy_dead -eq 0 ] && [ $ubuntu_dead -eq 0 ]; then
    echo "🎉 All tunnels healthy!"
  fi
}
```

**Usage:**
```bash
mole    # Check health and auto-repair dead tunnels
```

---

## Manual Tunnel Management

```bash
# Check running tunnels
tmux list-sessions

# Restart all tunnels
tmux kill-session -t tunnels
tmux kill-session -t ubuntu-tunnels
start_tunnels

# View tunnel output (for debugging)
tmux attach -t tunnels
# Detach with: Ctrl+B, then D

# Add a new port (edit ~/.zshrc, find ssh line, add):
-L <local-port>:localhost:<remote-port>
```

---

## Adding New Tunnels

### Same Server (e.g., another omarchy service)
Add to existing `-L` chain in `~/.zshrc`:
```bash
-L 5678:localhost:5678 \
-L 11434:localhost:11434 \
-L 8000:localhost:8000 \
-L NEW_PORT:localhost:NEW_PORT \  # Add here
```

### Different Server
Create new tmux session or add to existing:
```bash
# New server example
if ! tmux has-session -t newserver-tunnels 2>/dev/null; then
  tmux new-session -d -s newserver-tunnels 'ssh -N \
    -L LOCAL_PORT:localhost:REMOTE_PORT \
    -o ServerAliveInterval=60 -o ServerAliveCountMax=3 newserver'
fi
```

**Rule:** Local ports must be unique across all tunnels. Remote ports can repeat on different servers.

---

## Accessing Services

Open in phone browser:
- **n8n:** http://localhost:5678
- **Plex:** http://localhost:32400/web
- **Frigate:** http://localhost:5000
- **qBittorrent:** http://localhost:8080
- **Open WebUI:** http://localhost:3000
- **Ollama API:** http://localhost:11434

---

## Troubleshooting

### Tunnel not working
```bash
# Check if tmux session exists
tmux list-sessions

# Check if SSH process is running
ps aux | grep ssh

# Restart tunnels
start_tunnels
```

### Connection refused on localhost
1. Tunnel may have died - restart with `start_tunnels`
2. Service may be down on remote host
3. Check tmux session for errors: `tmux attach -t tunnels`

### SSH connection fails
```bash
# Test direct connection
ssh -v omarchy

# Check if Twingate is connected
ping 192.168.2.249
```

### Host key error
```bash
ssh-keygen -R <ip-address>
# Then reconnect to accept new key
```

---

## Known Issues

### Tunnels occasionally die
Tunnels can drop due to network changes or phone sleep. Use `mole` to check and auto-repair.

### Omarchy tunnel more unstable than Ubuntu
The omarchy tunnel is more prone to disconnection. Check `mole` output if services are unreachable.

### Powerlevel10k gitstatus
Gitstatus binary doesn't work on Termux/Android. Fixed by removing `vcs` from `~/.p10k.zsh` left prompt elements (2026-01-17).

---

## Related Documentation

- [omarchy.md](omarchy.md) - VM 100 services (n8n, Ollama)
- [ubuntu.md](ubuntu.md) - VM 101 services (Plex, Frigate, etc.)
- [mac.md](mac.md) - Mac SSH tunnel setup (similar pattern)
