//
//  MusicTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 2/15/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    @IBOutlet var musicView: MusicView!
    
    var music: Music!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(music: Music){
        self.music = music
        self.musicView.setData(music: music)
    }
    
    func setNoData(){
        self.music = Music()
        self.musicView.setNoData()
    }
}
