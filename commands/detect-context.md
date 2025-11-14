---
description: Auto-detect machine context and suggest appropriate documentation patterns
---

# Detect Context Command

This command automatically detects which machine you're operating on and provides context-aware suggestions for documentation patterns and workflows.

## Detection Process

### 1. Detect Operating System
```bash
os_type=$(uname -s)
```

### 2. Detect Hostname
```bash
hostname=$(hostname)
```

### 3. Detect Working Directory
```bash
current_dir=$(pwd)
```

### 4. Detect User
```bash
current_user=$(whoami)
```

### 5. Detect Git Context
```bash
# Check if in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git branch --show-current)
  git_remote=$(git remote get-url origin 2>/dev/null || echo "No remote")
  git_status=$(git status --porcelain | wc -l)
  git_context="Yes"
else
  git_context="No"
fi
```

### 6. Detect Project Context
```bash
# Identify project based on current directory
project_name=$(basename "$PWD")

# Check for project-specific files
has_claude_md="No"
has_gemini_md="No"
has_agents_md="No"
has_docs_dir="No"

[ -f "CLAUDE.md" ] && has_claude_md="Yes"
[ -f "GEMINI.md" ] && has_gemini_md="Yes"
[ -f "AGENTS.md" ] && has_agents_md="Yes"
[ -d "docs" ] && has_docs_dir="Yes"
```

## Report Generation

Generate a comprehensive context report:

```markdown
🔍 Context Detection Report
============================

## Machine Context
- **Operating System**: [Darwin/Linux]
- **Hostname**: [hostname]
- **User**: [username]
- **Home Directory**: [home path]

## Location Context
- **Current Directory**: [path]
- **Project Name**: [inferred name]
- **In Git Repository**: [Yes/No]
- **Git Branch**: [branch name or N/A]
- **Uncommitted Changes**: [count]

## Documentation Context
- **CLAUDE.md Present**: [Yes/No]
- **Multi-AI Setup**: [Complete/Partial/Missing]
- **docs/ Directory**: [Yes/No]
- **Documentation Health**: [score]

## Detected Environment

[One of the following based on detection:]

### 🖥️ Work Mac Environment
You're on your primary Mac workstation.

**Documentation Pattern**:
- Edit project CLAUDE.md files directly
- Global changes: Update ~/.claude/CLAUDE.md
- Changes sync to home lab automatically (hourly)

**Available Commands**:
- `doc-check` - Check documentation status
- `doc-metrics` - View documentation metrics
- `gitall` - Check all repository statuses
- `/init` - Initialize new project documentation
- `/log` - Document current session
- `/sum` - Archive and optimize documentation

### 🐧 Home Lab Environment (Direct)
You're working directly on the CachyOS home lab server.

**Documentation Pattern**:
- Server changes: Update ~/docs/*.md
- Global changes: Update ~/.claude/CLAUDE.md
- Changes sync to Mac automatically (hourly)

**Server-Specific Context**:
- Samba shares available
- Docker services running
- Ollama models accessible

### 🔗 Remote SSH Session
You're on Mac but executing commands on the home lab via SSH.

**Documentation Pattern**:
- Document changes in ~/.claude/docs/homelab.md on Mac
- Note changes as "on home lab server (cachyos-jade)"
- Use SSH to update server docs if needed

**SSH Command Patterns**:
```bash
# Execute on server
ssh jaded@192.168.1.228 "command"

# Edit file on server
ssh jaded@192.168.1.228 "vim ~/docs/file.md"

# Copy file to server
scp local_file.md jaded@192.168.1.228:~/docs/
```

## Suggested Actions

[Based on context, provide specific suggestions:]

### If No Documentation
```bash
# Initialize documentation for this project
/init
```

### If Documentation Outdated
```bash
# Update documentation with recent changes
/log

# If documentation is too large (>500 lines)
/sum
```

### If Missing Multi-AI Setup
```bash
# Create symlinks for multi-AI support
ln -sf CLAUDE.md GEMINI.md
ln -sf CLAUDE.md AGENTS.md
```

### If Not in Git
```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit"
gh repo create --private --source=. --push
```

## Machine-Specific Tips

### Mac Tips
- Use `open .` to open Finder in current directory
- Use `code .` to open VS Code
- Use `nvim` for quick edits
- LaunchAgents handle automation

### Linux/Home Lab Tips
- Use `systemctl status` to check services
- Docker containers: `docker ps`
- Ollama models: `ollama list`
- Hyprland shortcuts available

## Quick Navigation

Based on your current location, here are relevant paths:

### From Mac:
- Projects: `cd ~/projects`
- Scripts: `cd ~/scripts`
- Claude docs: `cd ~/.claude`
- Vault: `cd ~/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My\ Drive/Elevated\ Vault`

### From Home Lab:
- Projects: `cd ~/projects`
- Docs: `cd ~/docs`
- Config: `cd ~/.config`

## Integration Points

### Current Project Dependencies:
[Analyze and list what this project depends on]

### Projects That Depend on This:
[Analyze and list what depends on this project]

### Shared Resources Used:
- OAuth credentials: [if applicable]
- Symlinks: [list any]
- Scripts: [list any]

## Documentation Recommendations

[Provide specific recommendations based on context:]

1. **Immediate Actions**:
   - [Specific action based on current state]
   - [Another relevant action]

2. **Best Practices for This Context**:
   - [Context-specific best practice]
   - [Another practice]

3. **Common Issues to Avoid**:
   - [Context-specific pitfall]
   - [Another common issue]
```

## Implementation

When user runs `/detect-context`, autonomously:

1. Run all detection commands
2. Analyze the results
3. Determine which machine/context
4. Check documentation state
5. Identify project type
6. Generate comprehensive report
7. Provide actionable suggestions
8. List relevant commands
9. Show navigation shortcuts

## Special Contexts

### Docker Container Context
If detected inside a Docker container:
```bash
if [ -f /.dockerenv ]; then
  echo "🐳 Running inside Docker container"
  # Provide Docker-specific guidance
fi
```

### VS Code Terminal Context
If detected in VS Code integrated terminal:
```bash
if [ "$TERM_PROGRAM" = "vscode" ]; then
  echo "📝 Running in VS Code terminal"
  # Provide VS Code-specific tips
fi
```

### SSH Context
If detected in SSH session:
```bash
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  echo "🔐 Running in SSH session from: $SSH_CLIENT"
  # Provide SSH-specific guidance
fi
```

### CI/CD Context
If detected in CI/CD environment:
```bash
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
  echo "🔄 Running in CI/CD pipeline"
  # Provide CI/CD-specific guidance
fi
```

## Error Handling

- If detection fails, provide generic guidance
- Always show basic context even with partial failure
- Suggest manual verification commands
- Provide fallback documentation patterns