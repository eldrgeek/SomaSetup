#!/usr/bin/env bash
# SomaSetup doctor — umbrella health check. Runs whichever phase gates apply and
# prints a one-screen summary. Safe to run anytime.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
echo "════════════════════════════════════════════"
echo " SomaSetup doctor — $(date '+%Y-%m-%d %H:%M')"
echo "════════════════════════════════════════════"
for g in phase0-toolchain phase1-site phase2-daemon; do
  echo
  bash "$HERE/$g.sh" || true
done
echo
echo "Re-run any phase gate directly, e.g.: bash checks/phase1-site.sh"
