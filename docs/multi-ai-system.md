# Multi-AI Documentation System

This system allows you to maintain a single source of truth (CLAUDE.md) while supporting multiple AI assistants through symlinks.

## Overview

The multi-AI documentation system uses filesystem symlinks to ensure all AI assistants read the same, always-up-to-date documentation. This eliminates synchronization issues and maintains consistency across different AI tools.

## The Three Files (via Symlinks)

Every project should have these three documentation files in its root:

### 1. CLAUDE.md - Source of Truth

The primary documentation file that you edit directly.

**Contains:**
- Project overview and architecture
- Setup and installation instructions
- Development guidelines
- Changelog and version history
- Technical decisions and rationale

**Location:** `<project-root>/CLAUDE.md`

### 2. GEMINI.md - Symlink to CLAUDE.md

Used when working with Google Gemini AI Code Assist.

**Properties:**
- Automatically stays in sync via filesystem symlink
- No manual synchronization needed
- Git tracks the symlink itself, not a copy

**Location:** `<project-root>/GEMINI.md -> CLAUDE.md`

### 3. AGENTS.md - Symlink to CLAUDE.md

Used for other AI assistants (GitHub Copilot, Cursor, etc.).

**Properties:**
- Automatically stays in sync via filesystem symlink
- Universal compatibility across AI tools
- Single source of truth maintained

**Location:** `<project-root>/AGENTS.md -> CLAUDE.md`

## Benefits of Symlinks

### Always in Sync
- Edit CLAUDE.md once
- All AI assistants see the update immediately
- No sync commands or scripts needed

### Single Source of Truth
- One file to maintain
- No duplicate content
- No synchronization bugs

### Git-Friendly
- Commit symlinks once during setup
- Never falls out of sync
- Works across all platforms (Unix, macOS, Windows with git)

### Cross-Platform Compatibility
- Symlinks work on all Unix-like systems
- Git preserves symlinks across clones
- Windows users with Git for Windows get automatic support

## Workflow

### Regular Development

Just edit CLAUDE.md directly:

```bash
# Edit the source of truth
vim CLAUDE.md

# GEMINI.md and AGENTS.md automatically reflect changes
```

### Verifying Symlinks

Check that symlinks are correctly configured:

```bash
# List files showing symlinks
ls -la | grep -E "(GEMINI|AGENTS).md"

# Should output:
# GEMINI.md -> CLAUDE.md
# AGENTS.md -> CLAUDE.md

# Check what a symlink points to
readlink GEMINI.md
# Output: CLAUDE.md
```

### Manual Summarizing

When documentation grows too large:

```bash
# Archive old changelogs and create clean version
/sum

# Results:
# - Archives to: backups/CLAUDE-[timestamp].md
# - Creates clean: CLAUDE.md (without old changelogs)
# - Symlinks continue to work automatically
```

## Setting Up Symlinks

### Automatic Setup (Recommended)

Use the `/init` command for complete automation:

```bash
cd ~/projects/my-new-project
# In Claude Code:
/init

# Automatically creates:
# - CLAUDE.md with project analysis
# - GEMINI.md -> CLAUDE.md
# - AGENTS.md -> CLAUDE.md
# - Git repository with GitHub remote
# - Hourly backup integration
```

### Manual Setup

If you need manual control:

```bash
cd ~/projects/my-new-project

# Create CLAUDE.md first
vim CLAUDE.md

# Create symlinks (relative paths)
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md

# Verify symlinks
ls -la | grep -E "(GEMINI|AGENTS).md"

# Add to git
git add CLAUDE.md GEMINI.md AGENTS.md
git commit -m "docs: Add multi-AI documentation with symlinks"
```

## Git Integration

### Committing Symlinks

Git tracks symlinks as special files:

```bash
# Git sees the symlink, not the target file
git add GEMINI.md AGENTS.md

# Commit preserves the symlink relationship
git commit -m "docs: Add AI assistant symlinks"

# Symlinks work correctly after clone
git clone <repo>
ls -la | grep -E "(GEMINI|AGENTS).md"
# Still shows: GEMINI.md -> CLAUDE.md
```

### .gitignore Configuration

Ensure backups directory is excluded:

```bash
# Add to .gitignore
echo "backups/" >> .gitignore
git add .gitignore
git commit -m "chore: Ignore documentation backups"
```

## Working with Multiple AI Tools

### Using with Claude Code

Claude Code automatically reads CLAUDE.md from your project root:

```bash
# Start Claude Code in your project
claude

# Claude sees your CLAUDE.md automatically
```

### Using with Google Gemini

Google Gemini looks for GEMINI.md:

```bash
# Your GEMINI.md symlink ensures it reads CLAUDE.md
# No special configuration needed
```

### Using with Other AI Tools

Most AI tools check for AGENTS.md or similar:

```bash
# AGENTS.md symlink covers other AI assistants
# Works with GitHub Copilot, Cursor, etc.
```

## Troubleshooting

### Broken Symlinks

If symlinks break:

```bash
# Check if symlink exists
ls -la GEMINI.md

# If broken, recreate it
rm GEMINI.md
ln -s CLAUDE.md GEMINI.md

# Verify
readlink GEMINI.md
```

### Symlinks Not Working

On some systems, symlinks may need special handling:

```bash
# Check git config for symlink support
git config --get core.symlinks

# Enable if disabled (macOS/Linux)
git config core.symlinks true

# On Windows, may need Developer Mode or admin privileges
```

### Git Shows Symlink as Modified

If git shows symlinks as modified when they haven't changed:

```bash
# Check symlink target
readlink GEMINI.md

# Should output: CLAUDE.md
# If it shows full path, recreate with relative path:
rm GEMINI.md
ln -s CLAUDE.md GEMINI.md  # Relative, not absolute
```

## Best Practices

### Always Use Relative Paths

```bash
# Good - relative path
ln -s CLAUDE.md GEMINI.md

# Bad - absolute path
ln -s /full/path/to/CLAUDE.md GEMINI.md
```

Relative paths work across different systems and clone locations.

### Don't Edit Symlinks Directly

```bash
# Good - edit source
vim CLAUDE.md

# Bad - editing symlink (works but confusing)
vim GEMINI.md  # Actually edits CLAUDE.md
```

Always edit CLAUDE.md to make intentions clear.

### Test Symlinks After Setup

```bash
# Verify they work
ls -la | grep ".md"
readlink GEMINI.md
cat GEMINI.md  # Should show CLAUDE.md content
```

### Keep Symlinks in Git

```bash
# Always commit symlinks
git add GEMINI.md AGENTS.md
git commit -m "docs: Add AI assistant symlinks"

# Don't add symlinks to .gitignore
```

## Migration from Copy-Based System

If you previously used file copying:

```bash
# Remove old copies
rm GEMINI.md AGENTS.md

# Create symlinks
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md

# Remove sync commands from workflow
# (No longer needed with symlinks)

# Commit the change
git add GEMINI.md AGENTS.md
git commit -m "refactor: Switch from copies to symlinks for AI docs"
```

## Platform-Specific Notes

### macOS/Linux
- Symlinks work natively
- No special configuration needed
- Standard `ln -s` command

### Windows
- Git for Windows supports symlinks
- May need Developer Mode enabled
- Works in WSL without issues
- Some limitations in Command Prompt/PowerShell

### Cross-Platform Teams
- Git preserves symlinks correctly
- Works seamlessly across platforms
- No platform-specific workarounds needed
