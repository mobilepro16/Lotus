//
//  AccountServices.swift
//  lotus
//
//  Created by Robert Grube on 1/30/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Alamofire
import FacebookCore
import PKHUD
import SendBirdSDK
import UserNotifications
import Firebase

class AccountServices {
    
    class func connect(service: LoginService, token: String, refresh: String, completion: @escaping () -> Void) {
        let url = baseUrlString + HttpFunctions.registerService
        let param : Parameters = [
            "accessToken":token,
            "refreshToken":refresh,
            "service":service.rawValue
        ]
        httpRequest(url, method: .post, params: param) { (response) in
            completion()
        }
    }
    
    class func getMyProfile(completion: @escaping (_ profile: Profile?, _ error: Error?) -> Void) {

        let url = baseUrlString + HttpFunctions.getMyProfile
        httpRequest(url, method: .post, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let profile = try decoder.decode(Profile.self, from: data)
                Globals.sharedInstance.myProfile = profile
                let pushManager = PushNotificationManager(userID: Globals.sharedInstance.myProfile!.userId)
                pushManager.registerForPushNotifications()
                profile.save()
                completion(profile, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func getProfile(userId: String, completion: @escaping (_ profile: Profile?, _ error: Error?) -> Void) {

        let url = baseUrlString + HttpFunctions.getProfileFor(userId: userId)
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let profile = try decoder.decode(Profile.self, from: data)
                if let me = Globals.sharedInstance.myProfile, me.userId == profile.userId {
                    Globals.sharedInstance.myProfile = profile
                    let pushManager = PushNotificationManager(userID: Globals.sharedInstance.myProfile!.userId)
                    pushManager.registerForPushNotifications()
                    profile.save()
                }
                completion(profile, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func edit(profile: Profile, completion: @escaping (_ profile: Profile?, _ error: Error?) -> Void) {

        let url = baseUrlString + HttpFunctions.editProfile
        
        let param : Parameters = [
            "bio":profile.bio as Any,
            "coverImage":profile.coverImage as Any,
            "displayName":profile.displayName as Any,
            "firstName":profile.firstName as Any,
            "lastName":profile.lastName as Any,
            "profileImage":profile.profileImage as Any,
            "themeSongId":profile.themeSong?.contentId as Any,
            "userId":profile.userId,
        ]
                
        httpRequest(url, method: .post, params: param) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let profile = try decoder.decode(Profile.self, from: data)
                Globals.sharedInstance.myProfile = profile
                profile.save()
                completion(profile, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func uploadProfileImage(image: UIImage, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.profileImage
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        uploadRequest(url, data: jpg, dataName: "file") { (response) in
            completion(response.data)
        }
    }
    
    class func uploadCoverImage(image: UIImage, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.coverImage
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        uploadRequest(url, data: jpg, dataName: "file") { (response) in
            completion(response.data)
        }
    }
    
    class func follow(userId: String, completion: @escaping (_ data: Data?) -> Void) {
        guard let profile = Globals.sharedInstance.myProfile else {
            completion(nil)
            return
        }
        let url = baseUrlString + HttpFunctions.follow
        let param : Parameters = [
            "userId": profile.userId,
            "followId":userId
        ]
        httpRequest(url, method: .post, params: param) { (response) in
            print(response)
            completion(response.data)
        }
    }
    class func unfollow(userId: String, completion: @escaping (_ data: Data?) -> Void) {
        guard let profile = Globals.sharedInstance.myProfile else {
            completion(nil)
            return
        }
        let url = baseUrlString + HttpFunctions.unfollow
        let param : Parameters = [
            "userId": profile.userId,
            "followId":userId
        ]
        httpRequest(url, method: .post, params: param) { (response) in
            completion(response.data)
        }
    }
    
    class func getFollowers(userId: String, completion: @escaping (_ content: PagedContent<User>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getFollowersFor(userId: userId) + "?size=200"
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<User>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func getFollowing(userId: String, completion: @escaping (_ content: PagedContent<User>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getFollowingFor(userId: userId) + "?size=200"
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<User>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func getAllUsers(completion: @escaping (_ content: PagedContent<User>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getAllUsers
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<User>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func searchUsers(term: String, completion: @escaping (_ content: PagedContent<User>?, _ error: Error?) -> Void) {
        let searchTerm = term.replacingOccurrences(of: " ", with: "+")
        let url = baseUrlString + HttpFunctions.accountSearch + "?term=\(searchTerm)"
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<User>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    class func getAllMusic(page: Int = 0, pageSize: Int = 200, completion: @escaping (_ content: PagedContent<Music>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getAllMusic + "?page=\(page)&size=\(pageSize)"
        httpRequest(url, method: .get, params: nil) { (response) in
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
    
    class func getNotifications(page: Int = 0, pageSize: Int = 100, completion: @escaping (_ content: PagedContent<LotusNotification>?, _ error: Error?) -> Void) {
        let url = baseUrlString + HttpFunctions.getNotifications + "?page=\(page)&size=\(pageSize)"
        httpRequest(url, method: .get, params: nil) { (response) in
            guard let data = response.data else { return }
            do {
                let decoder = LotusJSONDecoder()
                let object = try decoder.decode(PagedContent<LotusNotification>.self, from: data)
                completion(object, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    class func deleteNotification(notificationId:String, completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.deleteNotification + notificationId
        httpRequest(url, method: .delete, params: nil) { (response) in
            completion(response.data)
        }
    }
    class func readNotifications(completion: @escaping (_ data: Data?) -> Void) {
        let url = baseUrlString + HttpFunctions.notificationsRead
        httpRequest(url, method: .post, params: nil) { (response) in
            completion(response.data)
        }
    }
}
