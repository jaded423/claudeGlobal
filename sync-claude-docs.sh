#!/bin/bash

# Claude Global Documentation Sync Script
# Purpose: Bidirectional sync of Claude documentation with GitHub
# Runs hourly via systemd timer to keep home lab and work Mac in sync

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Repository directory
REPO_DIR="/home/jaded/projects/.claude"

echo -e "${YELLOW}Starting Claude documentation sync...${NC}"
cd "$REPO_DIR" || exit 1

# Fetch latest changes from remote
echo -e "${GREEN}Fetching latest changes from GitHub...${NC}"
git fetch origin master

# Check if there are remote changes to pull
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo -e "${YELLOW}Remote changes detected. Pulling updates...${NC}"
    # Stash any local changes temporarily
    git stash push -m "Auto-stash before pull $(date '+%Y-%m-%d %H:%M:%S')"

    # Pull remote changes
    git pull origin master

    # Apply stashed changes if any
    if git stash list | grep -q "Auto-stash"; then
        echo -e "${YELLOW}Re-applying local changes...${NC}"
        git stash pop || {
            echo -e "${RED}Merge conflict detected! Manual intervention required.${NC}"
            echo -e "${RED}Stashed changes preserved. Use 'git stash list' to see them.${NC}"
        }
    fi
else
    echo -e "${GREEN}Already up to date with remote.${NC}"
fi

# Check for local changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}Local changes detected. Committing...${NC}"

    # Stage all changes
    git add -A

    # Create commit message
    COMMIT_MSG="[Home Lab Sync] Documentation updates from cachyos-jade"

    # Get list of modified files for detailed message
    MODIFIED_FILES=$(git diff --cached --name-only | head -5)
    if [ -n "$MODIFIED_FILES" ]; then
        COMMIT_MSG="$COMMIT_MSG

Modified files:
$MODIFIED_FILES"
    fi

    # Commit changes
    git commit -m "$COMMIT_MSG"

    echo -e "${GREEN}Changes committed.${NC}"

    # Push to remote
    echo -e "${YELLOW}Pushing changes to GitHub...${NC}"
    git push origin master || {
        echo -e "${RED}Push failed! Will retry on next sync.${NC}"
        exit 1
    }
    echo -e "${GREEN}Changes pushed successfully.${NC}"
elif git status --porcelain | grep -q "^"; then
    # Check for untracked files
    echo -e "${YELLOW}Untracked files detected.${NC}"
    git status --short
else
    echo -e "${GREEN}No local changes to sync.${NC}"
fi

echo -e "${GREEN}Claude documentation sync completed at $(date '+%Y-%m-%d %H:%M:%S')${NC}"