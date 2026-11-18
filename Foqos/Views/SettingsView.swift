import FamilyControls
import SwiftData
import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context
  @EnvironmentObject var themeManager: ThemeManager
  @EnvironmentObject var requestAuthorizer: RequestAuthorizer
  @EnvironmentObject var strategyManager: StrategyManager

  @State private var showResetBlockingAlert = false
  @State private var showDebugView = false

  private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      ?? "1.0"
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Theme") {
          HStack {
            Image(systemName: "paintpalette.fill")
              .foregroundStyle(themeManager.themeColor)
              .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
              Text("Appearance")
                .font(.headline)
              Text("Customize the look of your app")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          .padding(.vertical, 8)

          Picker("Theme Color", selection: $themeManager.selectedColorName) {
            ForEach(ThemeManager.availableColors, id: \.name) { colorOption in
              HStack {
                Circle()
                  .fill(colorOption.color)
                  .frame(width: 20, height: 20)
                Text(colorOption.name)
              }
              .tag(colorOption.name)
            }
          }
          .onChange(of: themeManager.selectedColorName) { _, _ in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
          }
        }

        Section("Help & Troubleshooting") {
          Link(destination: URL(string: "https://www.foqos.app/support.html")!) {
            HStack {
              VStack(alignment: .leading, spacing: 2) {
                Text("FoQoS setup guides")
                  .foregroundColor(.primary)
                Text("Technical guides from the open-source project")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              Spacer()
              Image(systemName: "arrow.up.right.square")
                .foregroundColor(.secondary)
            }
          }

          Link(destination: URL(string: "https://www.foqos.app/blocking-native-apps.html")!) {
            HStack {
              Text("Block Safari & Settings")
                .foregroundColor(.primary)
              Spacer()
              Image(systemName: "arrow.up.right.square")
                .foregroundColor(.secondary)
            }
          }

          HStack {
            Text("Debug Mode")
              .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
              .foregroundColor(.secondary)
              .font(.caption)
          }
          .onTapGesture {
            showDebugView = true
          }

          if !strategyManager.isBlocking {
            Button {
              showResetBlockingAlert = true
            } label: {
              Text("Fix Stuck Blocking")
                .foregroundColor(themeManager.themeColor)
            }
          }
        }

        Section("About") {
          HStack {
            Text("Version")
              .foregroundStyle(.primary)
            Spacer()
            Text("v\(appVersion)")
              .foregroundStyle(.secondary)
          }

          HStack {
            Text("Screen Time Access")
              .foregroundStyle(.primary)
            Spacer()
            HStack(spacing: 8) {
              Circle()
                .fill(requestAuthorizer.getAuthorizationStatus() == .approved ? .green : .red)
                .frame(width: 8, height: 8)
              Text(
                requestAuthorizer.getAuthorizationStatus() == .approved
                  ? "Authorized" : "Not Authorized"
              )
              .foregroundStyle(.secondary)
              .font(.subheadline)
            }
          }

          Link("Blocktab.app", destination: URL(string: "https://blocktab.app")!)
          Link("Source code", destination: URL(string: "https://github.com/KanishkKundu05/foqos")!)
          Text("Based on FoQoS by Ali Waseem. Open source under the MIT license.")
            .font(.footnote).foregroundStyle(.secondary)
        }

        Section("Your Blocktab") {
          Label("NFC tag · Recommended", systemImage: "wave.3.right")
          Text(
            "Tap your tag to start blocking. Tap the same tag to unlock. You can choose other methods in each mode's settings."
          )
          .font(.subheadline).foregroundStyle(.secondary)
          Link("Visit Blocktab", destination: URL(string: "https://blocktab.app")!)
        }

      }
      .navigationTitle("Settings")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Close")
        }
      }
      .alert("Fix Stuck Blocking?", isPresented: $showResetBlockingAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Fix Blocking", role: .destructive) {
          strategyManager.resetBlockingState(context: context)
        }
      } message: {
        Text(
          "Clear stuck restrictions on this iPhone and your synced Mac. Your profiles and history will be kept."
        )
      }
      .sheet(isPresented: $showDebugView) {
        DebugView()
      }
    }
  }
}

#Preview {
  SettingsView()
    .environmentObject(ThemeManager.shared)
    .environmentObject(RequestAuthorizer())
    .environmentObject(StrategyManager.shared)
    .modelContainer(for: BlockedProfiles.self, inMemory: true)
}
