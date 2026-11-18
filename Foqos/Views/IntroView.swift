import SwiftUI

struct IntroView: View {
  let onRequestAuthorization: () -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        Text("Blocktab").font(.system(.title2, design: .rounded, weight: .bold))
        BlocktabTileView().frame(width: 170, height: 170).padding(.vertical, 28)
        VStack(spacing: 16) {
          Text("Less scrolling.\nMore living.")
            .font(.system(.largeTitle, design: .rounded, weight: .medium))
          Text("A physical pause for your digital life.")
            .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        VStack(alignment: .leading, spacing: 24) {
          Label("Choose the apps that pull you away.", systemImage: "square.grid.2x2")
          Label("Tap your Blocktab NFC tag to block them.", systemImage: "wave.3.right")
          Label("Tap the same tag when you're ready to return.", systemImage: "lock.open")
        }
        .font(.subheadline)
        Button(action: onRequestAuthorization) {
          Text("Connect Screen Time").fontWeight(.semibold)
            .frame(maxWidth: .infinity).padding(20)
            .background(Color(hex: "#30382C"), in: Capsule())
            .foregroundStyle(.white)
        }
        Text("Blocktab needs Screen Time access to block your selected apps.")
          .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
      }
      .padding(32).frame(maxWidth: 520).frame(maxWidth: .infinity)
    }
    .preferredColorScheme(.light)
    .background(Color(hex: "#EFEDE6").ignoresSafeArea())
    .foregroundStyle(Color(hex: "#30322D"))
  }
}

#Preview { IntroView {} }
