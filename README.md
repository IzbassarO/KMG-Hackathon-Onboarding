# Onboard — iOS app (setup + App Store guide)

Personal, offline tracker for your first days at a new job. Built with **SwiftUI + SwiftData, iOS 17+**. No account, no network, no data collection — by design, the lowest-risk path through App Store review.

---

## 1. What's in the box

| File | What it is |
|---|---|
| `OnboardApp.swift` | App entry point, SwiftData `ModelContainer`, notification delegate |
| `Models.swift` | `JobProfile`, `TaskItem`, enums (`OnboardingPhase`, `TaskCategory`, `ProfileAccent`) |
| `SeedTemplates.swift` | Curated starter checklist (~28 items across 4 phases / 5 categories) |
| `NotificationManager.swift` | Local reminders (no push, no server) |
| `ProgressRing.swift` | Reusable progress ring |
| `HomeView.swift` | Job list, empty state, add-job sheet |
| `ProfileDetailView.swift` | Phases, task list, progress, add/edit task |

---

## 2. Create the Xcode project

1. Xcode → **File ▸ New ▸ Project ▸ iOS ▸ App**.
2. Settings:
   - Product Name: **Onboard** (you can rename later — see §5).
   - Interface: **SwiftUI**, Language: **Swift**.
   - Storage: **SwiftData**. (If you leave it "None", that's fine — the code creates the container itself.)
   - Minimum Deployment: **iOS 17.0**.
3. Delete the default `ContentView.swift` and the generated `…App.swift`.
4. Drag all 7 `.swift` files into the project (check "Copy items if needed", add to the app target).
5. Build & run on the simulator. The first screen is the empty state → "Add a job".

No Info.plist changes are required. Local notifications do **not** need a usage-description key; permission is requested at runtime when you enable a reminder.

---

## 3. Quick sanity test before anything else

- Add a job with the starter checklist on → you get a populated 4-phase checklist.
- Toggle a few tasks → progress ring animates; counts update.
- Add a custom task; edit one; delete one.
- Enable "Remind me" on a task → iOS asks for notification permission once.
- Force-quit and relaunch → data persists (SwiftData working).
- Switch the simulator to Dark Mode → everything stays readable.

---

## 4. App icon (REQUIRED — don't skip)

App Store **rejects** submissions with no icon. You need a 1024×1024 PNG (no alpha, no rounded corners — Apple rounds it).
- In `Assets.xcassets ▸ AppIcon`, drop in the 1024 image (single-size is enough for modern Xcode).
- Keep it simple and legible at small sizes (a checkmark / ring motif fits the app).

Ask me and I'll design a clean icon for you.

---

## 5. App Store Connect — metadata

You can edit all of this later; nothing here is locked in.

**Name (max 30):** `Onboard: New Job Checklist`
*(Plain "Onboard" may be taken — check availability in App Store Connect. The longer name doubles as keywords.)*

**Subtitle (max 30):** `Your first 90 days, sorted`

**Promotional text (max 170):**
`Starting a new job? Onboard gives you a ready checklist for your first day, week, month and 90 days — fully offline, private, and yours to customize.`

**Description:**
```
Starting a new job is exciting — and overwhelming. Onboard turns those first months into a clear, calm checklist so nothing slips through the cracks.

Add the job you're starting and Onboard sets up a recommended checklist across four phases: first day, first week, first month, and 90 days. Tasks are grouped into admin, people, tools & access, learning, and wellbeing — so you always know what to focus on next.

• Ready-made starter checklist you can fully edit
• Track multiple jobs or onboarding plans
• Visual progress for every phase
• Local reminders timed to your start date
• Add your own tasks and notes

Onboard is completely private. Everything stays on your device — no account, no sign-up, no tracking, and it works fully offline.

Make a strong start. One checked box at a time.
```

**Keywords (max 100, comma-separated, no spaces):**
`onboarding,new job,checklist,first day,first week,90 days,career,work,tasks,reminders,starter,planner`

**Category:** Primary **Productivity**, Secondary **Business**.

**Support URL / Marketing URL:** required — a one-page site or even a public Notion/GitHub Pages link is fine.

---

## 6. App privacy (the part that keeps simple apps safe)

In App Store Connect ▸ **App Privacy**, answer:

- **"Do you or your third-party partners collect data from this app?"** → **No**.

That single honest answer (true because there's no network, no account, no analytics SDK) removes the most common rejection class for small apps. Your privacy label shows **"Data Not Collected."**

You still need a **privacy policy URL** (Apple requires the field even when nothing is collected). One short paragraph suffices: *"Onboard does not collect, transmit, or share any personal data. All information you enter stays on your device."*

---

## 7. Avoiding the rejection that hits simple apps (Guideline 4.2)

The usual reason a "simple" app gets bounced is **minimum functionality** — Apple wants more than a single trivial task or a website wrapper. Onboard clears this comfortably: multiple job profiles, a templated **and** customizable checklist across 4 phases × 5 categories, per-phase progress, local reminders, and notes. Keep it that way — don't strip features down to "just a list" before submitting.

Two more easy wins reviewers care about:
- **No crashes / no placeholder content.** Test the flows in §3 on a real device if you can.
- **No private APIs, no hidden features.** This code uses only public SwiftUI / SwiftData / UserNotifications.

---

## 8. Pre-submission checklist

- [ ] App runs clean on simulator **and** a physical device.
- [ ] 1024×1024 app icon added (§4).
- [ ] Tested: add job, toggle tasks, add/edit/delete task, reminders, persistence, dark mode.
- [ ] App name availability checked in App Store Connect.
- [ ] Screenshots captured (6.7" iPhone required; iPad if you ship universal).
- [ ] Metadata filled (§5), privacy = "Data Not Collected" (§6), privacy policy URL live.
- [ ] Support URL live.
- [ ] Build archived & uploaded via Xcode (Product ▸ Archive).
- [ ] Submitted for review.

---

## 9. Honest note on "100%"

No one can *guarantee* App Store approval — review is done by people and varies. What this design does is put Onboard in the **lowest-risk category**: offline, no data collected, no login, genuinely multi-feature. If it ever gets a 4.2 query, the answer is the feature list in §7. That's about as safe as a quickly-built app gets.

---

## 10. Nice fast-follows (after v1 ships)

- **Localization (EN / RU / KK)** — your trilingual edge. The UI strings are short and easy to wrap in a String Catalog; ask me and I'll generate the translations.
- A custom-template feature (save your own checklist as a reusable template).
- iCloud sync via SwiftData — only if you later decide it's worth the added privacy disclosure.
