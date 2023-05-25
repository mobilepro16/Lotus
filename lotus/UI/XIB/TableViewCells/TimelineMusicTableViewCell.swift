//
//  TimelineMusicTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 1/2/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

protocol TimelineMusicTableViewCellDelegate {
    func cellCommentsClicked(history: TimelineHistory)
    func cellMenuClicked(history: TimelineHistory)
}

class TimelineMusicTableViewCell: UITableViewCell {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileNameLabel: UILabel!
    @IBOutlet var profileDisplayNameLabel: UILabel!
    @IBOutlet var musicView: MusicView!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var commentsButton: UIButton!
    @IBOutlet var favoritesButton: UIButton!
    @IBOutlet var sharesButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var timestampLabel: UILabel!
    
    var delegate: TimelineMusicTableViewCellDelegate?
    
    var timelineHistory: TimelineHistory!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(history: TimelineHistory){
        self.timelineHistory = history
        
        if let music = history.history?.music {
            musicView.setData(music: music)
        }
        commentLabel.text = history.history?.userComment ?? ""
        if let date = history.sharedDate {
            timestampLabel.text = "\(date.timeAgo()) ago"
        }
        if let commentCount = history.history?.commentCount {
            if(commentCount == 0){
                commentsButton.setTitle("", for: .normal)
            } else {
                commentsButton.setTitle("\(commentCount)", for: .normal)
            }
        }
        
        if let likeCount = history.history?.likesCount {
            if(likeCount == 0){
                favoritesButton.setTitle("", for: .normal)
            } else {
                favoritesButton.setTitle("\(likeCount)", for: .normal)
            }
        }
                
        if(history.isLiked){
            let origImage = UIImage(named: "icon_fave")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            favoritesButton.setImage(tintedImage, for: .normal)
            favoritesButton.tintColor = .red
        } else {
            favoritesButton.setImage(UIImage(named: "icon_fave"), for: .normal)
            favoritesButton.tintColor = .systemBlue
        }
        
        if let user = history.user {
            profileNameLabel.text = history.message ?? "NO MESSAGE"
            
            profileDisplayNameLabel.text = "@\(user.displayName ?? "")"
            if let profImage = user.image, let profUrl = URL(string: imageUrlPrefix + profImage){
                profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
            } else {
                profileImage.image = GeneralConstants.defaultUserImage
            }
        }
    }
    
    @IBAction func menuClicked(_ sender: Any) {
        delegate?.cellMenuClicked(history: timelineHistory)
    }
    
    @IBAction func commentsClicked(_ sender: Any) {
        delegate?.cellCommentsClicked(history: timelineHistory)
    }
    
    @IBAction func likesClicked(_ sender: Any) {
        timelineHistory.isLiked = !timelineHistory.isLiked
        guard let history = self.timelineHistory.history else { return }
        
        if(timelineHistory.isLiked){
            ContentServices.like(historyId: history.id) { (data) in
                history.likesCount = (history.likesCount ?? 0) + 1
                self.setData(history: self.timelineHistory)
                let usersRef = Firestore.firestore().collection("users_table").document(history.userId!)
                usersRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let token = document.get("fcmToken") as! String
                        print("Document data: \(token)")
                        let sender = PushNotificationSender()
                        sender.sendPushNotification(to: token , title: "", body: (Globals.sharedInstance.myProfile!.displayName! + " liked your post."))
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        } else {
            ContentServices.unlike(historyId: history.id) { (data) in
                history.likesCount = (history.likesCount ?? 0) - 1
                self.setData(history: self.timelineHistory)
            }
        }
    }
    
    @IBAction func shareClick(_ sender: Any) {
    }
}
