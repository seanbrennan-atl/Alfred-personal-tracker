#!/bin/bash
# Alfred Auto-Push
# Watches the project folder for changes and auto-commits + pushes to GitHub.
# Runs as a LaunchAgent — starts at login, keeps running in background.

REPO="/Users/sean/Documents/Claude/Projects/Personal Organizer"
LOG="$HOME/Library/Logs/alfred-auto-push.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

log "Auto-push started."

while true; do
  cd "$REPO" || { log "ERROR: Can't find project folder."; sleep 60; continue; }

  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    git add -A
    MSG="Auto-update $(date '+%Y-%m-%d %H:%M')"
    git commit -m "$MSG" >> "$LOG" 2>&1
    git push >> "$LOG" 2>&1
    if [[ $? -eq 0 ]]; then
      log "Pushed: $MSG"
    else
      log "Push failed — check credentials or network."
    fi
  fi

  sleep 60
done
