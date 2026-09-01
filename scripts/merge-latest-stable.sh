#!/bin/bash
# merge-latest-stable.sh - Merge latest Linux 4.9.y stable into daisy kernel
# Latest 4.9 LTS is 4.9.337 (EOL Jan 2023) - final stable with all CVE fixes
# Usage: bash scripts/merge-latest-stable.sh [kernel_source_dir]

set -e

KERNEL_SRC="${1:-kernel_source}"
LTS_TAG="${LTS_TAG:-v4.9.337}"
STABLE_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"

if [ ! -d "$KERNEL_SRC/.git" ]; then
  echo "[!] Kernel source not found at $KERNEL_SRC - clone first via build.sh"
  exit 1
fi

cd "$KERNEL_SRC"

echo "============================================"
echo " Merging latest 4.9 stable: $LTS_TAG"
echo " into: $KERNEL_SRC"
echo "============================================"

# Add stable remote if not exists
if ! git remote | grep -q "^stable$"; then
  echo "[*] Adding stable remote: $STABLE_REPO"
  git remote add stable "$STABLE_REPO"
else
  echo "[*] Stable remote exists"
fi

# Auto-detect latest 4.9 tag if LTS_TAG == auto
if [ "$LTS_TAG" = "auto" ]; then
  echo "[*] Detecting latest 4.9.y tag from kernel.org..."
  LTS_TAG=$(git ls-remote --tags stable 2>/dev/null | grep -o 'refs/tags/v4\.9\.[0-9]*' | sed 's|refs/tags/||' | sort -V | tail -n1)
  if [ -z "$LTS_TAG" ]; then
    LTS_TAG="v4.9.337"
  fi
  echo "[*] Latest detected: $LTS_TAG"
fi

echo "[*] Fetching $LTS_TAG from stable (shallow, ~200MB)..."
git fetch stable --depth=1 tag "$LTS_TAG" 2>&1 | tail -20 || git fetch stable tag "$LTS_TAG" 2>&1 | tail -20

# Show current kernel version
echo "[*] Current version before merge:"
cat Makefile | grep -E "^VERSION|^PATCHLEVEL|^SUBLEVEL|^EXTRAVERSION" | head -4 || true
echo "[*] Current HEAD: $(git log --oneline -1)"

# Check if already merged
if git tag --merged HEAD | grep -q "^${LTS_TAG}$"; then
  echo "[✓] $LTS_TAG already merged - skipping"
  exit 0
fi

# Alternative check via Makefile
CURRENT_EXTRA=$(grep "^EXTRAVERSION" Makefile | head -n1 || echo "")
echo "[*] $CURRENT_EXTRA"

echo "[*] Merging $LTS_TAG (no-commit, strategy patience)..."
set +e
git merge --no-commit --strategy=recursive -X patience "FETCH_HEAD" 2>&1 | tee /tmp/merge.log
MERGE_RET=$?
set -e

if [ $MERGE_RET -ne 0 ]; then
  echo "[!] Merge has conflicts - resolving..."
  cat /tmp/merge.log | head -100
  echo ""
  echo "Conflicts:"
  git diff --name-only --diff-filter=U | head -30
  echo ""
  echo "[*] Tips to resolve manually:"
  echo "  cd $KERNEL_SRC && git status"
  echo "  # For Makefile/version conflicts, keep upstream version:"
  echo "  git checkout --theirs Makefile  # take new stable version"
  echo "  # For daisy-specific drivers (msm8953), keep ours:"
  echo "  git checkout --ours drivers/ arch/arm*/ techpack/ 2>/dev/null"
  echo "  git add -A && git commit -m \"Merge $LTS_TAG into daisy-gaming\""
  echo ""
  echo "[*] Attempting auto-resolve for Makefile..."
  # Auto-resolve Makefile to upstream
  if git diff --name-only --diff-filter=U | grep -q "^Makefile$"; then
    echo "[*] Auto-resolving Makefile -> theirs (stable)"
    git checkout --theirs Makefile 2>/dev/null || true
    git add Makefile
  fi
  # Check if still conflicts
  if git diff --name-only --diff-filter=U | grep -q "."; then
    echo "[!] Manual conflict resolution required. Aborting auto-merge."
    echo "    Run: cd $KERNEL_SRC && git merge --abort"
    exit 1
  else
    echo "[✓] Auto-resolved - committing..."
    git commit -m "Merge $LTS_TAG into daisy-gaming

Merged latest Linux 4.9.y stable $LTS_TAG (final LTS EOL Jan 2023)
Includes all upstream CVE fixes, stable patches up to 4.9.337
Base: Xiaomi daisy-q-oss + $LTS_TAG"
  fi
else
  echo "[*] No conflicts - committing merge..."
  git commit -m "Merge $LTS_TAG into daisy-gaming

Merged latest Linux 4.9.y stable $LTS_TAG
Base: daisy-q-oss + upstream stable"
fi

echo "[✓] Merge complete!"
cat Makefile | grep -E "^VERSION|^PATCHLEVEL|^SUBLEVEL|^EXTRAVERSION" | head -4
echo "HEAD: $(git log --oneline -1)"
echo "Tags merged: $(git tag --merged HEAD | grep 'v4\.9\.' | tail -5)"
