//
//  ContentServices.swift
//  lotus
//
//  Created by Robert Grube on 2/3/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Alamofire

class ContentServices {
    
    class func search(term: String, page: Int = 0, pageSize: Int = 100, completion: @escaping (_ content: PagedContent<Music>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.search
        var service = "Spotify"
        if (Globals.sharedInstance.musicPlatform == .apple) {
              service = "Apple"
        }
        let param : Parameters = [
            "search":term,
          "service" : service
        ]
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<Music>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func getActivity(userId: String, page: Int = 0, pageSize: Int = 300, completion: @escaping (_ content: PagedContent<TimelineHistory>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getHistoryFor(userId: userId, page: page, pageSize: pageSize)
        
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<TimelineHistory>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func getTimeline(page: Int = 0, pageSize: Int = 300, completion: @escaping (_ content: PagedContent<TimelineHistory>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getTimelineFor(page: page, pageSize: pageSize)
        
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<TimelineHistory>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func deleteHistory(historyId:String, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.deleteHistory + historyId
        httpRequest(url, method: .delete, params: nil) { (response) in
            completion(response.data)  
        }
    }
    
    class func createHistory(music:Music, completion: @escaping (_ history: UserHistory?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.createHistory      
        let param : Parameters = [
            "contentType":music.contentType?.rawValue ?? "MUSIC",
            "contentId":music.contentId ?? "",
            "userId":music.userId ?? "0",
          "userComment":music.userComment ?? "",
          "playingStatus":music.playingStatus ?? "PLAYING",
          "album":music.album ?? "",
          "appleId":music.appleId ?? "",
          "appleUri":music.appleUri ?? "",
          "artist":music.artist ?? "",
          "image":music.image ?? "",
          "spotifyId":music.spotifyId ?? "",
          "spotifyUri":music.spotifyUri ?? "",
          "title":music.title ?? ""
        ]
        
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(UserHistory.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
  class func postBookmark(music:Music, completion: @escaping (_ history: UserHistory?, _ error: Error?) -> Void) {
      let url = baseUrlString + HttpFunctions.postBookmark
      let param : Parameters = [
//          "contentType":music.contentType?.rawValue ?? "MUSIC",
          "contentId":music.contentId ?? "",
//          "userId":music.userId ?? "0",
        "userComment":music.userComment ?? "",
        "playingStatus":music.playingStatus ?? "PLAYING",
//        "album":music.album ?? "",
//        "appleId":music.appleId ?? "",
//        "appleUri":music.appleUri ?? "",
//        "artist":music.artist ?? "",
//        "image":music.image ?? "",
//        "spotifyId":music.spotifyId ?? "",
//        "spotifyUri":music.spotifyUri ?? "",
//        "title":music.title ?? ""
      ]
      
      httpRequest(url, method: .post, params: param) { (response) in
          guard let data = response.data else { return }
          do {
              let decoder = LotusJSONDecoder()
              let object = try decoder.decode(UserHistory.self, from: data)
              completion(object, nil)
          } catch let error {
              print(error.localizedDescription)
              completion(nil, error)
          }
      }
  }
  
    class func getHistory(historyId:String, completion: @escaping (_ history: UserHistory?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getHistory + historyId
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(UserHistory.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func createCurrent(music:Music, completion: @escaping (_ history: UserHistory?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.createCurrent
        guard let profile = Globals.sharedInstance.myProfile else {
            print("NO PROFILE")
            completion(nil, nil)
            return
        }
        
        let param : Parameters = [
            "userId":profile.userId,
            "contentId":music.contentId ?? ""
        ]
        
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(UserHistory.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func removeCurrent(completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.removeCurrent
        httpRequest(url, method: .delete, params: nil) { (response) in
            completion(response.data)
        }
    }
    
    class func getContent(contentId: String, completion: @escaping (_ music: Music?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getContentFor(contentId: contentId)
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(Music.self, from: data)
                completion(object, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    class func getComments(historyId: String, completion: @escaping (_ comments: PagedContent<Comment>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getCommentsFor(historyId: historyId)
        
        //todo - handle paging
        
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<Comment>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func createComment(text: String, historyId: String, completion: @escaping (_ comment: Comment?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.createComment
        let param : Parameters = [
            "comment":text,
            "historyId":historyId
        ]
        
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(Comment.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    class func deleteComment(commentId:String, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.deleteComment + commentId
        httpRequest(url, method: .delete, params: nil) { (response) in
            completion(response.data)
        }
    }
    class func like(historyId: String, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.createLike + historyId
        httpRequest(url, method: .post, params: nil) { (response) in
            completion(response.data)
        }
    }
    
    class func unlike(historyId: String, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.deleteLike + historyId
        httpRequest(url, method: .delete, params: nil) { (response) in
            completion(response.data)
        }
    }
    
    class func getRecentlyPlayed(completion: @escaping (_ songs: [Music]?, _ error: Error?) -> Void) {
        var url = baseUrlString
        
        if (Globals.sharedInstance.musicPlatform == .apple){
            url = url + HttpFunctions.appleGetRecentlyPlayed
            completion(nil,nil)
            return
        } else {
            url = url + HttpFunctions.spotifyGetRecentlyPlayed
            if(SpotifyToken.load() == nil){
                completion(nil,nil)
                return
            }
        }

        print(url)
        httpRequest(url, method: .get, params: nil, sendErrorNotification: true, suppressResponseLog: true) { (response) in
           print("apple***")
            print(response)
          
            guard let data = response.data else {
                completion(nil, nil)
                return
            }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode([Music].self, from: data)
                completion(object, nil)
            } catch let error {
              print("error***")
              print(error)
                completion(nil, error)
            }
        }
    }
    
    
    class func refreshSpotifyToken(token: String, refreshToken: String, completion: @escaping (_ token: SpotifyToken?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.spotifyRefreshToken

        let param : Parameters = [
            "refreshToken":refreshToken,
            "service":LotusPlatform.spotify.rawValue,
            "accessToken":token
        ]
        
        print(param)
        
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(SpotifyToken.self, from: data)
                object.save()
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func playSpotify(uri: String, position : Int = 0, completion: @escaping (_ response: SpotifyPlayResponse?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.spotifyPlaySong

        let param : Parameters = [
            "position":position,
            "uri":uri
        ]
        
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(SpotifyPlayResponse.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func pauseSpotify(completion: @escaping (_ response: SpotifyPlayResponse?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.spotifyPauseSong
        
        httpRequest(url, method: .post, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(SpotifyPlayResponse.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func resumeSpotify(completion: @escaping (_ response: SpotifyPlayResponse?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.spotifyResumeSong
        
        httpRequest(url, method: .post, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(SpotifyPlayResponse.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func seekSpotify(completion: @escaping (_ response: SpotifyPlayResponse?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.spotifySeek
        httpRequest(url, method: .post, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(SpotifyPlayResponse.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
}
