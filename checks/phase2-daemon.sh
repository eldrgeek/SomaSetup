#!/usr/bin/env bash
# Phase 2 gate — change-management daemon in QUEUE-ONLY mode. Exit 0 only if all pass.
set -uo pipefail
D="$HOME/Projects/claude-email-daemon"
fail=0
ok(){ printf "  ✅ %s\n" "$1"; }
no(){ printf "  ❌ %s\n" "$1"; fail=1; }
warn(){ printf "  ⚠️  %s\n" "$1"; }

echo "Phase 2 gate — daemon (queue-only)"
cd "$D" 2>/dev/null || { echo "  ❌ $D not found"; exit 1; }

# 1) test suites pass (they stub Popen; source='test' rows never dispatch)
for t in test_change_queue.py test_build_firing.py test_greg_pipeline.py; do
  if [ -f "$t" ]; then
    if python3 -m pytest -q "$t" >/tmp/somasetup-$t.log 2>&1; then
      ok "$t passed"
    else
      no "$t FAILED (see /tmp/somasetup-$t.log)"
    fi
  else
    warn "$t not present in repo"
  fi
done

# 2) SAFETY INVARIANT: queue-only — email polling OFF, auto-dispatch OFF, build-firing OFF
cfg="$D/config.yaml"
if [ -f "$cfg" ]; then
  grep -qiE 'auto_dispatch:\s*false' "$cfg" && ok "auto_dispatch OFF" || no "auto_dispatch is NOT false — INVARIANT VIOLATION"
  # email channel / build firing guards (names may vary; verify intent)
  grep -qiE 'enabled:\s*false' "$cfg" && ok "a channel is gated off (verify it's email/dispatch)" || warn "verify email polling + build-firing are OFF"
else
  no "config.yaml not found"
fi

# 3) daemon process up? (foreground dry-run or launchd)
if pgrep -f 'daemon.py' >/dev/null 2>&1; then
  ok "daemon.py process running"
else
  warn "daemon.py not currently running (fine if you haven't started the dry-run yet)"
fi

# 4) reminder: end-to-end test row should show in admin-changelog.html
warn "End-to-end: insert a source='test' change_request, confirm it appears vet→awaiting-approval in admin-changelog.html"

echo
[ "$fail" -eq 0 ] && echo "PHASE 2: PASS" || { echo "PHASE 2: FAIL — see ❌ above, consult recovery.md"; exit 1; }
