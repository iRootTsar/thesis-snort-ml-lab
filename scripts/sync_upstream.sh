#!/bin/bash
set -e
echo "Updating snort3 subtree (master)..."
git subtree pull --prefix=repos/snort3 fork-snort3 master --squash
echo "Updating libdaq subtree (master)..."
git subtree pull --prefix=repos/libdaq fork-libdaq master --squash
echo "Updating libml subtree (master)..."
git subtree pull --prefix=repos/libml fork-libml master --squash
echo "All subtrees updated. Run ./scripts/build_all.sh if needed."
