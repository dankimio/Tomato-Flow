//
//  EmptyRoundedButton.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-24.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class EmptyRoundedButton: UIButton {

    let defaultColor = UIColor(red: 240/255, green: 90/255, blue: 90/255, alpha: 1)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Default params
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = defaultColor.CGColor
    }

    func highlight() {
        layer.backgroundColor = defaultColor.CGColor
    }

    func removeHighlight() {
        layer.backgroundColor = UIColor.clearColor().CGColor
    }

    override var highlighted: Bool {
        didSet {
            if highlighted {
                highlight()
            } else {
                removeHighlight()
            }
        }
    }

}
