#!/bin/bash
# Check for new upstream cmux updates and summarize what's changed
# Usage: ./scripts/check-upstream.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

UPSTREAM="upstream"
BRANCH="local-privacy-mods"

# Ensure upstream remote exists
if ! git remote get-url "$UPSTREAM" &>/dev/null; then
  echo "Adding upstream remote..."
  git remote add "$UPSTREAM" https://github.com/manaflow-ai/cmux.git
fi

echo "Fetching upstream..."
git fetch "$UPSTREAM" --quiet

LOCAL_HEAD=$(git rev-parse "$BRANCH")
UPSTREAM_HEAD=$(git rev-parse "$UPSTREAM/main")

if [ "$LOCAL_HEAD" = "$UPSTREAM_HEAD" ]; then
  echo "You're up to date with upstream."
  exit 0
fi

# Count new commits
NEW_COMMITS=$(git log --oneline "$BRANCH".."$UPSTREAM/main" | wc -l | tr -d ' ')

# Get latest upstream tag
LATEST_TAG=$(git describe --tags --abbrev=0 "$UPSTREAM/main" 2>/dev/null || echo "unknown")

echo ""
echo "=================================="
echo "  UPSTREAM UPDATES AVAILABLE"
echo "=================================="
echo ""
echo "  Your branch:    $BRANCH"
echo "  New commits:    $NEW_COMMITS"
echo "  Latest version: $LATEST_TAG"
echo ""
echo "  Notable changes:"
echo "  ─────────────────"

git log --oneline "$BRANCH".."$UPSTREAM/main" \
  | grep -iE "feat|fix|release|breaking|opacity|blur|theme|hook|socket|browser|ssh|keyboard|font|crash|perf" \
  | head -20 \
  | sed 's/^/  /'

REMAINING=$(git log --oneline "$BRANCH".."$UPSTREAM/main" \
  | grep -iE "feat|fix|release|breaking|opacity|blur|theme|hook|socket|browser|ssh|keyboard|font|crash|perf" \
  | tail -n +21 | wc -l | tr -d ' ')

if [ "$REMAINING" -gt 0 ]; then
  echo "  ... and $REMAINING more"
fi

echo ""

# Check for potential conflicts
CONFLICT_COUNT=$(git merge-tree "$(git merge-base "$BRANCH" "$UPSTREAM/main")" "$BRANCH" "$UPSTREAM/main" 2>/dev/null | grep -c "^<<<<<<<" || true)

if [ "$CONFLICT_COUNT" -gt 0 ]; then
  echo "  Potential conflicts: ~$CONFLICT_COUNT (likely in telemetry code you stripped)"
else
  echo "  Potential conflicts: none detected"
fi

echo ""
echo "  To merge: git merge upstream/main"
echo "  To see full log: git log --oneline $BRANCH..upstream/main"
echo ""
read -p "  Merge now? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "  Merging upstream/main..."
  git merge "$UPSTREAM/main" --no-ff -m "merge: upstream $LATEST_TAG into $BRANCH"
  echo "  Done! Review any conflicts, then rebuild."
else
  echo "  Skipped. Run again when ready."
fi
