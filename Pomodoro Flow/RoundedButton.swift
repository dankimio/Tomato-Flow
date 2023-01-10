import UIKit

class RoundedButton: UIButton {

  let highlightedColor = UIColor(red: 220/255, green: 70/255, blue: 70/255, alpha: 1)

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    layer.cornerRadius = 8
    layer.backgroundColor = Colors.primary.cgColor
  }

  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        layer.backgroundColor = highlightedColor.cgColor
      } else {
        layer.backgroundColor = Colors.primary.cgColor
      }
    }
  }

}
