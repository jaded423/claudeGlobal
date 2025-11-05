# /log - Document Session Changes

You are helping the user document changes made during this Claude Code session.

## Context

The user has a multi-layered documentation system:
- **Project CLAUDE.md** - Detailed project-specific documentation with changelog
- **Global ~/.claude/CLAUDE.md** - Overview of global Claude Code system
- **Global ~/.claude/docs/projects.md** - Detailed descriptions of all projects
- Each project should be cross-referenced so global Claude knows what each project needs

## Your Task

1. **Analyze what was done this session**
   - Review git changes if in a git repo: `git status`, `git diff`
   - Consider what files were created, modified, or discussed
   - Identify the nature of changes (features, fixes, configuration, documentation)

2. **Determine current project context**
   - Identify which project we're in (e.g., ~/scripts, ~/projects/nvimConfig)
   - Check if a CLAUDE.md exists in the current directory
   - Identify the project name for global docs reference

3. **Ask user for input** (be concise)
   Ask the user 1-2 focused questions:
   - "What's the main accomplishment or change from this session?"
   - If unclear: "Any important context or impact to document?"

   Keep this brief - the user wants quick logging, not an interview.

4. **Update Project CLAUDE.md** (if it exists)
   Add a detailed changelog entry following this format:

   ```markdown
   ### YYYY-MM-DD - [Brief Title]

   **Changes:**
   - [Specific change with file references if relevant]
   - [Another change]

   **Impact:**
   - [How this affects the project]
   - [What's now possible or improved]

   **Files modified:**
   - `path/to/file.ext` - [what changed]
   ```

5. **Update Global docs/projects.md**
   Find the section for the current project and:
   - Add/update a "Last Updated" line with today's date
   - Add/update a "Recent Changes" subsection with 1-2 line summary
   - Update project description if capabilities changed

   Example:
   ```markdown
   ### scripts
   **Last Updated:** 2025-11-05
   **Recent Changes:** Added Claude Global config to hourly automated backups

   [existing project description]
   ```

6. **Update Global CLAUDE.md** (only if necessary)
   Only update main global CLAUDE.md if:
   - A new project was created
   - A new global command/agent/skill was added
   - System architecture changed significantly

   For minor project updates, just updating docs/projects.md is sufficient.

7. **Summary for user**
   After updating files, show the user:
   ```
   📝 Documentation updated:

   Local changes:
   - ~/path/to/project/CLAUDE.md - Added changelog entry

   Global changes:
   - ~/.claude/docs/projects.md - Updated [project-name] section

   Would you like me to commit these documentation changes? (yes/no)
   ```

## Important Guidelines

**Be concise:**
- Don't ask unnecessary questions - infer from context when possible
- Keep changelog entries focused on impact, not implementation details
- User wants quick logging, not extensive documentation sessions

**Cross-reference:**
- Link between project and global docs where relevant
- Ensure global docs accurately reflect current project capabilities
- Maintain consistency in terminology across all docs

**Date format:**
- Always use YYYY-MM-DD format
- Include date in all changelog entries

**Git integration:**
- If user says yes to commit, create a commit with both project and global doc updates
- Use commit message: "docs: Document session changes - [brief summary]"
- Don't auto-commit without asking

**Handle edge cases:**
- If no CLAUDE.md in project: offer to create one (brief)
- If project not in docs/projects.md: offer to add it
- If working in global .claude directory: only update global docs

## Example Workflow

```
User runs /log in ~/scripts after adding a new backup repo

You:
1. Check git status - sees dotfiles_backup.sh was modified
2. Ask: "What was the main change? (I see dotfiles_backup.sh was updated)"
3. User: "Added Claude Global to automated backups"
4. Update ~/scripts/CLAUDE.md with detailed entry
5. Update ~/.claude/docs/projects.md scripts section
6. Show summary and ask about commit
7. If yes: commit both changes with appropriate message
```

Now proceed with logging this session's changes.
