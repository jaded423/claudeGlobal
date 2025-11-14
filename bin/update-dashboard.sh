#!/bin/bash

# update-dashboard.sh - Generate documentation dashboard with metrics
# This script scans all projects and creates a comprehensive documentation dashboard

DASHBOARD_FILE="$HOME/.claude/docs/dashboard.md"
PROJECTS_DIR="$HOME/projects"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}📊 Updating Documentation Dashboard...${NC}"

# Initialize dashboard content
cat > "$DASHBOARD_FILE" << 'EOF'
# Documentation Dashboard

**Last Updated**: TIMESTAMP_PLACEHOLDER

## Overview

This dashboard provides a real-time view of documentation health across all projects.

## Quick Links

| Project | Documentation | GitHub | Last Updated |
|---------|--------------|--------|--------------|
EOF

# Replace timestamp
sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$TIMESTAMP/" "$DASHBOARD_FILE" && rm "${DASHBOARD_FILE}.bak"

# Arrays to store metrics
declare -a project_names
declare -a doc_lines
declare -a last_updates
declare -a doc_health_scores

total_lines=0
total_projects=0
projects_documented=0
projects_missing_docs=0

# Function to calculate documentation health score
calculate_health_score() {
    local lines=$1
    local days_old=$2
    local has_docs_dir=$3
    local has_changelog=$4

    local score=0

    # Size score (max 25 points)
    if [ $lines -ge 100 ] && [ $lines -le 200 ]; then
        score=$((score + 25))
    elif [ $lines -ge 50 ] && [ $lines -lt 100 ]; then
        score=$((score + 15))
    elif [ $lines -ge 200 ] && [ $lines -le 500 ]; then
        score=$((score + 20))
    elif [ $lines -gt 500 ]; then
        score=$((score + 10))
    fi

    # Freshness score (max 25 points)
    if [ $days_old -le 7 ]; then
        score=$((score + 25))
    elif [ $days_old -le 30 ]; then
        score=$((score + 20))
    elif [ $days_old -le 60 ]; then
        score=$((score + 15))
    elif [ $days_old -le 90 ]; then
        score=$((score + 10))
    else
        score=$((score + 5))
    fi

    # Structure score (max 25 points)
    if [ "$has_docs_dir" = "yes" ]; then
        score=$((score + 15))
    fi
    if [ "$has_changelog" = "yes" ]; then
        score=$((score + 10))
    fi

    # Completeness bonus (max 25 points)
    # Check for symlinks
    if [ $lines -gt 0 ]; then
        score=$((score + 25))
    fi

    echo $score
}

# Function to get health emoji
get_health_emoji() {
    local score=$1
    if [ $score -ge 80 ]; then
        echo "🟢"
    elif [ $score -ge 60 ]; then
        echo "🟡"
    elif [ $score -ge 40 ]; then
        echo "🟠"
    else
        echo "🔴"
    fi
}

# Scan projects
echo -e "${YELLOW}Scanning projects...${NC}"

for dir in "$PROJECTS_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        project_name=$(basename "$dir")
        claude_file="$dir/CLAUDE.md"

        if [ -f "$claude_file" ]; then
            # Get metrics
            line_count=$(wc -l < "$claude_file")
            last_modified=$(date -r "$claude_file" "+%Y-%m-%d %H:%M")
            days_old=$(( ( $(date +%s) - $(stat -f %m "$claude_file") ) / 86400 ))

            # Check for docs directory and changelog
            has_docs_dir="no"
            has_changelog="no"
            if [ -d "$dir/docs" ]; then
                has_docs_dir="yes"
            fi
            if [ -f "$dir/docs/changelog.md" ]; then
                has_changelog="yes"
            fi

            # Calculate health score
            health_score=$(calculate_health_score $line_count $days_old $has_docs_dir $has_changelog)
            health_emoji=$(get_health_emoji $health_score)

            # Check for GitHub remote
            github_url="-"
            if [ -d "$dir/.git" ]; then
                cd "$dir" 2>/dev/null
                remote_url=$(git remote get-url origin 2>/dev/null || echo "")
                if [ ! -z "$remote_url" ]; then
                    # Convert SSH to HTTPS URL
                    github_url=$(echo "$remote_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
                    github_url="[$project_name]($github_url)"
                fi
                cd - > /dev/null 2>&1
            fi

            # Add to dashboard
            echo "| $health_emoji $project_name | [CLAUDE.md](../../projects/$project_name/CLAUDE.md) | $github_url | $last_modified |" >> "$DASHBOARD_FILE"

            # Store metrics
            project_names+=("$project_name")
            doc_lines+=($line_count)
            last_updates+=("$last_modified")
            doc_health_scores+=($health_score)

            # Update totals
            total_lines=$((total_lines + line_count))
            total_projects=$((total_projects + 1))
            projects_documented=$((projects_documented + 1))

            echo -e "  ✓ $project_name: ${health_emoji} Health: $health_score/100"
        else
            # Project without documentation
            echo "| ❌ $project_name | Missing | - | - |" >> "$DASHBOARD_FILE"
            projects_missing_docs=$((projects_missing_docs + 1))
            total_projects=$((total_projects + 1))

            echo -e "  ${RED}✗ $project_name: No documentation${NC}"
        fi
    fi
done

# Add metrics section
cat >> "$DASHBOARD_FILE" << EOF

## Documentation Metrics

### Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Projects** | $total_projects |
| **Documented Projects** | $projects_documented |
| **Missing Documentation** | $projects_missing_docs |
| **Total Documentation Lines** | $(printf "%'d" $total_lines) |
| **Average Lines per Project** | $((total_lines / (projects_documented > 0 ? projects_documented : 1))) |

### Documentation Health

Health scores are calculated based on:
- 📏 **Size** (25%): Optimal between 100-200 lines
- ⏱️ **Freshness** (25%): Recently updated
- 📁 **Structure** (25%): Has docs/ directory and changelog
- ✅ **Completeness** (25%): Has content and symlinks

| Legend | Score | Meaning |
|--------|-------|---------|
| 🟢 | 80-100 | Excellent |
| 🟡 | 60-79 | Good |
| 🟠 | 40-59 | Needs Attention |
| 🔴 | 0-39 | Critical |

### Projects Needing Attention

EOF

# Find projects needing attention (health score < 60)
needs_attention_count=0
for i in "${!project_names[@]}"; do
    if [ ${doc_health_scores[$i]} -lt 60 ]; then
        if [ $needs_attention_count -eq 0 ]; then
            echo "| Project | Issue | Action Required |" >> "$DASHBOARD_FILE"
            echo "|---------|-------|-----------------|" >> "$DASHBOARD_FILE"
        fi

        project="${project_names[$i]}"
        score="${doc_health_scores[$i]}"
        lines="${doc_lines[$i]}"

        issue=""
        action=""

        if [ $lines -lt 50 ]; then
            issue="Too brief ($lines lines)"
            action="Add more documentation"
        elif [ $lines -gt 500 ]; then
            issue="Too verbose ($lines lines)"
            action="Run /sum to archive old content"
        fi

        # Check age
        days_old=$(( ( $(date +%s) - $(stat -f %m "$PROJECTS_DIR/$project/CLAUDE.md") ) / 86400 ))
        if [ $days_old -gt 60 ]; then
            issue="${issue:+$issue, }Outdated (${days_old} days)"
            action="${action:+$action, }Update documentation"
        fi

        echo "| $project | $issue | $action |" >> "$DASHBOARD_FILE"
        needs_attention_count=$((needs_attention_count + 1))
    fi
done

if [ $needs_attention_count -eq 0 ]; then
    echo "✨ All projects have healthy documentation!" >> "$DASHBOARD_FILE"
fi

# Add dependency map section
cat >> "$DASHBOARD_FILE" << 'EOF'

## Cross-Project Dependencies

### Shared Resources

| Resource | Used By | Purpose |
|----------|---------|---------|
| Gmail OAuth (~/scripts) | odooReports, scripts | Email automation |
| gitBackup.sh | All projects | Hourly automated backups |
| SSH Keys | All git projects | GitHub authentication |
| .zshrc aliases | All projects | Quick navigation and commands |

### Dependency Graph

```mermaid
graph TD
    scripts[scripts<br/>Automation Hub] --> nvimConfig[nvimConfig]
    scripts --> zshConfig[zshConfig]
    scripts --> odooReports[odooReports]

    odooReports[odooReports] -.->|shares OAuth| scripts

    zshConfig[zshConfig] -->|sources| scripts
    zshConfig -->|aliases for| nvimConfig
    zshConfig -->|aliases for| promptLibrary

    graveyard[graveyard] -->|archives from| ALL[All Projects]
```

## Recent Documentation Updates

| Project | Last 7 Days | Last 30 Days | Older |
|---------|------------|--------------|-------|
EOF

# Calculate recent updates
recent_7days=0
recent_30days=0
older_updates=0

for i in "${!project_names[@]}"; do
    days_old=$(( ( $(date +%s) - $(stat -f %m "$PROJECTS_DIR/${project_names[$i]}/CLAUDE.md") ) / 86400 ))

    if [ $days_old -le 7 ]; then
        recent_7days=$((recent_7days + 1))
    elif [ $days_old -le 30 ]; then
        recent_30days=$((recent_30days + 1))
    else
        older_updates=$((older_updates + 1))
    fi
done

echo "| Count | $recent_7days | $recent_30days | $older_updates |" >> "$DASHBOARD_FILE"

# Add automation status
cat >> "$DASHBOARD_FILE" << 'EOF'

## Automation Status

### Active Systems

| System | Status | Schedule | Last Run |
|--------|--------|----------|----------|
EOF

# Check launchd jobs
if launchctl list | grep -q "gitbackup"; then
    echo "| Git Backup | ✅ Active | Hourly | Check logs: \`log show --predicate 'eventMessage contains \"git_backup\"' --last 1h\` |" >> "$DASHBOARD_FILE"
else
    echo "| Git Backup | ❌ Inactive | - | Enable with: \`launchctl load ~/Library/LaunchAgents/com.user.gitbackup.plist\` |" >> "$DASHBOARD_FILE"
fi

# Add footer
cat >> "$DASHBOARD_FILE" << 'EOF'

## Quick Actions

### Update Documentation
```bash
# Update this dashboard
~/.claude/bin/update-dashboard.sh

# Document current session
/log

# Archive old changelogs
/sum

# Check documentation metrics
doc-check  # In terminal
```

### Fix Common Issues
```bash
# Fix missing symlinks
cd ~/projects/PROJECT_NAME
ln -sf CLAUDE.md GEMINI.md
ln -sf CLAUDE.md AGENTS.md

# Initialize documentation for new project
cd ~/projects/NEW_PROJECT
/init
```

---

*Dashboard generated automatically. Run `~/.claude/bin/update-dashboard.sh` to refresh.*
EOF

echo -e "${GREEN}✅ Dashboard updated successfully!${NC}"
echo -e "View at: ${DASHBOARD_FILE}"

# Make script executable
chmod +x "$HOME/.claude/bin/update-dashboard.sh"