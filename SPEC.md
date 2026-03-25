# Rising — Product Specification

## 1. Concept & Vision

Rising is an AI-powered savings goal tracker that helps people save for major life goals — starting with homeownership. It feels like a personal financial coach wrapped in a calm, premium app: not anxious spreadsheets, but intentional progress. The experience is grounded in optimism — every deposit is a step forward, every milestone worth celebrating. The name "Rising" captures both financial growth and personal aspiration.

**Who it's for:** People saving for a house, investment property, or big purchase who want to understand their money, track progress visually, and get smart insights along the way.

---

## 2. Design Language

### Aesthetic Direction
**"Calm affluence"** — the visual language of a premium fintech app that takes money seriously without being cold or clinical. Think: a wealth management app designed by someone who also designs meditation apps. Generous whitespace, purposeful color, confident typography.

### Color Palette
| Role | Color | Hex |
|------|-------|-----|
| Primary | Forest Green | `#10B981` |
| Primary Dark | Emerald | `#059669` |
| Accent | Warm Gold | `#F59E0B` |
| Background (Dark) | Deep Charcoal | `#0F172A` |
| Surface (Dark) | Slate Dark | `#1E293B` |
| Card (Dark) | Card Dark | `#334155` |
| Background (Light) | Soft White | `#F8FAFC` |
| Surface (Light) | Light Gray | `#F1F5F9` |
| Text Primary (Dark) | Snow | `#F8FAFC` |
| Text Secondary (Dark) | Slate | `#94A3B8` |
| Text Primary (Light) | Deep Navy | `#0F172A` |
| Text Secondary (Light) | Gray | `#64748B` |
| Success | Emerald | `#10B981` |
| Warning | Amber | `#F59E0B` |
| Error | Rose | `#EF4444` |

### Typography
| Role | Font | Weight | Size |
|------|------|--------|------|
| Display | SF Pro Display | Bold | 34pt |
| Heading 1 | SF Pro Display | Semibold | 28pt |
| Heading 2 | SF Pro Display | Semibold | 22pt |
| Heading 3 | SF Pro Text | Medium | 20pt |
| Body | SF Pro Text | Regular | 17pt |
| Body Small | SF Pro Text | Regular | 15pt |
| Caption | SF Pro Text | Regular | 13pt |
| Label | SF Pro Text | Medium | 12pt |

### Spacing System (8pt Grid)
| Name | Value |
|------|-------|
| xxs | 4pt |
| xs | 8pt |
| sm | 12pt |
| md | 16pt |
| lg | 24pt |
| xl | 32pt |
| xxl | 48pt |
| xxxl | 64pt |

### Motion Philosophy
Motion communicates progress and calm. Animations are purposeful — they confirm actions, guide attention, and create continuity. Never decorative.
- Screen transitions: 350ms, easeInOut
- Card appear: 200ms, spring(0.7)
- Button press: 100ms, easeOut
- Sheet present: 400ms, spring(0.8)
- Progress ring fill: 800ms, easeOut
- Number count-up: 600ms, easeOut
- Delete/sweep: 250ms, easeIn

### Visual Assets
- Icons: SF Symbols exclusively
- Illustrations: Programmatic SwiftUI shapes for empty states
- App Icon: Programmatic — upward-trending arrow integrated with rising sun motif
- No stock photos

---

## 3. Architecture

### Pattern: MVVM + Services
```
Views (SwiftUI)
    ↓ binds to
ViewModels (@Observable)
    ↓ calls
Services (business logic, persistence)
    ↓ uses
Models (data structures, SQLite)
```

### Services
- `DatabaseService` — SQLite.swift persistence layer
- `GoalService` — goal CRUD operations
- `DepositService` — deposit tracking
- `AnalyticsService` — savings calculations, projections
- `OnboardingService` — first-run state management

---

## 4. R1 Features (Foundation)

### Onboarding (4 screens)
1. **Welcome** — "Your money, rising" tagline, app intro
2. **First Goal** — Set your first savings goal (name, target amount, deadline)
3. **Why Rising** — Value props: track, visualize, understand your money
4. **Ready** — Confirmation, enter the app

### Goals
- Create savings goal: name, target amount, deadline, optional description
- Edit goal
- Delete goal with confirmation
- Goal detail: shows progress ring, amount saved vs. target, days remaining

### Deposits
- Add deposit to a goal: amount, date, optional note
- View deposit history per goal
- Delete deposit

### Dashboard
- Overview of all active goals
- Total savings across all goals
- Most recent activity
- Empty state for new users

### Settings
- Theme toggle (dark/light/system)
- Reset onboarding
- App version

---

## 5. R2 Features
- Multiple properties with address, photos, notes
- Milestone tracker (pre-approved → save → offer → close)
- Agent contacts storage
- Monthly deposit history chart

## 6. R3 Features
- Real market data integration (Zillow/Realtor API mock)
- Mortgage calculator
- AI insights using on-device intelligence

## 7. R4 Features
- Push notifications and reminders
- Share progress as image
- Savings projection chart
- Full dark/light mode polish

---

## 8. Technical Requirements

### Platform
- iOS 26.0+
- SwiftUI
- SQLite.swift for persistence
- XcodeGen for project generation

### Data Model
```
Goal
  - id: UUID
  - name: String
  - targetAmount: Double
  - currentAmount: Double
  - deadline: Date?
  - createdAt: Date
  - iconName: String (SF Symbol)

Deposit
  - id: UUID
  - goalId: UUID
  - amount: Double
  - date: Date
  - note: String?
  - createdAt: Date

Property (R2)
  - id: UUID
  - goalId: UUID
  - address: String
  - price: Double
  - link: String?
  - notes: String?
  - photos: [Data]

Milestone (R2)
  - id: UUID
  - goalId: UUID
  - title: String
  - type: MilestoneType (preApproval, offerMade, offerAccepted, closing)
  - status: MilestoneStatus (pending, completed)
  - completedAt: Date?
  - amount: Double?

Agent (R2)
  - id: UUID
  - name: String
  - phone: String?
  - email: String?
  - notes: String?
```

### Privacy
- All data stored locally in Application Support
- No analytics without consent
- Privacy manifest required

---

## 9. App Structure

```
Rising/
├── App/
│   ├── RisingApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Goal.swift
│   ├── Deposit.swift
│   ├── Property.swift
│   ├── Milestone.swift
│   └── Agent.swift
├── Services/
│   ├── DatabaseService.swift
│   ├── GoalService.swift
│   └── DepositService.swift
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── GoalDetailViewModel.swift
│   ├── AddDepositViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── WelcomeStepView.swift
│   │   ├── FirstGoalStepView.swift
│   │   ├── WhyRisingStepView.swift
│   │   └── ReadyStepView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── GoalCardView.swift
│   │   └── EmptyDashboardView.swift
│   ├── Goals/
│   │   ├── GoalDetailView.swift
│   │   ├── CreateGoalView.swift
│   │   └── EditGoalView.swift
│   ├── Deposits/
│   │   ├── DepositListView.swift
│   │   ├── AddDepositView.swift
│   │   └── DepositRowView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Design/
│   ├── Colors.swift
│   ├── Typography.swift
│   └── Spacing.swift
└── Resources/
    ├── Assets.xcassets/
    └── PrivacyInfo.xcprivacy
```

---

## R5 — Platform, Data & Persistence

### SQLite Persistence (Properties, Agents, Milestones)
- Properties, Agents, and Milestones now persisted to SQLite (was in-memory in R2-R4)
- Data survives app restart and deletion
- Deleting a goal cascades to associated properties and milestones
- All services updated to use DatabaseService for CRUD operations

### Market Data Simulation
- Property model includes `marketTrend` (up/down/stable) — deterministic based on address
- `estimatedValueChange` shows simulated price change (-8% to +12%)
- Display price formatted as USD currency string

### Notification System
- Local push notifications via UNUserNotificationCenter
- Deposit reminders, milestone alerts, closing countdowns
- Notification settings in SettingsView

---

## R6 — Polish, Stability & Edge Cases

### Stability
- MilestoneService: toggleComplete uses direct update() instead of broken complete()/reset()
- All DatabaseService operations wrapped in error handling with fallbacks
- Property/Agent/Milestone deletion cascades properly when goal is deleted

### Edge Cases
- No properties → empty state in PropertyListView
- No agents → empty state in AgentListView  
- Milestone completion/uncompletion updates in-memory then saves to SQLite
- Goal deletion confirms and cleans up all associated data

### UI Polish
- Milestone tracker progress bar animates smoothly
- Market trend badges on property cards (up/down/stable with icons)
- Consistent dark theme with risingPrimary amber accent throughout
