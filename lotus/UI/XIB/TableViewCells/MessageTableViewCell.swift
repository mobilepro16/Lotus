//
//  MessageTableViewCell.swift
//  lotus
//
//  Created by admin on 3/3/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

  @IBOutlet weak var profileView: UIView!
  @IBOutlet weak var profileName: UILabel!
  @IBOutlet weak var profileId: UILabel!
  @IBOutlet weak var lastMessage: UILabel!
  @IBOutlet weak var albumImage: UIImageView!
  @IBOutlet weak var albumView: UIView!
  @IBOutlet weak var albumTitle: UILabel!
  @IBOutlet weak var albumInfo: UILabel!
  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var lasttime: UILabel!
  @IBOutlet weak var unReadCountBack: UIImageView!
  @IBOutlet weak var unReadCount: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.width / 2
        profilePhoto.clipsToBounds = true
        unReadCountBack.layer.cornerRadius = unReadCountBack.bounds.width / 2
        unReadCountBack.clipsToBounds = true
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
