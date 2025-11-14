# {{PROJECT_NAME}} Documentation

This file provides guidance to Claude Code when working with this repository.

**Multi-AI Documentation Setup**:
- **CLAUDE.md** is the source of truth - always edit this file
- **GEMINI.md** and **AGENTS.md** are symlinks to CLAUDE.md
- Changes to CLAUDE.md automatically sync to all AI assistants

## Overview

{{PROJECT_DESCRIPTION}}

**📚 Detailed Documentation**: For comprehensive information, see the `docs/` directory:
- **[architecture.md](docs/architecture.md)** - Technical design and system architecture
- **[workflows.md](docs/workflows.md)** - Development workflows and common tasks
- **[troubleshooting.md](docs/troubleshooting.md)** - Solutions for common issues
- **[changelog.md](docs/changelog.md)** - Complete version history

## Purpose

**What this project does**: {{PROJECT_PURPOSE}}

**Key features**:
- {{FEATURE_1}}
- {{FEATURE_2}}
- {{FEATURE_3}}

## Directory Structure

```
{{PROJECT_NAME}}/
├── CLAUDE.md              # This file (source of truth)
├── GEMINI.md              # Symlink → CLAUDE.md
├── AGENTS.md              # Symlink → CLAUDE.md
├── docs/                  # Detailed documentation
│   ├── architecture.md    # Technical architecture
│   ├── workflows.md       # Development workflows
│   ├── troubleshooting.md # Common issues and fixes
│   └── changelog.md       # Version history
├── {{MAIN_DIRECTORIES}}
└── README.md              # Public-facing documentation
```

## Quick Start

### Prerequisites

{{PREREQUISITES}}

### Installation

```bash
{{INSTALLATION_STEPS}}
```

### Running the Project

```bash
{{RUN_COMMANDS}}
```

## Common Tasks

### Task 1: {{COMMON_TASK_1}}
```bash
{{TASK_1_COMMANDS}}
```

### Task 2: {{COMMON_TASK_2}}
```bash
{{TASK_2_COMMANDS}}
```

## Configuration

{{CONFIGURATION_DETAILS}}

## Dependencies

- **Runtime**: {{RUNTIME_DEPS}}
- **Development**: {{DEV_DEPS}}
- **Optional**: {{OPTIONAL_DEPS}}

## Testing

```bash
{{TEST_COMMANDS}}
```

## Deployment

{{DEPLOYMENT_INSTRUCTIONS}}

## Important Notes

{{IMPORTANT_NOTES}}

## Automated Backups

This repository is included in the hourly automated backup system:
- **Script**: `~/scripts/gitBackup.sh`
- **Schedule**: Every hour at :00
- **GitHub**: Automatically pushed to private repository

## Version History

**Current Version**: {{VERSION}}
**Last Updated**: {{LAST_UPDATED}}

**Full changelog**: [docs/changelog.md](docs/changelog.md)

## Resources

- **Documentation**: [Project Wiki]({{WIKI_LINK}})
- **Issues**: [GitHub Issues]({{ISSUES_LINK}})
- **Related Projects**: {{RELATED_PROJECTS}}