# Rising — R13: Polish, Stability & Launch

## Goal
Ship RisingMac 1.0 to the Mac App Store — polished, stable, and delightful. Every pixel, transition, and interaction should feel intentional and premium.

## Motivation
R1-R10 built the features. R13 makes it feel like a finished product worthy of the App Store. Polish isn't superficial — it's the difference between "it works" and "I love using this."

---

## Polish Areas

### 1. App Icon & Visual Identity
**What:** Finalize the RisingMac app icon — upward-trending arrow integrated with rising sun motif, as described in SPEC.

**Details:**
- Programmatic icon: upward arrow + sun gradient
- macOS icon sizes: 16, 32, 64, 128, 256, 512, 1024, 2048 (512×512 @2x)
- Use SwiftUI to generate and export icon programmatically, or finalize in Figma
- Menu bar icon: simplified 18×18 version (upward arrow only)

**Implementation:**
- `AppIconGen.swift` — programmatic icon generation using SwiftUI Canvas
- Export as `.icns` using `NSImage` + `IconComposer`
- Fallback: Figma → export → add to Assets

### 2. Window Management
**What:** Proper macOS window behavior — minimum size, remembered position, full-size content support.

**Details:**
- Minimum window size: 900×600
- Default window size: 1100×750
- Remember last window position/size in UserDefaults
- Full-size content view: title bar blends with content
- Toolbar: unified title with search field

**Implementation:**
- `WindowState` in UserDefaults (x, y, width, height)
- `NSWindowDelegate` for window lifecycle
- SwiftUI `.windowResizability` and `.commands`

### 3. Menu Bar Extra (Menu Bar App)
**What:** RisingMac lives in the menu bar — quick deposit, goal at-a-glance, streak status.

**Details:**
- Menu bar extra: always-on icon (no popup window needed, just dropdown)
- Dropdown items:
  - Goal name + progress ring (small)
  - "Add Deposit" quick action
  - Current streak
  - "Open RisingMac"
  - "Quit"
- Updates in real-time when deposits added from main app
- Uses `MenuBarExtra` (macOS 13+) or `NSStatusItem`

**Implementation:**
- `MenuBarExtraView` — SwiftUI view for menu bar dropdown
- `MenuBarExtraService` — coordinates state with main app
- App group: share state between menu bar extra and main app (if sandboxed)
- Or: embed menu bar extra in main app bundle with separate target

### 4. Keyboard Shortcuts
**What:** Full keyboard navigation — power users never touch the mouse.

**Details:**
- `Cmd+N` — New goal
- `Cmd+D` — Add deposit (when goal selected)
- `Cmd+,` — Settings
- `Cmd+F` — Focus search
- `Escape` — Dismiss sheets
- `Cmd+1/2/3/4` — Switch tabs (Dashboard, Goals, Stats, Settings)
- All interactive elements have keyboard equivalents

**Implementation:**
- `.keyboardShortcut()` on all Buttons
- `.focusable()` on list items
- `KeyboardShortcuts.swift` — centralized shortcuts file
- Verify with accessibility audit

### 5. Animation Polish Pass
**What:** Review all animations — should feel responsive, never sluggish or excessive.

**Details:**
- Progress ring: 800ms easeOut (already in spec — verify implementation)
- Card appear: 200ms spring(0.7) — verify
- Sheet present: 400ms spring(0.8) — verify
- Number count-up: 600ms easeOut on dashboard
- Delete confirmation: 250ms easeIn
- Tab switching: cross-fade 200ms
- Confetti (R12): 2s burst, then 500ms fade out

**Implementation:**
- Audit all `withAnimation` calls — verify durations match spec
- Create `AnimationTokens.swift` in Design/ for consistent animation constants
- Replace magic numbers with `AnimationTokens.cardAppear`, etc.

### 6. Empty States
**What:** Every empty state should be warm, encouraging, and actionable — not generic.

**Details:**
- No goals: illustration + "Start your first goal" CTA
- No deposits: "Every dollar counts — add your first deposit"
- No shared goals: "Saving with someone? Share a goal with them"
- No properties (R2): "Save for a specific home? Add a property"
- Empty search: "No goals match '[query]'"

**Implementation:**
- Use SwiftUI programmatic illustrations (shapes, not images)
- Consistent `EmptyStateView` with illustration, title, description, action button
- Each empty state has its own copy and illustration

### 7. Onboarding Refresh
**What:** Review and polish onboarding — 4 screens that feel premium.

**Details:**
- Each screen: large illustration area, headline, body text, "Continue" button
- Page dots at bottom
- Skip option (top right) — jumps to Ready screen
- Progress bar at top (4 steps)
- Haptic feedback on page transition (if trackpad)

**Implementation:**
- Audit `OnboardingView.swift` against SPEC
- Verify copy: tagline "Your money, rising", value props
- Add `PageIndicatorDots` component
- Test on different window sizes

### 8. Settings Polish
**What:** Settings should be clear, organized, and complete.

**Details:**
- Sections: Appearance, Notifications, Data, About
- Appearance: Dark/Light/System toggle (already exists — verify)
- Notifications: toggle each type (deposit reminders, milestone alerts, streaks)
- Data: Export data (CSV), Reset onboarding, Delete all data
- About: Version, build, licenses, feedback link

**Implementation:**
- Verify `SettingsView` matches design spec
- Add notification toggles for each type
- Add "Export Data" — generates CSV of all goals/deposits
- Add "Delete All Data" with double-confirmation

### 9. Performance Audit
**What:** App should feel instant — no spinning, no jank.

**Details:**
- Dashboard loads in < 200ms with 10 goals
- Deposit list scrolls at 60fps with 100 deposits
- SQLite queries take < 50ms
- App cold start: < 1.5s to interactive
- Profile with Instruments: identify any slow views

**Implementation:**
- Use `@Query` (SwiftData) or manual background fetch for goals
- Index SQLite: `CREATE INDEX idx_deposits_goalId ON deposits(goalId)`
- Lazy load deposit history (load 20 at a time)
- Pre-warm views on app launch

### 10. Accessibility Audit
**What:** VoiceOver, Dynamic Type, Reduce Motion — every user can use RisingMac.

**Details:**
- VoiceOver: all interactive elements labeled, logical reading order
- Dynamic Type: UI scales from 13pt to 31pt body text
- Reduce Motion: replace animations with fades when `accessibilityReduceMotion`
- Color contrast: WCAG AA (4.5:1 for body, 3:1 for large text)
- Focus indicators: visible when using keyboard navigation

**Implementation:**
- Run Accessibility Inspector (Xcode → Open Developer Tools)
- Test with VoiceOver (`Cmd+F5`)
- Test Dynamic Type in System Settings
- Test Reduce Motion in System Settings
- Fix all issues before submission

---

## Launch Preparation

### Entitlements (Final)
```xml
com.apple.security.app-sandbox = true
com.apple.security.network.client = false
com.apple.security.files.user-selected.read-write = true
com.apple.security.files.bookmarks.app-scope = true (if using file export)
```

### Build & Notarize
```bash
# Clean build, Release
xcodebuild -scheme RisingMac \
  -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  build \
  CODE_SIGN_IDENTITY="-" \
  2>&1 | grep -E "error:|BUILD"

# Notarize (if distributing outside MAS)
xcrun notarytool submit RisingMac.app --apple-id $APPLE_ID ...
```

### App Store Connect
- Create app: RisingMac
- Bundle ID: `com.rising.macos`
- Category: Finance
- Pricing: Free (with Investor tier subscription via RevenueCat/Sparkle)
- Screenshots: 1280×720 minimum (5 required, 10 optional)
- Preview video: 30s (1080p .mov or .mp4)
- Privacy manifest: no data collection, all local storage
- Review notes: include test account instructions if needed

### Pre-Submission Checklist
- [ ] All LAUNCH_CHECKLIST.md items complete
- [ ] No crash on cold start
- [ ] No crash after 10 minutes of normal use
- [ ] All buttons have actions (no dead UI)
- [ ] All empty states have CTAs
- [ ] Notifications work when enabled
- [ ] Deep links (`risingmac://`) work from Safari
- [ ] Export CSV produces valid file
- [ ] Delete all data fully wipes app
- [ ] Window remembers position after restart

---

## File Changes

### New Files
```
Design/
  AnimationTokens.swift

Views/
  Polish/
    EmptyStateView.swift
    AppIconGen.swift (for programmatic icon generation)
    MenuBarExtraView.swift

Resources/
  PrivacyInfo.xcprivacy (verify exists and is complete)
  RisingMac.entitlements (verify)
```

### Modified Files
- `RisingMacApp.swift` — window management, keyboard shortcuts
- `DashboardView.swift` — empty state
- `GoalDetailView.swift` — empty states
- `SettingsView.swift` — add missing sections
- All views — audit `.animation()` calls for consistency
- `Assets.xcassets` — add app icon at all sizes
- `Info.plist` — add deep link URL scheme `risingmac`

### Removed
- Any dead UI (buttons with no action)
- Placeholder text that should be real copy
- Debug `print` statements left in code

---

## Testing
- Full run-through: launch → onboarding → create goal → add deposit → check dashboard → add property → use ROI calculator → settings
- Stress test: 50 goals, 500 deposits — verify performance
- Keyboard-only test: navigate entire app without mouse
- VoiceOver test: full walkthrough
- Crash test: airplane mode (no network required)
- Memory: verify no leaks with Instruments (Leaks, Allocations)

---

## Success Criteria
- App Store review passes first submission
- 4.5+ stars on Mac App Store within 30 days of launch
- No crash reports in App Store Connect
- All accessibility requirements met
- Users can complete core flow (create goal → add deposit → see progress) without guidance
