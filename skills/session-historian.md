---
description: Advanced session tracking with analytics and pattern recognition
gitignored: true
---

# Session Historian Skill

An enhanced version of `/log` that provides deep insights into development sessions, tracks patterns, generates comprehensive reports, and maintains a rich history of changes across time.

## Core Functions

### 1. Multi-Session Tracking

**Track changes across multiple Claude sessions:**
```bash
# Create session history directory if needed
mkdir -p ~/.claude/session-history

# Generate session ID
session_id=$(date "+%Y%m%d-%H%M%S")-$$
session_file=~/.claude/session-history/session-${session_id}.md
```

**Capture session context:**
- Current directory and project
- Active git branch
- Time of session start/end
- Files modified
- Commands executed
- Problems solved

### 2. Change Pattern Analysis

**Identify development patterns:**
```bash
# Analyze git history for patterns
git log --oneline --since="30 days ago" | grep -oE "(fix|add|update|refactor|test|docs):" | sort | uniq -c | sort -rn

# Common file modifications
git log --name-only --pretty=format: --since="30 days ago" | sort | uniq -c | sort -rn | head -10

# Peak activity times
git log --date=format:'%H' --pretty=format:'%ad' --since="30 days ago" | sort | uniq -c | sort -rn
```

**Generate insights:**
```markdown
## Development Patterns

### Activity Summary (Last 30 Days)
- **Most Common Actions**: Fixes (45%), Features (30%), Refactoring (25%)
- **Most Modified Files**: config.js (12x), README.md (8x), main.py (7x)
- **Peak Hours**: 14:00-16:00 (35% of commits)
- **Average Session Length**: 2.5 hours
```

### 3. Dependency Impact Tracking

**Track how changes affect other parts of the system:**
```bash
# Find files that import/require the changed file
changed_file="src/utils.js"
grep -r "import.*from.*utils\|require.*utils" --include="*.js" --include="*.ts"

# Identify downstream impacts
echo "Files potentially affected by changes to $changed_file:"
```

### 4. Weekly/Monthly Summaries

**Generate periodic summaries automatically:**

```markdown
## Weekly Summary - Week of [Date]

### Projects Worked On
1. **nvimConfig** (12 sessions, 34 changes)
   - Added new plugins: telescope-undo, vim-visual-multi
   - Fixed LSP configuration issues
   - Improved keybindings

2. **odooReports** (5 sessions, 15 changes)
   - Automated email notifications
   - Fixed timezone issues
   - Added error handling

### Key Achievements
- ✅ Completed authentication system refactor
- ✅ Set up automated testing pipeline
- ✅ Resolved 8 GitHub issues

### Time Tracking
- Total Development Time: 32 hours
- Most Productive Day: Wednesday (8 hours)
- Average Session: 2.3 hours

### Learning & Insights
- Discovered new Git workflow optimization
- Learned about Python async patterns
- Improved Docker debugging skills
```

### 5. Rich Change Documentation

**Create detailed change entries with context:**

```markdown
### 2025-11-14 14:30 - [MINOR] Enhanced Documentation System

**Session Context**:
- Duration: 2.5 hours
- Branch: feature/doc-improvements
- Trigger: User request for documentation assessment

**Changes Made**:
1. Created template system (3 templates)
   - `~/.claude/templates/project-claude-template.md`
   - `~/.claude/templates/changelog-entry-template.md`
   - `~/.claude/templates/troubleshooting-template.md`

2. Implemented documentation dashboard
   - `~/.claude/docs/dashboard.md`
   - `~/.claude/bin/update-dashboard.sh`

3. Enhanced slash commands
   - Updated `/init` to use templates
   - Created `/detect-context` command

**Technical Details**:
- Lines Added: 450
- Lines Removed: 23
- Files Created: 7
- Files Modified: 3

**Impact Analysis**:
- Improved documentation consistency across projects
- Reduced setup time for new projects by 70%
- Added real-time documentation health monitoring

**Follow-up Tasks**:
- [ ] Test dashboard on all projects
- [ ] Add more template variations
- [ ] Create automation for dashboard updates

**Session Metrics**:
- Commands Executed: 42
- Tokens Used: ~15,000
- Errors Encountered: 0
- Success Rate: 100%
```

### 6. Cross-Project Change Correlation

**Track related changes across multiple projects:**
```bash
# Find all projects modified today
for dir in ~/projects/*/; do
  if [ -d "$dir/.git" ]; then
    cd "$dir"
    if git log --since="1 day ago" --oneline | grep -q .; then
      echo "$(basename $dir): $(git log --since='1 day ago' --oneline | wc -l) changes"
    fi
    cd - > /dev/null
  fi
done
```

### 7. Intelligent Suggestions

**Based on session history, suggest next actions:**
```markdown
## Suggested Next Actions

Based on your recent activity patterns:

1. **Documentation Update Due**:
   - promptLibrary hasn't been updated in 15 days
   - Consider running /sum to archive old content

2. **Testing Coverage**:
   - Recent changes to auth.js lack test coverage
   - Suggested: Write unit tests for new authentication functions

3. **Dependency Updates**:
   - 5 npm packages have updates available
   - Run `npm outdated` to review

4. **Code Review**:
   - Large refactor in database.py (250+ lines)
   - Consider requesting peer review

5. **Performance Optimization**:
   - Recent sessions show increased build times
   - Consider optimizing webpack configuration
```

## Implementation Flow

When user invokes this skill:

1. **Capture Current Session**:
   - Analyze all changes made in current session
   - Check git diff, status, and recent commits
   - Record commands executed (if available from history)

2. **Load Historical Context**:
   - Read previous session files
   - Load weekly/monthly summaries
   - Check pattern database

3. **Perform Deep Analysis**:
   - Identify change patterns
   - Calculate metrics and statistics
   - Detect anomalies or issues
   - Correlate changes across projects

4. **Generate Comprehensive Report**:
   - Create detailed session entry
   - Update project CLAUDE.md with changelog
   - Add to global session history
   - Update pattern database

5. **Create Visualizations** (if applicable):
   - Activity heatmap
   - Commit frequency graph
   - Project interaction diagram

6. **Provide Actionable Insights**:
   - Suggest optimizations
   - Identify technical debt
   - Recommend next actions
   - Highlight learning opportunities

## Output Format

```
📚 Session Analysis Complete
============================

📊 Session Summary:
- Duration: 2h 45m
- Projects: 3 (nvimConfig, scripts, odooReports)
- Changes: 47 files, +1,234 lines, -456 lines
- Commits: 8

🎯 Key Accomplishments:
1. ✅ Implemented documentation dashboard
2. ✅ Created 3 new templates
3. ✅ Enhanced 2 slash commands
4. ✅ Fixed 5 bugs

📈 Productivity Metrics:
- Code Velocity: 450 lines/hour (150% of average)
- Focus Score: 92/100 (Excellent)
- Error Rate: 2% (Well below average)

🔍 Pattern Insights:
- You're most productive between 2-4 PM
- Documentation tasks take 40% less time than last month
- Your debugging speed has improved 25%

🔮 Predictions & Suggestions:
1. Based on current velocity, project will complete 2 days early
2. Consider refactoring auth module (complexity increasing)
3. Schedule documentation review for next week

📁 Documentation Updated:
- ~/projects/scripts/CLAUDE.md ✓
- ~/.claude/docs/projects.md ✓
- ~/.claude/session-history/session-20251114-143022.md ✓

🔗 Related Sessions:
- 2025-11-13: Similar template work
- 2025-11-10: Related documentation improvements
```

## Advanced Features

### Session Replay
Ability to "replay" a session by showing the sequence of changes:
```bash
# Show chronological list of changes
git log --reverse --since="2 hours ago" --oneline
```

### Collaboration Insights
If working with others, track:
- Who changed what
- Merge conflicts resolved
- Code review comments addressed

### Learning Tracker
Track new concepts, tools, or techniques learned:
```markdown
## Learning Log
- Learned about GitHub Actions matrix builds
- Discovered new vim motion: `gn` for next search match
- Implemented first WebSocket connection
```

### Error Pattern Recognition
Track and learn from errors:
```markdown
## Error Patterns
- TypeError in auth.js occurs when user object is null (3 times)
- Docker build fails when node_modules exists (2 times)
- Solution: Add node_modules to .dockerignore
```

## Data Storage

```
~/.claude/session-history/
├── sessions/
│   ├── session-20251114-143022.md
│   ├── session-20251114-091533.md
│   └── ...
├── summaries/
│   ├── weekly-2025-W46.md
│   ├── monthly-2025-11.md
│   └── ...
├── patterns/
│   ├── development-patterns.json
│   ├── error-patterns.json
│   └── productivity-metrics.json
└── index.md  # Master index of all sessions
```

## Success Criteria

- Comprehensive session documentation with zero information loss
- Pattern recognition accuracy > 80%
- Actionable suggestions provided
- Historical context preserved and searchable
- Cross-project correlations identified
- Documentation automatically updated
- Metrics tracked and visualized