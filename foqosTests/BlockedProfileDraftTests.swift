import XCTest

@testable import foqos

final class BlockedProfileDraftTests: XCTestCase {
  func testNewModeDefaultsToNFCAndRequiresSameTagToStop() {
    let draft = BlockedProfileDraft()
    XCTAssertEqual(draft.selectedStrategy?.getIdentifier(), NFCBlockingStrategy.id)
    XCTAssertEqual(draft.selectedStrategy?.usesNFC, true)
    XCTAssertEqual(draft.selectedStrategy?.requiresSameCodeToStop, true)
  }

  func testEditingAnExistingModePreservesItsChosenMethod() {
    let profile = BlockedProfiles(name: "QR mode", blockingStrategyId: QRCodeBlockingStrategy.id)
    let draft = BlockedProfileDraft(profile: profile)
    XCTAssertEqual(draft.selectedStrategy?.getIdentifier(), QRCodeBlockingStrategy.id)
  }

  func testSelectingTemporaryAccessDisablesAllowMode() {
    let draft = BlockedProfileDraft()
    draft.enableAllowMode = true

    draft.selectedStrategy = NFCSoftUnblockBlockingStrategy()

    XCTAssertFalse(draft.enableAllowMode)
    XCTAssertFalse(draft.selectedStrategySupportsAllowMode)
  }

  func testLoadingTemporaryAccessProfileDisablesAllowMode() {
    let profile = BlockedProfiles(
      name: "Temporary Access",
      blockingStrategyId: QRSoftUnblockBlockingStrategy.id,
      enableAllowMode: true
    )

    let draft = BlockedProfileDraft(profile: profile)

    XCTAssertFalse(draft.enableAllowMode)
    XCTAssertFalse(draft.selectedStrategySupportsAllowMode)
  }

  func testOtherStrategiesContinueToSupportAllowMode() {
    let draft = BlockedProfileDraft()

    draft.enableAllowMode = true

    XCTAssertTrue(draft.enableAllowMode)
    XCTAssertTrue(draft.selectedStrategySupportsAllowMode)
  }
}
