//
//  UserTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 2/14/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func followTapped(userId: String)
    func unfollowTapped(userId: String)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var selectionStatus: UIButton!
    @IBOutlet weak var followButton: UIButton!
  
    var user: User!
    var delegate: UserTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        followButton.layer.cornerRadius = followButton.bounds.height / 2
        followButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  @IBAction func followClicked(_ sender: Any) {
      let buttonTitle = self.followButton.title(for: .normal)
      if (buttonTitle == "FOLLOW"){
          delegate?.followTapped(userId: user.id)
      } else if (buttonTitle == "FOLLOWING"){
          delegate?.unfollowTapped(userId: user.id)
      }
  }
  func setData(user: User){
        self.user = user
        nameLabel.text = user.displayName
        profileImageView.image = GeneralConstants.defaultUserImage
        if let image = user.image, let url = URL(string: imageUrlPrefix + image) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        }
    }
}
