import UIKit

class SecondaryButton: UIButton {
  override func layoutSubviews() {
    super.layoutSubviews()
  
    layer.cornerRadius = 6
    layer.borderWidth = 2
    layer.borderColor = Colors.primary.cgColor
  }
}
