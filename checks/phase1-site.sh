#!/usr/bin/env bash
# Phase 1 gate — repos, secrets, live site loop. Exit 0 only if all pass.
# Run after cloning. A LIVE human smoke test (open site in CiC, trigger Bill) is
# still required in addition to this script — see SOMASETUP.md Phase 1 gate.
set -uo pipefail
P="$HOME/Projects"
fail=0
ok(){ printf "  ✅ %s\n" "$1"; }
no(){ printf "  ❌ %s\n" "$1"; fail=1; }
warn(){ printf "  ⚠️  %s\n" "$1"; }

echo "Phase 1 gate — repos, secrets, live site"

# 1) repos present on master
for r in legends-membership-site soma-platform bill-talk claude-email-daemon; do
  if [ -d "$P/$r/.git" ]; then
    b=$(git -C "$P/$r" rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ "$b" = "master" ] && ok "$r on master" || warn "$r on '$b' (expected master — see recovery.md branch-drift)"
  else
    no "$r not cloned"
  fi
done

# 2) daemon .env present with 600 perms, holds Supabase URL + key (values not printed)
env="$P/claude-email-daemon/.env"
if [ -f "$env" ]; then
  perm=$(stat -f '%Lp' "$env" 2>/dev/null || stat -c '%a' "$env" 2>/dev/null)
  [ "$perm" = "600" ] && ok ".env perms 600" || no ".env perms are $perm (chmod 600 $env)"
  grep -q 'SUPABASE_URL' "$env"        && ok ".env has SUPABASE_URL"        || no ".env missing SUPABASE_URL"
  grep -q 'SUPABASE_SERVICE_KEY' "$env" && ok ".env has SUPABASE_SERVICE_KEY" || no ".env missing SUPABASE_SERVICE_KEY"
else
  no ".env not found at $env (secrets checkpoint not completed)"
fi

# 3) site is live (read the canonical URL from the repo if present)
url=""
[ -f "$P/legends-membership-site/LIVE-URL.txt" ] && url=$(tr -d '[:space:]' < "$P/legends-membership-site/LIVE-URL.txt")
[ -z "$url" ] && url="https://legends-membership.netlify.app"
code=$(curl -s -o /dev/null -w '%{http_code}' "$url" 2>/dev/null)
[ "$code" = "200" ] && ok "site live ($url → 200)" || no "site $url returned $code"

# 4) soma-agent engine reachable + version string present
eng="https://soma-guide.netlify.app/soma-guide.js"
if curl -s "$eng" 2>/dev/null | grep -qE 'SOMA_GUIDE_VERSION'; then
  ver=$(curl -s "$eng" 2>/dev/null | grep -oE "SOMA_GUIDE_VERSION\s*=\s*['\"][^'\"]+" | head -1 | grep -oE "[^'\"]+$")
  ok "soma-agent engine reachable (version ${ver:-?})"
else
  no "soma-agent engine not reachable at $eng"
fi

# 5) Bill text Q&A backend — best-effort (exact endpoint lives in the repo config).
warn "Bill text Q&A + voice: verify LIVE in CiC (ask one question; one voice turn if in scope)"

echo
[ "$fail" -eq 0 ] && echo "PHASE 1: PASS (now do the live CiC smoke test)" || { echo "PHASE 1: FAIL — see ❌ above, consult recovery.md"; exit 1; }
