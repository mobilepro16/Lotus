//
//  CustomNibView.swift
//  lotus
//
//  Created by Robert Grube on 1/2/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class CustomNibView: UIView {

    var contentView: UIView!
    
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    
    //MARK:
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        loadViewFromNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        setup()
    }
    
    //MARK:
    func loadViewFromNib() {
        contentView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as? UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    func setup(){
        // should override
    }
}
