//
//  RoundedButton.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-25.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

  let defaultColor = UIColor(red: 240/255, green: 90/255, blue: 90/255, alpha: 1)
  let highlightedColor = UIColor(red: 220/255, green: 70/255, blue: 70/255, alpha: 1)

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    layer.cornerRadius = 5
    layer.backgroundColor = defaultColor.cgColor
  }

  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        layer.backgroundColor = highlightedColor.cgColor
      } else {
        layer.backgroundColor = defaultColor.cgColor
      }
    }
  }

}
