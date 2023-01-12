import UIKit

class EmptyCell: UICollectionViewCell {
  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height) / 2.0
    contentView.layer.masksToBounds = true
    contentView.layer.borderWidth = 2
    contentView.layer.borderColor = Colors.primary.cgColor
  }
}
