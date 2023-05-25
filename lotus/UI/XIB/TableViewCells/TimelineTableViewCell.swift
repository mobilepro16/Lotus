//
//  TimelineTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 9/11/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol TimelineTableViewCellDelegate {
    func cellUserClicked(history: TimelineHistory)
    func cellCommentsClicked(history: TimelineHistory)
    func cellMenuClicked(history: TimelineHistory)
    func cellPlayClicked(history: TimelineHistory)
    func addPending(history: TimelineHistory)
}

class TimelineTableViewCell: UITableViewCell {

    @IBOutlet var timelineView: TimelineView!
    
    var delegate: TimelineTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(history: TimelineHistory){
        timelineView.setData(timelineHistory: history)
        timelineView.delegate = self
    }
    
}

extension TimelineTableViewCell : TimelineViewDelegate {
    func addPending(history: TimelineHistory) {
      delegate?.addPending(history: history)
    }
  
    func cellUserClicked(history: TimelineHistory) {
        delegate?.cellUserClicked(history: history)
    }
   
    func cellPlayClicked(history: TimelineHistory) {
        delegate?.cellPlayClicked(history: history)
    }
    
    func cellCommentsClicked(history: TimelineHistory) {
        delegate?.cellCommentsClicked(history: history)
    }
    
    func cellMenuClicked(history: TimelineHistory) {
        delegate?.cellMenuClicked(history: history)
    }
}
