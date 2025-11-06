# /log - Document Session Changes

You are autonomously documenting what **you (Claude)** did during this session.

## Context

The user has a multi-layered documentation system:
- **Project CLAUDE.md** - Detailed project-specific documentation with changelog
- **Global ~/.claude/CLAUDE.md** - Overview of global Claude Code system
- **Global ~/.claude/docs/projects.md** - Detailed descriptions of all projects
- Each project should be cross-referenced so global Claude knows what each project needs

**Important**: This command is for documenting **Claude's changes**, not the user's manual work. The user documents their own changes. You document what you did.

## Your Task

1. **Analyze what YOU did this session**
   - Review git changes if in a git repo: `git status`, `git diff`
   - Recall what files YOU created, modified, or deleted
   - Consider bash commands YOU ran
   - Identify the nature of YOUR changes (features, fixes, configuration, documentation)

2. **Determine current project context**
   - Identify which project we're in (e.g., ~/scripts, ~/projects/nvimConfig)
   - Check if a CLAUDE.md exists in the current directory
   - Identify the project name for global docs reference

3. **NO questions - autonomous summary**
   DO NOT ask the user what changed. You know what you did.
   Autonomously summarize based on:
   - Files you wrote/edited
   - Commands you ran
   - Problems you solved
   - Features you implemented

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
   After updating documentation, show:
   ```
   📝 Session documented:

   Local changes:
   - ~/path/to/project/CLAUDE.md - Added changelog entry

   Global changes:
   - ~/.claude/docs/projects.md - Updated [project-name] section

   Note: Changes saved locally. Your hourly backup will commit with AI-generated message.
   ```

## Important Guidelines

**Be autonomous:**
- NO questions - you know what you did during the session
- Summarize YOUR work (files created/edited, commands run, problems solved)
- Keep changelog entries focused on impact, not implementation details
- User wants quick, accurate logging of Claude's work

**Cross-reference:**
- Link between project and global docs where relevant
- Ensure global docs accurately reflect current project capabilities
- Maintain consistency in terminology across all docs

**Date format:**
- Always use YYYY-MM-DD format
- Include date in all changelog entries

**No auto-commit:**
- Documentation changes are saved to files only
- Hourly backup script handles ALL git commits with AI-generated messages
- This allows multiple sessions' changes to accumulate for better AI context
- User's backup automation will commit and push automatically

**Handle edge cases:**
- If no CLAUDE.md in project: offer to create one (brief)
- If project not in docs/projects.md: offer to add it
- If working in global .claude directory: only update global docs

## Example Workflow

```
User runs /log in ~/scripts

You (autonomous):
1. Check git status - see dotfiles_backup.sh was modified
2. Recall: I added "Claude Global" to REPOS array
3. Write to ~/scripts/CLAUDE.md:
   ### 2025-11-05 - Added Claude Global to Automated Backups
   **Changes:**
   - Added ~/.claude to REPOS array (line 14)
   - Now backing up 6 repositories hourly
   ...
4. Update ~/.claude/docs/projects.md scripts section:
   **Last Updated:** 2025-11-05
   **Recent Changes:** Added Claude Global config to backup system
5. Show summary to user (changes saved, will be committed by hourly backup)
```

**Another example** - working in ~/.claude directory:
```
User runs /log in ~/.claude after creating /log command

You:
1. See new files: commands/log.md, docs/project-logs/README.md
2. See modified: CLAUDE.md
3. Write to ~/.claude/CLAUDE.md changelog (it documents itself)
4. Update docs/projects.md if needed
5. Show summary (no commit - let hourly backup handle it)
```

Now proceed with logging this session's changes.
