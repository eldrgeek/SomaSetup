# SomaSetup

**Status:** Active setup kit for putting a SOMA/Legends development environment in Greg's hands
**Authorship:** Mike Wolf + prior AI setup collaborators; 2026-06-26 Codex (GPT-5) added mission, focus, and authorship guidance.

Agent-driven, self-healing installer for standing up a Soma site on a fresh Mac.
The human runs ~5 trust-gate clicks; **Claude Code in Claude Desktop (CDCC)** does
everything else — installs the toolchain, clones the repos, wires secrets, brings
up the services, and **runs tests as it goes**, fixing the install procedure when a
gate fails.

This version ships **profile #1: `legends`** — the Legends of Basketball membership
site, which includes **soma-agent** (the SOMA-Guide / "Bill" engine) and
**soma-auth** (Supabase magic-link). Future profiles reuse the same machinery to
stand up any Soma site.

## Mission and focus

This repo exists to put Greg in control of the practical SOMA development environment,
starting with Legends. The priority order is:

1. **Legends first:** build the Legends Membership Services/Bill loop as far and as
   fast as Greg wants to take it.
2. **Playmaker/Playwriting second:** after Legends is moving, push the Playmaker
   product/naming work with Eric as fast as he can move. Do not confuse this with
   Playwright browser automation unless the task is explicitly about tests or browser
   control.

If an AI notices Mike, Greg, or itself wandering into adjacent SOMA ideas before the
active goal is done, it should say so gently and steer back to the current Legends or
Playmaker priority unless Mike explicitly changes the goal. This is not resistance;
Mike asked for focus help.

## How it works

1. **Greg does Stage 0** (`STAGE0-GREG.md`) — the only manual part. Five clicks:
   install Claude Desktop on a Pro/Max plan, enable computer use + grant the two
   macOS permissions, install & pair **Claude in Chrome (CiC)**. These are OS/browser
   trust gates that are *designed* to require a human; we don't fight them.
2. **Greg pastes the bootstrap email** (`BOOTSTRAP-EMAIL.md`) into a CDCC session.
   The email is short and trusted: it sets the permission mode, clones this repo,
   and tells CDCC to read `SOMASETUP.md` with `profile=legends` and execute.
3. **CDCC runs `SOMASETUP.md`** phase by phase. Each phase ends in a **test gate**
   (`checks/*.sh`) that must pass before the next phase starts. On failure it
   consults `recovery.md`, fixes, and re-runs.
4. **CiC handles every browser/login step** in Greg's *real* Chrome, where he's
   already signed into Google — so "Sign in with Google" is one click, no password,
   no 2FA wall. (Playwright is deliberately **not** in the critical path; Google
   blocks automation browsers.)

## What's automated vs. manual

| Step | Who | Why |
|---|---|---|
| Install Desktop (Pro/Max), grant Mac perms, install+pair CiC | **Greg** | Trust gates — resist automation by design |
| Xcode CLT, Homebrew, node, python, git, `gh`, Netlify CLI, **standalone `claude` CLI**, Ollama + `qwen2.5:7b` | CDCC (Bash) | Pure shell |
| Clone the four repos, write `.env` (chmod 600) | CDCC | Pure shell |
| GitHub / Netlify / Google logins, key retrieval | CDCC **via CiC** | Real Chrome + Greg's Google session |
| Run every phase's tests, self-heal, log fixes | CDCC | The whole point |

## Files

- `BOOTSTRAP-EMAIL.md` — the copy/paste blob Greg drops into CDCC.
- `STAGE0-GREG.md` — the ~5-click human guide (screenshots to be added).
- `SOMASETUP.md` — the master agent instruction file CDCC executes.
- `profiles/legends.yaml` — repos, components, required secrets (by name), services,
  daemon defaults, and the per-phase test gates for Legends.
- `checks/` — runnable test-gate scripts (`doctor.sh`, `phase0/1/2`).
- `recovery.md` — known-failure → fix hints CDCC consults before improvising.
- `skills/provision-accounts.md` — **skill #2 (stubbed)**: CiC flows to provision
  Greg's *own* ElevenLabs/Supabase accounts. Not on the first-launch path.

## Secrets model

**No secrets live in this repo or in the bootstrap email.** Key ownership splits two ways:

- **Model / LLM keys are Greg's own, from day one** — the standalone `claude` CLI is
  signed into *Greg's* Claude account (model usage billed to him), his own OpenAI key
  if a profile needs one, and local Ollama (free). Set up in Phase 0.
- **Infra keys are Mike's, for now** — Supabase, ElevenLabs, Netlify, Gmail. CDCC
  *prompts Greg to paste each one* (Mike supplies them over a secure channel) and
  writes it straight to the right `.env` at `chmod 600`, never echoing it back.

Graduating Greg's **infra** to his own accounts is `skills/provision-accounts.md`
(skill #2), built after first launch is green. Model keys need no migration — they're
already his.

## Safety invariants (non-negotiable)

1. **The daemon starts in queue-only mode** (email polling OFF, auto-dispatch OFF).
   Two daemons against the same Supabase queue / `claude@mike-wolf.com` mailbox will
   double-dispatch. The `legends` profile enforces this default.
2. **Never push to `master` or start the daemon without an explicit Greg confirm.**
3. **cc-dispatch (auto build-worker) is Phase 3, opt-in only.** It's the fragile,
   machine-specific piece and Greg doesn't need it to maintain the site — he is the
   worker (runs CDCC on approved queue items himself).
4. **Recommend Auto permission mode**, not full Bypass, for an unattended install on
   a non-developer's machine.

## Hosting note (for Mike)

This repo is written to be **public-safe**: it contains no credentials, and
infra-specific IDs (ElevenLabs agent IDs, Supabase project ref) are deferred to the
private legends repos rather than duplicated here. Hosting it public means the
bootstrap clone needs no auth on a bare machine. If you'd rather keep it private,
the email's first step becomes `gh auth login` (CiC handles the device flow) before
the clone. The four product repos (`eldrgeek/legends-membership`, `soma-platform`,
`bill-talk`, `claude-email-daemon`) are cloned in Phase 1 after GitHub auth.

## Self-hardening

Every run appends to `run-log.md` what CDCC had to fix, and (if it has push access)
opens a PR back to this repo with the improvement. Each install makes the next one
cleaner.
