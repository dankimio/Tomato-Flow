import UIKit

class SettingsViewController: UITableViewController, PickerViewControllerDelegate {

  @IBOutlet weak var pomodoroLengthLabel: UILabel!
  @IBOutlet weak var shortBreakLengthLabel: UILabel!
  @IBOutlet weak var longBreakLengthLabel: UILabel!
  @IBOutlet weak var targetPomodorosLabel: UILabel!

  // About section
  @IBOutlet weak var twitterCell: UITableViewCell!
  @IBOutlet weak var homepageCell: UITableViewCell!
  @IBOutlet weak var appStoreCell: UITableViewCell!

  fileprivate let userDefaults = UserDefaults.standard
  fileprivate let settings = SettingsManager.sharedManager

  fileprivate struct About {
    static let twitterURL = "https://twitter.com/dankimio"
    static let homepageURL = "https://dan.kim"
    static let appStoreURL = "https://apps.apple.com/us/app/tomato-flow/id1095742214"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupLabels()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }

  fileprivate func setupLabels() {
    pomodoroLengthLabel.text = "\(settings.pomodoroLength / 60) minutes"
    shortBreakLengthLabel.text = "\(settings.shortBreakLength / 60) minutes"
    longBreakLengthLabel.text = "\(settings.longBreakLength / 60) minutes"
    targetPomodorosLabel.text = "\(settings.targetPomodoros) pomodoros"
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let picker = segue.destination as? PickerViewController {
      switch segue.identifier! {
      case "PomodoroLengthPicker":
        picker.selectedValue = settings.pomodoroLength
        picker.type = PickerType.pomodoroLength
      case "ShortBreakLengthPicker":
        picker.selectedValue = settings.shortBreakLength
        picker.type = PickerType.shortBreakLength
      case "LongBreakLengthPicker":
        picker.selectedValue = settings.longBreakLength
        picker.type = PickerType.longBreakLength
      case "TargetPomodorosPicker":
        picker.specifier = "pomodoros"
        picker.selectedValue = settings.targetPomodoros
        picker.type = PickerType.targetPomodoros
      default:
        break
      }
      picker.delegate = self
    }
  }

  func pickerDidFinishPicking(_ picker: PickerViewController) {
    setupLabels()
  }

  // MARK: - Table view delegate

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)

    let cell = tableView.cellForRow(at: indexPath)!
    switch cell {
    case twitterCell: openURL(About.twitterURL)
    case homepageCell: openURL(About.homepageURL)
    case appStoreCell: openURL(About.appStoreURL)
    default: return
    }
  }

  // MARK: - Helpers

  fileprivate func openURL(_ url: String) {
    if let url = URL(string: url) {
      UIApplication.shared.open(url)
    }
  }

}
