//
//  HistoryView.swift
//  lotus
//
//  Created by Robert Grube on 3/5/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol HistoryViewDelegate {
    func historyMenuClicked(historyView: HistoryView)
    func historyCommentClicked(history: UserHistory)
    func postSongClicked(music: Music)
    func historyCommentClicked(history: TimelineHistory)
}

class HistoryView: CustomNibView {

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
    
    var delegate: HistoryViewDelegate?
    
    var timelineHistory: TimelineHistory?
    var history: UserHistory!
    var user: User!
    
    
    // MARK: Actions
    
    @IBAction func menuClick(_ sender: Any) {
        delegate?.historyMenuClicked(historyView: self)
    }
    
    @IBAction func commentsClick(_ sender: Any) {
        delegate?.historyCommentClicked(history: history)
    }
    
    @IBAction func likesClick(_ sender: Any) {
                
        history.isLiked = !history.isLiked

        if(history.isLiked){
            ContentServices.like(historyId: history.id) { (data) in
                self.history.likesCount = (self.history.likesCount ?? 0) + 1
                self.setLikeButton()
            }
        } else {
            ContentServices.unlike(historyId: history.id) { (data) in
                self.history.likesCount = (self.history.likesCount ?? 0) - 1
                self.setLikeButton()
            }
        }
    }
    
    @IBAction func shareClick(_ sender: Any) {
        delegate?.postSongClicked(music: history.music!)
    }
    
    @IBAction func bookmarkClick(_ sender: Any) {
        
        history.isBookmarked = !history.isBookmarked
        
        guard let contentId = history.contentId else { return }

        if(history.isBookmarked){
            BookmarkServices.saveBookmark(musicId: contentId, historyId: history.id) { (bookmark, error) in
                self.bookmarkButton.setImage(self.history.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)

            }
        } else {
            BookmarkServices.removeBookmark(musicId: contentId) { (bookmark, error) in
                self.bookmarkButton.setImage(self.history.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)

            }
        }
    }
    
    // MARK: Set up data / ui
    
    override func setup() {
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
    }
    
    func setLikeButton(){
        favoritesButton.setImage(UIImage(named: history.isLiked ? "icon_liked" : "icon_fave"), for: .normal)
        if let likeCount = history.likesCount {
            if(likeCount == 0){
                favoritesButton.setTitle("", for: .normal)
            } else {
                favoritesButton.setTitle("\(likeCount)", for: .normal)
            }
        }
    }
    
    func setData(history: UserHistory, user: User){
        self.history = history
        self.user = user
        
        if let music = history.music {
            musicView.setData(music: music)
            musicView.titleText.isHidden = true
        }
        commentLabel.text = history.userComment ?? ""
        if let date = history.start {
            timestampLabel.text = "\(date.timeAgo()) ago"
        }
        if let commentCount = history.commentCount {
            if(commentCount == 0){
                commentsButton.setTitle("", for: .normal)
            } else {
                commentsButton.setTitle("\(commentCount)", for: .normal)
            }
        }
        
        setLikeButton()

        profileNameLabel.text = "\(user.displayName ?? "") listened to"
        profileDisplayNameLabel.text = "@\(user.displayName ?? "")"
        if let profImage = user.image, let profUrl = URL(string: imageUrlPrefix + profImage){
            profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        } else {
            profileImage.image = GeneralConstants.defaultUserImage
        }

        self.bookmarkButton.setImage(self.history.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)
    }
    
    func setData(timelineHistory: TimelineHistory){
        self.timelineHistory = timelineHistory
        guard let history = timelineHistory.history, let user = timelineHistory.user else { return }
        history.isLiked = timelineHistory.isLiked
        history.isBookmarked = timelineHistory.isBookmarked
        self.history = history
        self.user = user
        
        if let music = history.music {
            musicView.setData(music: music)
            musicView.titleText.isHidden = true
        }
        commentLabel.text = history.userComment ?? ""
        if let date = timelineHistory.sharedDate {
            timestampLabel.text = "\(date.timeAgo()) ago"
        }
        if let commentCount = history.commentCount {
            if(commentCount == 0){
                commentsButton.setTitle("", for: .normal)
            } else {
                commentsButton.setTitle("\(commentCount)", for: .normal)
            }
        }
        
        setLikeButton()
        
        profileNameLabel.text = timelineHistory.message
        profileDisplayNameLabel.text = "@\(user.displayName ?? "")"
        if let profImage = user.image, let profUrl = URL(string: imageUrlPrefix + profImage){
            profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        } else {
            profileImage.image = GeneralConstants.defaultUserImage
        }
        
        self.bookmarkButton.setImage(self.history.isBookmarked ? UIImage(named: "icon_bookmark_active") : UIImage(named: "icon_bookmark_inactive"), for: .normal)
    }
}
