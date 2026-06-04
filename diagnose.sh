#!/bin/bash
# Alfred Auto-Push Diagnostic
# Run with: bash "/Users/sean/Documents/Claude/Projects/Personal Organizer/diagnose.sh"

SEP="────────────────────────────────────"
REPO="/Users/sean/Documents/Claude/Projects/Personal Organizer"
PLIST="$HOME/Library/LaunchAgents/com.alfred.autopush.plist"
LOG="$HOME/Library/Logs/alfred-auto-push.log"

echo "$SEP"
echo "1. GIT"
echo "   which git:    $(which git 2>/dev/null || echo 'NOT FOUND')"
echo "   git version:  $(git --version 2>/dev/null || echo 'NOT FOUND')"
echo "   PATH:         $PATH"

echo "$SEP"
echo "2. REPO"
echo "   exists:       $([ -d "$REPO" ] && echo YES || echo NO)"
cd "$REPO" 2>/dev/null && echo "   git status:   $(git status --short 2>&1 | head -5 || echo 'not a git repo')" || echo "   cd failed"
echo "   remote:       $(git remote get-url origin 2>/dev/null || echo 'none')"
echo "   last commit:  $(git log -1 --oneline 2>/dev/null || echo 'none')"

echo "$SEP"
echo "3. SCRIPT"
echo "   exists:       $([ -f "$REPO/alfred-auto-push.sh" ] && echo YES || echo NO)"
echo "   executable:   $([ -x "$REPO/alfred-auto-push.sh" ] && echo YES || echo NO)"

echo "$SEP"
echo "4. LAUNCHAGENT"
echo "   plist exists: $([ -f "$PLIST" ] && echo YES || echo NO)"
echo "   launchctl:    $(launchctl list 2>/dev/null | grep alfred || echo 'not loaded')"

echo "$SEP"
echo "5. LOG"
echo "   log exists:   $([ -f "$LOG" ] && echo YES || echo NO)"
echo "   log dir:      $([ -d "$HOME/Library/Logs" ] && echo YES || echo NO)"
[ -f "$LOG" ] && echo "   last 5 lines:" && tail -5 "$LOG" || echo "   no log file"

echo "$SEP"
echo "6. NETWORK + GITHUB AUTH"
echo "   ping github:  $(ping -c 1 -t 2 github.com 2>/dev/null | grep 'bytes from' || echo 'FAILED')"
echo "   git ls-remote: $(cd "$REPO" && git ls-remote --heads origin 2>&1 | head -3)"

echo "$SEP"
echo "Done. Paste all output above to Claude."
