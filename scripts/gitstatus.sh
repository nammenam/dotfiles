#!/bin/bash

# Define colors for nice terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Parse arguments: support --all flag, treat the rest as paths
ALL_BRANCHES=""
PATHS=()
for arg in "$@"; do
    case "$arg" in
        --all) ALL_BRANCHES=1 ;;
        *) PATHS+=("$arg") ;;
    esac
done
if [ ${#PATHS[@]} -eq 0 ]; then
    PATHS=(".")
fi

# Temp file to record per-repo results for the end summary (analyze_repo runs in a subshell)
STATE_FILE=$(mktemp)
trap 'rm -f "$STATE_FILE"' EXIT

echo -e "${BOLD}Fetching and analyzing repositories. Please wait...${NC}\n"

# Analyze a single repository
analyze_repo() {
    local repo_path="$1"
    (
        # Per-repo result flags for the end summary
        result_dirty=0 result_ahead=0 result_behind=0 result_track=1 result_fetch=0

        cd "$repo_path" || { echo -e "${RED}✗ Could not enter: $repo_path${NC}\n"; echo "cdfail" >> "$STATE_FILE"; exit 1; }

        # 1. Fetch latest changes silently (repo-wide, done once)
        if ! fetch_err=$(git fetch -q 2>&1); then
            fetch_status="${RED}✗ Fetch failed (remote unreachable or moved?)${NC}"
            result_fetch=1
        fi

        # Repo-wide remote URL
        remote_url=$(git remote get-url origin 2>/dev/null)
        [ -z "$remote_url" ] && remote_url=$(git remote get-url 2>/dev/null | head -n1)
        [ -z "$remote_url" ] && remote_url="${YELLOW}(no remote)${NC}"

        # Compute sync (ahead/behind) status for the currently checked-out branch
        compute_sync() {
            sync_status=""
            if git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
                has_upstream=1
                read -r ahead behind <<< "$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)"
                ahead=${ahead:-0}
                behind=${behind:-0}

                if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
                    sync_status="${GREEN}✓ Up to date${NC}"
                else
                    if [ "$ahead" -gt 0 ]; then
                        sync_status="${YELLOW}↑ Ahead by $ahead commit(s)${NC}  "
                        result_ahead=1
                    fi
                    if [ "$behind" -gt 0 ]; then
                        sync_status="${sync_status}${RED}↓ Behind by $behind commit(s)${NC}"
                        result_behind=1
                    fi
                fi
            else
                has_upstream=0
                result_track=0
                sync_status="${YELLOW}⚠ No remote tracking branch${NC}"
            fi
        }

        # Compute dirty (uncommitted changes) status for the current working tree
        compute_dirty() {
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                dirty_status="${RED}✗ Dirty (Uncommitted changes)${NC}"
                result_dirty=1
            else
                dirty_status="${GREEN}✓ Clean working tree${NC}"
            fi
        }

        # Report the currently checked-out branch in the standard single-repo format
        report_single() {
            branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
            compute_sync
            compute_dirty

            echo -e "${CYAN}${BOLD}${repo_path}${NC} [${BLUE}${branch}${NC}]"
            if [ -n "$fetch_status" ]; then
                echo -e "   Fetch  : ${fetch_status}"
                [ -n "$fetch_err" ] && echo -e "           ${RED}${fetch_err}${NC}"
            fi
            echo -e "   Status : ${sync_status}"
            echo -e "   Local  : ${dirty_status}"
            echo -e "   Remote : ${remote_url}\n"
        }

        if [ -n "$ALL_BRANCHES" ]; then
            current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
            branches=$(git for-each-ref --format='%(refname:short)' refs/heads/)

            # If the working tree is dirty we cannot safely switch branches;
            # fall back to normal mode for this repo.
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                echo -e "${YELLOW}⚠ Uncommitted changes in ${repo_path}; skipping branch switch, showing current branch only.${NC}"
                report_single
            else
                echo -e "${CYAN}${BOLD}${repo_path}${NC} ${BLUE}(all branches)${NC}"
                if [ -n "$fetch_status" ]; then
                    echo -e "   Fetch  : ${fetch_status}"
                    [ -n "$fetch_err" ] && echo -e "           ${RED}${fetch_err}${NC}"
                fi
                echo -e "   Remote : ${remote_url}"

                # Current branch (no switch needed)
                compute_sync
                compute_dirty
                echo -e "   • ${BOLD}${current_branch}${NC} ${BLUE}[current]${NC} : ${sync_status} | ${dirty_status}"

                switch_failed=""
                for b in $branches; do
                    [ "$b" = "$current_branch" ] && continue
                    if git checkout -q "$b" 2>/dev/null; then
                        compute_sync
                        compute_dirty
                        echo -e "   • ${b} : ${sync_status} | ${dirty_status}"
                    else
                        switch_failed=1
                        break
                    fi
                done

                # Always switch back to the original branch
                git checkout -q "$current_branch" 2>/dev/null

                if [ -n "$switch_failed" ]; then
                    echo -e "${YELLOW}⚠ Could not switch branches in ${repo_path}; showing current branch only.${NC}"
                fi
                echo
            fi
        else
            report_single
        fi

        # Record this repo's result for the end summary
        echo "repo $result_dirty $result_ahead $result_behind $result_track $result_fetch" >> "$STATE_FILE"
    )
}

# Look only inside the given parent folders (non-recursive) for git repos.
for parent in "${PATHS[@]}"; do
    if [ ! -d "$parent" ]; then
        echo -e "${RED}✗ Not a directory: $parent${NC}\n"
        continue
    fi
    for dir in "$parent"/*/; do
        [ -d "${dir}.git" ] && analyze_repo "${dir%/}"
    done
done

# Tally results into a summary
total=0 clean_count=0 dirty_count=0 ahead_count=0 behind_count=0 notrack_count=0 fetchfail_count=0 cdfail_count=0
while read -r kind d a b t f; do
    if [ "$kind" = "cdfail" ]; then
        cdfail_count=$((cdfail_count + 1))
        continue
    fi
    total=$((total + 1))
    if [ "$d" = 1 ]; then dirty_count=$((dirty_count + 1)); else clean_count=$((clean_count + 1)); fi
    [ "$a" = 1 ] && ahead_count=$((ahead_count + 1))
    [ "$b" = 1 ] && behind_count=$((behind_count + 1))
    [ "$t" = 0 ] && notrack_count=$((notrack_count + 1))
    [ "$f" = 1 ] && fetchfail_count=$((fetchfail_count + 1))
done < "$STATE_FILE"

if [ "$total" -eq 0 ] && [ "$cdfail_count" -eq 0 ]; then
    echo -e "${YELLOW}No git repositories found.${NC}"
else
    echo -e "${BOLD}Summary${NC}"
    echo -e "   Repositories        : ${BOLD}$total${NC}"
    echo -e "   ${GREEN}✓ Clean${NC}             : $clean_count"
    echo -e "   ${RED}✗ Dirty${NC}             : $dirty_count"
    echo -e "   ${YELLOW}↑ Ahead${NC}             : $ahead_count"
    echo -e "   ${RED}↓ Behind${NC}            : $behind_count"
    echo -e "   ${YELLOW}⚠ No tracking branch${NC}: $notrack_count"
    echo -e "   ${RED}✗ Fetch failures${NC}    : $fetchfail_count"
    [ "$cdfail_count" -gt 0 ] && echo -e "   ${RED}✗ Unreadable paths${NC}  : $cdfail_count"
fi

echo -e "${BOLD}Done!${NC}"
