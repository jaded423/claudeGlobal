---
description: Initialize comprehensive project documentation with AI-aware setup
---

# Initialize Project Documentation

This command autonomously analyzes your codebase and creates comprehensive documentation using standardized templates. It sets up git, creates a GitHub repository, and adds the project to automated backups.

## AUTONOMOUS EXECUTION - NO QUESTIONS ASKED

When the user runs `/init`, execute ALL steps automatically without asking for confirmation. The user knows what /init does and wants the complete workflow.

## Workflow Steps

### 1. Analyze Project Structure
- Scan the current directory to understand project type and structure
- Identify main technologies, frameworks, and languages
- Detect existing configuration files (package.json, requirements.txt, etc.)
- List main directories and their purposes

### 2. Create Documentation Structure
```bash
# Create docs subdirectory
mkdir -p docs

# Create base documentation files from templates
touch docs/architecture.md
touch docs/workflows.md
touch docs/troubleshooting.md
touch docs/changelog.md
```

### 3. Generate CLAUDE.md from Template
Use the template at `~/.claude/templates/project-claude-template.md` and populate:

- **{{PROJECT_NAME}}**: Use directory name or detected project name
- **{{PROJECT_DESCRIPTION}}**: Generate based on project analysis
- **{{PROJECT_PURPOSE}}**: Infer from code structure and dependencies
- **{{FEATURE_1/2/3}}**: Extract key features from codebase
- **{{MAIN_DIRECTORIES}}**: List actual directory structure
- **{{PREREQUISITES}}**: Detect from config files (Node.js version, Python version, etc.)
- **{{INSTALLATION_STEPS}}**: Generate based on package manager detected
- **{{RUN_COMMANDS}}**: Extract from package.json scripts or similar
- **{{COMMON_TASK_1/2}}**: Identify common development tasks
- **{{CONFIGURATION_DETAILS}}**: Note environment variables, config files
- **{{RUNTIME_DEPS}}**: Extract from package.json, requirements.txt, etc.
- **{{DEV_DEPS}}**: List development dependencies
- **{{OPTIONAL_DEPS}}**: Note optional features
- **{{TEST_COMMANDS}}**: Find test scripts
- **{{DEPLOYMENT_INSTRUCTIONS}}**: Infer from Dockerfile, deploy scripts
- **{{IMPORTANT_NOTES}}**: Add project-specific considerations
- **{{VERSION}}**: Use 1.0.0 or extract from package.json
- **{{LAST_UPDATED}}**: Current date
- **{{WIKI_LINK}}**: Placeholder or detected from existing docs
- **{{ISSUES_LINK}}**: Will be GitHub URL after repo creation
- **{{RELATED_PROJECTS}}**: Detect from dependencies or leave placeholder

### 4. Create Symlinks for Multi-AI Support
```bash
# Create symlinks to CLAUDE.md
ln -sf CLAUDE.md GEMINI.md
ln -sf CLAUDE.md AGENTS.md
```

### 5. Initialize Documentation Files

**docs/architecture.md**:
```markdown
# Architecture Documentation

## System Overview
[Analyzed from codebase structure]

## Component Design
[Major components identified]

## Data Flow
[How data moves through the system]

## Technology Stack
[Detected technologies]

## Design Decisions
[Inferred patterns and choices]
```

**docs/workflows.md**:
```markdown
# Development Workflows

## Setup
[Based on detected requirements]

## Development Process
[Common development tasks]

## Testing
[Test structure and commands]

## Deployment
[Deployment process if detected]
```

**docs/troubleshooting.md**:
```markdown
# Troubleshooting Guide

## Common Issues

[Populate with standard issues for detected tech stack]
```

**docs/changelog.md**:
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## Version History

### 2025-MM-DD - [MAJOR] Initial Documentation

**Changes**:
- Created comprehensive documentation structure
- Set up multi-AI documentation support
- Initialized git repository
- Created GitHub repository
- Added to automated backup system

**Impact**:
- Project now has complete documentation
- Automated hourly backups enabled
- Ready for collaborative development
```

### 6. Initialize Git Repository
```bash
# Only if not already a git repo
if [ ! -d .git ]; then
    git init
    echo "✅ Initialized git repository"
fi
```

### 7. Create Initial Commit
```bash
# Stage documentation files
git add CLAUDE.md GEMINI.md AGENTS.md docs/

# Create initial commit
git commit -m "Initial documentation setup via /init

- Created CLAUDE.md with comprehensive project documentation
- Set up multi-AI support with GEMINI.md and AGENTS.md symlinks
- Added detailed documentation in docs/ directory
- Ready for automated backups"
```

### 8. Create GitHub Repository
```bash
# Extract project name
PROJECT_NAME=$(basename "$PWD")

# Create private GitHub repository
gh repo create "$PROJECT_NAME" --private --source=. --push
```

### 9. Add to Automated Backup System
```bash
# Get the repository path
REPO_PATH="$PWD"

# Add to gitBackup.sh REPOS array
# Check if already in backup list first
if ! grep -q "$REPO_PATH" ~/scripts/bin/gitBackup.sh; then
    # Add the new repo to the REPOS array
    sed -i.bak '/^REPOS=($/a\    "'"$REPO_PATH"'"' \
        ~/scripts/bin/gitBackup.sh

    echo "✅ Added to automated hourly backup system"
fi
```

### 10. Commit and Push Backup Script Update
```bash
cd ~/scripts
git add bin/gitBackup.sh
git commit -m "Add $PROJECT_NAME to automated backup system"
git push
cd - # Return to project directory
```

### 11. Final Report
```
✅ Project Documentation Initialized!

Documentation created:
- CLAUDE.md (main documentation)
- GEMINI.md → CLAUDE.md (symlink)
- AGENTS.md → CLAUDE.md (symlink)
- docs/architecture.md
- docs/workflows.md
- docs/troubleshooting.md
- docs/changelog.md

Git setup:
- Repository initialized
- Initial commit created
- GitHub repository: github.com:username/$PROJECT_NAME (private)
- Remote added and pushed

Automation:
- Added to hourly backup system
- Backups will run every hour at :00
- Email notifications on changes

Next steps:
1. Review and refine the generated documentation
2. Update docs/architecture.md with specific design details
3. Add project-specific troubleshooting entries
4. Run '/log' at the end of work sessions to track changes
```

## Error Handling

If any step fails, report the specific error but continue with remaining steps where possible. Common issues:

- **GitHub repo exists**: Skip creation, just add remote
- **Not in a project directory**: Abort with message
- **No git installed**: Abort with installation instructions
- **No gh CLI**: Provide manual GitHub creation instructions
- **Backup script not found**: Note that manual addition needed

## Important Notes

- This command assumes the current directory is the project root
- It will not overwrite existing CLAUDE.md files (will prompt if exists)
- Symlinks use relative paths for portability
- Documentation is generated based on common patterns - manual refinement expected
- The command is idempotent - safe to run multiple times