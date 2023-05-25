//
//  BookmarkServices.swift
//  lotus
//
//  Created by Robert Grube on 9/16/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class BookmarkServices {
    class func saveBookmark(musicId: String, historyId: String, completion: @escaping (_ bookmark: Bookmark?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.bookmarks
        let params = ["history_id" : historyId, "music_id": musicId]
        httpRequest(url, method: .post, params: params) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(Bookmark.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func removeBookmark(musicId: String, completion: @escaping (_ bookmark: Bookmark?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.bookmarks + "/remove/\(musicId)"
        httpRequest(url, method: .delete, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(Bookmark.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func getBookmarks(completion: @escaping (_ music: PagedContent<Bookmark>?, _ error: Error?) -> Void){
        let uid = Globals.sharedInstance.myProfile?.userId ?? ""
        let url = baseUrlString + HttpFunctions.bookmarks + "/user/\(uid)"
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<Bookmark>.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
}
