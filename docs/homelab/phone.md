# Samsung S25 Ultra (Phone)

**Last Updated:** January 17, 2026
**IP Address:** 192.168.1.96
**Network:** 192.168.1.0/24 (Mac/PC network)

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

---

## Tunnel Management

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

## Related Documentation

- [omarchy.md](omarchy.md) - VM 100 services (n8n, Ollama)
- [ubuntu.md](ubuntu.md) - VM 101 services (Plex, Frigate, etc.)
- [mac.md](mac.md) - Mac SSH tunnel setup (similar pattern)
