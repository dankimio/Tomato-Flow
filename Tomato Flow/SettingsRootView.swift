import SwiftUI
import UIKit

struct SettingsRootView: View {
  @State private var pomodoroMinutes: Int = 25
  @State private var shortBreakMinutes: Int = 5
  @State private var longBreakMinutes: Int = 20
  @State private var targetPomodoros: Int = 5

  private let settings = SettingsManager.sharedManager

  private struct About {
    static let twitterURL = URL(string: "https://twitter.com/dankimio")!
    static let homepageURL = URL(string: "https://dan.kim")!
    static let appStoreURL = URL(string: "https://apps.apple.com/us/app/tomato-flow/id1095742214")!
  }

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("General")) {
          NavigationLink(
            destination: DiscreteOptionSelectionView(
              title: "Interval length",
              options: [25, 30, 35, 40],
              specifier: "minutes",
              selected: pomodoroMinutes,
              onSelect: { value in
                pomodoroMinutes = value
                settings.pomodoroLength = value
              }
            )
          ) {
            HStack {
              Text("Interval length")
              Spacer()
              Text("\(pomodoroMinutes) minutes").foregroundColor(.secondary)
            }
          }

          NavigationLink(
            destination: DiscreteOptionSelectionView(
              title: "Short break length",
              options: [5, 10, 15, 20],
              specifier: "minutes",
              selected: shortBreakMinutes,
              onSelect: { value in
                shortBreakMinutes = value
                settings.shortBreakLength = value
              }
            )
          ) {
            HStack {
              Text("Short break length")
              Spacer()
              Text("\(shortBreakMinutes) minutes").foregroundColor(.secondary)
            }
          }

          NavigationLink(
            destination: DiscreteOptionSelectionView(
              title: "Long break length",
              options: [10, 15, 20, 25, 30],
              specifier: "minutes",
              selected: longBreakMinutes,
              onSelect: { value in
                longBreakMinutes = value
                settings.longBreakLength = value
              }
            )
          ) {
            HStack {
              Text("Long break length")
              Spacer()
              Text("\(longBreakMinutes) minutes").foregroundColor(.secondary)
            }
          }

          NavigationLink(
            destination: DiscreteOptionSelectionView(
              title: "Target pomodoros",
              options: Array(2...14),
              specifier: "pomodoros",
              selected: targetPomodoros,
              onSelect: { value in
                targetPomodoros = value
                settings.targetPomodoros = value
              }
            )
          ) {
            HStack {
              Text("Target pomodoros")
              Spacer()
              Text("\(targetPomodoros) pomodoros").foregroundColor(.secondary)
            }
          }
        }

        Section(header: Text("About")) {
          Button(action: { open(url: About.twitterURL) }) {
            HStack {
              Text("Follow me on Twitter")
              Spacer()
              Text("@dankimio").foregroundColor(.secondary)
            }
          }

          Button(action: { open(url: About.homepageURL) }) {
            Text("Visit my website")
          }

          Button(action: { open(url: About.appStoreURL) }) {
            Text("Rate on the App Store")
          }
        }
      }
      .navigationTitle("Settings")
    }
    .onAppear(perform: loadFromSettings)
  }

  private func loadFromSettings() {
    pomodoroMinutes = displayMinutes(from: settings.pomodoroLength)
    shortBreakMinutes = displayMinutes(from: settings.shortBreakLength)
    longBreakMinutes = displayMinutes(from: settings.longBreakLength)
    targetPomodoros = settings.targetPomodoros
  }

  private func open(url: URL) {
    UIApplication.shared.open(url)
  }
}

private func displayMinutes(from value: Int) -> Int {
  #if DEBUG
    return value
  #else
    return max(1, value / 60)
  #endif
}
