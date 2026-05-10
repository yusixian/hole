# Hole · 树洞

iOS native app — private AI-augmented diary / "树洞" with emotional companion. Offline-first, beautiful, locally storable.

## Stack

- SwiftUI, iOS 18+
- Tuist 4.x (managed via mise)
- Swift 5.10
- Multi-env: Dev / Staging / Release

## Setup

```bash
mise install            # install pinned tuist
tuist install           # fetch SPM deps (none yet)
tuist generate          # generate Xcode workspace
open Hole.xcworkspace
```

## Common commands

```bash
tuist xcodebuild build  # build (tuist >= 4.x)
tuist xcodebuild test   # run tests
tuist clean             # clean build artifacts
```

## Structure

```
Hole/
  Sources/              # app source
  Tests/                # XCTest unit tests
  Resources/            # assets (Assets.xcassets)
Configurations/         # per-env xcconfig (Dev, Staging, Release)
Project.swift           # Tuist project definition
Tuist.swift             # Tuist top-level config
mise.toml               # tool versions
docs/superpowers/specs/ # design specs
```

## Environments

| Config  | Bundle ID                  | ENVIRONMENT  |
| ------- | -------------------------- | ------------ |
| Debug   | io.mewtant.hole.dev        | development  |
| Staging | io.mewtant.hole.staging    | staging      |
| Release | io.mewtant.hole            | production   |
