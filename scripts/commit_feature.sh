#!/bin/bash
set -e
git add .
git commit -m "feat: $1" || echo "No changes to commit"
echo "Committed to current branch: $(git branch --show-current)"
