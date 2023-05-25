//
//  ReceivedMusicTableViewCell.swift
//  lotus
//
//  Created by admin on 4/2/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class ReceivedMusicTableViewCell: UITableViewCell {

  @IBOutlet weak var splitDateView: UIView!
  @IBOutlet weak var splitDate: UILabel!
  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var artPhoto: UIImageView!
  @IBOutlet weak var musicTitle: UILabel!
  @IBOutlet weak var musicInfo: UILabel!
  @IBOutlet weak var labelTime: UILabel!
 
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.width / 2
        profilePhoto.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
