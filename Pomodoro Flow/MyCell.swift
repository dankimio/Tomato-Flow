//
//  File.swift
//  Pomodoro Flow
//
//  Created by Dan on 10/01/2023.
//  Copyright © 2023 Dan K. All rights reserved.
//

import UIKit

class MyCell: UICollectionViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .red
        contentView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height) / 2.0
        contentView.layer.masksToBounds = true
    }
}
