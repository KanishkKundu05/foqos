# Blocktab

The iOS companion for [Blocktab.app](https://blocktab.app): a physical pause for your digital life. Choose distracting apps, tap your NFC tag to block them, and tap the same tag to return.

This is a fork of [FoQoS by Ali Waseem](https://github.com/awaseem/foqos), licensed under MIT. The original copyright and license are preserved in [LICENSE](LICENSE).

## What's changed

- Blocktab branding across onboarding, settings, Screen Time shields, widgets, Live Activities, shortcuts and companion UI.
- A quiet, warm home screen when idle and a dark olive screen during an active session, with a central Blocktab device mark, mode selection, session timer and primary action.
- NFC is preselected for new modes and explicitly recommended during setup. Other blocking methods remain available; existing profiles retain their chosen method.
- Original Blocktab artwork drawn in SwiftUI and AppKit. No Brick logos or product artwork are included.

## Development

Open `foqos.xcodeproj` and select the `foqos` scheme. Source folders, target names, persisted keys and shared identifiers retain their upstream names for compatibility.

```sh
xcodebuild -project foqos.xcodeproj -scheme foqos \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

xcodebuild -project foqos.xcodeproj -scheme foqos \
  -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO \
  test -only-testing:foqosTests/BlockedProfileDraftTests
```

Regenerate the default device mark with `swift scripts/generate-blocktab-mark.swift`.

## Device validation and distribution

NFC scanning and Screen Time enforcement need a physical iPhone, Screen Time authorization and properly provisioned entitlements. The simulator validates compilation and app presentation, not real blocking.

Before distributing Blocktab, configure your Apple Developer team, bundle IDs, App Groups, Family Controls entitlement and associated domains across the app and extensions. This fork retains upstream internal identifiers and deep links; it is not configured as a separately signed App Store product. Publish an Apple App Site Association file before switching universal links to blocktab.app. Mac update feeds and signing also require separate release configuration.

See [the handoff notes](docs/blocktab/HANDOFF.md) for validation and remaining device checks, and the [upstream documentation](https://github.com/awaseem/foqos/tree/main/docs) for the blocking engine.
