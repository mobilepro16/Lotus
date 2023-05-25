//
//  NotificationTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 3/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol NotificationTableViewCellDelegate {
    func followTapped(userId: String)
    func unfollowTapped(userId: String)
    func profileTapped(userId: String)
    func albumTapped(notification: LotusNotification)
    func menuClicked(notification: LotusNotification)
}
class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var timeAgoLabel: UILabel!
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var unreadView: UIView!
    
    var notification: LotusNotification!
    var delegate: NotificationTableViewCellDelegate?
  
    func setData(notification: LotusNotification){
        self.notification = notification
        
        var attrString1 = notification.message ?? ""
        switch notification.type {
        case .follow, .friend, .party:
            followButton.isHidden = false
            albumImage.isHidden = true
            attrString1 = " followed you"
        case .comment:
            followButton.isHidden = true
            albumImage.isHidden = false
            attrString1 = " commented on your post"
        case .like:
            followButton.isHidden = true
            albumImage.isHidden = false
            attrString1 = " liked your post"
        default:
            followButton.isHidden = true
            albumImage.isHidden = true
        
        }
        let myString = "\(notification.fromUser?.firstName ?? "") \(notification.fromUser?.lastName ?? "")" + attrString1
        messageLabel.text = myString
      
        if let image = notification.historyImage, let url = URL(string: image){
            albumImage.sd_setImage(with: url)
        } else {
            albumImage.image = nil
        }
        
        if let prof = notification.fromUser?.image, let url = URL(string: imageUrlPrefix + prof){
            profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        } else {
            profileImage.image = GeneralConstants.defaultUserImage
        }
        
        unreadView.isHidden = notification.isRead
        var aString = "\((notification.createdAt ?? Date()).timeAgo())"
        aString = aString.replacingOccurrences(of: " seconds", with: "s")
        aString = aString.replacingOccurrences(of: " minutes", with: "m")
        aString = aString.replacingOccurrences(of: " hours", with: "h")
        aString = aString.replacingOccurrences(of: " days", with: "d")
        aString = aString.replacingOccurrences(of: " weeks", with: "w")
        aString = aString.replacingOccurrences(of: " months", with: "mo")
        aString = aString.replacingOccurrences(of: " years", with: "y")
        aString = aString.replacingOccurrences(of: " second", with: "s")
        aString = aString.replacingOccurrences(of: " minute", with: "m")
        aString = aString.replacingOccurrences(of: " hour", with: "h")
        aString = aString.replacingOccurrences(of: " day", with: "d")
        aString = aString.replacingOccurrences(of: " week", with: "w")
        aString = aString.replacingOccurrences(of: " month", with: "mo")
        aString = aString.replacingOccurrences(of: " year", with: "y")
        timeAgoLabel.text = aString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        unreadView.layer.cornerRadius = unreadView.bounds.height / 2
      
        followButton.layer.cornerRadius = followButton.bounds.height / 2
        followButton.clipsToBounds = true
      
        albumImage.layer.borderWidth = 0.9
        albumImage.layer.borderColor = UIColor.white.cgColor
      
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileImage.addGestureRecognizer(profileTap)
        
        let albumTap = UITapGestureRecognizer(target: self, action: #selector(albumTapped))
        albumImage.addGestureRecognizer(albumTap)
      
    }
    @objc func profileTapped(){
        delegate?.profileTapped(userId: notification.fromUser!.id)
    }
    @objc func albumTapped(){
        delegate?.albumTapped(notification: notification)
    }
    @IBAction func moreClicked(_ sender: Any) {
        delegate?.menuClicked(notification: notification)
    }
    @IBAction func followTapped(_ sender: Any) {
        let buttonTitle = self.followButton.title(for: .normal)
        if (buttonTitle == "FOLLOW"){
          delegate?.followTapped(userId: notification.fromUser!.id)
        } else if (buttonTitle == "FOLLOWING"){
          delegate?.unfollowTapped(userId: notification.fromUser!.id)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
