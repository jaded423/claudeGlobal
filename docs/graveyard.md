# Graveyard - Obsolete File Archive System

The graveyard is a safety net for file deletion across all projects. Instead of permanently deleting files, move them to the graveyard for 6-month retention.

## Overview

**Location**: `~/projects/graveyard/`

The graveyard provides a holding area for obsolete and questionable files from all projects. This approach balances cleanup with safety - you can delete files from active projects without fear of permanently losing something you might need later.

## Why Use the Graveyard?

### Problems It Solves

1. **"Might need it later" paralysis** - Clean up confidently knowing files aren't gone forever
2. **Accidental deletions** - Easy recovery if you realize you need something
3. **Historical reference** - Compare old implementations with new approaches
4. **Debugging regressions** - Check if old code had working logic
5. **Audit trail** - See what was tried and why it didn't work

### Alternative to Git History

While git history preserves everything, the graveyard offers:
- **Faster access** - No git archaeology needed
- **Cross-project visibility** - All obsolete files in one place
- **Organized by project** - Easy to browse by source
- **Explicit retention policy** - 6 months then delete
- **No repo clutter** - Keeps git history focused on meaningful changes

## When to Use the Graveyard

### Good Candidates

Move files to graveyard when:
- **Refactoring away old code** that might have useful logic
- **Cleaning up test scripts** that are no longer needed
- **Archiving old configs** after updating architecture
- **Removing "just in case" files** cluttering directories
- **Uncertain about deletion** - better safe than sorry

### Don't Use Graveyard For

Skip the graveyard for:
- **Temporary files** - Just delete (.tmp, .cache, etc.)
- **Generated files** - Can be regenerated (build artifacts)
- **Duplicates** - Keep one good copy, delete the rest
- **Empty files** - No value to preserve
- **Large binaries** - Use proper backup if needed, don't bloat graveyard

## Directory Structure

```
~/projects/graveyard/
├── CLAUDE.md              # This documentation + log of moves
├── odooReports/           # Files from odooReports project
│   ├── old_report_v1.py
│   └── deprecated_config.yaml
├── nvimConfig/            # Files from nvimConfig project
│   └── old_plugin_config.lua
├── promptLibrary/         # Files from promptLibrary project
│   ├── failed_experiment/
│   └── old_test_harness.py
└── [projectName]/         # One subdir per source project
    └── [files...]
```

### Organization Rules

1. **One subdirectory per project** - Match project name exactly
2. **Preserve relative paths** - Maintain directory structure from source
3. **Add date prefix** - Optional: `YYYY-MM-DD_filename` for clarity
4. **Log every move** - Update graveyard/CLAUDE.md with what and why

## Usage Workflow

### Moving Files to Graveyard

```bash
# 1. Create project subdir if it doesn't exist
mkdir -p ~/projects/graveyard/myProject

# 2. Move obsolete file(s)
mv old_file.py ~/projects/graveyard/myProject/

# Or move entire directory
mv old_feature/ ~/projects/graveyard/myProject/

# 3. Optional: Add date prefix for clarity
mv file.py ~/projects/graveyard/myProject/2025-11-07_file.py

# 4. Log the move in graveyard/CLAUDE.md
```

### Logging Moves

Always document what you moved and why:

```bash
# Edit graveyard documentation
vim ~/projects/graveyard/CLAUDE.md

# Add entry like:
# ### 2025-11-07 - Moved from myProject
# - old_file.py - Replaced by new architecture
# - test_old_api.py - API deprecated, tests no longer relevant
```

### Retrieving Files from Graveyard

If you need something back:

```bash
# 1. Find the file
cd ~/projects/graveyard
find . -name "old_file.py"

# 2. Check when it was moved
grep -r "old_file.py" CLAUDE.md

# 3. Copy (don't move) back to project
cp graveyard/myProject/old_file.py ~/projects/myProject/

# 4. Review and adapt as needed
```

### Cleaning Up Graveyard

Every 6 months, delete old files:

```bash
# Find files older than 6 months
cd ~/projects/graveyard
find . -type f -mtime +180

# Review the list
find . -type f -mtime +180 -ls

# Delete permanently
find . -type f -mtime +180 -delete

# Update CLAUDE.md log noting the cleanup
```

## Integration with Projects

### During Refactoring

```bash
# Starting a refactor
cd ~/projects/myProject

# Move old implementation to graveyard
mv src/old_approach/ ~/projects/graveyard/myProject/

# Implement new approach
# ...

# If new approach works well, old code will naturally age out in 6 months
# If new approach has issues, old code is easy to reference
```

### During Cleanup

```bash
# Identify clutter
cd ~/projects/myProject
ls -la | grep -E "(old|deprecated|backup|copy|test)"

# Move to graveyard
mv old_*.py ~/projects/graveyard/myProject/
mv *_backup.yaml ~/projects/graveyard/myProject/

# Document why in graveyard/CLAUDE.md
```

### When Uncertain

```bash
# Not sure if you'll need a file?
# Default to graveyard rather than delete

mv maybe_useful.py ~/projects/graveyard/myProject/

# Add note in graveyard/CLAUDE.md
# "maybe_useful.py - Not sure if needed, keeping for reference"

# After 6 months, if you haven't needed it, it auto-deletes
```

## Best Practices

### 1. Log Every Move

Keep graveyard/CLAUDE.md updated:

```markdown
### 2025-11-07 - Cleanup from promptLibrary

**Files moved:**
- `test_old_api.py` - Old test file for deprecated API endpoint
- `config_v1.yaml` - Replaced by config_v2.yaml with new structure
- `experiment_failed/` - Directory of failed LLM prompting approach

**Reason:** Project refactor to new architecture, old files no longer relevant

**Retrieve by:** `find ~/projects/graveyard/promptLibrary -name "test_old*"`
```

### 2. Preserve Context

When moving files, preserve surrounding context:

```bash
# If moving a Python file, consider moving related tests
mv src/old_feature.py ~/projects/graveyard/myProject/
mv tests/test_old_feature.py ~/projects/graveyard/myProject/

# Preserve directory structure
mv src/deprecated/ ~/projects/graveyard/myProject/src/deprecated/
```

### 3. Use Date Prefixes for Clarity

Optional but helpful:

```bash
# Add date when moving
mv config.yaml ~/projects/graveyard/myProject/2025-11-07_config.yaml

# Makes it obvious when you moved it
# Useful if graveyard has multiple versions of same filename
```

### 4. Don't Over-Archive

Be selective about what goes to graveyard:

```bash
# Good candidates
mv experimental_approach.py ~/projects/graveyard/  # Might want to compare later
mv old_working_version.py ~/projects/graveyard/    # Known working state

# Bad candidates (just delete)
rm .DS_Store           # OS junk
rm *.pyc              # Compiled Python
rm node_modules/      # Can be reinstalled
rm build/             # Can be rebuilt
```

### 5. Review Periodically

Check graveyard monthly:

```bash
# What's in there?
cd ~/projects/graveyard
ls -lR

# How old is stuff?
find . -type f -mtime +90  # Files older than 90 days

# Have I referenced any of it?
# If not, probably safe to delete
```

## Graveyard vs. Git History

### When to Use Each

**Use Graveyard for:**
- Quick access to recently removed code
- Comparing old vs. new implementations side-by-side
- When you might need to reference within 6 months
- Files that were never committed (local experiments)

**Use Git History for:**
- Long-term archival (permanent record)
- Understanding evolution of the codebase
- Reverting entire features or commits
- Seeing what changed between versions

**Use Both:**
1. Commit old working version to git
2. Move old files to graveyard for easy access
3. Implement new approach
4. After 6 months, graveyard auto-cleans but git preserves forever

## Example Workflow: Major Refactor

```bash
# 1. Before refactoring, commit current working state
cd ~/projects/myProject
git add .
git commit -m "feat: Working version before refactor"
git push

# 2. Move old implementation to graveyard for easy reference
mv src/old_architecture/ ~/projects/graveyard/myProject/

# 3. Document in graveyard
vim ~/projects/graveyard/CLAUDE.md
# Add entry about what was moved and why

# 4. Implement new approach
# (develop new code)

# 5. If new approach has issues, easily reference old code
cd ~/projects/graveyard/myProject/old_architecture/
cat old_implementation.py  # See how it was done before

# 6. After 6 months, if new approach is stable, old code auto-deletes
# Git history still preserves everything permanently
```

## Maintenance Schedule

### Weekly
- None required (just move files as needed)

### Monthly
- Review what's in graveyard: `ls -lR ~/projects/graveyard`
- Check if anything needs to be permanently deleted early
- Update CLAUDE.md log with any notable patterns

### Every 6 Months
- Run cleanup command: `find ~/projects/graveyard -type f -mtime +180 -delete`
- Document cleanup in CLAUDE.md
- Verify graveyard structure is still organized

## Tips and Tricks

### Quick Find Command

```bash
# Add to your ~/.zshrc for quick graveyard search
grave() {
    cd ~/projects/graveyard
    find . -iname "*$1*"
}

# Usage: grave "old_config"
```

### Browse by Project

```bash
# See what's in graveyard from specific project
ls -la ~/projects/graveyard/myProject/

# Count files per project
for d in ~/projects/graveyard/*/; do
    echo "$(basename $d): $(find "$d" -type f | wc -l) files"
done
```

### Check File Age

```bash
# Files moved in last 30 days
find ~/projects/graveyard -type f -mtime -30 -ls

# Files older than 150 days (approaching deletion)
find ~/projects/graveyard -type f -mtime +150 -ls
```

## See Also

- **[~/projects/graveyard/CLAUDE.md](../../graveyard/CLAUDE.md)** - Complete log of all moves
- **[projects.md](projects.md)** - Overview of all active projects
- **[best-practices.md](best-practices.md)** - General documentation best practices
