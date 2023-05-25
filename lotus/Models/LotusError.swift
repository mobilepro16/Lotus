//
//  LotusError.swift
//  lotus
//
//  Created by Robert Grube on 1/30/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct LotusError: Codable {
    var error: String
    var message: String
    var path: String
    var status: Int
    var timestamp: String
    
    var expiredToken : Bool {
        return message == "Token Expired"
    }
    
    var expiredSpotifyToken : Bool {
        return message == "401 Unauthorized" && path.contains("spotify")
    }
    
    func debugPrint(){
        print("ERROR")
        print("error:\(error)")
        print("message:\(message)")
        print("path:\(path)")
        print("status:\(status)")
        print("timestamp:\(timestamp)")
    }
}
