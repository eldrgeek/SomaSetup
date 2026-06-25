#!/usr/bin/env bash
# Phase 0 gate — toolchain + agent CLI. Exit 0 only if everything is present.
set -uo pipefail
fail=0
ok(){ printf "  ✅ %s\n" "$1"; }
no(){ printf "  ❌ %s\n" "$1"; fail=1; }

echo "Phase 0 gate — toolchain & agent CLI"

command -v git        >/dev/null 2>&1 && ok "git $(git --version | awk '{print $3}')"            || no "git missing (xcode-select --install)"
command -v brew       >/dev/null 2>&1 && ok "homebrew $(brew --version | head -1 | awk '{print $2}')" || no "homebrew missing"
command -v node       >/dev/null 2>&1 && ok "node $(node --version)"                              || no "node missing (brew install node)"
command -v python3    >/dev/null 2>&1 && ok "python $(python3 --version | awk '{print $2}')"      || no "python3 missing (brew install python@3.12)"
command -v gh         >/dev/null 2>&1 && ok "gh $(gh --version | head -1 | awk '{print $3}')"     || no "gh missing (brew install gh)"
command -v netlify    >/dev/null 2>&1 && ok "netlify $(netlify --version 2>/dev/null | head -1)"  || no "netlify CLI missing (npm i -g netlify-cli)"
command -v claude     >/dev/null 2>&1 && ok "claude CLI $(claude --version 2>/dev/null | head -1)" || no "standalone claude CLI missing (npm i -g @anthropic-ai/claude-code)"
command -v ollama     >/dev/null 2>&1 && ok "ollama $(ollama --version 2>/dev/null | awk '{print $NF}')" || no "ollama missing (brew install ollama)"

# gh authenticated?
gh auth status >/dev/null 2>&1 && ok "gh authenticated" || no "gh not authenticated (gh auth login — use CiC for the device flow)"

# local model present?
ollama list 2>/dev/null | grep -q 'qwen2.5:7b' && ok "qwen2.5:7b pulled" || no "qwen2.5:7b not pulled (ollama pull qwen2.5:7b)"

# Greg's own model auth (revision): the claude CLI should be signed into Greg's account.
claude whoami >/dev/null 2>&1 && ok "claude CLI signed in (Greg's own account)" || printf "  ⚠️  could not confirm claude CLI login — run 'claude' once and sign in with Greg's account\n"

echo
[ "$fail" -eq 0 ] && echo "PHASE 0: PASS" || { echo "PHASE 0: FAIL — see ❌ above, consult recovery.md"; exit 1; }
