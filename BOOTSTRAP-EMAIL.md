# Bootstrap email — what Mike sends Greg

Greg pastes the block below into a **new Claude Desktop → Code session** (after
finishing the five Stage-0 clicks). Keep the email short and trusted: it carries no
secrets, just sets the mode and hands CDCC the versioned instructions.

---

## Subject: Setting up Legends on your Mac — paste this into Claude

Hey Greg — you've done the five setup clicks (Claude Desktop on Pro/Max, computer
use + Mac permissions, Claude in Chrome installed & paired). Now:

1. Open Claude Desktop, click the **Code** tab, start a **new session**.
2. Set the mode (next to the send button) to **Auto**.
3. Select a project folder when asked — use or create **`~/Projects`**.
4. Paste everything between the lines below as your first message, and send it.

I'll be reachable if Claude hits something it needs me for. It'll ask you to paste a
few keys and to approve a couple of website logins — that's expected.

— Mike

```
You are setting up the Legends of Basketball maintenance environment on this Mac for
Greg, a non-developer. You have: an integrated terminal/Bash, file tools, computer
use, and Claude in Chrome (CiC) already installed and paired. Greg is signed into
Chrome with his Google account.

Do this:

1. Clone the SomaSetup instructions:
   git clone https://github.com/eldrgeek/SomaSetup.git ~/Projects/SomaSetup
   (If git prompts to install Xcode Command Line Tools, tell Greg to click "Install"
   in the dialog and wait for it to finish, then continue.)

2. Read ~/Projects/SomaSetup/SOMASETUP.md in full, then read
   ~/Projects/SomaSetup/profiles/legends.yaml. Follow SOMASETUP.md exactly, with
   profile = legends.

3. Honor its operating rules: run each phase's test gate before moving on, consult
   recovery.md before improvising, NEVER echo a secret back into the chat, and STOP
   and ask me/Greg at the marked checkpoints (secrets, logins, and the two go/no-go
   confirmations before pushing the site live or starting the daemon).

4. For all website logins and key retrieval, use CiC in Greg's real Chrome and
   "Sign in with Google." Do not use a headless/automation browser for logins.

Start now. Narrate what you're doing in plain language for Greg, and tell him exactly
when you need him.
```

---

## Notes for Mike (not part of the email)

- **Secrets are handled in-session, not here.** When CDCC reaches the secrets
  checkpoint it will ask Greg to paste each key. Send Greg the keys over a **separate
  secure channel** (1Password share / Signal), not in this email. The keys needed are
  listed by name in `profiles/legends.yaml` under `secrets:`.
- **If you host SomaSetup private** instead of public, add one line before the clone:
  `gh auth login` (CiC will handle the device-flow approval in Chrome) — but `gh`
  isn't installed until Phase 0, so the simplest path is to keep SomaSetup public
  (it has no secrets) and let the four private product repos get cloned in Phase 1
  after GitHub auth is set up.
- **Repo name:** the email assumes you push this kit to
  `github.com/eldrgeek/SomaSetup`. Change the URL if you put it elsewhere.
