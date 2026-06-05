# Alfred Personal Tracker — Project Context

**Last updated:** June 4, 2026 · 7:32 PM ET  

**Live app:** https://seanbrennan-atl.github.io/Alfred-personal-tracker/  
**GitHub repo:** https://github.com/seanbrennan-atl/Alfred-personal-tracker  
**Local file:** `/Users/sean/Documents/Claude/Projects/Personal Organizer/index.html`  
**Storage key:** `wt_data_v2` — do not change, will break existing data

---

## How Claude Works on This Project

- Claude edits `index.html` directly in this folder
- `alfred-auto-push.sh` (LaunchAgent) watches for changes and auto-commits + pushes to GitHub every 60 seconds
- At the end of each session, Claude updates this `CONTEXT.md` with a session log entry
- To check push logs: `cat ~/Library/Logs/alfred-auto-push.log`

---

## What's Built

### 4-Tab PWA (bottom nav order: Today · Week · Backlog · Review)

**Today tab** — tasks tagged `list='today'`. At midnight, week tasks tagged for today auto-promote. Unfinished tasks carry over.

**Week tab** — flat list of all non-backlog tasks with colored day tags (Mon–Sun). "⇅ Day" sort button. Stats bar at top showing % complete + pace vs. target. Expandable habit cards below tasks.

**Backlog tab** — long-term tasks with "→ Week" move button.

**Review tab** — weekly score (0–100), per-metric breakdown with % change vs prior week (delta badges), full task list, AI summary (copies prompt to clipboard, paste-back to save). Week nav (Prev/Next).

### Habit Tracker — 6 scored metrics

| Habit | Type | Goal |
|-------|------|------|
| Sleep | Daily binary + hours | 64 hrs/week, 7/7 on-time |
| Alcohol | Numeric | <14 drinks, <2 heavy days |
| Workouts | Numeric, step 1 | 4/week |
| Creative Time | Numeric, step 0.5 | 2 hrs/week |
| Reading | Numeric, step 0.5 | 2 hrs/week |
| Relationships | Numeric, step 1 | 1/week |

Context logging on Relationships, Creative, Reading (purple tag chips in habit card).

**Habit card color logic:** Bar and chip color reflect pace-to-target (not raw %), based on day of week elapsed vs. goal fraction achieved. Green = on/ahead of pace, Yellow = slightly behind, Red = at risk.

### Weekly Score Formula
Average of all habit scores + task completion rate (equal weight). Capped at 100%. Raw actuals stored uncapped.

### Scheduled Seed Tasks
Every Monday at 12:01am, a Claude scheduled task injects 4 Workout tasks + 1 Relationships task into the Week list via `<script id="wt-seed-tasks">`. App deduplicates by week key.

### Week Rollover Cleanup
On first app open of a new week (detected via `lastOpenDate`), all completed non-backlog tasks are automatically removed.

### Firebase Sync
- On-open sync (pulls whichever device saved most recently)
- Pushes on every save
- Google sign-in auth (signInWithPopup — redirect broken in Chrome due to cookie restrictions)
- Sync status dot in header: · Synced / · Syncing… / · Offline
- Config stored in `localStorage` under `wt_fb_cfg`
- To reset: run `resetFbConfig()` in browser console

---

## Key Data Model

```js
APP = {
  tasks: [{ id, title, notes, list, dayTag, completed, completedAt, dueDate, createdAt }],
  habits: {
    "2026-W23": {
      sleepOnTime[], wakeOnTime[], sleepHours[],
      alcoholDrinks, alcoholHeavyDays,
      workouts, creative, reading, relationships
    }
  },
  habitLogs: { "2026-W23": { relationships: [{tag, ts}], creative: [...], reading: [...] } },
  reviews: { "2026-W23": { score, summary } },
  lastOpenDate: "2026-06-04",
  seededWeeks: [],
  lastSaved: "<ISO timestamp>"
}
```

`list` values: `'today'` | `'week'` | `'backlog'`  
`completedAt` is logged (ISO timestamp) whenever a task is checked off and displayed as "✓ Jun 3" in the task row.

---

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| PWA over native app | No App Store needed |
| localStorage as primary, Firebase as sync layer | Simple, no backend required |
| Timestamp-based conflict resolution | Whichever device saved most recently wins |
| Weeks run Mon–Sun (ISO standard) | Consistent with habit tracking conventions |
| signInWithPopup (not redirect) | Redirect broken in Chrome due to cookie restrictions |
| Scores capped at 100% for grading; raw actuals stored uncapped | Clean scoring, accurate data |
| Today tab as default/first tab | Most frequent daily use case |
| Pace-to-target color for habits | More actionable than raw % — tells you if you're behind relative to time elapsed |

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `index.html` | The entire app — single file PWA |
| `CONTEXT.md` | This document — living project context |
| `alfred-auto-push.sh` | Auto-push script (runs as LaunchAgent) |
| `com.alfred.autopush.plist` | LaunchAgent definition |
| `Weekly Tracker Setup Guide.md` | Original setup notes |

---

## What's Not Built Yet (Backlog)

- Trend charts — multi-week view of scores and habit actuals
- Push notifications — PWA supports this; needs a service worker
- Goal adjustment suggestions
- Print/PDF polish
- Google Calendar sync

---

## Working Principles (Claude must follow these)

- **Never guess or fabricate** facts, times, values, or behavior — if uncertain, say so explicitly before acting
- **Always check the shell** for current time when timestamping: `TZ="America/New_York" date "+%B %-d, %Y · %-I:%M %p ET"`
- **Flag uncertainty proactively** — "I'm not sure about X, let me check" is always better than a confident wrong answer
- Sean is relying on Claude's recommendations being accurate and well-reasoned; silent guessing destroys that trust

---

## Session Log

### 2026-06-04 — Session 3
**Changes made:**

1. **Apple Calendar ↔ Google Calendar sync** — Enabled Calendars toggle on `seanbrennan.atl@gmail.com` in System Settings → Internet Accounts. Google Calendar API was already enabled in the "Alfred personal tracker" GCP project.

2. **Google Calendar integration in Alfred** — Read-only pull from Google Calendar API. Auth piggybacks on existing Firebase Google sign-in (adds `calendar.readonly` scope). Events fetched for -1 to +3 months from today, stored in `window.__calEvents`.
   - **Today tab** — Today's Google Calendar events appear above the task list in a blue section, with time + title + calendar name.
   - **Week tab** — This week's events appear grouped by day (above habits), visually distinct from tasks.
   - **Calendar tab (5th tab)** — New monthly calendar view. Tap any day to expand and see events. Prev/Next month nav. "Refresh" button to re-sync. "Connect Calendar" prompt shown if not yet connected.
   - **connectCalendar()** — Button on Calendar tab triggers a Google popup (silent if scope already granted) to get a fresh access token and fetch events.
   - **URL param support** — Opening `?alfred=add&task=...&list=week` auto-adds a task (for iOS Shortcut integration).

3. **Alfred Voice Assistant** — 🎤 mic button in the header. Tap → speaks → Alfred parses the command and adds the task.
   - Natural language parsing: "Add workout to my weekly list" → task="Workout", list='week'
   - Responds via `speechSynthesis` in a Michael Caine / Alfred Pennyworth voice (en-GB voice, rate 0.82, pitch 0.82)
   - Sample responses: "Very good, sir. I've added that to your weekly list.", "Certainly, sir.", etc.
   - Supports today/week/backlog routing from spoken phrase
   - iOS Shortcut integration: create a Shortcut named "Alfred" → Ask for Input → Open URL `https://seanbrennan-atl.github.io/Alfred-personal-tracker/?alfred=add&task=[input]&list=week`

**New tab order (bottom nav):** Today · Week · Backlog · Review · Calendar

**Key notes:**
- Calendar token is short-lived (1 hr). Returning users need to tap "Refresh" on the Calendar tab to re-authenticate and fetch fresh events.
- Voice recognition requires HTTPS (works on GitHub Pages URL, not `file://`)
- `window.__calEvents` is in-memory only — not persisted to localStorage or Firebase (fetched fresh each session)

### 2026-06-04 — Session 2
**Changes made:**
1. **Firebase config hardcoded** — embedded directly in `index.html` so no per-device setup is needed. Any device opening the GitHub Pages URL will connect to Firebase automatically.
2. **file:// fix** — added protocol check at top of Firebase init; skips Firebase entirely when opened as a local file (prevents auth error on desktop local opens).
3. **Git + auto-push fully set up** — installed Xcode CLT (git), granted Terminal Full Disk Access, initialized the git repo, connected remote to `https://github.com/seanbrennan-atl/Alfred-personal-tracker.git`, force-pushed, and got LaunchAgent running (PID confirmed, exit 0).

**How sync works now:**
- **Data sync** (tasks/habits): Firebase Realtime Database. Both phone and desktop must use the GitHub Pages URL and sign in with the same Google account. Sign-in uses `signInWithPopup` — works on `https://`, not on `file://`.
- **Code sync** (app updates): Claude edits local `index.html` → LaunchAgent auto-pushes to GitHub every 60s → GitHub Pages serves updated code → both devices get it on next refresh.

**Important notes:**
- Always use **https://seanbrennan-atl.github.io/Alfred-personal-tracker/** on desktop — never open the local file for data entry
- Firebase config is now hardcoded in the Firebase sync script (no longer stored only in localStorage)
- `wt_fb_skip` in localStorage still works as an escape hatch to bypass Firebase
- LaunchAgent plist is at `~/Library/LaunchAgents/com.alfred.autopush.plist` — if it stops after a restart, run: `launchctl load ~/Library/LaunchAgents/com.alfred.autopush.plist`
- `diagnose.sh` left in project folder — useful for future debugging

### 2026-06-04 — Session 1
**Changes made:**
1. **Week rollover cleanup** — on first app open of new week, all completed non-backlog tasks are cleared automatically
2. **Bottom nav** — tap target height +30%, icon size 22px, label size 11px, active tab shows purple background pill
3. **Removed → Week button** from Today view
4. **Completion date display** — `completedAt` was already logged; now displayed as "✓ Jun 3" in task row
5. **Swapped tab order** — Today is now first/default tab, Week is second
6. **Active tab highlight** — purple background on active nav button (was just color change before)
7. **Week tab stats bar** — shows % complete, tasks done/total, and pace vs. weekly target
8. **Habit card pace colors** — bar and chip color now reflects pace-to-target by day of week; % number unchanged

**Infrastructure:**
- Set up `alfred-auto-push.sh` + `com.alfred.autopush.plist` for automatic GitHub sync
- Created this `CONTEXT.md` living context document

**Decisions:**
- GitHub PAT was exposed in chat — Sean should revoke it and generate a new one for the git setup
- Auto-push uses macOS Keychain for credential storage (one-time auth, then fully automatic)
