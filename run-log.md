# SomaSetup run log

CDCC appends here: what failed during an install and what fixed it.
Each entry is a candidate improvement to SOMASETUP.md / recovery.md.

---

## 2026-07-04 — VM dry-run attempt (background subagent) — BLOCKED at screen access

**Runner:** SOMA night-shift worker (background subagent), authorized by Mike (informed, not vetoed).
**Goal:** Execute the never-run Stage-0 VM dry-run and log what actually happens.

**What was attempted (in order):**
1. Loaded computer-use tools via ToolSearch — OK (request_access, screenshot, list_granted_applications, open_application all resolved).
2. `request_access(apps=["UTM"])` — **TIMED OUT after 300s.** The approval dialog requires an interactive human "Allow" click; nothing answered it from the background context.
3. `list_granted_applications` — returned empty allowlist (`allowedApps: []`), confirming the grant never went through.
4. `screenshot` — errored: "No applications are granted for this session. Call request_access first."

**Result:** Could not obtain visual+control access to the screen. The dry-run needs computer-use to drive UTM's Setup Assistant (a native macOS GUI), and request_access cannot be approved non-interactively from a background subagent.

**Conclusion:** VM dry-run needs foreground/interactive computer-use. It cannot run from a background subagent. The COO should run it inline (a session where the request_access dialog can be approved).

**Install phase reached:** 0 (never booted the VM — blocked before touching UTM).

**No host environment, keychain, or account was touched. No VM was booted.**

---
