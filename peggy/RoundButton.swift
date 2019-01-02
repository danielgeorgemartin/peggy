//
//  RoundButton.swift
//  peggy
//
//  Created by Daniel Martin on 02/01/2019.
//  Copyright © 2019 1416394. All rights reserved.
//

import UIKit
@IBDesignable

class RoundButton: UIButton {

    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
