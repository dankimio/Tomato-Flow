import UIKit

class EmptyCell: UICollectionViewCell {
  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height) / 2.0
    contentView.layer.masksToBounds = true
    contentView.layer.borderWidth = 2.5
    contentView.layer.borderColor = UIColor.systemGray4.cgColor
  }
}
