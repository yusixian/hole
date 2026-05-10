# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

iOS SwiftUI native app — private AI-augmented "树洞" / journal with emotional companion. Offline-first, local storage, AI-enhanced, exportable, monetizable from day 1.

## Stack & build

- SwiftUI, iOS 18+, Swift 5.10
- Tuist 4.110.3 (pinned via `mise.toml`)
- Multi-env xcconfigs in `Configurations/` (Dev / Staging / Release)

### Commands

- `tuist install` — fetch SPM dependencies
- `tuist generate` — generate Xcode workspace (run after editing `Project.swift`)
- `tuist xcodebuild build` — build via Tuist (`tuist build` deprecated)
- `tuist xcodebuild test` — run tests
- `xcodebuild test -workspace Hole.xcworkspace -scheme Hole -destination 'platform=iOS Simulator,name=iPhone 16'` — test via raw xcodebuild
- `swiftlint` / `swiftformat .` — once configured

## Structure

```
Hole/Sources/        # app code
Hole/Tests/          # XCTest
Hole/Resources/      # assets
Configurations/      # xcconfig per env
docs/superpowers/specs/  # design specs (brainstorming output)
```

Add new SwiftUI screens under `Hole/Sources/Views/`, view models under `Hole/Sources/ViewModels/`, business logic under `Hole/Sources/Managers/`, models under `Hole/Sources/Models/`, core utilities under `Hole/Sources/Core/`. Mirror Prof reference layout.

## Code review skills (apply proactively)

- `swift-concurrency` — async/await, actors, Sendable, Swift 6 concurrency
- `swiftui-expert-skill` — SwiftUI state, composition, performance, modern APIs
- `swiftui-performance-audit` — rendering, scrolling, view update perf
- `swiftui-view-refactor` — view structure, DI, `@Observable`
- `revenuecat` — subscription / IAP review (planned)

## Conventions

- Single-file primary type. PascalCase types, camelCase vars.
- Files under ~500 lines.
- Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `ci:`).
- All user-facing strings localizable via `.xcstrings` (en + zh-Hans).
- Never hardcode secrets; use xcconfig + Keychain.

## Workflow

- Brainstorm before coding new feature; spec to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`.
- Plan before multi-step implementation (use `superpowers:writing-plans`).
- Verify before claiming done (`superpowers:verification-before-completion`).
- Run lint only on changed files; avoid full repo scans.
