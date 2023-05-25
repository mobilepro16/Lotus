//
//  HistoryCommentTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 2/13/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol HistoryCommentTableViewCellDelegate {
    func deleteCommentClicked(comment: Comment)
    func profileClicked(userId: String)
}

class HistoryCommentTableViewCell: UITableViewCell {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet var timestampLabel: UILabel!
    
    var comment: Comment!
    var delegate: HistoryCommentTableViewCellDelegate?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.cornerRadius = userImage.bounds.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  @IBAction func deleteTapped(_ sender: Any) {
      self.delegate?.deleteCommentClicked(comment: comment)
  }
  func setData(comment: Comment){
        self.comment = comment
        commentLabel.text = comment.comment ?? ""
        var timestamp = ""
        if let date = comment.createdAt {
            timestamp = "  •  \(date.timeAgo()) ago"
        }
        nameLabel.text = (comment.fromUser?.displayName ?? "") + timestamp
        if let img = comment.fromUser?.image, let url = URL(string: imageUrlPrefix + img) {
            userImage.sd_setImage(with: url, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        }
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(profileTap)
    
        if (comment.fromUser?.id == Globals.sharedInstance.myProfile?.userId) {
            self.deleteBtn.isHidden = false
        } else {
            self.deleteBtn.isHidden = true
        }
    }
    @objc func profileTapped(){
        let uid = comment.fromUser?.id
        self.delegate?.profileClicked(userId: uid!)
    }
}
