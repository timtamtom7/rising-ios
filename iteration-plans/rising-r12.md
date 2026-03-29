# Rising — R12: Social Savings

## Goal
Turn saving from a lonely activity into a shared one — letting users involve a partner, family member, or trusted friend in their homeownership journey. Accountability drives results.

## Motivation
Research consistently shows accountability increases savings success by 30-65%. R12 adds shared goals, partner visibility, and a simple social layer — without building a full social network or requiring sign-ups.

---

## Features

### 1. Shared Goals (Partner Access)
**What:** Designate one other person as a "partner" on a goal — they can view progress and add deposits, but not delete the goal.

**Details:**
- Goal creation: "Add a partner?" — enter their email or share a link
- If recipient has RisingMac: linked directly
- If not: receive an email with a view-only link (deep-link into app)
- Partner can: view goal detail, add deposits, see all deposit history
- Partner cannot: edit goal, delete goal, delete deposits
- Max 1 partner per goal

**Views:**
- `PartnerAccessSheet` — invite/add partner flow
- `PartnerBadge` — shows on goal card when partner is linked
- Updated `GoalDetailView` — partner's deposits marked with avatar
- `SharedGoalLinkView` — for email invite with QR code

**Implementation:**
- `PartnerService` — manages partner links
- Deep link: `risingmac://goal/{goalId}?partner={token}`
- Partner token stored in `Goal.partnerToken` (UUID, generated on invite)
- No account required for partner — view-only with token

### 2. Shared Dashboard
**What:** When a partner is added, both users see the goal in a shared section.

**Details:**
- Partner's deposits appear in deposit history with "(Partner)" label
- Dashboard shows shared goals separately from solo goals
- Notifications: "Your partner added $200 to [Goal]!"

**Views:**
- `SharedGoalsSection` — grouped section on dashboard
- `PartnerDepositRow` — deposit row with partner avatar

**Implementation:**
- Partner deposits stored same as regular deposits (just flagged with `isPartnerDeposit`)
- New field `Goal.isShared`
- Notification via `UserNotificationService` when partner deposits

### 3. Savings Streaks (Gamification)
**What:** Weekly and monthly savings streaks — consecutive weeks/months with at least one deposit.

**Details:**
- "4-week savings streak!" badge on dashboard
- Streak counter resets if a week/month passes with no deposits
- Milestone rewards: 4-week, 8-week, 12-week, 26-week, 52-week
- Streak freeze: 1 free pass per quarter (miss a week but streak intact)

**Views:**
- `StreakBadge` — fire icon + week count
- `StreakDetailView` — calendar view showing deposit days
- `StreakFreezeCard` — shows if freeze is available

**Implementation:**
- `StreakService` — calculates current streak from deposit history
- `Streakfreeze` model stored in UserDefaults
- Calendar view built with SwiftUI grids

### 4. Milestone Celebrations
**What:** When a goal hits 25%, 50%, 75%, 100% — show a celebration animation and option to share.

**Details:**
- Confetti animation on milestone hit
- "Share your progress" sheet with card image (uses `MacShareCardView`)
- Shareable image: goal name, progress ring, amount saved, motivational quote
- Celebration screen: "Halfway there! You saved $X of $Y"

**Views:**
- `MilestoneCelebrationView` — full-screen celebration overlay
- `ShareProgressSheet` — preview + share options (copy image, save, mail)

**Implementation:**
- Reuse `MacShareCardViewModel` from existing codebase
- Confetti: SwiftUI canvas animation or Lottie (embedded JSON)
- Share via `NSSharingServicePicker` or `ShareLink`

### 5. Accountability Check-ins
**What:** Weekly nudge: "How's [Goal] going? You're [on track/ahead/behind]."

**Details:**
- Configurable: daily, weekly, biweekly, or off
- Notification or in-app banner
- Shows goal health score + one tip
- Quick action: "Add deposit" from notification

**Views:**
- Updated notification content with goal name + health score
- `CheckInBanner` — in-app banner on dashboard open

**Implementation:**
- Use `UserNotificationService` (from R5/R6)
- Notification content built dynamically from goal state

---

## Technical Approach

### Partner Linking
- No backend needed — use cryptographic sharing links
- `goalId` + `partnerToken` (UUID) encodes access
- Token stored in goal record
- Deep link: `risingmac://goal/{goalId}?token={partnerToken}`
- On open: validate token exists for goal → grant view access

### Streak Calculation
```
currentStreak = count consecutive periods (week/month) with >= 1 deposit
period = week (Sunday-Saturday) or month
starts from first deposit date
breaks if current period has 0 deposits and period is complete
```

### Celebration Trigger
- Check after each deposit: `currentAmount / targetAmount` crosses threshold
- Thresholds: 0.25, 0.50, 0.75, 1.0
- Track `lastMilestoneHit` on Goal — don't re-trigger same milestone
- Reset milestone tracking if goal is edited and amount changes

### Dependencies
- No new external dependencies
- Reuse: `MacShareCardViewModel`, `UserNotificationService`, SQLite.swift

---

## UI Changes

### Dashboard
- New section: `SharedGoalsSection` (shows goals with partners)
- `StreakBadge` on top bar
- `CheckInBanner` slides in from top on open

### Goal Cards
- `PartnerBadge` (two-person icon) if partner linked
- `StreakBadge` shows active streak

### Goal Detail
- `MilestoneCelebrationView` overlay on milestone hit
- `ShareProgressSheet` accessible from share button
- `PartnerAccessSheet` accessible from settings button

---

## File Changes

### New Files
```
Services/
  PartnerService.swift
  StreakService.swift

Models/
  Partner.swift
  Streak.swift
  MilestoneCelebration.swift

ViewModels/
  PartnerViewModel.swift
  StreakViewModel.swift

Views/
  Social/
    PartnerAccessSheet.swift
    PartnerBadge.swift
    SharedGoalsSection.swift
    SharedGoalLinkView.swift
    PartnerDepositRow.swift
  Gamification/
    StreakBadge.swift
    StreakDetailView.swift
    StreakFreezeCard.swift
    MilestoneCelebrationView.swift
    ShareProgressSheet.swift
  CheckIn/
    CheckInBanner.swift
```

### Modified Files
- `DashboardView.swift` — add shared goals, streak badge, check-in banner
- `GoalDetailView.swift` — add celebration trigger, share button
- `Goal.swift` — add `partnerToken`, `isShared`, `lastMilestoneHit` fields
- `GoalService.swift` — handle partner operations
- `DatabaseService.swift` — add partner/streak columns
- `RisingMacApp.swift` — check for partner deep links on launch

---

## Testing
- Unit tests for `StreakService` streak calculation
- Unit tests for `PartnerService` token validation
- UI test: create partner link, open deep link, verify access
- UI test: milestone celebration fires at 25/50/75/100%

---

## Success Metrics
- 30%+ of users share a goal with a partner within first month
- 40%+ of shared goals have partner deposits within 2 weeks
- Users with active streaks save 50%+ more than users without streaks
