# Manual Project Setup Guide

This guide covers manual setup for new projects. **Recommended: Use `/init` command instead** for full automation.

## When to Use Manual Setup

Manual setup is useful when:
- You need custom project structure
- You want fine-grained control over initialization
- You're setting up a non-standard project type
- You want to understand the setup process in detail

For standard projects, `/init` is faster and more reliable.

## Prerequisites

Before starting:

```bash
# Ensure you have required tools
which git     # Git version control
which gh      # GitHub CLI
which claude  # Claude Code

# Verify GitHub authentication
gh auth status
```

## Step-by-Step Manual Setup

### 1. Navigate to Project Directory

```bash
cd ~/projects/my-new-project

# Or create a new directory
mkdir ~/projects/my-new-project
cd ~/projects/my-new-project
```

### 2. Create CLAUDE.md Documentation

Create the main documentation file:

```bash
# Create with basic structure
cat > CLAUDE.md << 'EOF'
# Project Name

## Overview

Brief description of what this project does.

## Architecture

Key components and how they work together.

## Setup

Installation and configuration instructions.

## Development

How to run, test, and develop locally.

## Deployment

Production deployment process.

## Changelog

### YYYY-MM-DD - Initial Setup
- Created project structure
- Added documentation
EOF
```

### 3. Create AI Assistant Symlinks

Create symlinks for multi-AI support:

```bash
# Create symlinks (relative paths)
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md

# Verify symlinks
ls -la | grep -E "(GEMINI|AGENTS).md"

# Expected output:
# GEMINI.md -> CLAUDE.md
# AGENTS.md -> CLAUDE.md
```

### 4. Configure .gitignore

Set up git ignore rules:

```bash
# Create or append to .gitignore
cat >> .gitignore << 'EOF'

# Claude Code documentation backups
backups/

# Environment files
.env
.env.local
credentials.json

# OS files
.DS_Store
Thumbs.db
EOF
```

### 5. Initialize Git Repository

Set up version control:

```bash
# Initialize git
git init

# Add files
git add .

# Initial commit
git commit -m "Initial commit: Project setup with documentation"
```

### 6. Create GitHub Repository

Create remote repository:

```bash
# Create private GitHub repo and push
gh repo create my-new-project --private --source=. --remote=origin --push

# Verify remote
git remote -v
```

### 7. Add to Automated Backups

Integrate with backup system:

```bash
# Open backup script
vim ~/scripts/gitBackup.sh

# Add your project to the REPOS array
# Find the line with REPOS=( and add:
#   "/Users/joshuabrown/projects/my-new-project"

# Save and commit the backup script change
cd ~/scripts
git add gitBackup.sh
git commit -m "Add my-new-project to automated backups"
git push
```

### 8. Verify Setup

Test that everything works:

```bash
# Return to your project
cd ~/projects/my-new-project

# Check git status
git status

# Verify symlinks
readlink GEMINI.md  # Should output: CLAUDE.md

# Check GitHub remote
gh repo view

# Test backup manually (if desired)
cd ~/scripts
./gitBackup.sh
```

## Project-Specific Customizations

### Python Projects

```bash
# Add Python-specific files
cat > requirements.txt << 'EOF'
# Add your dependencies here
EOF

# Update .gitignore
cat >> .gitignore << 'EOF'

# Python
__pycache__/
*.py[cod]
*$py.class
.Python
venv/
env/
EOF
```

### Node.js Projects

```bash
# Add Node.js-specific files
npm init -y

# Update .gitignore
cat >> .gitignore << 'EOF'

# Node.js
node_modules/
npm-debug.log
yarn-error.log
.env.local
EOF
```

### Docker Projects

```bash
# Add Docker files
touch Dockerfile docker-compose.yml

# Update .gitignore
cat >> .gitignore << 'EOF'

# Docker
.docker/
EOF
```

## Advanced Configuration

### Custom Slash Commands

Create project-specific commands:

```bash
# Create commands directory
mkdir -p .claude/commands

# Create custom command
cat > .claude/commands/custom.md << 'EOF'
# Custom Command

This command does something specific to this project.

## Steps
1. First step
2. Second step
EOF
```

### Project-Specific Settings

Override global settings:

```bash
# Create local settings
mkdir -p .claude
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "auto_approve": [
      "Read(src/**/*)",
      "Bash(npm run test:*)"
    ]
  }
}
EOF
```

### Custom Git Hooks

Add project-specific hooks:

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run tests before commit
npm run test
EOF

chmod +x .git/hooks/pre-commit
```

## Troubleshooting Manual Setup

### Git Init Fails

```bash
# If directory already has .git
rm -rf .git
git init
```

### GitHub Remote Issues

```bash
# If remote already exists
git remote remove origin
gh repo create my-new-project --private --source=. --remote=origin --push

# If repo already exists on GitHub
gh repo view owner/my-new-project  # Check if exists
# Either delete from GitHub or use different name
```

### Symlink Problems

```bash
# If symlinks don't work
rm GEMINI.md AGENTS.md
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md

# On Windows, may need admin privileges or Developer Mode
```

### Backup Integration Issues

```bash
# Verify backup script syntax
cd ~/scripts
bash -n gitBackup.sh  # Check for syntax errors

# Test manually
./gitBackup.sh

# Check logs
tail -f logs/git-backup.log
```

## Comparison: Manual vs `/init`

| Aspect | Manual Setup | `/init` Command |
|--------|-------------|----------------|
| Time | 10-15 minutes | 1-2 minutes |
| Steps | 8+ manual steps | 1 command |
| Errors | Prone to typos | Automated checks |
| Customization | Full control | Standard setup |
| Documentation | Manual writing | AI-generated analysis |
| Backup Integration | Manual editing | Automatic |
| Learning | Understand each step | Black box |

**Recommendation**: Use `/init` for 95% of projects, manual setup only when you need custom configuration.

## Quick Reference

### Minimal Setup (No GitHub)

```bash
cd ~/projects/my-project
echo "# My Project" > CLAUDE.md
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md
git init
git add .
git commit -m "Initial commit"
```

### Full Setup (With GitHub and Backups)

```bash
cd ~/projects/my-project
vim CLAUDE.md  # Write documentation
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md
echo "backups/" > .gitignore
git init
git add .
git commit -m "Initial commit: Project setup"
gh repo create my-project --private --source=. --remote=origin --push
vim ~/scripts/gitBackup.sh  # Add to REPOS array
cd ~/scripts && git add gitBackup.sh && git commit -m "Add my-project to backups" && git push
```

### Using `/init` Instead

```bash
cd ~/projects/my-project
# In Claude Code:
/init
# Done! Everything automated.
```

## Next Steps

After setup is complete:

1. **Document your project** - Fill out CLAUDE.md sections
2. **Start developing** - Begin writing code
3. **Use `/log` command** - Document changes at end of sessions
4. **Run `/sum` monthly** - Keep documentation lean
5. **Reference this guide** - For future manual setups if needed

For most projects, remember: **`/init` is your friend!**
