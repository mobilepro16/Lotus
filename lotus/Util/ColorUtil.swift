//
//  ColorUtil.swift
//  lotus
//
//  Created by Robert Grube on 1/6/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

extension UIColor {
    public class var lotusBackground : UIColor {
        return UIColor(named: "lotusBackground") ?? UIColor.systemBackground
    }
    
    public class var lotusHR : UIColor {
        return UIColor(named: "lotusHR") ?? UIColor.lightGray
    }
    
    public class var lotusTabUnselected : UIColor {
        return UIColor(named: "lotusTabUnselected") ?? UIColor.systemBlue
    }
  
    public class var tabbarUnselected : UIColor {
        return UIColor(named: "tabbarcolor") ?? UIColor.systemBlue
    }
}
