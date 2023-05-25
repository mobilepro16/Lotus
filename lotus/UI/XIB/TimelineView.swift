//
//  TimelineView.swift
//  lotus
//
//  Created by Robert Grube on 9/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

protocol TimelineViewDelegate {
    func cellCommentsClicked(history: TimelineHistory)
    func cellMenuClicked(history: TimelineHistory)
    func cellPlayClicked(history: TimelineHistory)
    func cellUserClicked(history: TimelineHistory)
    func addPending(history: TimelineHistory)
}

class TimelineView: CustomNibView {
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet var authorView: UIView!
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorDetailLabel: UILabel!
    @IBOutlet var authorImageView: UIImageView!
    
    @IBOutlet var albumImageView: UIImageView!
    
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var songArtistAlbumLabel: UILabel!
    @IBOutlet var bookmarkButton: UIButton!
    
    @IBOutlet var commentsButton: UIButton!
    @IBOutlet var likesButton: UIButton!
    @IBOutlet var sharesButton: UIButton!
    @IBOutlet var timeAgoLabel: UILabel!
    @IBOutlet var userCommentLabel: UILabel!
    
    var timelineHistory: TimelineHistory!
    
    var delegate: TimelineViewDelegate?
    
    override func setup() {
        authorImageView.layer.cornerRadius = authorImageView.bounds.width / 2
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(authorTapped))
        authorView.addGestureRecognizer(tapGest)
      
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(myUIImageViewTapped))
        albumImageView.addGestureRecognizer(singleTap)
        albumImageView.isUserInteractionEnabled = true
      
    }
  
    @objc func myUIImageViewTapped(recognizer: UITapGestureRecognizer) {
      if(recognizer.state == UIGestureRecognizer.State.ended){
            delegate?.cellPlayClicked(history: timelineHistory)
         }
     }
    
    @objc func authorTapped(){
        delegate?.cellUserClicked(history: timelineHistory)
    }
    
    func setData(timelineHistory: TimelineHistory){
        self.timelineHistory = timelineHistory
        
        if let user = timelineHistory.user {
            authorDetailLabel.text = user.displayName ?? ""
            
            let myAttribute = [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
          
            let myString = NSMutableAttributedString(string: "\(user.firstName ?? "") \(user.lastName ?? "")", attributes: myAttribute)
            let attrString1 = NSAttributedString(string: " is listening to")

            myString.append(attrString1)
      
          
            authorNameLabel.attributedText = myString
                       
            if let profImage = user.image, let profUrl = URL(string: imageUrlPrefix + profImage){
                authorImageView.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
            } else {
                authorImageView.image = UIImage(named: "fake-user")
            }
        }

        userCommentLabel.text = timelineHistory.userComment ?? ""
        
        bookmarkButton.setImage(timelineHistory.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)
        
        if let music = timelineHistory.history?.music {
            if(music.title!.count > 25){
              songTitleLabel.text = music.title!.prefix(25) + "..."
            } else {
              songTitleLabel.text = music.title ?? ""
            }
            let albumlabel = music.artist ?? ""
            if(albumlabel.count > 25){
              songArtistAlbumLabel.text = albumlabel.prefix(25) + "..."
            } else {
              songArtistAlbumLabel.text = albumlabel
            }
      
            if let image = music.image, let url = URL(string: image){
                albumImageView.sd_setImage(with: url)
            }
        }
        
        if let commentCount = timelineHistory.history?.commentCount {
            if(commentCount == 0){
                commentsButton.setTitle("", for: .normal)
            } else {
                commentsButton.setTitle("\(commentCount)", for: .normal)
            }
        }
        
        if let date = timelineHistory.sharedDate {
            timeAgoLabel.text = "\(date.timeAgo()) ago"
        }
        if (Globals.sharedInstance.musicPlatform == .spotify){
            self.spotifyButton.setBackgroundImage(UIImage(named: "spotify2"), for: .normal)
        } else {
            self.spotifyButton.setBackgroundImage(UIImage(named: "apple2"), for: .normal)
        }
        self.setLikeButton()
    }
    
    @IBAction func menuClick(_ sender: Any) {
        delegate?.cellMenuClicked(history: timelineHistory)
    }
    
    @IBAction func bookmarkClick(_ sender: Any) {

        timelineHistory.isBookmarked = !timelineHistory.isBookmarked
        
        if(timelineHistory.isBookmarked){
            BookmarkServices.saveBookmark(musicId: timelineHistory.history?.music?.contentId ?? "", historyId: timelineHistory.actionId) { (bookmark, error) in
                self.bookmarkButton.setImage(self.timelineHistory.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)
                
            }
        } else {
            BookmarkServices.removeBookmark(musicId: timelineHistory.history?.music?.contentId ?? "") { (bookmark, error) in
                self.bookmarkButton.setImage(self.timelineHistory.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)
                
            }
        }
    }
    
    @IBAction func commentClick(_ sender: Any) {
        delegate?.cellCommentsClicked(history: timelineHistory)
    }
    
    func setLikeButton(){
        likesButton.setImage(UIImage(named: timelineHistory.isLiked ? "icon_liked" : "icon_fave"), for: .normal)
        
        if let likeCount = timelineHistory.history?.likesCount {
            if(likeCount == 0){
                likesButton.setTitle("", for: .normal)
            } else {
                likesButton.setTitle("\(likeCount)", for: .normal)
            }
        }
        likesButton.isUserInteractionEnabled = true
    }
    
    @IBAction func likeClick(_ sender: Any) {
        
        timelineHistory.isLiked = !timelineHistory.isLiked

        guard let userHistory = timelineHistory.history else { return }
        likesButton.isUserInteractionEnabled = false
        if(timelineHistory.isLiked){
            ContentServices.like(historyId: userHistory.id) { (data) in
                userHistory.likesCount = (userHistory.likesCount ?? 0) + 1
                self.setLikeButton()
                let usersRef = Firestore.firestore().collection("users_table").document(userHistory.userId!)
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
            ContentServices.unlike(historyId: userHistory.id) { (data) in
                userHistory.likesCount = (userHistory.likesCount ?? 1) - 1
                self.setLikeButton()
            }
        }
    }
    
    @IBAction func shareClick(_ sender: Any) {
        self.delegate?.addPending(history: timelineHistory)
    }
    
    @IBAction func playClick(_ sender: Any) {
        delegate?.cellPlayClicked(history: timelineHistory)
    }
  
}
