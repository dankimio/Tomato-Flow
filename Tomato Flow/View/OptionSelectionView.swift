import SwiftUI

struct OptionSelectionView: View {
  let title: String
  let options: [Int]
  let specifier: String
  let selected: Int
  let onSelect: (Int) -> Void

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List {
      ForEach(options, id: \.self) { option in
        Button(action: {
          onSelect(option)
          dismiss()
        }) {
          HStack {
            Text("\(option) \(specifier)")
              .foregroundStyle(.primary)
            Spacer()
            if option == selected {
              Image(systemName: "checkmark")
                .foregroundStyle(.tint)
            }
          }
        }
      }
    }
    .navigationTitle(title)
  }
}

#if DEBUG
  struct DiscreteOptionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        OptionSelectionView(
          title: "Interval length",
          options: [25, 30, 35, 40],
          specifier: "minutes",
          selected: 25,
          onSelect: { _ in }
        )
      }
    }
  }
#endif
