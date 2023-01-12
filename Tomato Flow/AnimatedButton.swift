import UIKit

class AnimatedButton: UIButton {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    UIView.animate(withDuration: 0.1) {
      self.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    UIView.animate(withDuration: 0.1) {
      self.transform = .identity
    }
  }
}
