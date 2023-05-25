//
//  AlbumView.swift
//  lotus
//
//  Created by Robert Grube on 5/14/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class AlbumView: CustomNibView {

    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    func setData(album: Album){
        artistLabel.text = album.artist
        albumLabel.text = album.album
        
        if let img = album.image, let url = URL(string: img){
            albumImage.sd_setImage(with: url, placeholderImage: nil)
        }
    }

}
