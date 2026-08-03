#!/usr/bin/env bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <old> <new>"
    exit 1
fi

OLD_VAR="$1"
NEW_VAR="$2"

echo "searching '$OLD_VAR'..."
MATCH_COUNT=$(rg -c "\b$OLD_VAR\b" | wc -l || true)

if [ "$MATCH_COUNT" -eq 0 ] || [ -z "$MATCH_COUNT" ]; then
    echo "No match for'$OLD_VAR'."
    exit 0
fi

echo "Found '$OLD_VAR':"
rg -l "\b$OLD_VAR\b"
echo "----------------------------------------"

read -p "Do you want to replace '$OLD_VAR' with '$NEW_VAR' in these files? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "No files changed"
    exit 0
fi

rg -l "\b$OLD_VAR\b" | xargs sed -i "s/\b$OLD_VAR\b/$NEW_VAR/g"
