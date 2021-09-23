import UIKit

class EmptyRoundedButton: UIButton {

  let defaultColor = UIColor(red: 240/255, green: 90/255, blue: 90/255, alpha: 1)

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    // Default params
    layer.cornerRadius = 10
    layer.borderWidth = 2
    layer.borderColor = defaultColor.cgColor
  }

  func highlight() {
    layer.backgroundColor = defaultColor.cgColor
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
