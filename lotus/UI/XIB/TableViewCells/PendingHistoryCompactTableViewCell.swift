//
//  PendingHistoryCompactTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 2/5/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

protocol PendingHistoryCompactTableViewCellDelegate {
    func addPending(history: TimelineHistory)
    func openMenu(history: TimelineHistory)
}

class PendingHistoryCompactTableViewCell: UITableViewCell {

    @IBOutlet var albumImageView: UIImageView!
    @IBOutlet var musicTitleLabel: UILabel!
    @IBOutlet var musicDescriptionLabel: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    var delegate : PendingHistoryCompactTableViewCellDelegate?
    
    var history: TimelineHistory!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumImageView.layer.borderWidth = 0.9
        albumImageView.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shareButtonClick(_ sender: Any) {
        self.delegate?.addPending(history: self.history)
    }
    
    @IBAction func menuButtonClick(_ sender: Any) {
        self.delegate?.openMenu(history: self.history)
    }
    
    func setData(timelineHistory: TimelineHistory){
        self.history = timelineHistory
        guard let music = timelineHistory.history?.music else { return }
        
        musicTitleLabel.text = music.title ?? ""
        musicDescriptionLabel.text = "\(music.artist ?? "") - \(music.album ?? "")"
        if let image = music.image, let url = URL(string: image){
            albumImageView.sd_setImage(with: url)
        }
    }
    
}
