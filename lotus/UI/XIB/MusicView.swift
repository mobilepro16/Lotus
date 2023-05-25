//
//  MusicView.swift
//  lotus
//
//  Created by Robert Grube on 2/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import SDWebImage

class MusicView: CustomNibView {

    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var spotifyButton: UIButton!
  
    @IBOutlet var availabilityView: UIView!
    @IBOutlet var availabilityStackView: UIStackView!
    
    @IBOutlet var constraint_mainStack_trailingToAvailability: NSLayoutConstraint!
    
    var music : Music!
    
    override func setup() {
        super.setup()
        
        self.contentView.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
      
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        MusicPlayer.play(music: music)
    }
    func setNoData(){
        self.music = Music()
        titleLabel.text = ""
        artistLabel.text = ""
        albumImage.image = nil
        
        for v in availabilityStackView.arrangedSubviews{
            v.removeFromSuperview()
        }
    }
    
    func setData(music: Music, showingAvailability : Bool = true){
        self.music = music
        titleLabel.text = music.title ?? ""
        artistLabel.text = music.artist ?? ""
        if let image = music.image, let url = URL(string: image){
            albumImage.sd_setImage(with: url)
        }
        albumImage.layer.borderWidth = 1.0
        albumImage.layer.borderColor = UIColor.white.cgColor
        if (Globals.sharedInstance.musicPlatform == .spotify){
            self.spotifyButton.setBackgroundImage(UIImage(named: "spotify2"), for: .normal)
        } else {
            self.spotifyButton.setBackgroundImage(UIImage(named: "apple2"), for: .normal)
        }
    }
}
