//
//  IndicatorTableViewCell.swift
//  lotus
//
//  Created by admin on 4/8/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class IndicatorTableViewCell: UITableViewCell {

  @IBOutlet weak var indicator: UIActivityIndicatorView!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
