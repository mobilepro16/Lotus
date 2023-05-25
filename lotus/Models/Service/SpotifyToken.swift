//
//  SpotifyToken.swift
//  lotus
//
//  Created by Robert Grube on 2/18/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct SpotifyToken: Codable {
    var accessToken: String
    var code: String?
    var expiresIn: String?
    var refreshToken: String
    var scope: String?
    var tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case code
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
    }
}

extension SpotifyToken {
    func save() {
        print("SAVING SPOTIFY TOKENS \n AT:\(accessToken) \nRT: \(refreshToken)")
        UserDefaults.standard.set(accessToken, forKey: UserDefaultsKeys.spotifyAccessToken)
        UserDefaults.standard.set(refreshToken, forKey: UserDefaultsKeys.spotifyRefreshToken)
    }
    
    static func load() -> SpotifyToken? {
        guard let at = UserDefaults.standard.string(forKey: UserDefaultsKeys.spotifyAccessToken),
            let rt = UserDefaults.standard.string(forKey: UserDefaultsKeys.spotifyRefreshToken) else {
                print("LOADING SPOTIFY TOKENS FAILED")
                return nil
        }
        print("LOADED SPOTIFY TOKENS")
        print(at)
        return SpotifyToken(accessToken: at, refreshToken: rt)
    }
}
