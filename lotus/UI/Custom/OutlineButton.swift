//
//  OutlineButton.swift
//  lotus
//
//  Created by Robert Grube on 3/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class OutlineButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = bounds.height / 2
        
        contentEdgeInsets.left = 20
        contentEdgeInsets.right = 20
    }

}
