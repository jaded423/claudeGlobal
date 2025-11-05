---
description: Compact AI docs by archiving changelogs and creating clean versions
---

This command creates lean versions of AI documentation files by removing changelog history while preserving essential information. Works with any project type (Python, SQL, Neovim, web apps, etc.).

**Instructions:**

1. **Create backups directory if it doesn't exist**:
   ```bash
   mkdir -p backups
   ```

2. **Archive current documentation with timestamp**:
   - Generate timestamp in format: YYYY-MM-DD-HH-MM-SS
   - Copy only the source of truth to backups/:
     - `CLAUDE.md` → `backups/CLAUDE-[timestamp].md`
   - (No need to backup GEMINI.md or AGENTS.md since they're just copies)

3. **Create compacted version of CLAUDE.md**:
   - **Keep essential sections** (project-specific, but typically includes):
     - Project/Repository Overview
     - Setup/Installation instructions
     - Architecture/Structure
     - Development workflow
     - Testing/Running commands
     - Configuration details
     - Troubleshooting
     - Important files and their purposes
     - Resources/Links
   - **Remove or minimize**:
     - Any section named "Major Updates", "Changes", "Changelog", "Recent Updates", "Update History", or similar
     - Detailed changelog entries with dates
     - Historical explanations of why certain decisions were made
     - Verbose descriptions of past features/changes
   - **Keep the structure lean**: Remove verbose explanations that are now outdated
   - **Preserve**: The "Multi-AI Documentation Setup" header at the top (if it exists)

4. **Report results**:
   - Show backup location and filenames
   - Confirm compacted file created
   - Show size reduction (old vs new)
   - List what was removed (number of lines, sections)

**Example output:**
```
📦 Archived old documentation:
   ✅ backups/CLAUDE-2025-10-31-14-30-45.md (125 KB)

✂️  Compacted CLAUDE.md:
   - Removed "Major Updates" section (50+ lines)
   - Removed "Recent Changes" section (30+ lines)
   - Kept essential structure and commands
   - New size: 82 KB (saved 43 KB)

CLAUDE.md is now lean and ready! /sync-ai-docs will copy it to other files.
```

**Notes:**
- Backups are never deleted automatically
- You can always refer to backups/ for historical context
- This command is automatically run by /sync-ai-docs on the first day of each month
- Only compacts CLAUDE.md - syncing to other files is handled by /sync-ai-docs
- Works in any project directory that has a CLAUDE.md file
