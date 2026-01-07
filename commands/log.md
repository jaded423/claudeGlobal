# /log - Smart Documentation Logger

You are autonomously documenting what **you (Claude)** did during this session with intelligent routing.

---

## Core Principle: Claude Needs Current State, User Needs Paper Trail

**Two separate concerns:**
1. **CLAUDE.md** = What Claude needs to know NOW (current state only)
2. **docs/changelog.md** = Paper trail of everything that changed (append-only history)

**The rule:** Claude doesn't need the journey, just the destination.

---

## Documentation Structure (Create if Missing)

```
project/
├── CLAUDE.md              # Current state ONLY (target: 200-400 lines)
├── docs/
│   ├── changelog.md       # Append-only history (unlimited)
│   └── [topic].md         # Detailed reference docs
```

For global ~/.claude:
```
~/.claude/
├── CLAUDE.md              # Global config overview
├── docs/
│   ├── changelog.md       # Global changes history
│   ├── projects.md        # Project summaries
│   ├── homelab.md         # Homelab current state (lean)
│   ├── homelab/           # Homelab detailed docs
│   └── ...
```

---

## Step 1: Analyze What YOU Did

**Gather context (no questions asked):**
```bash
git status                  # What files changed
git diff --stat            # Scope of changes
```

**Recall your session work:**
- Files you created/edited
- Commands you ran
- Problems you solved
- Configurations you changed

---

## Step 2: Categorize Changes

### Category A: CURRENT STATE CHANGES → Update CLAUDE.md
Things that change "what exists now":
- ✅ New service/tool added
- ✅ IP address or port changed
- ✅ Access method changed
- ✅ New gotcha/known issue discovered
- ✅ Service removed or deprecated
- ✅ New dependency added
- ✅ Breaking change that affects how things work

**Format for CLAUDE.md updates:** Brief, factual, present-tense
```markdown
## Services
- **New:** Frigate NVR on port 5000
```
NOT: "Added Frigate NVR after troubleshooting Docker networking issues for 2 hours"

### Category B: IMPLEMENTATION DETAILS → changelog.md ONLY
Things that don't change current state:
- ❌ Bug fixes (unless they reveal a gotcha)
- ❌ How you troubleshot something
- ❌ Refactoring/cleanup
- ❌ Documentation improvements
- ❌ Configuration tweaks
- ❌ The story of how you got something working

### Category C: NEW REFERENCE MATERIAL → docs/[topic].md
Detailed how-tos or guides:
- ❌ Step-by-step installation procedures
- ❌ Detailed troubleshooting guides
- ❌ Configuration file examples
- ❌ Full command references

---

## Step 3: Create Structure If Needed

**If docs/ doesn't exist:**
```bash
mkdir -p docs
```

**If docs/changelog.md doesn't exist, create it:**
```markdown
# Changelog

All notable changes to this project are documented here.

Format: Each entry includes date, summary, and details.

---

## [First Entry Will Go Here]
```

---

## Step 4: ALWAYS Append to docs/changelog.md

**Every /log run creates a changelog entry.** This is your paper trail.

**Format:**
```markdown
## YYYY-MM-DD - [Brief Title]

**What changed:**
- [Specific change with context]
- [Another change]

**Why:**
- [Motivation or problem solved]

**Files modified:**
- `path/to/file.ext` - [what changed]

**Technical notes:** (optional, for complex changes)
- [Implementation details, gotchas encountered, decisions made]

---
```

**Example:**
```markdown
## 2026-01-06 - Restructured Homelab Documentation

**What changed:**
- Created lean homelab.md (271 lines, down from 2,282)
- Moved detailed docs to homelab/ subdirectory
- Created 6 reference files: services.md, troubleshooting.md, setup-guides.md, gpu-passthrough.md, google-drive.md, media-server.md

**Why:**
- Original file exceeded Claude's read limit
- Separated "current state" from "reference material"

**Files modified:**
- `docs/homelab.md` - Complete rewrite, lean version
- `docs/homelab/*.md` - New detailed reference files
- `docs/backups/homelab-20260106-*.md` - Archived original

**Technical notes:**
- Pattern: main doc links to subdirectory for details
- Target size: 200-400 lines for main docs

---
```

---

## Step 5: CONDITIONALLY Update CLAUDE.md

**Only if Category A changes exist.**

### What to ADD to CLAUDE.md:
- New entries in existing tables (services, IPs, etc.)
- New sections for new capabilities
- New gotchas in "Known Issues" section
- Updated values (changed IPs, ports, etc.)

### What to NEVER ADD to CLAUDE.md:
- Changelog entries (that's what changelog.md is for)
- "Journey" narratives ("After trying X, Y, and Z...")
- Implementation details
- Troubleshooting steps you took
- Historical context

### Format for CLAUDE.md updates:
**Present tense, factual, brief:**
```markdown
| Frigate | 5000 | NVR with AI detection |
```

**NOT:**
```markdown
### 2026-01-06 - Added Frigate NVR
We installed Frigate today after configuring Docker...
```

---

## Step 6: Update Global docs/projects.md

**Find the project section and update:**
```markdown
## projectName
**Last Updated:** YYYY-MM-DD
**Recent Changes:** [1-line summary of what changed]

[existing description - update if capabilities changed]
```

---

## Step 7: Check Document Health

**After updates, check main CLAUDE.md size:**
```bash
wc -l CLAUDE.md
```

**Thresholds:**
- ✅ **< 300 lines:** Healthy
- ⚠️ **300-500 lines:** Getting large, watch it
- 🔴 **> 500 lines:** Too large! Recommend cleanup

**If > 500 lines, warn the user:**
```
⚠️ CLAUDE.md is [X] lines (recommended: <400)

Suggestions:
- Move detailed sections to docs/[topic].md
- Archive old changelog entries to docs/changelog.md
- Run /sum to compact
- Review for "journey" content that should be removed
```

---

## Step 8: Summary for User

```
📝 Session Documented

📋 Changelog (paper trail):
   → docs/changelog.md - Added entry for [brief description]

📄 Current state updates:
   → CLAUDE.md - [what was updated, or "No current-state changes"]

🌐 Global updates:
   → ~/.claude/docs/projects.md - Updated [project] section

📊 Document health:
   → CLAUDE.md: [X] lines [✅ Healthy | ⚠️ Getting large | 🔴 Needs cleanup]

💾 Changes saved locally. Hourly backup will commit automatically.
```

---

## Decision Flowchart

```
For each change you made:
│
├─ Does it change CURRENT STATE? (what exists now)
│  ├─ YES → Update CLAUDE.md (brief, factual)
│  │        AND append to docs/changelog.md (detailed)
│  │
│  └─ NO → Append to docs/changelog.md ONLY
│
├─ Is it detailed reference material?
│  └─ YES → Create/update docs/[topic].md
│           AND append to docs/changelog.md
│
└─ ALWAYS append full details to docs/changelog.md
```

---

## Examples

### Example 1: Bug Fix (Category B - changelog only)

**You fixed:** Intel NIC TSO bug causing network hangs

**docs/changelog.md:**
```markdown
## 2025-12-12 - Fixed Intel I218-LM NIC Hang Issue

**What changed:**
- Disabled TSO/GSO/GRO on prox-tower's Intel NIC
- Added post-up rule to /etc/network/interfaces

**Why:**
- NIC was hanging under load, requiring physical reboot
- Known e1000e driver bug with TSO enabled

**Files modified:**
- `/etc/network/interfaces` - Added ethtool post-up commands
```

**CLAUDE.md:** Add to "Known Issues" section (this IS current state - a gotcha):
```markdown
### Intel I218-LM NIC Bug (prox-tower)
**Problem:** TSO causes hangs. **Fix:** TSO/GSO/GRO disabled.
```

### Example 2: Documentation Cleanup (Category B - changelog only)

**You did:** Reorganized homelab docs

**docs/changelog.md:** [Full details of what was moved where]

**CLAUDE.md:** No changes (current state didn't change, just documentation structure)

### Example 3: New Service Added (Category A - both)

**You added:** Frigate NVR

**docs/changelog.md:**
```markdown
## 2026-01-04 - Installed Frigate NVR

**What changed:**
- Deployed Frigate container on VM 101
- Configured Tapo C210 camera
- Set up Mosquitto MQTT broker
- Created ~/frigate/ directory structure

[full details...]
```

**CLAUDE.md:** Add to services table:
```markdown
| Frigate | 5000 | NVR with AI detection |
| Mosquitto | 1883 | MQTT broker |
```

**docs/homelab/services.md:** Add full Frigate section with config details

---

## Special Cases

### Working in ~/.claude directory
- Changelog goes to `~/.claude/docs/changelog.md`
- Only update main CLAUDE.md for new commands/skills/system changes

### No existing CLAUDE.md
- Create minimal one with current state
- Create docs/changelog.md
- Log the creation

### Project not in global docs/projects.md
- Add new section for the project
- Include brief description and last updated date

---

## Anti-Patterns to Avoid

❌ **Don't do this in CLAUDE.md:**
```markdown
### 2026-01-06 - Session Log
Today we worked on fixing the NIC issue. First we tried X, then Y...
```

✅ **Do this instead:**
- Full narrative → docs/changelog.md
- Just the gotcha → CLAUDE.md "Known Issues" section

❌ **Don't do this:**
```markdown
## Changelog
### 2026-01-06 ...
### 2026-01-05 ...
### 2026-01-04 ...
[50 more entries]
```

✅ **Do this instead:**
- All changelog entries → docs/changelog.md
- CLAUDE.md has no changelog section (or just "See docs/changelog.md")

---

Now proceed with logging this session's changes using these guidelines.
