# Rising

A savings goal tracker that makes saving feel like progress — attach a photo to a goal and watch it reveal as you get closer to 100%.

## Concept

- Photo reveal as the progress mechanic
- Milestones at 25 / 50 / 75%
- Deposit history with notes
- Multiple goals with filtering
- JSON export
- Data stays on device

## Targets

- iOS

## Stack

- SwiftUI
- XcodeGen (`project.yml`)

## Structure

`RisingTests/` target alongside the app. Key types: `AISavingsTipsService`, `AchievementBadgeView`, `AchievementsView`, `AddAgentView`.

A web/Electron companion with the same name lives at [`../rising`](../rising) — that one has browser-extension and Electron targets and already carries its own `PORTFOLIO.md`.

Version 1.0.

## Status

Apple-platform experiment built to explore what an AI coding agent could produce for a native app. Not actively maintained.

Xcode projects here were generated with XcodeGen (`project.yml`); open the `.xcodeproj` directly.
