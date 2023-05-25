//
//  UserActionServices.swift
//  lotus
//
//  Created by Robert Grube on 5/11/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Alamofire

class UserActionServices {
    class func getAlbums(userId: String, completion: @escaping (_ music: PagedContent<Album>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getAlbumsFor(userId: userId)
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<Album>.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func getArtists(userId: String, completion: @escaping (_ music: PagedContent<Artist>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getArtistsFor(userId: userId)
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<Artist>.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func getPendingHistory(completion: @escaping (_ music: PagedContent<TimelineHistory>?, _ error: Error?) -> Void){
        let url = baseUrlString + HttpFunctions.getPendingHistory
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<TimelineHistory>.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func addAction(actionId: String, comment: String = "", completion: @escaping (_ action: TimelineHistory?, _ error: Error?) -> Void){
        let url = baseUrlString + HttpFunctions.addAction + actionId
        httpRequest(url, method: .post, params: ["userComment" : comment]) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(TimelineHistory.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
  class func editAction(actionId: String, comment: String = "", completion: @escaping (_ action: TimelineHistory?, _ error: Error?) -> Void){
      let url = baseUrlString + HttpFunctions.editAction + actionId
      httpRequest(url, method: .put, params: ["userComment" : comment]) { (response) in
          guard let data = response.data else { return }
          do {
              let decoder = LotusJSONDecoder()
              let object = try decoder.decode(TimelineHistory.self, from: data)
              completion(object, nil)
          } catch let error {
              print(error.localizedDescription)
              completion(nil, error)
          }
      }
  }
    class func removeAction(actionId: String, completion: @escaping (_ action: TimelineHistory?, _ error: Error?) -> Void){
        let url = baseUrlString + HttpFunctions.removeAction + actionId
        httpRequest(url, method: .delete, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(TimelineHistory.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    class func deleteAction(actionId: String, completion: @escaping (_ action: TimelineHistory?, _ error: Error?) -> Void){
        let url = baseUrlString + HttpFunctions.deleteAction + actionId
        httpRequest(url, method: .delete, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(TimelineHistory.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
}
