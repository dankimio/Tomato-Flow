import UIKit

class FilledCell: UICollectionViewCell {
  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.backgroundColor = .tintColor
    contentView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height) / 2.0
    contentView.layer.masksToBounds = true
  }
}
