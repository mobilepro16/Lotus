//
//  PartyServices.swift
//  lotus
//
//  Created by Robert Grube on 3/1/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Alamofire

class PartyServices {

    class func create(name: String, completion: @escaping (_ party: Party?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.createParty
        let param : Parameters = [ "name" : name ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(Party.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func delete(partyId: String, completion: @escaping (_ status: String?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.deleteParty
        let param : Parameters = [ "partyId" : partyId ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(String.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }

    class func join(partyId: String, completion: @escaping (_ status: String?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.createParty
        let param : Parameters = [ "partyId" : partyId ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(String.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func leave(partyId: String, completion: @escaping (_ status: String?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.leaveParty
        let param : Parameters = [ "partyId" : partyId ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(String.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func pause(partyId: String, contentId: String, progress: Int64, completion: @escaping (_ status: String?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.pauseParty
        let param : Parameters = [ "partyId" : partyId, "contentId": contentId, "progress" : progress ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(String.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func play(partyId: String, contentId: String, progress: Int64, completion: @escaping (_ status: String?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.playParty
        let param : Parameters = [ "partyId" : partyId, "contentId": contentId, "progress" : progress ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(String.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func sendMessage(completion: @escaping (_ status: String?, _ error: Error?) -> Void) {
        let url = baseUrlString + "test/hello"
        let param : Parameters = [ "message" : "1.e4" ]
        httpRequest(url, method: .post, params: param) { (response) in
            completion(nil, nil)
        }
    }
}
