//
//  Token.swift
//  lotus
//
//  Created by Robert Grube on 1/29/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct Token: Codable {
    let expiresIn: Int
    let refreshToken: String
    let token: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case expiresIn
        case refreshToken
        case token
        case type
    }
}

extension Token {
    
    func print(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            
            guard let json = try? JSONSerialization.jsonObject(with: encoded, options: []) else{return}
            Swift.print("USING TOKEN:")
            Swift.print(json)
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.lotusToken)
        }
    }
    
    static func load() -> Token? {
        
        if let savedToken = UserDefaults.standard.object(forKey: UserDefaultsKeys.lotusToken) as? Data {
            let decoder = LotusJSONDecoder()
            if let loadedToken = try? decoder.decode(Token.self, from: savedToken) {
                Globals.sharedInstance.token = loadedToken
                return loadedToken
            }
        }
        
        return nil
    }
    
    static func deleteToken() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lotusToken)
        Globals.sharedInstance.token = nil
    }
}
