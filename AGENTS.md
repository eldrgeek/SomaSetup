# SomaSetup Agent Guidance

**Status:** Active repo-local guidance
**Authorship:** Mike Wolf direction + Codex (GPT-5) synthesis, 2026-06-26

## Read Order

1. `README.md` for mission and safety invariants.
2. `SOMASETUP.md` for the executable runbook.
3. `profiles/legends.yaml` for the active profile.
4. `recovery.md` before improvising on failed installs.
5. `SOMA-ENV-GUIDE.md` when preparing Greg's ongoing Claude Project context.

## Mission Focus

This repo exists to put the SOMA development environment in Greg's hands, starting
with Legends.

- **Priority 1:** build the Legends Membership Services/Bill loop as far and as fast
  as Greg wants to take it.
- **Priority 2:** after Legends is moving, push Playmaker/Playwriting forward with
  Eric as fast as he can move through the naming/product transition.

If Mike, Greg, or an agent starts wandering into adjacent SOMA ideas before the active
goal is done, say so gently and help steer back unless Mike or Greg explicitly changes
the goal. This is an explicit collaboration preference, not a lack of imagination.

If someone says "Playwright" in this product context, confirm whether they mean the
Playmaker/Playwriting product or the Playwright browser automation library before
acting.

## Execution Rules

- Keep first launch on the `legends` profile unless instructed otherwise.
- Do not enable email polling, auto-dispatch, or cc-dispatch for Greg's first launch.
  The daemon starts queue-only; Greg is the build worker.
- Never push to `master` or start the daemon without explicit Greg confirmation.
- Use CiC in Greg's real Chrome for browser logins. Do not use headless/automation
  browsers for Google login flows.
- Never echo secrets. Write them to the target location, `chmod 600`, and verify only
  with a masked fingerprint.
- When you create a doc or materially improve one, add an authorship/update note with
  Mike's role, the AI/model if known, and the date/context of the pass.
