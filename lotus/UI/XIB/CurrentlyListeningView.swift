//
//  ListeningToView.swift
//  lotus
//
//  Created by Robert Grube on 2/28/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol CurrentlyListeningViewDelegate {
    func cellSharesClicked(music: Music)
    func cellMenuClicked(music: Music)
}
class CurrentlyListeningView: CustomNibView {

    @IBOutlet var titleLabel: UILabel!
  @IBOutlet weak var albumImage: UIImageView!
  @IBOutlet weak var songLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
    
    var music: Music!
    var delegate: CurrentlyListeningViewDelegate?
  
    func setData(music: Music, showingAvailability : Bool = true){
        self.music = music
        albumImage.layer.borderWidth = 1.0
        albumImage.layer.borderColor = UIColor.white.cgColor
        artistLabel.text = music.artist
        songLabel.text = music.title
          
        if let img = music.image, let url = URL(string: img){
          albumImage.sd_setImage(with: url, placeholderImage: nil)
        }
    }
  @IBAction func postTapped(_ sender: Any) {
    self.delegate?.cellSharesClicked(music: music)
  }
  @IBAction func moreTapped(_ sender: Any) {
    self.delegate?.cellMenuClicked(music: music)
  }
}
