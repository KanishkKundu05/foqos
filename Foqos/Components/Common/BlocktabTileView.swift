import SwiftUI

/// An original, code-drawn Blocktab device mark shared by onboarding and Home.
struct BlocktabTileView: View {
  var isActive = false

  private var face: Color {
    isActive ? Color(hex: "#59634E") : Color(hex: "#DDDCD4")
  }

  var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      ZStack {
        RoundedRectangle(cornerRadius: size * 0.24)
          .fill(face.gradient)
          .shadow(color: .black.opacity(isActive ? 0.3 : 0.18), radius: 14, x: 6, y: 12)
          .shadow(color: .white.opacity(isActive ? 0.04 : 0.7), radius: 8, x: -6, y: -6)
        RoundedRectangle(cornerRadius: size * 0.19)
          .strokeBorder(.white.opacity(0.22), lineWidth: 2)
          .padding(7)
        VStack(spacing: 10) {
          Image(systemName: isActive ? "lock.fill" : "wave.3.right")
            .font(.system(size: size * 0.15, weight: .medium))
          Text("Blocktab")
            .font(.system(size: size * 0.16, weight: .bold, design: .rounded))
            .tracking(-1)
          Capsule()
            .fill(isActive ? Color(hex: "#DDE9BC") : Color(hex: "#A7AC9B"))
            .frame(width: size * 0.15, height: 4)
        }
        .foregroundStyle(isActive ? Color(hex: "#F0F0E6") : Color(hex: "#777C6F"))
      }
      .frame(width: size, height: size)
    }
  }
}

#Preview("Idle") { BlocktabTileView().frame(width: 184, height: 184).padding(40) }
#Preview("Blocking") { BlocktabTileView(isActive: true).frame(width: 184, height: 184).padding(40) }
