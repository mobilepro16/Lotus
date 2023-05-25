//
//  CompactMusicTableViewCell.swift
//  lotus
//
//  Created by Robert Grube on 3/9/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol CompactMusicTableViewCellDelegate {
    func cellSharesClicked(music: Music)
    func cellMenuClicked(music: Music)
}

class CompactMusicTableViewCell: UITableViewCell {
    
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var artistAlbumLabel: UILabel!
    @IBOutlet var shareButton: UIButton!
    
    var music: Music!
    var delegate: CompactMusicTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumImage.layer.borderWidth = 0.9
        albumImage.layer.borderColor = UIColor.white.cgColor
    }

    func setData(music: Music){
        self.music = music
        songTitleLabel.text = music.title ?? ""
        if let artist = music.artist {
            if let album = music.album {
                self.artistAlbumLabel.text = "\(artist), \(album)"
            } else {
                self.artistAlbumLabel.text = artist
            }
        } else {
            if let album = music.album {
                self.artistAlbumLabel.text = album
            } else {
                self.artistAlbumLabel.text = ""
            }
        }
        
        if let image = music.image, let url = URL(string: image){
            albumImage.sd_setImage(with: url)
        } else {
            albumImage.image = nil
        }
    }
    
    @IBAction func shareButtonClick(_ sender: Any) {
        self.delegate?.cellSharesClicked(music: music)
    }
    
    @IBAction func menuButtonClick(_ sender: Any) {
        self.delegate?.cellMenuClicked(music: music)
    }
}
