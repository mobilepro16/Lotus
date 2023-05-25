//
//  BookmarkView.swift
//  lotus
//
//  Created by Robert Grube on 10/5/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol BookmarkViewDelegate {
    func postBookmark(bookmark: Bookmark)
    func bookmarkRemoved(bookmark: Bookmark)
}

class BookmarkView: CustomNibView {

    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var songLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    var bookmark: Bookmark!
    var delegate: BookmarkViewDelegate?

    func setData(bookmark: Bookmark){
        self.bookmark = bookmark
        
        if let music = bookmark.music {
          albumImage.layer.borderWidth = 1.0
            albumImage.layer.borderColor = UIColor.white.cgColor
            artistLabel.text = music.artist
            songLabel.text = music.title
            
            if let img = music.image, let url = URL(string: img){
                albumImage.sd_setImage(with: url, placeholderImage: nil)
            }
        }
        
    }
    
    @IBAction func pendingClicked(_ sender: Any) {
        self.delegate?.postBookmark(bookmark: self.bookmark)
    }
    @IBAction func bookmarkClicked(_ sender: Any) {
        self.delegate?.bookmarkRemoved(bookmark: self.bookmark)
    }
}
