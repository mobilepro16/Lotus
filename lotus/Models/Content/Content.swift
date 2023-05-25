//
//  Content.swift
//  lotus
//
//  Created by Robert Grube on 1/31/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

enum LotusContentType : String, Codable {
    case music = "MUSIC"
    case movie = "MOVIE"
    case book = "BOOK"
    case tvShow = "TVSHOW"
}

enum LotusPlatform : String, Codable {
    case spotify = "Spotify"
    case apple = "Apple"
    case google = "Google"
}

class Content {
//    var contentId : String?
//    var contentType: LotusContentType?
}
