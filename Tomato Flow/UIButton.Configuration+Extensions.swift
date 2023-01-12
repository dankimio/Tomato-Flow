import UIKit

extension UIButton.Configuration {
  public static func primary() -> UIButton.Configuration {
    var configuration = UIButton.Configuration.filled()
    configuration.baseBackgroundColor = Colors.primary

    return configuration
  }

  public static func secondary() -> UIButton.Configuration {
    return UIButton.Configuration.tinted()
  }
}
