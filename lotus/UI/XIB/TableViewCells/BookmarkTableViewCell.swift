//
//  BookmarkTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 10/26/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {

    @IBOutlet var bookmarkView: BookmarkView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
