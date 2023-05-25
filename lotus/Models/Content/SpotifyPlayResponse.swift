//
//  SpotifyPlayResponse.swift
//  lotus
//
//  Created by Robert Grube on 3/11/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class SpotifyPlayResponse: Codable {
    var playing: Bool!
    var succeeded: Bool?
    var uri: String?
}
