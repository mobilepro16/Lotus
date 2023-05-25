//
//  PendingHistoryView.swift
//  lotus
//
//  Created by Robert Grube on 5/15/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol PendingHistoryViewDelegate {
    func addPending(pendingView: PendingHistoryView)
    func removePending(pendingView: PendingHistoryView)
}

class PendingHistoryView: CustomNibView {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileNameLabel: UILabel!
    @IBOutlet var profileDisplayNameLabel: UILabel!
    @IBOutlet var musicView: MusicView!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    
    var history: TimelineHistory!
    
    var delegate: PendingHistoryViewDelegate?
    
    override func setup() {
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        addButton.layer.cornerRadius = addButton.bounds.height / 2
        addButton.clipsToBounds = true
    }
    
    @IBAction func addClick(_ sender: Any) {
        delegate?.addPending(pendingView: self)
    }
    
    @IBAction func removeClick(_ sender: Any) {
        delegate?.removePending(pendingView: self)
    }
    
    func setData(timelineHistory: TimelineHistory){
        self.history = timelineHistory
        guard let history = timelineHistory.history, let user = timelineHistory.user else { return }
        
        if let music = history.music {
            musicView.setData(music: music)
        }
        commentLabel.text = history.userComment ?? ""
        
        profileNameLabel.text = timelineHistory.message
        profileDisplayNameLabel.text = "\(timelineHistory.history?.start?.timeAgo() ?? "0 days") ago" //@\(user.displayName ?? "")"
        if let profImage = user.image, let profUrl = URL(string: imageUrlPrefix + profImage){
            profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        } else {
            profileImage.image = GeneralConstants.defaultUserImage
        }
    }
}
