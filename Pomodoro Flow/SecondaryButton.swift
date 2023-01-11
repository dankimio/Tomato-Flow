import UIKit

class SecondaryButton: UIButton {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = 6
    layer.borderWidth = 2
    layer.borderColor = Colors.primary.cgColor
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    UIView.animate(withDuration: 0.15) {
      self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    UIView.animate(withDuration: 0.15) {
      self.transform = .identity
    }
  }
}
