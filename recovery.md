# recovery.md — known failures → fixes

Consult this before improvising. When you fix something not listed here, append the
failure + fix to `run-log.md` and (if you can push) open a PR adding it here.

## Toolchain (Phase 0)

- **`git` triggers a popup / not found** → Xcode Command Line Tools aren't installed.
  Run `xcode-select --install`, tell Greg to click **Install**, wait for it to finish,
  retry. Don't proceed until `git --version` works.
- **`brew` not on PATH after install** → add `eval "$(/opt/homebrew/bin/brew shellenv)"`
  to the current shell and append it to `~/.zprofile`. Apple Silicon uses
  `/opt/homebrew`; Intel uses `/usr/local`.
- **Desktop can't find `node`/`npm`/`claude`** → Claude Desktop reads `~/.zshrc`/
  `~/.zprofile` for PATH on launch but not other exports. After installing tools,
  fully **quit and reopen** Claude Desktop so the Code session reloads PATH.
- **`gh auth login` browser step stalls** → use CiC to complete the device-flow:
  open the verification URL in Greg's real Chrome, paste the one-time code, approve.
  Confirm with `gh auth status`.
- **standalone `claude` CLI vs Desktop confusion** → they're separate installs that
  share config. The daemon needs the standalone CLI for its headless `claude -p`
  second-opinion call; Desktop's Code tab is interactive-only and can't serve it.
  Sign the CLI into **Greg's own** Claude account (`claude`, then follow login).

## Repos & git (Phase 1)

- **Working tree on the wrong branch** → the legends tree drifts onto
  `preview/review-work-page-and-history`. Check `git rev-parse --abbrev-ref HEAD`;
  push with `git push origin HEAD:master`, then `git checkout master` if needed.
- **Commit silently no-ops / "another git process"** → stale lock from a timed-out
  process. `rm -f .git/HEAD.lock .git/index.lock` and retry.
- **Private repo clone fails** → `gh auth status` first; the four product repos are
  private and need GitHub auth from Phase 0.

## Secrets (Phase 1)

- **Don't have a value** → STOP and ask Greg to paste it (Mike supplies out-of-band).
  Never invent or guess a key. Model keys are **Greg's own**; infra keys are Mike's
  (see `profiles/legends.yaml` → `secrets:` for which is which).
- **After writing any secret** → `chmod 600` the file and confirm by reading back only
  a masked fingerprint (last 4 chars). Never echo the value.

## Site / engine (Phase 1)

- **Engine change didn't show after deploy** → the CDN sets `Cache-Control:
  max-age=300`. Hard-refresh (Cmd-Shift-R) to bypass the 5-min JS cache. Bumping
  `SOMA_GUIDE_VERSION` only invalidates stale sessionStorage, not the JS cache.
- **`git push` to soma-platform didn't update the CDN** → `dist/` is a hand-maintained
  mirror with no build step. Ship with:
  `cp packages/soma-guide/soma-guide.js dist/ && git commit --no-verify && git push &&
  netlify deploy --prod --dir=dist`. The `netlify deploy` is what actually publishes.
- **Bill widget dead** → it's a 4-link external chain (soma-guide CDN, bill-talk
  el-proxy, the ElevenLabs agent, VPS infer/ask). Any one down breaks it. Check each;
  see the repo's `BREADCRUMBS.md` "what breaks what" table.
- **Never re-add Netlify Identity** → it was permanently removed; soma-auth (Supabase
  magic-link) is the only auth.

## Daemon (Phase 2)

- **INVARIANT: queue-only.** Email polling OFF, `auto_dispatch: false`, build-firing
  OFF. A second daemon on the shared Supabase queue / `claude@mike-wolf.com` mailbox
  double-dispatches. If the gate finds these on, fix the config before starting.
- **Restart the daemon (if launchd installed)** →
  `launchctl kickstart -k gui/$(id -u)/com.mikewolf.claude-email-daemon`.
  Prefer a foreground dry-run first; install launchd only after a clean run.
- **Tests need a stubbed dispatcher** → the suites stub `Popen`; the live daemon never
  dispatches `source='test'` rows (env-gated). If a test tries to fire a real build,
  you're not running the test config.

## Browser / CiC

- **A login needs an automation browser** → don't. Use CiC in Greg's real Chrome with
  "Sign in with Google." If Google still challenges, Greg approves 2FA on his phone.
- **CiC not responding** → confirm the extension is pinned and paired with Desktop
  (Stage 0 step 4). Re-pair if needed; this is a human trust gate, so walk Greg through it.
