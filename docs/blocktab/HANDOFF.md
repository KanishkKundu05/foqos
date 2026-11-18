# Blocktab implementation notes

The home screen is implemented in `Foqos/Components/Dashboard/HomeDashboardView.swift`; the device tile is `Foqos/Components/Common/BlocktabTileView.swift`. Existing StrategyManager actions remain the source of truth. Starting a default mode opens the NFC scanner; stopping requires the original tag. Breaks, pauses and hard-mode locks route to session details. Mode management, activity and authorization alerts remain accessible.

## Branding and compatibility

Visible application names use Blocktab. Upstream copyright and attribution remain intact. Settings links to the Blocktab website and fork, with upstream technical guides labelled explicitly. The home screen no longer promotes upstream donations or affiliate NFC tag sellers. The legacy alternate-icon picker is hidden; the new default icon is Blocktab.

Internal Swift symbols, database fields, App Groups, bundle IDs, control kinds, URL schemes and universal links retain their existing names. This avoids a silent compatibility break; a separate distribution setup is needed before shipping. Legacy alternate-icon assets and Mac release infrastructure remain upstream resources.

## Validation

Verified on November 18, 2026: iOS Simulator build passed, all five `BlockedProfileDraftTests` passed, and strict swift-format lint passed for the changed Swift files. Onboarding and the empty home screen were inspected in an iPhone 17 simulator; screenshots are included alongside this document. Active and inactive SwiftUI previews are available in HomeDashboardView.

Use the simulator build and `BlockedProfileDraftTests` commands in the README. The tests cover NFC selection, same-tag requirements and preservation of an existing QR method, along with the upstream allow-mode tests. Swift formatting is available through `xcrun swift-format` with Xcode 26.

On a provisioned physical iPhone, check:

1. Fresh install, Screen Time approval and creating a mode with NFC preselected.
2. Choose apps; tap a real NFC tag; confirm the dark active screen and actual app shields.
3. Try another tag (must not end a normal NFC session), then the original tag (must end it).
4. Check a saved QR/manual mode, breaks, pauses, scheduled sessions and hard-mode locks.
5. Confirm widgets and Live Activities reflect the session and the Blocktab brand.

The home screen's warm idle palette and physical tile take inspiration from the supplied Brick reference and https://getbrick.com. Blocktab's artwork is original code-drawn artwork.
