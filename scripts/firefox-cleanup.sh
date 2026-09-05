#!/usr/bin/env bash
# Review-only cleanup script for Firefox split-brain
# This script makes backups and prints actions. It does not delete anything
# without explicit user confirmation. Run a copy locally after review.

set -euo pipefail

workdir="$HOME/.local/share/firefox-cleanup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$workdir"

echo "Backup and report dir: $workdir"

echo "1) Inspecting legacy root: ~/.mozilla/firefox"
if [ -d "$HOME/.mozilla/firefox" ]; then
  echo " - backing up ~/.mozilla/firefox -> $workdir/legacy-mozilla-firefox.tgz"
  tar -c -C "$HOME" ".mozilla/firefox" | gzip > "$workdir/legacy-mozilla-firefox.tgz"
  echo " - contents:"; ls -la "$HOME/.mozilla/firefox" || true
else
  echo " - legacy root does not exist"
fi

echo
echo "2) Inspecting native root: ~/Library/Application Support/Firefox"
if [ -d "$HOME/Library/Application Support/Firefox" ]; then
  echo " - listing profiles and sizes:";
  du -sh "$HOME/Library/Application Support/Firefox/Profiles"/* 2>/dev/null || true
  echo " - profiles.ini:"; cat "$HOME/Library/Application Support/Firefox/profiles.ini" 2>/dev/null || true
  echo " - installs.ini:"; cat "$HOME/Library/Application Support/Firefox/installs.ini" 2>/dev/null || true
else
  echo " - native root missing"
fi

echo
echo "3) Stale Nix Firefox installations (will not be removed, just listed):"
ls -d /nix/store/*-firefox-* 2>/dev/null || echo " - none found"

echo
echo "4) Actions I recommend (no action taken yet):"
echo " - Remove legacy root ~/.mozilla/firefox (backup created above).";
echo " - Fix installs.ini if it references non-existent profiles.";
echo " - Optionally remove unused stub profiles listed above after manual review.";

echo
read -rp "Proceed to remove legacy root ~/.mozilla/firefox now? [y/N] " yn || yn=N
if [ "${yn:-N}" = "y" ]; then
  if [ -d "$HOME/.mozilla/firefox" ]; then
    mv "$HOME/.mozilla/firefox" "$workdir/.mozilla-firefox-moved" || true
    echo "Moved ~/.mozilla/firefox -> $workdir/.mozilla-firefox-moved"
  else
    echo "Nothing to remove"
  fi
fi

echo
echo "5) Stray empty '*.default' profiles created by Firefox's per-install"
echo "   profile logic after version bumps (the real profile is managed by"
echo "   home-manager, e.g. 'cameron'). Empty defaults are safe to remove."
prof_root="$HOME/Library/Application Support/Firefox/Profiles"
if [ -d "$prof_root" ]; then
  for p in "$prof_root"/*.default; do
    [ -d "$p" ] || continue
    # "Empty" heuristic: no places.sqlite (history/bookmarks DB) present.
    if [ ! -f "$p/places.sqlite" ]; then
      echo " - stray empty profile: $p ($(du -sh "$p" 2>/dev/null | cut -f1))"
      read -rp "   Back up and remove this stray profile? [y/N] " sp || sp=N
      if [ "${sp:-N}" = "y" ]; then
        tar -c -C "$prof_root" "$(basename "$p")" | gzip > "$workdir/stray-$(basename "$p").tgz"
        mv "$p" "$workdir/removed-$(basename "$p")"
        echo "   Moved $p -> $workdir/removed-$(basename "$p")"
      fi
    else
      echo " - keeping (has history data): $p"
    fi
  done
fi

echo "Cleanup review script finished. Review backups in $workdir before deleting anything."
