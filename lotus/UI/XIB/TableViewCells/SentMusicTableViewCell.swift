//
//  SentMusicTableViewCell.swift
//  lotus
//
//  Created by admin on 4/2/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class SentMusicTableViewCell: UITableViewCell {

  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var splitDateView: UIView!
  @IBOutlet weak var splitDate: UILabel!
  @IBOutlet weak var labelTime: UILabel!
  @IBOutlet weak var artPhoto: UIImageView!
  @IBOutlet weak var musicTitle: UILabel!
  @IBOutlet weak var messageBackground: UIImageView!
  @IBOutlet weak var musicInfo: UILabel!
  @IBOutlet weak var separatorViewHeight: NSLayoutConstraint!
  @IBOutlet weak var spotifyButton: UIButton!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.width / 2
        profilePhoto.clipsToBounds = true
      
        messageBackground.layer.cornerRadius = 12
        messageBackground.clipsToBounds = true
    
        artPhoto.layer.cornerRadius = 10
        artPhoto.clipsToBounds = true
    
        if (Globals.sharedInstance.musicPlatform == .spotify){
            self.spotifyButton.setBackgroundImage(UIImage(named: "spotify2"), for: .normal)
        } else {
            self.spotifyButton.setBackgroundImage(UIImage(named: "apple2"), for: .normal)
        }
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
