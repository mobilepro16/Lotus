//
//  PendingHistoryTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 10/21/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol PendingHistoryTableViewCellDelegate {
    func addPending(pendingView: PendingHistoryView)
    func removePending(pendingView: PendingHistoryView)
}

class PendingHistoryTableViewCell: UITableViewCell {

    @IBOutlet var pendingHistoryView: PendingHistoryView!
    var delegate: PendingHistoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension PendingHistoryTableViewCell : PendingHistoryViewDelegate {
    func addPending(pendingView: PendingHistoryView){
        delegate?.addPending(pendingView: pendingHistoryView)
    }
    func removePending(pendingView: PendingHistoryView){
        delegate?.removePending(pendingView: pendingHistoryView)
    }
}
