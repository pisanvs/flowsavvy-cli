---
name: flowsavvy
description: Use when the user asks to add tasks, study sessions, or any items to FlowSavvy.
allowed-tools: Bash(flowsavvy *)
---

Use the `flowsavvy` CLI to create tasks. Auth is stored in `~/.config/flowsavvy/auth`.

## Commands

### Single task
```bash
flowsavvy add "Title" "YYYY-MM-DD" "HH:MM" "HH:MM" DURATION_MIN "Notes"
#                       due date    start   end     total minutes
```

### Batch (fastest for multiple tasks)
```bash
# From file
flowsavvy batch tasks.tsv

# From stdin
printf 'Title\t2026-04-10\t16:00\t17:30\t90\tNotes\n' | flowsavvy batch -
```

TSV columns: `Title`, `Due (YYYY-MM-DD)`, `Start (HH:MM)`, `End (HH:MM)`, `Duration (min)`, `Notes`
Lines starting with `#` are skipped.

### Refresh auth
```bash
flowsavvy auth
```
Run when you see `[AUTH EXPIRED]`. Get fresh CSRF token + Cookie from Chrome DevTools on any `/api/Item/Create` request.

## Key behaviours
- `DueDateTime` = `YYYY-MM-DDT23:59` (always end of day)
- `Start`/`End` define preferred time window and total duration
- `minLengthTotalMinutes` = duration → schedules in one block
- Buffer: 10 min before, 15 min after (FlowSavvy default)
- Non-repeating, non-fixed-time — FlowSavvy auto-schedules

## Workflow: generating tasks from a plan

1. Build the task list (title, due, start, end, duration, notes)
2. Write TSV to `/tmp/tasks.tsv`
3. Run `flowsavvy batch /tmp/tasks.tsv`
4. Confirm all lines show `[OK]`

```bash
cat > /tmp/tasks.tsv <<'EOF'
Physics P1 Past Paper	2026-04-15	16:00	16:45	45	30 MCQ timed. No calculator. Self-mark immediately.
History GT9 Essay	2026-04-17	16:00	17:30	90	Essay plan 10 min + attempt 45 min. Mark scheme after.
EOF
flowsavvy batch /tmp/tasks.tsv
```
