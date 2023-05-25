//
//  ArtistView.swift
//  lotus
//
//  Created by Robert Grube on 5/14/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class ArtistView: CustomNibView {

    @IBOutlet var artistImage: UIImageView!
    @IBOutlet var artistLabel: UILabel!

    func setData(artist: Artist){
        artistLabel.text = artist.artist
        
        if let img = artist.image, let url = URL(string: img){
            artistImage.sd_setImage(with: url, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
        }
    }
}
