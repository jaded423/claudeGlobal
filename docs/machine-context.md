# Machine Context Detection

**ALWAYS check which machine you're operating on before documenting changes.** This system spans two machines with different documentation patterns.

---

## Detecting Current Machine

**Check the environment:**
```bash
# OS detection
uname -s          # Darwin = Mac, Linux = Home Lab

# Hostname detection
hostname          # Shows which specific machine

# Working directory
pwd               # Shows if you're in a Mac or Linux path structure
```

**Your Machines:**

| Machine | OS | Hostname | Home Dir | Purpose |
|---------|-----|----------|----------|---------|
| **Work Mac** | Darwin (macOS) | joshuabrown-macbook (or similar) | `/Users/joshuabrown` | Primary development, work projects |
| **Home Lab** | Linux (CachyOS) | cachyos-jade | `/home/jaded` | Server, file sharing, remote access |

---

## Documentation Patterns by Machine

### Working directly on Work Mac
- Document in relevant project's CLAUDE.md
- Global changes: Update `~/.claude/CLAUDE.md` or `~/.claude/docs/*.md`
- Changes sync to home lab automatically (hourly)

### Working directly on Home Lab (SSH session where Claude Code is running ON the server)
- Document in `~/docs/*.md` for server-specific changes
- Global changes: Update `~/.claude/CLAUDE.md` (same global docs)
- Changes sync to work Mac automatically (hourly)

### Working from Mac via SSH to server (Claude Code running ON MAC, executing commands ON SERVER)
- **This is the tricky case!**
- Claude Code is running on your MAC
- Commands executed via `ssh jaded@192.168.2.250 "command"` run ON SERVER
- Documentation updates happen on your MAC (where Claude Code runs)
- **Pattern:**
  - Document **what** changed on the server
  - Document **where** it changed: "on home lab server (cachyos-jade)"
  - Update home lab docs: Use SSH to edit server files OR wait for next sync
  - Update global docs on Mac: `~/.claude/docs/homelab.md` with changes

---

## SSH Operations from Mac: Documentation Flow

**Example:** You're on your Mac, using Claude Code to configure something on the home lab server via SSH.

**What happens:**
1. **Claude executes:** `ssh jaded@192.168.2.250 "systemctl restart sshd"`
2. **Change occurs:** On home lab server
3. **Documentation occurs:** On your Mac (where Claude Code runs)
4. **Where to document:**
   - **Global context:** Update `~/.claude/docs/homelab.md` on Mac
   - **Server-specific:** Use SSH to update `~/docs/*.md` on server OR note it in homelab.md
   - **Project-specific:** If related to a project, update that project's CLAUDE.md on Mac

**Commands to update server docs from Mac:**
```bash
# Option 1: Edit file remotely via SSH
ssh jaded@192.168.2.250 "echo 'New entry' >> ~/docs/maintenance.md"

# Option 2: Copy updated file from Mac to server
scp /tmp/updated-doc.md jaded@192.168.2.250:~/docs/

# Option 3: Let it sync naturally (if you updated ~/.claude/docs/homelab.md)
# - Mac pushes to GitHub (hourly)
# - Server pulls from GitHub (hourly)
# - Changes appear on server within ~1 hour
```

---

## Quick Machine Detection

**At the start of any documentation task:**

```bash
uname -s && hostname && pwd
```

**Then document accordingly:**
- **Darwin + Mac hostname + /Users/...:** You're on Mac, use Mac documentation patterns
- **Linux + cachyos-jade + /home/jaded:** You're on home lab, use server documentation patterns
- **Running SSH commands from Mac:** Note that changes are on server, document in homelab.md

---

## Documentation Decision Tree

```
Q: Where am I running Claude Code?
├─ Mac → Continue
└─ Linux (home lab) → Document in server's ~/docs/ and ~/.claude/ (global)

Q: Am I making changes via SSH from Mac to server?
├─ No → Document on current machine normally
└─ Yes → Document on Mac, note "on home lab server", update homelab.md

Q: Is this a project-specific change?
├─ Yes → Update project's CLAUDE.md
└─ No → Update global docs or machine-specific docs

Q: Should this sync to other machine?
├─ Global context → Update ~/.claude/docs/homelab.md or projects.md
└─ Machine-specific → Update local docs on that machine
```

---

## Examples

### Example 1: Installing package on Mac
- Machine: Work Mac
- Action: `brew install something`
- Document: Project CLAUDE.md or global docs on Mac
- Sync: Not needed (Mac-specific)

### Example 2: Configuring Samba on home lab while SSH'd from Mac
- Machine: Work Mac (running Claude Code)
- Target: Home lab server (via SSH)
- Action: `ssh jaded@192.168.2.250 "sudo systemctl restart smb"`
- Document: `~/.claude/docs/homelab.md` on Mac with note "Updated Samba configuration on cachyos-jade server"
- Optionally: SSH to update `~/docs/maintenance.md` on server for detailed local docs
- Sync: Automatic (homelab.md syncs to server hourly)

### Example 3: Updating Hyprland config while logged into home lab
- Machine: Home lab (SSH session, Claude Code running on server)
- Action: Edit `~/.config/hypr/hyprland.conf`
- Document: `~/docs/desktop-environment.md` on server
- Sync: Not critical (desktop config is local to server)
