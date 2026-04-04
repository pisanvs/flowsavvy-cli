# flowsavvy-cli

A minimal bash CLI to create tasks in [FlowSavvy](https://flowsavvy.app) from the terminal — and a [Claude Code](https://claude.ai/code) skill so your AI assistant can add tasks directly.

```
flowsavvy add "Physics Past Paper" "2026-04-15" "16:00" "16:45" 45 "30 MCQ timed"
[OK  id=17294680  ] Physics Past Paper (due 2026-04-15, 45 min)
```

## Requirements

- `bash` + `curl` (pre-installed on most systems)
- A FlowSavvy account

## Install

```bash
git clone https://github.com/YOUR_USERNAME/flowsavvy-cli.git
cd flowsavvy-cli
chmod +x install.sh
./install.sh
```

This copies `flowsavvy` to `~/.local/bin/` and (if Claude Code is installed) copies the skill to `~/.claude/skills/flowsavvy/`.

Make sure `~/.local/bin` is in your `PATH`:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Setup

Run the auth wizard once:

```bash
flowsavvy auth
```

This will ask for:
1. **CSRF token** — from the `X-CSRF-TOKEN` request header
2. **Cookie** — from the `Cookie` request header
3. **Three account IDs** — from the request form data (`taskListId`, `calendarId`, `timeProfileId`)

**How to get these values:**
1. Open FlowSavvy in Chrome and create any task manually
2. Open DevTools → Network tab → find the `Item/Create` request
3. Under **Headers**: copy `X-CSRF-TOKEN` and `Cookie`
4. Under **Payload / Form Data**: copy `taskListId`, `calendarId`, `timeProfileId`

Auth is saved to `~/.config/flowsavvy/auth` (mode 600).

> **Session expiry:** FlowSavvy sessions expire. When you see `[AUTH EXPIRED]`, repeat the steps above and run `flowsavvy auth` again.

## Usage

### Add a single task

```bash
flowsavvy add "Title" "YYYY-MM-DD" "HH:MM" "HH:MM" DURATION_MIN ["Notes"]
#                       due date    start   end     minutes
```

```bash
flowsavvy add "Write report" "2026-04-10" "09:00" "10:30" 90 "Draft + outline"
```

- **Due date**: hard deadline — task must be done by end of this day
- **Start / End**: preferred time window for scheduling (also signals total duration to FlowSavvy)
- **Duration**: total minutes needed (used as minimum session length)
- **Notes**: optional, plain text

### Batch from a TSV file

```bash
flowsavvy batch tasks.tsv
```

TSV format — **tab-separated**, one task per line, no header:

```
Title	Due	Start	End	Duration	Notes
Physics Past Paper	2026-04-15	16:00	16:45	45	30 MCQ timed
History Essay	2026-04-17	16:00	17:30	90	Past question, timed
```

Lines starting with `#` are treated as comments and skipped.

**Pipe from stdin:**
```bash
cat tasks.tsv | flowsavvy batch -
```

### Refresh auth

```bash
flowsavvy auth
```

## Claude Code Skill

If you use [Claude Code](https://claude.ai/code), the included skill lets Claude create FlowSavvy tasks directly from conversation.

Install it manually if `install.sh` didn't find Claude:

```bash
mkdir -p ~/.claude/skills/flowsavvy
cp skills/flowsavvy/SKILL.md ~/.claude/skills/flowsavvy/SKILL.md
```

After that, you can say things like:
> *"Add these study sessions to FlowSavvy"*
> *"Create a FlowSavvy task for the project review on Friday at 14:00, 60 minutes"*

Claude will use `flowsavvy batch` under the hood, passing tasks from a temp TSV.

## How it works

FlowSavvy exposes a private REST API used by its web app. This tool calls `POST /api/Item/Create` with a `multipart/form-data` body matching what the browser sends. Authentication uses the same session cookie and CSRF token as your browser session — which is why you need to grab them from DevTools.

> **Note:** This uses an undocumented internal API. It may break if FlowSavvy changes their API. If something stops working, re-run `flowsavvy auth` first. If that doesn't help, open an issue.

## License

MIT
