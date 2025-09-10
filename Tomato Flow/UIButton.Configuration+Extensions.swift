import UIKit

extension UIButton.Configuration {
  public static func primary() -> UIButton.Configuration {
    var configuration = UIButton.Configuration.filled()
    configuration.baseBackgroundColor = Colors.primary
    configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
      incoming in
      var outgoing = incoming
      let bodyFont = UIFont.preferredFont(forTextStyle: .body)
      let mediumWeight = UIFont.Weight.medium
      outgoing.font = UIFont.systemFont(ofSize: bodyFont.pointSize, weight: mediumWeight)
      return outgoing
    }

    return configuration
  }

  public static func secondary() -> UIButton.Configuration {
    var configuration = UIButton.Configuration.tinted()
    configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
      incoming in
      var outgoing = incoming
      let bodyFont = UIFont.preferredFont(forTextStyle: .body)
      let mediumWeight = UIFont.Weight.medium
      outgoing.font = UIFont.systemFont(ofSize: bodyFont.pointSize, weight: mediumWeight)
      return outgoing
    }
    return configuration
  }
}
