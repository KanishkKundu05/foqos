import SwiftData
import SwiftUI

struct HomeDashboardView: View {
  @EnvironmentObject private var strategyManager: StrategyManager

  let profiles: [BlockedProfiles]
  let sessions: [BlockedProfileSession]
  let alerts: [HomeAlert]
  let onSupportTapped: () -> Void
  let onSettingsTapped: () -> Void
  let onAlertTapped: (HomeAlert) -> Void
  let onGuidedCreationTapped: () -> Void
  let onAdvancedCreationTapped: () -> Void
  let onInsightsTapped: (DashboardInsightsContext) -> Void
  let onManageProfilesTapped: () -> Void
  let onStartProfile: (BlockedProfiles) -> Void
  let onStopProfile: (BlockedProfiles) -> Void
  let onEditProfile: (BlockedProfiles) -> Void
  let onProfileInsightsTapped: (BlockedProfiles) -> Void
  let onLauncherTapped: () -> Void
  let onActiveSessionTapped: () -> Void

  @State private var selectedProfileId: UUID?
  // Profile selection updates the expanded detail; closing the screen keeps Home on top.
  @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

  private var selectedProfile: BlockedProfiles? {
    profiles.first { $0.id == selectedProfileId } ?? profiles.first
  }

  var body: some View {
    HomeDashboardLayout(preferredCompactColumn: $preferredCompactColumn) { showsProfileInsights in
      dashboardContent(showsProfileInsights: showsProfileInsights)
    } insights: {
      profileInsights
        .toolbar(.visible, for: .navigationBar)
    }
  }

  private var activeProfile: BlockedProfiles? {
    strategyManager.isBlocking ? strategyManager.activeSession?.blockedProfile : nil
  }

  private var displayedProfile: BlockedProfiles? { activeProfile ?? selectedProfile }
  private var isResting: Bool { strategyManager.isBreakActive || strategyManager.isPauseActive }
  private var isDark: Bool { activeProfile != nil && !isResting }
  private var ink: Color { isDark ? Color(hex: "#EEECE4") : Color(hex: "#30322D") }
  private var surface: Color { isDark ? Color(hex: "#242923") : Color(hex: "#EFEDE6") }

  private var status: String {
    if strategyManager.isPauseActive { return "SESSION PAUSED" }
    if strategyManager.isBreakActive { return "TAKE A BREATHER" }
    return isDark ? "DISTRACTIONS BLOCKED" : "MAKE ROOM FOR LIFE"
  }

  private var actionTitle: String {
    guard let profile = displayedProfile else { return "Set up your Blocktab" }
    if activeProfile != nil {
      return isResting || strategyManager.activeSession?.isSessionActionLockedByHardMode() == true
        ? "View your session" : "Tap to unblock"
    }
    let strategy = StrategyManager.getStrategyFromId(id: profile.blockingStrategyId ?? "")
    return strategy.usesNFC ? "Tap your Blocktab" : "Start blocking"
  }

  private func primaryAction() {
    if let profile = activeProfile {
      if isResting || strategyManager.activeSession?.isSessionActionLockedByHardMode() == true {
        onActiveSessionTapped()
      } else {
        onStopProfile(profile)
      }
    } else if let profile = selectedProfile {
      onStartProfile(profile)
    } else {
      createGuidedProfile()
    }
  }

  private func dashboardContent(showsProfileInsights: Bool) -> some View {
    GeometryReader { geometry in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          HStack {
            Text("Blocktab")
              .font(.system(.title2, design: .rounded, weight: .bold))
            Spacer()
            Button(action: onSettingsTapped) {
              Image(systemName: "gearshape").font(.title3).frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings")
          }

          ForEach(alerts) { alert in
            Button {
              onAlertTapped(alert)
            } label: {
              HStack(spacing: 10) {
                Image(systemName: alert.iconName)
                Text(alert.title).multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
              }
              .font(.footnote.weight(.medium))
              .padding(14)
              .background(ink.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .accessibilityHint(alert.message)
          }

          if activeProfile != nil {
            VStack(spacing: 8) {
              Label(
                isResting ? "Apps available" : "You're in control",
                systemImage: isResting ? "pause.circle" : "lock.fill"
              )
              .font(.subheadline)
              Text(DateFormatters.formatDurationClock(strategyManager.sessionDisplayTime))
                .font(.system(.title, design: .monospaced, weight: .medium))
                .contentTransition(.numericText())
                .accessibilityLabel("Session time")
                .accessibilityValue(
                  DateFormatters.formatDurationClock(strategyManager.sessionDisplayTime))
            }
          } else {
            Label("Your time. Your attention.", systemImage: "sun.max")
              .font(.subheadline)
              .padding(.horizontal, 16).padding(.vertical, 10)
              .background(ink.opacity(0.05), in: Capsule())
          }

          Spacer(minLength: 12)

          VStack(spacing: 32) {
            BlocktabTileView(isActive: isDark)
              .frame(width: 184, height: 184)
              .accessibilityHidden(true)
            VStack(spacing: 12) {
              Text(status)
                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                .tracking(2)
                .foregroundStyle(ink.opacity(0.65))
              Text(displayedProfile?.name ?? "A little distance.\nA lot more presence.")
                .font(.system(.title, design: .rounded, weight: .medium))
                .multilineTextAlignment(.center)
              if let profile = displayedProfile {
                Text(
                  profile.enableAllowMode
                    ? "Only your selected apps are allowed"
                    : "Your selected distractions, out of reach"
                )
                .font(.subheadline).foregroundStyle(ink.opacity(0.7))
              } else {
                Text("Choose your distractions. Tap your NFC tag.\nGet back to what matters.")
                  .font(.subheadline).foregroundStyle(ink.opacity(0.7))
                  .multilineTextAlignment(.center)
              }
              if activeProfile != nil {
                Button("Session details", action: onActiveSessionTapped)
                  .font(.subheadline.weight(.medium))
              } else if !profiles.isEmpty {
                Menu {
                  ForEach(profiles) { profile in
                    Button {
                      selectedProfileId = profile.id
                    } label: {
                      if profile.id == selectedProfile?.id {
                        Label(profile.name, systemImage: "checkmark")
                      } else {
                        Text(profile.name)
                      }
                    }
                  }
                  Divider()
                  Button("Manage modes", action: onManageProfilesTapped)
                  Button("Create a mode", action: createGuidedProfile)
                } label: {
                  Label("Change mode", systemImage: "chevron.down")
                    .font(.subheadline.weight(.medium)).padding(8)
                }
              }
            }
          }

          Spacer(minLength: 24)

          VStack(spacing: 16) {
            Text(
              activeProfile != nil
                ? "A little space for what matters." : "Leave your Blocktab somewhere intentional."
            )
            .font(.footnote).foregroundStyle(ink.opacity(0.6))
            .multilineTextAlignment(.center)
            Button(action: primaryAction) {
              Label(actionTitle, systemImage: activeProfile != nil ? "lock.open" : "wave.3.right")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity).padding(.vertical, 19)
                .background(isDark ? Color(hex: "#DFE6CD") : Color(hex: "#30382C"), in: Capsule())
                .foregroundStyle(isDark ? Color(hex: "#242923") : Color(hex: "#F5F3EC"))
            }
            .buttonStyle(.plain)
            if let profile = displayedProfile {
              HStack {
                Button(action: onManageProfilesTapped) {
                  Label("Modes", systemImage: "square.grid.2x2")
                }
                Spacer()
                Button {
                  if showsProfileInsights {
                    selectProfile(profile)
                  } else {
                    onProfileInsightsTapped(profile)
                  }
                } label: {
                  Label("Activity", systemImage: "chart.bar.xaxis")
                }
              }
              .font(.footnote.weight(.medium)).padding(.horizontal, 12).padding(.top, 8)
            }
          }
        }
        .padding(.horizontal, 28).padding(.top, 8).padding(.bottom, 24)
        .frame(minHeight: geometry.size.height)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
      }
      .background(surface.ignoresSafeArea())
      .foregroundStyle(ink)
      .tint(ink)
    }
    .preferredColorScheme(isDark ? .dark : .light)
    .navigationTitle("Blocktab")
    .toolbar(.hidden, for: .navigationBar)
  }

  private var profileInsights: some View {
    Group {
      if let selectedProfile {
        ProfileInsightsContent(profile: selectedProfile)
          .id(selectedProfile.id)
      } else {
        ContentUnavailableView(
          "No Profiles",
          systemImage: "chart.line.uptrend.xyaxis",
          description: Text("Create a profile to see its focus insights here.")
        )
      }
    }
  }

  private func selectProfile(_ profile: BlockedProfiles) {
    selectedProfileId = profile.id
  }

  private func createGuidedProfile() {
    guard !strategyManager.isBlocking else { return }
    onGuidedCreationTapped()
  }

  private func createAdvancedProfile() {
    guard !strategyManager.isBlocking else { return }
    onAdvancedCreationTapped()
  }
}

private struct HomeDashboardPreview: View {
  let hasProfiles: Bool
  var isActive = false
  private let container: ModelContainer
  private let profile: BlockedProfiles
  private let session: BlockedProfileSession

  init(hasProfiles: Bool, isActive: Bool = false) {
    self.hasProfiles = hasProfiles
    self.isActive = isActive
    do {
      container = try ModelContainer(
        for: BlockedProfiles.self, BlockedProfileSession.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
      )
      profile = BlockedProfiles(
        name: "Deep Work",
        blockingStrategyId: NFCBlockingStrategy.id,
        domains: ["example.com"]
      )
      session = BlockedProfileSession(tag: ManualBlockingStrategy.id, blockedProfile: profile)
      session.startTime = Date().addingTimeInterval(-3600)
      session.endTime = isActive ? nil : Date()
      container.mainContext.insert(profile)
      container.mainContext.insert(session)
      try container.mainContext.save()
    } catch {
      fatalError("Failed to create dashboard preview: \(error)")
    }
  }

  private var previewStrategyManager: StrategyManager {
    let manager = StrategyManager()
    if isActive {
      manager.activeSession = session
      manager.elapsedTime = 3600
    }
    return manager
  }

  var body: some View {
    HomeDashboardView(
      profiles: hasProfiles ? [profile] : [],
      sessions: hasProfiles ? [session] : [],
      alerts: [],
      onSupportTapped: {},
      onSettingsTapped: {},
      onAlertTapped: { _ in },
      onGuidedCreationTapped: {},
      onAdvancedCreationTapped: {},
      onInsightsTapped: { _ in },
      onManageProfilesTapped: {},
      onStartProfile: { _ in },
      onStopProfile: { _ in },
      onEditProfile: { _ in },
      onProfileInsightsTapped: { _ in },
      onLauncherTapped: {},
      onActiveSessionTapped: {}
    )
    .modelContainer(container)
    .environmentObject(previewStrategyManager)
    .environmentObject(ThemeManager())
    .defaultAppStorage(UserDefaults(suiteName: "home-dashboard-preview")!)
  }
}

#Preview("Dashboard") {
  HomeDashboardPreview(hasProfiles: true)
}

#Preview("Empty Dashboard") {
  HomeDashboardPreview(hasProfiles: false)
}

#Preview("Blocktab Active") {
  HomeDashboardPreview(hasProfiles: true, isActive: true)
}
