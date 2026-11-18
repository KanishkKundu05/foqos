import SwiftUI

struct SupportView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List {
        Section("Blocktab") {
          Text(
            "A physical pause for your digital life. Tap your NFC tag to make space for what matters."
          )
          Link("Visit Blocktab.app", destination: URL(string: "https://blocktab.app")!)
          Link(
            "Source code & issues",
            destination: URL(string: "https://github.com/KanishkKundu05/foqos")!)
        }
        Section("Open-source acknowledgements") {
          Text(
            "Blocktab is based on FoQoS, created by Ali Waseem and its contributors, under the MIT license."
          )
          Link(
            "FoQoS upstream project", destination: URL(string: "https://github.com/awaseem/foqos")!)
          Link(
            "Technical setup guides",
            destination: URL(string: "https://www.foqos.app/support.html")!)
        }
      }
      .navigationTitle("About Blocktab")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
      }
    }
  }
}
