# AdaptRise build-prompt kit

## Steps
1. PowerShell in VS Code:
   mkdir E:\Projects\VSCode\PostOmniroute\AdaptRise; cd E:\Projects\VSCode\PostOmniroute\AdaptRise; git init
2. Codex desktop (kr-codegen-claude): open that folder, paste STARTER A followed by the BUILD PROMPT. Iterate until it writes final PLAN.md, CHECKLIST.md, DECISIONS.md into the repo. Commit: `docs: initial plan`.
3. VS Code agent (kr-codegen-gemini): new session in the repo, paste STARTER B. Approve its Phase 1 plan, then let it run item by item.
4. Test on the phone and watch only when it asks for Session T1, T2 or T3.

---

## STARTER A — Codex desktop (planning/review loop)
```
You are the planner and reviewer for AdaptRise. You write and refine docs only; you never write app code. Below is the BUILD PROMPT. Produce PLAN.md, CHECKLIST.md and DECISIONS.md in the repo root, exactly as it specifies. Before writing, list any contradictions, infeasible items or missing decisions and propose fixes. Never invent metrics, APIs or library versions — mark anything unverified as "VERIFY". Do not touch ~/.codex/config.toml. No assistant/AI attribution anywhere (D-011 rule). When done, print the paths of every file you wrote and STOP.
Later in this conversation I'll paste agent reports or diffs; review them against the three docs and reply: VERDICT (approve / changes) / ISSUES / DOC CHANGES NEEDED.
```

## BUILD PROMPT
```
Project: AdaptRise — adaptive sleep-shift alarm with a smart wake window. Public GitHub portfolio project, public on GitHub by Sat 7 Nov 2026, explained by the author at GDG Bangalore Flutter Meetup on 19 Nov 2026. Repo: E:\Projects\VSCode\PostOmniroute\AdaptRise.

DEVICES: Samsung Galaxy S24 Ultra (Android 14+ target, latest stable SDK) + Galaxy Watch 4 (Wear OS). Dev machine: Windows, PowerShell in VS Code.

ARCHITECTURE
- Phone: Flutter app (Dart, stable channel). Holds the showcase: adaptive-target engine (pure Dart, fully unit tested), sleep history + "sleep-shift timeline" screen (target vs actual wake per day, with a note on each adjustment the engine made), settings, onboarding/permissions flow.
- Native Android layer in the phone app (Kotlin), called via platform channels (MethodChannel/EventChannel, or Pigeon for typed APIs): Health Connect reads (sleep sessions, stages if present), exact alarm scheduling, full-screen alarm, foreground service for the wake window, Wear Data Layer receiver.
- Watch: native Kotlin Wear OS app (Compose for Wear OS). Streams accelerometer + heart rate to the phone only during the wake window, shows a custom alarm face with a gentle vibration ramp (not a stock dialog), dismiss/snooze syncs to phone.
- Optional backup: one fixed alarm per night via AlarmClock.ACTION_SET_ALARM. Apps cannot reliably edit/delete those; user clears old ones manually. Record as a decision.

FEATURES
1. Read past sleep sessions from Health Connect (synced from Samsung Health). After-the-fact data is enough for history and the adaptive target.
2. Adaptive target: if user oversleeps or sleeps late, ease the next wake time, then ramp back toward the goal. Rule must be deterministic, configurable (max shift per day, ramp rate) and explained in the timeline notes.
3. Smart wake window (e.g. 30 min, configurable): app rings at the lightest moment detected from live watch motion/HR within the window; always rings at window end. Start with a simple, documented threshold heuristic; tune only against recorded sample data. Never claim accuracy figures not measured.
4. Local-only data; no accounts, no cloud, no analytics.

DAY-1 RISK SPIKES (gate everything else)
R1 Health Connect sleep data reaches Flutter (verify whether stages sync or only start/end).
R2 Watch streams accelerometer + HR to phone over Data Layer with the phone locked.
R3 Exact alarm + full-screen intent rings with phone locked; survives Samsung battery optimisation (document required user settings).
If one fails, propose a scope cut in DECISIONS.md and stop for approval.

DESIGN (must not look generic)
Use the ui-ux-pro-max-skill to define one specific visual direction (palette, type scale, motion, dark-first night theme) in PLAN.md before UI work. Standout screens: sleep-shift timeline, custom watch alarm face, polished empty/loading/permission states.

TESTING POLICY (important)
- Agents run all automated checks themselves: flutter analyze, dart format check, flutter test (engine coverage ≥90%), Kotlin unit tests + ktlint/detekt, Gradle builds, emulator runs, recorded-sample-data replays.
- The author tests on real devices ONLY three times, each with a full checklist in CHECKLIST.md:
  T1 end of Day 1 — R1–R3.
  T2 night of Day 3 — one full real night: wake window, watch vibration ramp, backup alarm, next-morning adaptive target + timeline note.
  T3 Day 4 — release build, demo flow, UI end to end.
- Never ask the author to try small changes between sessions.

SCHEDULE
Day 1 (Wed 4 Nov) scaffold + risk spikes → T1. Day 2 engine + detector + history. Day 3 end to end, design polish → T2 overnight. Day 4 fixes from T2, README (architecture diagram, demo GIF, honest limitations), CI, public release → T3. 15–18 Nov reserved for the author to study and rebuild one piece by hand; no new features then.

TOOLING
- Coding: VS Code agent on OmniRoute combo kr-codegen-gemini (1M context).
- Review: review-loop skill calling `codex exec -m kr-codegen-claude --sandbox read-only`, scoped to the git diff plus touched files (fits 200K). Max 6 rounds; stop early if the same issue repeats twice.
- Claude reviewer access ends 18 Nov; fallback reviewer = highest Gemini 3.8 Flash tier. Record as a decision.
- Never modify ~/.codex/config.toml; OmniRoute stays default.
- Skills to use: superpowers + andrej-karpathy-skills (coding approach), systematic-debugging (failures), ui-ux-pro-max-skill (design), security-review + review (pre-commit), marketing skills (README/pitch only).
- CI: GitHub Actions on ubuntu-latest — Flutter analyze/test, Gradle build + Kotlin tests for phone native and watch modules.

RULES
Conventional commits; one CHECKLIST item at a time; tick only when acceptance passes with real pasted output; every report lists changed file paths; no secrets in repo; no AI/assistant attribution anywhere (D-011); never invent metrics/APIs; if docs must change, stop and ask.

OUTPUT
PLAN.md: goal, architecture diagram (mermaid), module/file tree (flutter app, android native, wear module), platform-channel API, engine rules, detector heuristic, design direction, permissions list, risks, schedule.
CHECKLIST.md: phases matching the schedule, numbered items with acceptance criteria and exact PowerShell commands; T1–T3 device checklists in full.
DECISIONS.md: D-001 onward (native watch app, backup alarm limits, local-only data, testing policy, reviewer fallback, design direction, D-011, etc.).
Report format for agents: ITEM / DONE / FILES CHANGED / COMMANDS RUN + RESULTS / CODEX REVIEW / HOW TO VERIFY / DEVIATIONS / KNOWN ISSUES / NEXT
```

## STARTER B — VS Code agent (coding)
```
Read PLAN.md, CHECKLIST.md and DECISIONS.md in full. They are the reviewed source of truth for AdaptRise; follow them exactly.
Setup: create .github/copilot-instructions.md (and keep CLAUDE.md consistent if present) with conventions and PowerShell commands (flutter analyze, dart format, flutter test --coverage, gradlew builds/tests, ktlint/detekt). New decisions go in DECISIONS.md as the next D-number.
Now plan Phase 1 only (scaffold + R1–R3 spikes): file tree, packages/dependencies with versions marked VERIFY until checked, Gradle/Flutter config, platform-channel stubs, and exact PowerShell commands. Flag contradictions or infeasible items. Then STOP for my approval.
Rules: one item at a time; use superpowers/karpathy skills for approach, systematic-debugging on failures, ui-ux-pro-max-skill for any UI, security-review before commits; run all automated checks yourself and paste real output; run the review-loop skill on the diff before each commit; never ask me to test on devices except at T1/T2/T3 with the full checklist; never touch ~/.codex/config.toml; never invent metrics; D-011; if docs must change, stop and ask.
Report: ITEM / DONE / FILES CHANGED / COMMANDS RUN + RESULTS / CODEX REVIEW / HOW TO VERIFY / DEVIATIONS / KNOWN ISSUES / NEXT
```
