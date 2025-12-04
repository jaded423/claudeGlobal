# macOS User Migration Plan: joshuabrown → j

**Date Created**: December 4, 2025
**Situation**: User `j` home directory is currently symlinked to `/Users/joshuabrown`. Need to migrate to real `/Users/j` directory.

**Current State**:
- User: `j`
- Home: `/Users/j` → `/Users/joshuabrown` (symlink)
- Backup: `/Users/j.new` (backup created before symlinking)

---

## Phase 1: Backup & Preparation ⚠️ CRITICAL

### 1. Create Full Backup to External Drive

```bash
# Connect external drive, then:
sudo rsync -aAXv /Users/joshuabrown/ /Volumes/BackupDrive/joshuabrown-backup-2025-12-04/

# Verify backup completed
ls -la /Volumes/BackupDrive/joshuabrown-backup-2025-12-04/
du -sh /Volumes/BackupDrive/joshuabrown-backup-2025-12-04/
```

### 2. Document Current System State

```bash
# Save current user configuration
dscl . -read /Users/j > ~/j-user-config-$(date +%Y%m%d).txt
dscl . -read /Users/j NFSHomeDirectory

# Document current symlink
ls -la /Users/j

# Document home directory contents
ls -la /Users/joshuabrown | head -30 > ~/joshuabrown-contents-$(date +%Y%m%d).txt
```

---

## Phase 2: Create Temporary Admin User

**Why?** You cannot modify your own home directory while logged in. A temporary admin account is required to perform the migration.

### Steps:

1. **System Settings → Users & Groups**
2. Click the **lock icon** and authenticate
3. Click **+** to add a new user
4. Create user:
   - Name: `tempAdmin`
   - Account type: **Administrator**
   - Set a temporary password
5. **Log out** of user `j`
6. **Log in** as `tempAdmin`

---

## Phase 3: The Migration (Run as `tempAdmin`)

### 1. Remove the Symlink

```bash
sudo rm /Users/j
```

### 2. Create Real /Users/j Directory

```bash
sudo mkdir -p /Users/j
```

### 3. Copy All Data from joshuabrown to j

```bash
sudo rsync -aAXv /Users/joshuabrown/ /Users/j/

# Flags explained:
# -a: archive mode (preserves permissions, timestamps, symlinks)
# -A: preserve ACLs (Access Control Lists)
# -X: preserve extended attributes
# -v: verbose output
```

**This will take several minutes depending on data size.**

### 4. Fix File Ownership (CRITICAL!)

```bash
# Get the UID for user 'j'
id -u j  # Note this number (typically 501 or 502)

# Update all file ownership recursively
sudo chown -R j:staff /Users/j/

# Verify ownership
ls -la /Users/j/ | head -20
```

### 5. Update macOS Directory Services

```bash
# Point user 'j' home directory to /Users/j
sudo dscl . -create /Users/j NFSHomeDirectory /Users/j

# Verify the change
dscl . -read /Users/j NFSHomeDirectory
# Should output: NFSHomeDirectory: /Users/j
```

---

## Phase 4: Verification & Testing

### 1. Log Out and Back In

1. Log out of `tempAdmin`
2. Log in as user `j`

### 2. Verify Home Directory

```bash
# Check environment variable
echo $HOME
# Should show: /Users/j

# Check current directory
pwd
# Should show: /Users/j

# Check Directory Services
dscl . -read /Users/j NFSHomeDirectory
# Should show: NFSHomeDirectory: /Users/j

# Verify it's NOT a symlink
ls -la /Users/ | grep "j "
# Should show a regular directory, not a symlink
```

### 3. Test Critical Services

```bash
# Test Claude configuration
ls -la ~/.claude/
cat ~/.claude/CLAUDE.md | head -20

# Test Git configuration
git config --global --list
git config --global user.name
git config --global user.email

# Test SSH keys
ssh-add -l

# Test running LaunchAgents
launchctl list | grep user

# Test crontab
crontab -l
```

### 4. Test Project Access

```bash
# Verify projects directory
ls -la ~/projects/

# Test git in a project
cd ~/projects/scripts
git status
git remote -v

# Test another project
cd ~/projects/nvimConfig
git status
```

### 5. Test Application-Specific Configs

```bash
# ZSH config
cat ~/.zshrc | head -10

# Neovim config
ls -la ~/.config/nvim/

# Verify symlinks still work
readlink ~/.config/nvim
# Should show: /Users/j/projects/nvimConfig

readlink ~/.zshrc
# Should show: /Users/j/projects/zshConfig/.zshrc
```

### 6. Test Automated Scripts

```bash
# Check backup script
~/scripts/gitBackup.sh --dry-run

# Verify script paths are correct
cat ~/scripts/gitBackup.sh | grep "/Users/"
```

---

## Phase 5: Cleanup (After 2-3 Days of Verification)

**⚠️ Only proceed after confirming everything works correctly!**

### 1. Remove Old joshuabrown Directory

```bash
# FINAL CHECK: Make sure you're NOT using it
dscl . -read /Users/j NFSHomeDirectory
# Must show /Users/j, NOT /Users/joshuabrown

# Remove old directory
sudo rm -rf /Users/joshuabrown
```

### 2. Remove Backup Directory (Optional)

```bash
# Only if you're confident and have external backup
sudo rm -rf /Users/j.new
```

### 3. Delete Temporary Admin User

1. **System Settings → Users & Groups**
2. Select `tempAdmin`
3. Click **-** to remove
4. Choose **Delete the home folder**
5. Confirm deletion

---

## Rollback Plan (If Something Goes Wrong)

If you encounter issues during migration:

### Option 1: Restore Symlink

```bash
# As tempAdmin:
sudo rm -rf /Users/j
sudo ln -s /Users/joshuabrown /Users/j

# Log back in as 'j' - should work as before
```

### Option 2: Restore from Backup

```bash
# As tempAdmin:
sudo rm -rf /Users/j
sudo rsync -aAXv /Volumes/BackupDrive/joshuabrown-backup-2025-12-04/ /Users/joshuabrown/
sudo ln -s /Users/joshuabrown /Users/j
sudo chown -R j:staff /Users/joshuabrown/
```

### Option 3: Restore from j.new

```bash
# As tempAdmin:
sudo rm -rf /Users/joshuabrown
sudo rsync -aAXv /Users/j.new/ /Users/joshuabrown/
sudo rm /Users/j
sudo ln -s /Users/joshuabrown /Users/j
```

---

## Common Issues & Solutions

### Issue: "Permission Denied" Errors

**Solution**: Make sure you're running commands as `tempAdmin` with `sudo`

### Issue: SSH Keys Not Working

**Solution**:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
ssh-add -K ~/.ssh/id_rsa  # Add to macOS Keychain
```

### Issue: Git Push Requires Password

**Solution**:
```bash
# Re-add SSH key to keychain
ssh-add -K ~/.ssh/id_rsa

# Verify key is loaded
ssh-add -l
```

### Issue: LaunchAgents Not Running

**Solution**:
```bash
# Reload launch agents
launchctl unload ~/Library/LaunchAgents/*.plist
launchctl load ~/Library/LaunchAgents/*.plist

# Check status
launchctl list | grep user
```

### Issue: Symlinks Broken

**Solution**:
```bash
# Check symlink targets
ls -la ~/.config/nvim
ls -la ~/.zshrc

# If broken, recreate:
ln -sf ~/projects/nvimConfig ~/.config/nvim
ln -sf ~/projects/zshConfig/.zshrc ~/.zshrc
```

---

## Timeline Recommendation

- **Day 1**: Phases 1-4 (Backup, create tempAdmin, migrate, verify)
- **Days 2-3**: Extended testing, use system normally, monitor for issues
- **Day 4+**: Phase 5 cleanup (if everything works perfectly)

---

## Checklist

Before starting:
- [ ] External backup drive connected and has sufficient space
- [ ] All important work is saved and committed
- [ ] You have time set aside (1-2 hours for migration)
- [ ] You understand how to create a temporary admin user

After migration:
- [ ] Can log in as user `j`
- [ ] `$HOME` shows `/Users/j`
- [ ] Claude config accessible (`~/.claude/`)
- [ ] Git works and can push to GitHub
- [ ] SSH keys work
- [ ] Projects accessible (`~/projects/`)
- [ ] All symlinks functional (`~/.config/nvim`, `~/.zshrc`)
- [ ] LaunchAgents running
- [ ] Crontab jobs working
- [ ] Can run automation scripts

After cleanup:
- [ ] `/Users/joshuabrown` removed
- [ ] `/Users/j.new` removed (or kept as local backup)
- [ ] `tempAdmin` user deleted
- [ ] External backup stored safely

---

## Notes

- **j.new**: This was created as a backup before symlinking. Can be kept as a local backup or removed after successful migration.
- **UID Issues**: The original problem was UID changes. After migration, verify with `id -u j` that UID is consistent.
- **Symlink Dependencies**: Many configs use symlinks to `~/projects/`. These should work fine after migration since the relative paths remain the same.

---

**Good luck! Take your time and don't skip the backup step.**
