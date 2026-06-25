# Stage 0 — five clicks (Greg does this once)

Everything after this, Claude does for you. These five steps are the only parts that
*have* to be done by a human, because macOS and Chrome deliberately require a person
to approve them. Total time: ~10 minutes, most of it waiting on downloads.

When you're done, you'll paste one email into Claude and sit back.

---

## 1. Install Claude Desktop and sign in (Pro or Max plan)

- Download from **https://claude.com/download** and install like any Mac app.
- Open it and sign in.
- **Plan matters:** you need **Pro or Max**. The features we rely on (computer use,
  letting Claude control your screen) are not available on Team/Enterprise plans.
  If you're not sure, you can upgrade inside the app.

## 2. Open the **Code** tab once

- Claude Desktop has three tabs across the top: **Chat**, **Cowork**, **Code**.
- Click **Code**. If it asks to set anything up, accept the defaults.
- If it ever says "Git is required," it will point you to a one-click installer —
  run it and reopen. (On most Macs Git is already there.)

## 3. Turn on Computer Use and grant two Mac permissions

- In Claude Desktop go to **Settings → General** (under "Desktop app").
- Turn on the **Computer use** toggle.
- macOS will ask you to grant two permissions — click through and enable both:
  - **Accessibility** (lets Claude click and type)
  - **Screen Recording** (lets Claude see the screen)
- You may need to toggle them on in **System Settings → Privacy & Security**, then
  come back. The Claude settings page shows a green check when each is granted.

## 4. Install **Claude in Chrome** (CiC) and pair it

This is what lets Claude do the website logins for you (ElevenLabs, Supabase, Netlify)
**in your real Chrome**, where you're already signed into Google.

- In Chrome, install the **Claude in Chrome** extension (Claude Desktop will offer a
  link, or get it from the Chrome Web Store).
- Click **Add to Chrome**, then **pin** the extension (puzzle-piece icon → pin).
- Follow the prompt to **connect/pair** it with Claude Desktop.
- Make sure you're **signed into Chrome with the Google account** you'll use for
  ElevenLabs/Supabase/Netlify. That's the account Claude will click "Sign in with
  Google" against.

## 5. (Recommended) Set Claude to **Auto** mode for the install

- In a Code session, use the mode selector next to the send button and choose
  **Auto**. This lets Claude work without stopping to ask at every step, while still
  running background safety checks. (Don't use "Bypass permissions" — Auto is safer
  for an unattended install.)

---

## That's it — now paste the email

Open a new **Code** session in Claude Desktop, paste in the email Mike sent you
(the "SomaSetup bootstrap"), and send it. Claude will take over: install the
developer tools, set up the Legends site, and test everything as it goes.

It will **stop and ask you** for three kinds of things only:
1. **Secrets to paste** (API keys Mike gives you) — paste them when asked; Claude
   stores them securely and never shows them again.
2. **Logins** — when a site needs you to approve a Google sign-in or click an email
   verification link, Claude will do it in Chrome, but may ask you to tap an approval
   on your phone if Google prompts for 2FA.
3. **Two go/no-go confirmations** — before it pushes the website live and before it
   starts the background daemon, it will ask "OK to proceed?" Say yes when you're ready.

If anything looks stuck, you can always type "what are you doing right now?" or
"stop" — Claude will explain or pause.
