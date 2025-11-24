# Grand Synchronization Project

**Started:** November 23, 2025
**Goal:** Establish bidirectional documentation sync between Work Mac and Home Lab Server
**Primary Target:** Global CLAUDE.md and all critical documentation

---

## Project Overview

This project establishes automated synchronization of documentation between two machines:
- **Work Mac** (Darwin) @ `/Users/joshuabrown` - Primary development machine
- **Home Lab Server** (CachyOS Linux) @ `/home/jaded` - cachyos-jade @ 192.168.2.250

The synchronization uses GitHub as the central hub, with the Mac as the source of truth for all documentation.

---

## Architecture

```
Work Mac                  GitHub                    Home Lab Server
~/.claude/      push      jaded423/     pull       ~/.claude/
(source)    ─────────►   claudeGlobal  ◄─────────  (replica)
            hourly                       hourly

Edit here → Auto-commit → GitHub → Auto-sync → Server updated
```

**Key Principles:**
1. **Mac is source of truth** - All edits happen on Mac
2. **GitHub is the hub** - Central repository for version control
3. **Server is read-only replica** - Pulls changes, never pushes
4. **Automated sync** - Hourly synchronization without manual intervention
5. **Conflict resolution** - Server hard resets to match origin (no merging)

---

## Phase 1: Test with homelab.md ✅ COMPLETE

**Status:** Successfully deployed and tested on November 23, 2025

### What Was Done

#### 1. Unified Documentation
- Merged divergent versions of `homelab.md` between Mac and server
- Reconciled differences:
  - Network change from 192.168.1.x to 192.168.2.x
  - Raspberry Pi consolidation (Pi 1 decommissioned, Pi 2 expanded)
  - New services added (Odoo, RustDesk, Portainer, Homarr, MagicMirror)
  - Preserved changelog history from both versions
- Created `homelab-expansion.md` for future infrastructure plans

#### 2. Mac → GitHub (Already Working)
**Existing infrastructure leveraged:**
- Script: `~/projects/scripts/bin/gitBackup.sh`
- LaunchAgent: `~/Library/LaunchAgents/com.user.gitbackup.plist`
- Schedule: Every hour at :00
- Repository: `github.com:jaded423/claudeGlobal`
- Entry in REPOS array: `"Claude Global|/Users/joshuabrown/projects/.claude"`

#### 3. GitHub → Server (New Setup)
**Created sync infrastructure on server:**

**Sync Script:** `~/scripts/sync-claude-global.sh`
```bash
#!/bin/bash
# Sync Claude Global from GitHub (Mac is source of truth)
cd ~/.claude

# Stash any local changes
git stash

# Fetch latest from origin
git fetch origin

# Reset to match origin/master exactly
git reset --hard origin/master

# Log the sync
echo "$(date): Synced Claude Global from GitHub" >> ~/logs/sync-claude.log
```

**Systemd Service:** `~/.config/systemd/user/claude-sync.service`
```ini
[Unit]
Description=Sync Claude Global Documentation from GitHub
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/jaded/scripts/sync-claude-global.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

**Systemd Timer:** `~/.config/systemd/user/claude-sync.timer`
```ini
[Unit]
Description=Sync Claude Global Documentation from GitHub every hour
Requires=claude-sync.service

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

**Activation Commands:**
```bash
systemctl --user enable claude-sync.timer
systemctl --user start claude-sync.timer
```

#### 4. Testing Performed
- ✅ Made test change on Mac: Added comment to `homelab.md`
- ✅ Pushed to GitHub via `git push`
- ✅ Manually triggered sync on server: `~/scripts/sync-claude-global.sh`
- ✅ Verified change appeared on server
- ✅ Cleaned up test change
- ✅ Confirmed systemd timer is active and waiting for next hour

### Lessons Learned
1. **Conflict Resolution:** Server had divergent commits - solved with hard reset approach
2. **No Cron on CachyOS:** Used systemd timers instead (more modern approach)
3. **Fish Shell Compatibility:** Scripts use bash explicitly for compatibility
4. **Stash Before Reset:** Prevents losing any local work-in-progress

---

## Phase 2: Observation & Refinement 🔄 IN PROGRESS

**Timeline:** 1-3 days of observation

### What to Monitor
1. **Hourly Sync Success**
   - Check server logs: `tail -f ~/logs/sync-claude.log`
   - Check systemd status: `systemctl --user status claude-sync.timer`
   - Verify changes propagate within 1 hour

2. **Workflow Impact**
   - Does the sync delay affect your workflow?
   - Any unexpected conflicts or resets?
   - Is hourly frequent enough? Too frequent?

3. **Edge Cases to Test**
   - Large documentation changes
   - Multiple rapid edits
   - Network outages during sync
   - Simultaneous edits (should favor Mac)

### Refinements to Consider
- [ ] Add email notifications for sync failures
- [ ] Implement pre-sync backup on server
- [ ] Add sync status to Mac's menu bar
- [ ] Create manual sync trigger command
- [ ] Add file change detection for immediate sync

---

## Phase 3: Expand to Global CLAUDE.md 📋 PLANNED

**Target File:** `~/.claude/CLAUDE.md` - The main documentation file

### Why This Is Critical
- Central documentation for all projects
- Contains user preferences and workflows
- Referenced by all AI assistants (via symlinks)
- Most frequently updated documentation

### Implementation Plan
Since `CLAUDE.md` is in the same repository (`.claude/`), it's already syncing! But we should:

1. **Verify Sync Coverage**
   ```bash
   # On Mac
   cd ~/.claude
   git ls-files | grep CLAUDE.md

   # Should show:
   # CLAUDE.md
   # GEMINI.md (symlink)
   # AGENTS.md (symlink)
   ```

2. **Test CLAUDE.md Specifically**
   - Make distinctive change to CLAUDE.md on Mac
   - Wait for hourly sync (or trigger manually)
   - Verify on server that change appears
   - Check symlinks still work: `readlink GEMINI.md`

3. **Monitor for Issues**
   - File size (CLAUDE.md can get large)
   - Symlink preservation
   - Line ending consistency

---

## Phase 4: Project Documentation Sync 📋 PLANNED

**Target:** Individual project CLAUDE.md files across `~/projects/*`

### Projects to Sync
1. **Already in gitBackup.sh:**
   - nvimConfig
   - zshConfig
   - odooReports
   - scripts
   - n8nDev
   - n8nProd

2. **Need to Add:**
   - promptLibrary
   - graveyard
   - gitCheatsheet

### Implementation Strategy

**Option A: Individual Timers per Project**
- Pro: Granular control
- Pro: Can sync at different intervals
- Con: More complex to manage
- Con: Multiple timer services

**Option B: Single Master Sync Script**
- Pro: One timer to rule them all
- Pro: Easier to maintain
- Pro: Coordinated sync timing
- Con: All-or-nothing approach

**Recommended: Option B with Enhancement**

Create `~/scripts/sync-all-projects.sh`:
```bash
#!/bin/bash
# Master sync script for all projects

PROJECTS=(
    "$HOME/projects/nvimConfig"
    "$HOME/projects/zshConfig"
    "$HOME/projects/odooReports"
    # ... etc
)

for PROJECT in "${PROJECTS[@]}"; do
    if [ -d "$PROJECT/.git" ]; then
        echo "Syncing $PROJECT..."
        cd "$PROJECT"
        git stash
        git fetch origin
        git reset --hard origin/master
        echo "$(date): Synced $PROJECT" >> ~/logs/sync-projects.log
    fi
done
```

---

## Phase 5: Advanced Features 📋 FUTURE

### Bidirectional Sync (If Needed)
Currently, server is read-only. If bidirectional sync is needed:

1. **Conflict Detection System**
   ```bash
   # Check if local changes exist
   if ! git diff-index --quiet HEAD --; then
       # Local changes detected
       # Email alert or merge strategy
   fi
   ```

2. **Merge Strategy Options**
   - Timestamp-based priority
   - Directory-based rules (some dirs Mac priority, others server)
   - Interactive merge tool

### Instant Sync Trigger
Instead of hourly, trigger on file changes:

**Mac Side (fswatch):**
```bash
fswatch -o ~/.claude | while read; do
    cd ~/.claude
    git add -A
    git commit -m "Auto-sync: $(date)"
    git push
done
```

**Server Side (inotifywait):**
```bash
# Monitor GitHub webhook or use push notification
```

### Sync Status Dashboard
Create web dashboard showing:
- Last sync time per project
- Pending changes count
- Sync failures/warnings
- Network status
- File diff preview

---

## Phase 6: Full Deployment Checklist 📋 FINAL

### Infrastructure Checklist
- [x] GitHub repository exists (claudeGlobal)
- [x] SSH keys configured on both machines
- [x] Git credentials stored
- [x] Server has pull access to repo
- [ ] Email notifications configured
- [ ] Backup system tested
- [ ] Recovery procedure documented

### Per-Machine Setup

**Mac (Source) Requirements:**
- [x] gitBackup.sh script deployed
- [x] LaunchAgent active
- [x] All projects in REPOS array
- [ ] Sync status indicator
- [ ] Pre-push validation

**Server (Replica) Requirements:**
- [x] sync-claude-global.sh created
- [x] systemd timer enabled
- [x] Logs directory created
- [ ] sync-all-projects.sh created
- [ ] Error alerting configured
- [ ] Cleanup old logs cron

### Documentation Updates
- [x] sync-project.md created (this file)
- [ ] Update interconnections.md with sync dependencies
- [ ] Update troubleshooting.md with sync issues
- [ ] Add sync status to projects.md
- [ ] Document recovery procedures

### Testing Protocol
- [x] Single file sync (homelab.md)
- [ ] Full directory sync (.claude/)
- [ ] Large file handling (>1MB)
- [ ] Network failure recovery
- [ ] Conflict resolution
- [ ] Symlink preservation
- [ ] Permission preservation

---

## Success Criteria

The project will be considered successful when:

1. **Automatic Sync** ✅ Works without intervention for 7 days
2. **No Data Loss** ✅ All changes on Mac appear on server
3. **Predictable Timing** ✅ Changes sync within 1 hour
4. **Error Recovery** ⏳ System recovers from network/git failures
5. **Documentation** ⏳ All systems documented and maintainable
6. **Monitoring** ⏳ Can verify sync status easily
7. **Scalability** ⏳ Can add new projects easily

---

## Risk Mitigation

### Identified Risks

1. **Data Loss Risk**
   - Mitigation: Server uses stash before reset
   - Mitigation: GitHub serves as backup
   - Mitigation: Mac has Time Machine

2. **Sync Conflict Risk**
   - Mitigation: Mac is always source of truth
   - Mitigation: Server never pushes
   - Mitigation: Hard reset prevents conflicts

3. **Network Failure Risk**
   - Mitigation: Persistent systemd timer
   - Mitigation: Local logs for debugging
   - Mitigation: Manual sync option

4. **Large File Risk**
   - Mitigation: Git LFS for binaries
   - Mitigation: .gitignore for generated files
   - Mitigation: Separate binary storage

---

## Commands Reference

### Monitoring Commands

**Check sync status on server:**
```bash
# Timer status
systemctl --user status claude-sync.timer

# Last sync time
systemctl --user status claude-sync.service

# View logs
tail -f ~/logs/sync-claude.log

# Manual sync
~/scripts/sync-claude-global.sh
```

**Check sync status on Mac:**
```bash
# Check last push
cd ~/.claude && git log -1 --oneline

# Check backup script
tail -f /tmp/git_backup.log

# Manual push
cd ~/.claude && git push
```

### Troubleshooting Commands

**Reset server to match GitHub:**
```bash
cd ~/.claude
git fetch origin
git reset --hard origin/master
```

**Check for divergence:**
```bash
git status
git log origin/master..HEAD  # Local commits not on origin
git log HEAD..origin/master  # Remote commits not local
```

**Fix systemd timer:**
```bash
systemctl --user daemon-reload
systemctl --user restart claude-sync.timer
journalctl --user -u claude-sync.service -f
```

---

## Next Steps

### Immediate (After Phase 1 Validation)
1. Monitor homelab.md sync for 24-48 hours
2. Check logs for any errors
3. Make several test edits to verify reliability
4. Document any issues encountered

### Short Term (This Week)
1. Test CLAUDE.md sync specifically
2. Add remaining projects to gitBackup.sh
3. Create sync-all-projects.sh script
4. Set up email notifications

### Medium Term (Next Week)
1. Deploy full project sync
2. Create monitoring dashboard
3. Document recovery procedures
4. Train on the new workflow

### Long Term (Next Month)
1. Consider bidirectional sync needs
2. Optimize sync frequency
3. Add instant sync triggers
4. Create backup rotation system

---

## Conclusion

This synchronization project solves the documentation drift problem between the Work Mac and Home Lab server. By establishing the Mac as the source of truth and using GitHub as the synchronization hub, we ensure consistent documentation across both environments while maintaining version control and backup capabilities.

The phased approach allows for testing and refinement before full deployment, minimizing risk while building confidence in the system.