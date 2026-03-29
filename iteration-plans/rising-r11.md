# Rising — R11: AI Savings Intelligence

## Goal
Bring intelligent, proactive savings guidance to RisingMac — helping users save faster with AI-driven insights, personalized suggestions, and predictive analytics — all on-device.

## Motivation
R7-R9 established investment tools (ROI calculator, portfolio tracking). R10 launches the app. R11 layers AI on top to make Rising genuinely smart — not just a tracker but a savings coach that understands the user's financial picture and suggests concrete actions.

---

## Features

### 1. AI Savings Coach
**What:** A persistent sidebar/panel (or menu bar popup) that surfaces personalized savings insights.

**Details:**
- Onboarding question: "What's your biggest challenge saving?" (Answers: irregular income, spending triggers, slow progress, don't know where to start)
- AI categorizes spending patterns from deposit frequency
- Weekly "Savings Pulse" notification: "You saved $X this week — $Y above your average. Keep it up!"
- Monthly summary card on dashboard

**Views:**
- `SavingsCoachView` — coaching tips, weekly stats, streak counter
- `TipCardView` — individual tip with icon, title, description, action button
- `WeeklyPulseView` — 7-day sparkline of deposits

**Implementation:**
- New `SavingsCoachViewModel` with `@Observable`
- Tips stored in `UserDefaults` as JSON array
- Tip engine: rule-based for R11 (can be upgraded to ML later)
- Tip categories: motivation, strategy, milestone celebration, warning

### 2. Smart Deposit Suggestions
**What:** "You saved $X last month. Here's your suggested weekly deposit to hit [Goal] by [Deadline]."

**Details:**
- Calculates required monthly/weekly deposit based on remaining amount and time
- Shows: "Save $143/week to reach your $50K goal by Dec 2026"
- User can accept suggestion (pre-fills AddDeposit sheet) or dismiss
- Appears on dashboard after a goal is 7+ days old with no deposits

**Views:**
- `DepositSuggestionCard` — inline on DashboardView
- `DepositSuggestionSheet` — full sheet with breakdown

**Implementation:**
- New `DepositSuggestionService`
- Uses `Goal` and `Deposit` data to calculate suggested amount
- Triggers via `DashboardViewModel` check on appear

### 3. Goal Health Score
**What:** Each goal gets a health score (0-100) based on:
- On-track percentage (actual vs. expected savings rate)
- Deposit consistency (vs. suggested schedule)
- Days since last deposit
- Progress trend (improving/declining)

**Details:**
- Shown as a colored badge on goal cards and goal detail
- Score breakdown available on tap: "Why this score?"
- Color: green (80+), amber (50-79), red (<50)
- Persisted to `Goal.healthScore` in DB

**Views:**
- `HealthScoreBadge` — small badge component
- `HealthScoreDetailView` — breakdown on goal detail

**Implementation:**
- `GoalHealthService` — calculates score from deposit history
- Updates on each deposit add/delete
- Uses a simple weighted formula (can be tuned)

### 4. AI Savings Scenarios
**What:** "What if you saved an extra $X?" — shows impact of different deposit amounts on goal timeline.

**Details:**
- On goal detail: "What if I added $50/mo?" → shows new completion date
- Three scenarios: current pace, +$25/mo, +$50/mo
- Simple compound growth projection

**Views:**
- `SavingsScenarioCard` — on GoalDetailView
- `ScenarioRow` — amount + projected date

**Implementation:**
- `ProjectionService` — pure calculation, no ML needed
- Uses remaining amount / monthly deposit to project date

---

## Technical Approach

### Architecture
- MVVM + Services (same as existing pattern)
- All AI logic runs on-device — no network calls
- New services: `SavingsCoachService`, `GoalHealthService`, `ProjectionService`
- Data stays in SQLite/UserDefaults — no new persistence needed

### Tip Engine (R11)
- Predefined tip library in `Tips.json` or `Tips.swift` enum
- Rule engine matches tip categories to user state:
  - `irregular_income` → tips about setting minimum deposits
  - `slow_progress` → tips about finding extra savings
  - `milestone_reached` → celebration tips
  - `streak_active` → encouragement tips
- Tips are dismissible; don't re-show dismissed tips for 30 days

### Health Score Formula
```
depositConsistency = actualDeposits / expectedDepositsForElapsedTime
onTrackPct = currentAmount / expectedAmountAtToday
recentActivityBonus = +10 if deposit in last 7 days, else -5 per week stale
baseScore = (depositConsistency * 0.4 + onTrackPct * 0.4) * 100
finalScore = clamp(baseScore + recentActivityBonus, 0, 100)
```

### Dependencies
- No new external dependencies
- Uses existing SQLite.swift, SwiftUI, Charts

---

## UI Changes

### Dashboard
- `SavingsCoachView` panel on right side (collapsible on smaller windows)
- `DepositSuggestionCard` appears between total savings and goal cards
- Goal cards get `HealthScoreBadge` in top-right corner

### Goal Detail
- New section: `SavingsScenarioCard` below progress ring
- `HealthScoreDetailView` accessible via info button on badge

### Menu Bar Extra
- Add "Savings Pulse" to menu bar extra dropdown

---

## File Changes

### New Files
```
Services/
  SavingsCoachService.swift
  GoalHealthService.swift
  ProjectionService.swift

ViewModels/
  SavingsCoachViewModel.swift
  HealthScoreViewModel.swift

Views/
  SavingsCoach/
    SavingsCoachView.swift
    TipCardView.swift
    WeeklyPulseView.swift
  Suggestions/
    DepositSuggestionCard.swift
    DepositSuggestionSheet.swift
  HealthScore/
    HealthScoreBadge.swift
    HealthScoreDetailView.swift
  Scenarios/
    SavingsScenarioCard.swift
    ScenarioRow.swift

Models/
  Tip.swift
  HealthScore.swift
  SavingsScenario.swift
```

### Modified Files
- `DashboardView.swift` — add coach panel, suggestion card
- `GoalDetailView.swift` — add scenario card, health score badge
- `GoalCardView.swift` — add health score badge
- `RisingMacApp.swift` — add tip engine init
- `DatabaseService.swift` — add healthScore column to Goal
- `Goal.swift` — add healthScore field

---

## Testing
- Unit tests for `GoalHealthService` score calculation
- Unit tests for `ProjectionService` timeline calculations
- UI test: dismiss tip, verify doesn't reappear
- UI test: add deposit, verify health score updates

---

## Success Metrics
- 60%+ of active users see at least one AI tip within 3 days
- Average goal health score increases from 65 → 75 within first month
- Deposit suggestion acceptance rate > 20%
