---
description: Advanced documentation optimization with analysis and archiving
gitignored: true
---

# Documentation Optimizer Skill

An enhanced version of `/sum` that not only archives changelogs but also analyzes documentation health, suggests improvements, and generates comprehensive reports.

## Core Functions

### 1. Documentation Analysis

**First, analyze the current documentation:**
```bash
# Get basic metrics
lines=$(wc -l < CLAUDE.md)
sections=$(grep "^##" CLAUDE.md | wc -l)
changelog_lines=$(sed -n '/## Version History\|## Changelog\|## Changes/,$ p' CLAUDE.md | wc -l)

# Check for required sections
has_overview=$(grep -q "^## Overview" CLAUDE.md && echo "yes" || echo "no")
has_structure=$(grep -q "^## Directory Structure\|^## Structure" CLAUDE.md && echo "yes" || echo "no")
has_quickstart=$(grep -q "^## Quick Start\|^## Getting Started" CLAUDE.md && echo "yes" || echo "no")
```

**Generate analysis report:**
```
📊 Documentation Analysis Report
================================
File: CLAUDE.md
Total Lines: [lines]
Sections: [sections]
Changelog Size: [changelog_lines] lines ([percentage]% of document)

Structure Analysis:
- Overview Section: [✓/✗]
- Directory Structure: [✓/✗]
- Quick Start Guide: [✓/✗]
- Version Requirements: [✓/✗]
- Testing Instructions: [✓/✗]

Recommendations:
[Based on analysis, suggest specific improvements]
```

### 2. Intelligent Archiving

**Create smart archives with metadata:**
```bash
# Create backups directory
mkdir -p backups

# Generate rich filename with context
timestamp=$(date "+%Y%m%d-%H%M%S")
version=$(grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" CLAUDE.md | head -1 || echo "v1.0.0")
archive_name="backups/CLAUDE-${version}-${timestamp}.md"

# Add metadata header to archive
{
  echo "<!--"
  echo "Archived: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Original Size: $(wc -l < CLAUDE.md) lines"
  echo "Reason: Documentation optimization"
  echo "Version: $version"
  echo "-->"
  echo ""
  cat CLAUDE.md
} > "$archive_name"
```

### 3. Generate Table of Contents

**Auto-generate TOC for documentation:**
```markdown
## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Version History](#version-history)
```

### 4. Documentation Coverage Report

**Check documentation completeness:**
```bash
# For code projects, check if key files are documented
coverage_report=""

# Check for README
[ -f "README.md" ] && coverage_report+="✓ README.md exists\n" || coverage_report+="✗ README.md missing\n"

# Check for API documentation
[ -d "docs/api" ] && coverage_report+="✓ API documentation\n" || coverage_report+="✗ API documentation missing\n"

# Check for examples
[ -d "examples" ] && coverage_report+="✓ Examples directory\n" || coverage_report+="✗ Examples missing\n"

# Check for contributing guide
[ -f "CONTRIBUTING.md" ] && coverage_report+="✓ Contributing guide\n" || coverage_report+="✗ Contributing guide missing\n"
```

### 5. Optimize Documentation Structure

**Create optimized version with improvements:**

1. **Remove redundancy** - Identify and eliminate duplicate information
2. **Consolidate changelogs** - Move old entries to archive, keep recent 3-5 entries
3. **Improve formatting** - Ensure consistent markdown formatting
4. **Add missing sections** - Insert templates for missing required sections
5. **Update links** - Verify and fix broken internal links

### 6. Generate Documentation Metrics

```markdown
## Documentation Metrics

### Readability Score
- **Flesch Reading Ease**: [Score]
- **Average Sentence Length**: [Words]
- **Complex Terms**: [Count]

### Completeness Score
- **Required Sections**: [X/10]
- **Code Examples**: [Present/Missing]
- **External Links**: [Valid/Broken]

### Maintenance Score
- **Last Updated**: [Days ago]
- **Update Frequency**: [Updates per month]
- **Contributors**: [Count]
```

## Implementation

When user invokes this skill:

1. **Analyze** current documentation structure and content
2. **Report** findings with specific metrics and recommendations
3. **Archive** existing documentation with rich metadata
4. **Optimize** by removing old changelog entries and redundancy
5. **Enhance** by adding missing sections from templates
6. **Generate** table of contents and coverage report
7. **Create** new lean version with improvements
8. **Validate** all links and references
9. **Report** size reduction and improvements made

## Output Format

```
📚 Documentation Optimization Complete
=====================================

📊 Analysis Results:
- Original: 523 lines
- Optimized: 142 lines (72% reduction)
- Archive: backups/CLAUDE-v2.1.0-20251114-121543.md

✅ Improvements Made:
- Archived 12 changelog entries
- Added table of contents
- Fixed 3 broken links
- Added missing Testing section
- Consolidated redundant configuration info

📈 Documentation Health:
- Coverage: 85% → 95%
- Readability: Good
- Structure: Optimal
- Freshness: Current

💡 Recommendations:
1. Add more code examples in workflows.md
2. Update troubleshooting with recent issues
3. Consider adding API documentation

📁 Files Modified:
- CLAUDE.md (optimized)
- docs/changelog.md (updated)
- backups/CLAUDE-[timestamp].md (created)
```

## Advanced Features

### Batch Processing
Process multiple projects at once:
```bash
for dir in ~/projects/*/; do
  if [ -f "$dir/CLAUDE.md" ]; then
    echo "Optimizing $dir"
    # Run optimization
  fi
done
```

### Scheduled Optimization
Suggest cron job for monthly optimization:
```bash
0 0 1 * * cd ~/projects && ~/.claude/skills/doc-optimizer.sh
```

### Integration with Dashboard
Update dashboard after optimization to reflect new metrics.

## Error Handling

- If no CLAUDE.md exists, offer to create one with `/init`
- If already optimized (< 150 lines), skip optimization
- If no changelog found, skip changelog archiving
- Always create backup before making changes

## Success Criteria

- Documentation remains complete but becomes more concise
- All essential information preserved
- Old changelog entries safely archived
- Improved readability and structure
- Generated metrics and reports
- No broken links or references