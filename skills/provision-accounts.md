# Skill #2 (STUB) — provision Greg's own INFRA accounts

> Status: **deferred, not on the first-launch path.** First launch uses Mike's infra
> keys (Supabase, ElevenLabs, Netlify), pasted in-session. **Model keys are already
> Greg's own from day one** (see below) — this skill is only about migrating the
> *infrastructure* to Greg's accounts later.

## The key-ownership split (per Mike's revision)

| Kind | Whose key | When |
|---|---|---|
| **Model / LLM keys** — the `claude` CLI (Greg's Claude account), any OpenAI API key, local Ollama (free) | **Greg's own** | **Day one**, during Phase 0 |
| **Infra keys** — Supabase, ElevenLabs, Netlify, Gmail | **Mike's**, pasted in-session | First launch; migrate later via this skill |

So at first launch CDCC signs the standalone `claude` CLI into **Greg's** account, and
(if a profile uses OpenAI) prompts Greg for **his own** OpenAI API key. Nothing about
models depends on Mike. This skill handles only the eventual infra cutover.

## What this skill will do (when built)

Drive **CiC in Greg's real Chrome** ("Sign in with Google") to stand up Greg-owned
infra and swap it in, one service at a time, with a test gate after each:

1. **Supabase** — create Greg's org/project; provision the `change_requests` and
   `bill_transcripts` schema (use the migrations in `legends-membership-site/migrations/`);
   retrieve his project URL + service key; write to the daemon `.env` (chmod 600);
   point `soma-auth` at his project. Gate: magic-link login works; queue round-trips.
2. **ElevenLabs** — create Greg's account; recreate the Bill/Dana/Quinn agents
   (separate agents because voice_id override is disabled); set his `ELEVENLABS_API_KEY`
   in the bill-talk Netlify env. Gate: a voice turn plays in Greg's voice set.
3. **Netlify** — fork hosting to Greg's team or transfer the sites; relink the CLIs.
   Gate: a push deploys to Greg's site; CDN engine deploy works.

## Why it's deferred

Signup/login/provisioning is the brittle part (CAPTCHAs, email verification, project
provisioning waits). Build it as adaptive CiC flows — not brittle recorded recipes —
**after** first launch is green, so there's a known-good baseline to diff against.
Until then, Mike's infra keys + Greg's own model keys is the supported configuration.
