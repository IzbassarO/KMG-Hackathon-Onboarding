# Threadline — Design Brief & Asset Guide

**Product:** Threadline — onboarding flowchart tracker
**Tagline:** *Map the onboarding. Track every step.*
**Platform:** iOS (SwiftUI + SwiftData), English‑only UI, local‑only (no backend).

Threadline lets a team lead **draw** an onboarding process as a flowchart of
stages (each a rectangle: a task + the team responsible — e.g. *ID card issuance
→ Badge Center*), save it as a reusable **template**, then **onboard** a real
person against a snapshot of that chart and **manually check off** each stage as
it completes. Nothing updates without the user — it's a deliberate, Sketch‑like
builder + tracker.

The name: an onboarding is a **thread** woven through nodes; *line* = the
progress line / timeline. Coined, unique, App‑Store‑clean.

---

## 1. Color palette

The app already renders these via in‑code fallbacks, so it looks finished with no
assets. Add color sets to `Assets.xcassets` with the **exact names below** to
override from Xcode — code automatically prefers the asset. `AccentColor` is
already set to `ThreadPrimary`.

| Asset name | Role | Light | Dark |
|---|---|---|---|
| `ThreadPrimary` | Brand petrol (primary) | `#0E6E66` | `#2DB7A6` |
| `ThreadPrimaryDeep` | Brand deep (gradients/headers) | `#0A4D47` | `#14857A` |
| `ThreadAccent` | Amber signal | `#E07B2C` | `#FFAE57` |
| `BackgroundBase` | Screen background | `#F4F7F6` | `#0D1413` |
| `BackgroundElevated` | Cards / nodes | `#FFFFFF` | `#18211F` |
| `BackgroundSunken` | Inset rows / capsules | `#EAF0EE` | `#0A0F0E` |
| `ThreadSeparator` | Hairlines / borders | `#DDE5E3` | `#273230` |
| `CanvasGrid` | Flowchart grid dots | `#E3EBE9` | `#1A2624` |
| `TextPrimary` | Primary text | `#0E1413` | `#F1F5F4` |
| `TextSecondary` | Secondary text | `#5A6B68` | `#9DB0AC` |
| `ThreadInfo` | Info | `#2563C9` | `#6AA1FF` |
| `ThreadSuccess` | Completed (green) | `#1E9E66` | `#3CCB88` |
| `ThreadWarning` | Warning (amber) | `#CE8211` | `#F3B44C` |
| `ThreadDanger` | Destructive (red) | `#CE3A43` | `#FF6B72` |

**Add a color set:** Assets → *New Color Set* → rename to the asset name →
Attributes inspector → *Appearances = Any, Dark* → enter each hex.

---

## 2. Typography
- **Titles:** SF Rounded (`Font.system(design: .rounded)`), bold/semibold.
- **Body:** SF Pro (system default).
- **Hashes/numbers:** SF Mono.

All in `Onboard/DesignSystem/Theme.swift` (`Theme.Font.*`).

---

## 3. App structure (the logic)

1. **Welcome (first launch only)** — 3‑slide pager; sets
   `@AppStorage("threadline.hasCompletedWelcome")`. Starter templates are seeded
   into SwiftData on first run so the user never sees an empty app.
2. **Templates → Builder** — list of flowcharts; tap to open a free‑form canvas.
   `+` adds a node, drag moves it, tap/long‑press edits (Title, Owner, Notes,
   Est. days), **Connect** mode links nodes with directed arrows.
3. **Templates (starter)** — seeded KMG‑style charts: *Direct hire (full)*,
   *Contractor*, *Field rotation*. Duplicate/edit freely.
4. **Onboardings** — list of people in flight. `+` → pick template → fill the
   employee form (full name, DOB, contract type, contract number, position,
   department, location, start date, email, phone) → creates a **deep clone** of
   the template's stages/links so later template edits don't touch active
   onboardings. Inside: the same canvas in **tracker mode** — tap a stage to mark
   it complete; a progress ring updates. A checklist mirrors the chart.
5. **Settings** — your name, theme (System/Light/Dark), library counts,
   re‑seed starter templates, reset all data, about.

Persistence is **SwiftData** (`Template`, `TemplateStage`, `TemplateLink`,
`Employee`, `Onboarding`, `OnboardingStage`, `OnboardingLink`). No static demo
data — everything the user creates survives relaunch.

---

## 4. Claude design prompts

### 4.1 App icon (1024×1024)
```
Design a 1024×1024 iOS app icon for "Threadline", an onboarding flowchart tracker.
Concept: a single continuous thread (rounded stroke) weaving through three small
rounded-square nodes arranged in a gentle zig-zag, ending in an amber dot.
Background: diagonal gradient from deep petrol #0A4D47 (top-left) to petrol
#0E6E66 (bottom-right). Thread and first two nodes in soft white/light teal; the
final node/dot in amber #E07B2C. Flat, geometric, modern, no text, generous
padding, centered. Square PNG, no transparency.
```

### 4.2 Logo / wordmark
```
Horizontal logo lockup for "Threadline": left, the thread-through-three-nodes mark
(petrol thread, two petrol nodes, one amber node); right, the word "Threadline" in
a geometric rounded sans (like SF Rounded), bold, #0E1413 on light / #F1F5F4 on
dark. Transparent background. Colors: petrol #0E6E66, deep petrol #0A4D47, amber
#E07B2C.
```

### 4.3 Screen mockups
Prefix every screen prompt with:
```
Style: iOS app UI, SwiftUI look, light mode, SF Rounded headings, rounded 20pt
cards on #F4F7F6, soft shadows, generous spacing. Petrol #0E6E66, amber accent
#E07B2C, success green #1E9E66. English only. iPhone 15, portrait.
```
Then append:

- **Welcome:** `Full-bleed petrol gradient. A white thread-through-nodes logo, "Threadline" title, tagline "Map the onboarding. Track every step." A 3-dot page indicator and a large amber "Get started" button.`
- **Templates list:** `Title "Templates", subtitle. A list of template cards: a petrol flowchart glyph tile, template name (e.g. "Direct hire (full)"), short summary, a category tag pill and a "7 stages" pill, chevron. A + in the nav bar.`
- **Flowchart builder:** `A dotted-grid canvas with rounded-rectangle nodes connected by smooth arrows top-to-bottom: "HR contract signing / HR", "ID card issuance / Badge Center", "Laptop provisioning / IT Service Desk". Each node shows a title and an owner pill. A floating amber link button and a petrol + button bottom-right. One node highlighted with an amber border (connect mode).`
- **New onboarding form:** `A grouped form: Template picker; Person section (full name, date of birth toggle, email, phone); Contract section (type picker, contract number, start date); Role section (position, department, location). Nav bar Cancel / Create.`
- **Onboarding detail (tracker):** `Header card: avatar, position, department, location, a green progress ring at 43%, pills for template and "Starts in 4 days" and "3/7 stages". Below: the same flowchart but completed nodes have a green check and green tint; caption "Tap a stage to mark it complete." Below that, a checklist mirroring the stages with circular checkboxes, completed ones struck through.`
- **Settings:** `Grouped form: Threadline logo + subtitle; "Your name" field; Theme segmented control (System/Light/Dark); Library counts (Templates/Onboardings/Employees) + "Re-add starter templates"; red "Reset all data"; About (Version 1.0, "Built for KMG Digital Hackathon 2026").`

---

## 5. Xcode settings for publication

1. **Display name:** set to `Threadline` (Target → General → Display Name). *(Only
   manual setting needed.)*
2. **App icon (required):** Assets → `AppIcon` → drop the 1024 PNG from §4.1.
3. **Accent color:** already `ThreadPrimary` via `AccentColor`.
4. **Version/build:** `1.0 (1)` (already set).
5. **Deployment target:** currently iOS 26.0. SwiftData + `@Observable` need
   iOS 17+, so you can lower **Minimum Deployments to iOS 17.0** for wider reach.
6. **No special capabilities, entitlements, or privacy strings** — the app is
   fully local (SwiftData on device), no notifications, camera, mic, or location.

No `project.pbxproj` edits required — the target uses a synchronized file group,
so new Swift files under `Onboard/` are picked up automatically.
