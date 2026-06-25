# SOMASETUP — master agent instruction file

You (Claude Code in Claude Desktop, "CDCC") are setting up a Soma site on a fresh Mac
for a non-developer. Read this whole file, then read the profile named in your
instruction (`profiles/<profile>.yaml`; default `legends`). Execute the phases in
order. **This is an executable runbook, not documentation — do the steps.**

---

## 0. Operating rules (apply to every phase)

1. **Idempotent & resumable.** Before doing a step, check whether it's already done
   (tool already installed, repo already cloned, secret already present). Skip or
   update rather than redo. The whole script must be safe to re-run.
2. **Test as you go.** Every phase ends with a **gate**: run the named `checks/*.sh`
   script (or the inline checks) and do not proceed until it passes. The gate IS the
   definition of "phase done."
3. **Self-heal, then self-harden.** On a failed step or gate, consult `recovery.md`
   for a known fix before improvising. When you fix something not covered there,
   append it to `~/Projects/SomaSetup/run-log.md` (what failed, what fixed it). If you
   have push access, open a PR to SomaSetup with the improvement.
4. **Never echo secrets.** When you receive a key, write it to the target file and
   `chmod 600`. Never print it back into the chat, never paste it into a commit, never
   put it in `run-log.md`. Verify by reading back only a masked fingerprint
   (e.g. last 4 chars).
5. **STOP-and-ask checkpoints.** Pause and ask the human at every 🛑 marker below:
   secrets entry, any login Google might challenge, and the two go/no-go confirms
   (before first push to `master`, before starting the daemon). Do not bypass these
   even in Auto mode.
6. **Browser work goes through CiC** in the user's real Chrome with "Sign in with
   Google." Never drive a headless/automation browser for a login — Google blocks it.
7. **Narrate in plain language.** The user is not a developer. Say what you're doing
   and what you need from them, in short, friendly sentences.
8. **Honor the profile's safety invariants** (e.g. daemon defaults). They override
   convenience.

---

## Phase 0 — Toolchain & agent CLI

**Goal:** a working developer toolchain on the Mac, plus the standalone `claude` CLI
that the daemon needs (Desktop's Code tab is interactive-only and can't serve the
daemon's headless `claude -p` call).

Steps:
1. **Xcode Command Line Tools** — `xcode-select -p` to check; if missing, run
   `xcode-select --install` and tell the user to click **Install** and wait. This
   also provides `git`.
2. **Homebrew** — check `brew --version`; if missing, install from
   https://brew.sh (run the official non-interactive script). Add it to PATH for the
   current shell and for `~/.zprofile`.
3. **Core packages via brew:** `node`, `python@3.12`, `gh`, `ollama`. Verify each.
4. **Netlify CLI:** `npm install -g netlify-cli`. Verify `netlify --version`.
5. **Standalone Claude Code CLI (Greg's own model key):** `npm install -g
   @anthropic-ai/claude-code` (or the official native installer). Verify
   `claude --version`, then run `claude` once and **sign it into Greg's own Claude
   account** — model usage is billed to Greg, not Mike. This is separate from the
   Desktop app you're running inside, but uses the same account.
   - If this profile needs an **OpenAI** key anywhere, prompt Greg for **his own**
     (note: a ChatGPT subscription is not an API key — he creates a key at the OpenAI
     dashboard). Do not use a Mike-owned model key.
6. **Local model for the daemon:** `ollama pull qwen2.5:7b` (the daemon's fast
   first-pass classifier — local and free, no key). Start the Ollama service if not
   running.

> **Key-ownership rule (per Mike):** model/LLM keys are **Greg's own** (this step);
> infra keys (Supabase, ElevenLabs, Netlify, Gmail) are **Mike's**, pasted at the
> Phase 1 secrets checkpoint. See `key_ownership` in the profile.
7. 🛑 **GitHub auth:** run `gh auth login` (HTTPS, browser device flow). **Use CiC**
   to complete the device-flow approval in Chrome. Confirm `gh auth status`.

**Gate:** run `checks/phase0-toolchain.sh`. It must report every tool present and
`gh` authenticated. Do not continue until green.

---

## Phase 1 — Repos, secrets, and the live site loop

**Goal:** the four product repos cloned, secrets in place, and a proven
edit → push → deploy loop, with the embedded agent (Bill) answering.

Steps:
1. **Clone the profile's repos** into `~/Projects` (see `repos:` in the profile).
   They're private; this works now that `gh` is authenticated. Check out `master` on
   each and confirm a clean working tree (see `recovery.md` for the branch-drift and
   stale-lock gotchas).
2. 🛑 **Secrets checkpoint (infra keys = Mike's).** For each entry in the profile's
   `secrets:` list, ask the user to paste the value (Mike supplies these out-of-band,
   over a secure channel — not in the bootstrap email). Write each to its `target`
   path and `chmod 600`. Record only a masked fingerprint. Do **not** invent or guess
   any key. (Model keys were already set to Greg's own in Phase 0 — don't ask Mike for
   those.)
3. **Netlify auth/link:** `netlify login` (🛑 CiC handles the browser approval).
   Confirm the site links named in the profile resolve (`netlify status` in the linked
   dirs). Do not change production settings.
4. **Verify the agent + auth components are wired** (the profile's `components:` —
   `soma-agent` = the SOMA-Guide engine loaded from the CDN; `soma-auth` = Supabase
   magic-link). Confirm the site's pages reference the current engine version and that
   `soma-auth` config points at the right Supabase project (read these from the cloned
   repos / their `BILL-HANDOFF.md`; do not hardcode here).
5. **Prove the edit→deploy loop (low-risk):** make a trivial, reversible change (e.g.
   an HTML comment with today's date) on a `legends-membership` page.
   🛑 **Go/no-go #1:** confirm with the user before pushing. On yes:
   `git push origin HEAD:master`. Watch Netlify deploy; confirm the change is live at
   the site URL.
6. **Engine (soma-agent) deploy path** — verify only, don't ship a change unless asked:
   confirm you can build the manual CDN deploy (`cp packages/soma-guide/soma-guide.js
   dist/` → `netlify deploy --prod --dir=dist`) and that a version bump + hard-refresh
   would show the new `SOMA_GUIDE_VERSION`. (This path is manual by design.)

**Gate:** run `checks/phase1-site.sh`. It confirms repos present on `master`, secrets
files exist with `600` perms, the site URL serves 200, Bill's text Q&A endpoint
responds, and the engine version string is reachable. Then do one **live smoke test
with the user**: open the site in CiC, trigger Bill, ask one text question (exercises
CDN + inference) and, if voice is in scope, do one voice turn (exercises the el-proxy
+ ElevenLabs). Green = phase done.

---

## Phase 2 — Change-management daemon (queue-only)

**Goal:** the daemon running in a **safe, non-colliding** mode so Greg can see and
approve the change queue, with himself as the build worker.

⚠️ **Safety invariant (from the profile):** start the daemon with **email polling OFF
and auto-dispatch OFF**. A second daemon polling the shared Supabase queue and the
shared `claude@mike-wolf.com` mailbox will double-dispatch. Set the profile's
`daemon.mode: queue-only` config before first start.

Steps:
1. Confirm the daemon's `.env` (Supabase URL + service key) is present from Phase 1's
   secrets step, `chmod 600`.
2. Apply the queue-only config (email off, `auto_dispatch: false`, build-firing off).
   Keep `second_opinion` pointed at the `claude` CLI installed in Phase 0.
3. **Run the existing test suites first** (these stub `Popen`; the live daemon never
   dispatches `source='test'` rows): `test_change_queue.py`, `test_build_firing.py`,
   `test_greg_pipeline.py`. All must pass.
4. 🛑 **Go/no-go #2:** confirm with the user before starting the daemon. On yes, start
   it (foreground first to watch logs; only install the launchd service once a dry run
   looks clean).
5. **End-to-end queue test:** insert a `source='test'` `change_request` and watch it
   flow vet → awaiting-approval in `admin-changelog.html`. Approve it; confirm Greg
   can open it and run a build himself in CDCC. Do **not** enable auto-dispatch.

**Gate:** run `checks/phase2-daemon.sh`. It confirms the test suites pass, the daemon
process is up in queue-only mode (email off, auto-dispatch off), and a test row
appears in the queue UI. Green = phase done.

---

## Phase 3 — Auto-dispatch (cc-dispatch) — OPT-IN, DEFERRED

**Do not run this unless the user explicitly asks for hands-off automation.** This
stands up `cc-dispatch` + `mac-controller` so the daemon can fire builds by driving
Claude Code itself. It is the fragile, machine-specific piece, and Greg does not need
it to maintain the site — he is the worker. If asked, treat it as its own project with
its own gates. Otherwise stop after Phase 2.

---

## Done

When Phase 2 is green: summarize for the user what's installed, what's live, the
masked fingerprints of the secrets you stored (not the values), and the daily loop
("open Code, describe the change, I'll make it, you approve, we push"). Append the run
summary and any fixes to `run-log.md`, and open the self-hardening PR if you can.

Then tell Mike (via the user) that first launch is green and that **skill #2
(`skills/provision-accounts.md`) — moving Greg to his own ElevenLabs/Supabase keys —
is the next build.**
