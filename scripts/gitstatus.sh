#!/bin/bash

# Define colors for nice terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}Fetching and analyzing repositories. Please wait...${NC}\n"

# Loop through all directories
for dir in */ ; do
    if [ -d "${dir}.git" ]; then
        (
            cd "$dir" || exit
            repo_name="${dir%/}"

            # 1. Fetch latest changes silently
            git fetch -q 2>/dev/null

            # 2. Get current branch name
            branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

            # 3. Check for uncommitted (dirty) changes
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                dirty_status="${RED}✗ Dirty (Uncommitted changes)${NC}"
            else
                dirty_status="${GREEN}✓ Clean working tree${NC}"
            fi

            # 4. Check Ahead/Behind status relative to remote
            sync_status=""
            # Check if there is an upstream branch tracked
            if git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
                counts=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
                ahead=$(echo "$counts" | awk '{print $1}')
                behind=$(echo "$counts" | awk '{print $2}')

                if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
                    sync_status="${GREEN}✓ Up to date${NC}"
                else
                    if [ "$ahead" -gt 0 ]; then
                        sync_status="${YELLOW}↑ Ahead by $ahead commit(s)${NC}  "
                    fi
                    if [ "$behind" -gt 0 ]; then
                        sync_status="${sync_status}${RED}↓ Behind by $behind commit(s)${NC}"
                    fi
                fi
            else
                sync_status="${YELLOW}⚠ No remote tracking branch${NC}"
            fi

            # 5. Print the formatted result
            echo -e "${CYAN}${BOLD}${repo_name}${NC} [${BLUE}${branch}${NC}]"
            echo -e "   Status : ${sync_status}"
            echo -e "   Local  : ${dirty_status}\n"
        )
    fi
done

echo -e "${BOLD}Done!${NC}"
