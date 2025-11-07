# Best Practices for Claude Code Documentation

This guide provides recommendations for maintaining high-quality documentation across all projects using the Claude Code global configuration system.

## Changelog Entry Guidelines

When documenting changes in project CLAUDE.md files:

- **Be specific**: Include file paths and line numbers
  - Good: "Updated authentication logic in `src/auth.py:45-67`"
  - Bad: "Fixed auth stuff"

- **Explain why**: Not just what changed, but why it matters
  - Good: "Switched to bcrypt for password hashing to improve security against rainbow table attacks"
  - Bad: "Changed password hashing"

- **Include impact**: How does this affect the project?
  - Good: "This change requires users to reset their passwords on next login"
  - Bad: "Updated password system"

- **Use examples**: Show concrete examples when helpful
  ```python
  # Before
  hash = md5(password)

  # After
  hash = bcrypt.hashpw(password, bcrypt.gensalt())
  ```

- **Keep it concise**: 3-5 bullet points is usually enough
  - Focus on the most important changes
  - Link to detailed documentation if needed
  - Avoid walls of text

## Git Workflow

Standard workflow for making changes with documentation:

```bash
# 1. Make changes to your code
vim src/api.py

# 2. Document changes in CLAUDE.md
vim CLAUDE.md

# 3. Commit everything together
git add .
git commit -m "feat: Add user authentication"
git push
```

**Commit message conventions:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks

## Backup Management

Best practices for working with the backup system:

- **Backups live in `backups/` directory** (gitignored)
- **Never deleted automatically** - manual cleanup only
- **Can reference historical context anytime**
  ```bash
  # Find when a feature was added
  grep -r "user authentication" backups/
  ```
- **Organized by timestamp** (YYYY-MM-DD-HH-MM-SS)
  - Easy to find specific points in time
  - Chronological browsing supported

## Documentation Maintenance

Keep documentation lean and useful:

1. **Use `/sum` command monthly** or when docs exceed 500 lines
   - Prevents documentation bloat
   - Archives old changelogs while preserving them
   - Creates clean, scannable current docs

2. **Link to detailed docs** instead of repeating information
   - Keep main CLAUDE.md as a quick reference
   - Put detailed explanations in separate files
   - Use relative links: `[detailed info](docs/details.md)`

3. **Update cross-references** when moving or renaming files
   - Check all documentation files for broken links
   - Update project references in global `docs/projects.md`

4. **Document decisions, not just changes**
   - Why was this approach chosen?
   - What alternatives were considered?
   - What are the tradeoffs?

## Multi-Project Workflows

When working across multiple projects:

1. **Use `/log` at end of each session** to document Claude's work
   - Updates project CLAUDE.md with details
   - Updates global docs/projects.md with summary
   - Maintains cross-project awareness

2. **Check interconnections** before moving files
   - Consult `docs/interconnections.md`
   - Search for hardcoded paths
   - Test affected automation after changes

3. **Use graveyard** for uncertain deletions
   - 6-month safety net for "might need later" files
   - Prevents cluttering active projects
   - Easy to reference if needed

## Security Best Practices

When working with sensitive operations:

1. **Email Testing Policy** (see User Preferences)
   - Always test to joshua@elevatedtrading.com only
   - Comment out production recipients
   - Add TODO comments for production deployment

2. **Credentials Management**
   - Never commit credentials to git
   - Use environment variables or secure files
   - Document credential locations in project CLAUDE.md

3. **API Keys and Tokens**
   - Store in gitignored files (.env, credentials.json)
   - Document required environment variables
   - Provide example files (.env.example)

## Project Initialization

When starting a new project:

1. **Prefer `/init` command** for full automation
   - Analyzes codebase automatically
   - Creates all documentation files
   - Sets up git and GitHub
   - Adds to automated backups

2. **Only use manual setup** when customization needed
   - See `docs/setup.md` for manual steps
   - Useful for non-standard project structures

3. **Verify symlinks** after initialization
   ```bash
   ls -la | grep -E "(GEMINI|AGENTS).md"
   # Should show: GEMINI.md -> CLAUDE.md
   ```

## Debugging and Troubleshooting

When things go wrong:

1. **Check automation status first**
   ```bash
   # LaunchAgents
   launchctl list | grep user

   # Cron jobs
   crontab -l

   # Recent logs
   tail -f ~/scripts/logs/*.log
   ```

2. **Verify permissions** in settings.json
   - Check auto-approved operations
   - Add new patterns if needed
   - Test with dry run when possible

3. **Consult troubleshooting guide**
   - See `docs/troubleshooting.md` for common issues
   - Check interconnections for dependency issues
   - Review recent changelog for related changes

## Code Quality

Maintain high standards:

1. **Test before committing**
   - Run test suite if available
   - Test critical paths manually
   - Verify automation still works

2. **Document breaking changes clearly**
   - Note required migrations
   - List affected dependencies
   - Provide upgrade instructions

3. **Keep dependencies updated**
   - Document version requirements
   - Note incompatibilities
   - Test thoroughly after updates
