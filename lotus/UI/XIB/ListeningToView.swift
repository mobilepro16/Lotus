//
//  ListeningToView.swift
//  lotus
//
//  Created by Robert Grube on 2/28/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class ListeningToView: CustomNibView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var musicView: MusicView!
    
    var music: Music!
    
    func setData(music: Music, showingAvailability : Bool = true){
        self.music = music
        musicView.setData(music: music, showingAvailability: showingAvailability)
    }
}
