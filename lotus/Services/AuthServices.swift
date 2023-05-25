//
//  AuthServices.swift
//  lotus
//
//  Created by Robert Grube on 1/29/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Alamofire

enum LoginService: String, Codable {
    case apple = "Apple"
    case facebook = "Facebook"
    case spotify = "Spotify"
}

class AuthServices {
    
    class func getAuthFrom(service: LoginService, token: String, firstName : String? = nil, lastName : String? = nil, completion: @escaping (_ token: Token?, _ error: Error?) -> Void) {
        var param : Parameters = [
            "accessToken":token,
            "service":service.rawValue
        ]
        
        if(service == .apple){
            param["firstName"] = firstName
            param["lastName"] = lastName
        }
        
        let url = baseUrlString + HttpFunctions.getAuthFromService
        httpRequest(url, method: .post, params: param, shouldSendAuth: false) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let token = try decoder.decode(Token.self, from: data)
                completion(token, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func refresh(token: String, completion: @escaping (_ token: Token?, _ error: Error?) -> Void) {
        let param : Parameters = [
            "token":token
        ]
        
        let url = baseUrlString + HttpFunctions.refreshToken
                        
        nocheck_httpRequest(url, method: .post, params: param, shouldSendAuth: false) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let newToken = try decoder.decode(Token.self, from: data)
                
                Globals.sharedInstance.token = newToken
                newToken.save()
                
                completion(newToken, nil)
            } catch let error {
                
                completion(nil, error)
            }
        }
    }
}
