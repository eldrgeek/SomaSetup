# SOMA Environment Guide — operating Legends

**How to use this file:** add it to your Claude **Project** (as project instructions or
project knowledge). Every chat in that project will then understand how the Legends /
SOMA environment is put together and how to do things in it — so you can say "fix the
typo on the members page" or "Bill isn't talking, what's wrong?" and Claude already has
the context. This is the *operating* guide; the one-time install is handled separately
by SomaSetup.

---

## 1. The mental model

Legends of Basketball is a membership website with an embedded assistant named **Bill**
who can give tours, answer questions, operate on-page controls, and take bug/feature
requests by **text or voice**. Requests flow into one **queue**; you approve them, the
work gets done, you review and accept it. Think of it as: *a website + a helper that
lives on it + a to-do pipeline behind it.*

You don't edit code by hand. You describe what you want in plain language; Claude makes
the change, you approve, and it ships. Your job is direction and judgment, not syntax.

---

## 2. The pieces (repos) and what each is for

All live in `~/Projects`. You rarely touch more than the first one.

| Repo | What it is | When it changes |
|---|---|---|
| **legends-membership-site** | The actual website: pages, members area, the admin **Change Log**, Bill's config & knowledge, tour audio. | Most edits — content, pages, Bill's behavior. |
| **soma-platform** | The shared **soma-agent** engine (Bill's brains, the "SOMA-Guide") used across Soma sites. | When you change how Bill works generally. |
| **bill-talk** | The voice proxy that turns Bill's words into speech (ElevenLabs). Holds the voice key. | Rarely — voice plumbing only. |
| **claude-email-daemon** | The background **daemon** that watches the request queue and helps process it. | Rarely — runs quietly. |

Two reusable building blocks you'll hear named:

- **soma-agent** = the SOMA-Guide engine, i.e. *Bill himself* — the voice+text assistant
  loaded onto the site from a shared address (a CDN). Lives in `soma-platform`.
- **soma-auth** = how members log in: **Supabase magic-link** (they get an email link).
  The reference version lives in `legends-membership-site`. *Note: the old "Netlify
  Identity" login was permanently removed — never bring it back.*

---

## 3. Your daily loop

1. Open **Claude Desktop → Code**, pick the `legends-membership-site` folder.
2. Describe the change ("add a FAQ entry about parking", "Bill should greet returning
   members by name").
3. Claude makes the edit and shows you a preview/diff. You review.
4. **You give the go-ahead to publish.** Claude pushes to `master`; the site
   **auto-deploys** on Netlify within a minute or two.
5. Hard-refresh the page (Cmd-Shift-R) to see it live.

That's it for ordinary content and Bill-config work. The queue/daemon (below) is for
tracking requests that come *in from others*, not for your own direct edits.

---

## 4. How things publish (deploy)

Two different paths — this trips people up, so it's worth knowing:

- **The website** (`legends-membership-site`): **automatic.** Push to `master` →
  Netlify builds and publishes. Live at the URL in the repo's `LIVE-URL.txt`
  (legends-membership.netlify.app).
- **The engine / soma-agent** (`soma-platform`): **manual.** A plain `git push` does
  **not** update it. Claude must copy the file into `dist/` and run
  `netlify deploy --prod --dir=dist`. Also: the engine is cached for 5 minutes, so
  after an engine change, **hard-refresh** to see it. If you ask Claude to "change how
  Bill works," it knows to use this manual path.

---

## 5. The request queue, daemon, and Change Log

- Requests (bugs, feature asks) land in one **queue** (a Supabase table called
  `change_requests`). They arrive from Bill on the site, and — when enabled — by email.
- The admin page **`admin-changelog.html`** is your control panel: **Approve** a
  request to start it, **Review work** to see the result, **Accept** to sign off,
  **Revert** to undo a tracked change, or **Cancel**.
- The **daemon** (`claude-email-daemon`) is a quiet background helper: it watches the
  queue, sanity-checks risky requests, and tracks status. **On your Mac it runs in
  "queue-only" mode** — it shows and vets requests, but **you** are the one who makes
  the build (in Claude Code) and approves it. It deliberately does **not** auto-run
  builds or read email, so it can't collide with Mike's copy.
- Everything Bill says is recorded (a `bill_transcripts` table), so if a conversation
  went sideways you can ask Claude to "pull the last few Bill sessions and tell me where
  it went wrong."

> **Safety invariant — don't change this:** the daemon stays queue-only (no email, no
> auto-dispatch). Two daemons doing the same job against the same shared queue/mailbox
> would step on each other.

---

## 6. When Bill goes quiet — troubleshooting

Bill's voice/answers depend on a **chain of four services**; if any one is down, the
widget breaks:

1. the **soma-agent engine** (the CDN address it loads from),
2. **bill-talk** (the voice proxy),
3. the **ElevenLabs** voice agent,
4. the **VPS inference** backend (for text answers).

If Bill won't talk or answer, ask Claude to "check the Bill chain" — it knows to test
each link and consult the `BREADCRUMBS.md` "what breaks what" table in the site repo.
Bill has three personas, each its own voice: **Bill** (main guide), **Dana** (takes bug
reports), **Quinn** (reviews finished work).

---

## 7. Who pays for what (keys)

- **Models are on your accounts.** The Claude that does your work is signed into *your*
  Claude account, and any other model usage is on your keys. That's billed to you and
  independent of Mike.
- **Infrastructure is on Mike's accounts for now** — the database (Supabase), the voice
  service (ElevenLabs), and hosting (Netlify). Later you'll move these to your own
  accounts (Claude can walk you through it); until then, you use Mike's, and he hands
  you those keys privately when needed.
- **Secrets live in files, never in chat.** Keys are stored in a protected `.env` file
  on your Mac. Claude will never print a key back to you, and you shouldn't paste keys
  into a normal chat — only when Claude explicitly asks during setup.

---

## 8. Good things to ask Claude (in this project)

- "Make this change to the members page and show me before publishing."
- "Bill should stop saying X / should start doing Y." (Claude edits Bill's config.)
- "Something's wrong with Bill's voice — diagnose the chain."
- "What's in the request queue right now? Walk me through approving the safe ones."
- "Deploy the engine change and remind me to hard-refresh."
- "Pull the last 5 Bill conversations and summarize any problems."
- "I want my own Supabase/ElevenLabs accounts now — set them up." (Triggers the
  account-migration flow.)

When in doubt, describe the *outcome* you want. Claude maps it to the right repo,
deploy path, and safety rules.

---

## 9. Cheat-sheet

| Thing | Answer |
|---|---|
| The website | `legends-membership-site` → push to `master` → auto-deploys |
| Bill's brains (soma-agent) | `soma-platform` → **manual** `dist/` deploy + hard-refresh |
| Member login (soma-auth) | Supabase magic-link; **never** re-add Netlify Identity |
| Control panel | `admin-changelog.html` (Approve / Review / Accept / Revert) |
| The queue | Supabase `change_requests`; the daemon vets, **you** build & approve |
| Daemon mode | **queue-only** — no email, no auto-builds (safety invariant) |
| Bill broke | Check the 4-link chain (engine → bill-talk → ElevenLabs → VPS infer) |
| Model bills | Your accounts. Infra (DB/voice/hosting): Mike's, for now |
| See a change live | Hard-refresh (Cmd-Shift-R); engine is cached 5 min |

*Companion docs inside the repos: `BILL-HANDOFF.md` (full system state),
`BREADCRUMBS.md` (what-breaks-what), `AUTH-SETUP.md` (soma-auth). Ask Claude to read
them when you need depth.*
