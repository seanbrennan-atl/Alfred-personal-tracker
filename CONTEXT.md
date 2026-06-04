# Alfred Personal Tracker — Project Context

**Last updated:** June 4, 2026 · 4:02 PM ET  

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
