//
//  SentMessageTableViewCell.swift
//  lotus
//
//  Created by admin on 4/2/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class SentMessageTableViewCell: UITableViewCell {

  @IBOutlet weak var splitDateView: UIView!
  @IBOutlet weak var splitDate: UILabel!
  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var labelTime: UILabel!
  @IBOutlet weak var messageBackground: UIImageView!
  @IBOutlet weak var message: UILabel!
  @IBOutlet weak var separatorViewHeight: NSLayoutConstraint!
  override func awakeFromNib() {
        super.awakeFromNib() 
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.width / 2
        profilePhoto.clipsToBounds = true
    
        messageBackground.layer.cornerRadius = 18
        messageBackground.clipsToBounds = true
    
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
