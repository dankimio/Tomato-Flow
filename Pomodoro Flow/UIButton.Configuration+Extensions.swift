import UIKit

extension UIButton.Configuration {
  public static func primary() -> UIButton.Configuration {
    var configuration = UIButton.Configuration.filled()
    configuration.baseBackgroundColor = Colors.primary
    
    return configuration
  }
  
  public static func secondary() -> UIButton.Configuration {
    var configuration = UIButton.Configuration.filled()
    configuration.baseBackgroundColor = UIColor.clear
    configuration.baseForegroundColor = Colors.primary
    
    return configuration
  }
}
