import UIKit

class EmptyRoundedButton: UIButton {

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    // Default params
    layer.cornerRadius = 8
    layer.borderWidth = 2
    layer.borderColor = Colors.primary.cgColor
  }

  func highlight() {
    layer.backgroundColor = Colors.primary.cgColor
  }

  func removeHighlight() {
    layer.backgroundColor = UIColor.clear.cgColor
  }

  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        highlight()
      } else {
        removeHighlight()
      }
    }
  }

}
