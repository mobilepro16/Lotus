//
//  Song.swift
//  lotus
//
//  Created by Robert Grube on 1/30/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class Music: Content, Codable{
    
    var contentId : String?
    var contentType: LotusContentType?
    
    var album: String?
    var appleId: String?
    var appleUri: String?
    var artist: String?
    var duration: CLong?
    var image: String?
    var spotifyId: String?
    var spotifyUri: String?
    var title: String?
    var userId: String?
    var playingStatus: String?
    var start: String?
    var end: String?
    var userComment: String?
    
    var debugName : String {
        let t = title ?? "[NO NAME]"
        let a = artist ?? "[NO ARTIST]"
        return "'\(t)' by \(a)"
    }
}
