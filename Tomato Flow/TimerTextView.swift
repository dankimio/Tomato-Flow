import SwiftUI

final class TimerTextViewModel: ObservableObject {
  @Published var timeString: String
  @Published var textColor: Color

  init(timeString: String = "25:00", textColor: Color = Color(UIColor.label)) {
    self.timeString = timeString
    self.textColor = textColor
  }
}

struct TimerTextView: View {
  @ObservedObject var viewModel: TimerTextViewModel

  var body: some View {
    let baseText = Text(viewModel.timeString)
      .font(.system(size: 128, weight: .medium, design: .monospaced))
      .foregroundColor(viewModel.textColor)
      .multilineTextAlignment(.center)
      .lineLimit(1)
      .minimumScaleFactor(0.2)

    Group {
      if #available(iOS 17.0, *) {
        baseText
          .contentTransition(.numericText())
          .animation(.easeInOut(duration: 0.3), value: viewModel.timeString)
      } else {
        baseText
          .animation(.easeInOut(duration: 0.3), value: viewModel.timeString)
      }
    }
  }
}
