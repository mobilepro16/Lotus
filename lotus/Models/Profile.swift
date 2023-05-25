//
//  Profile.swift
//  lotus
//
//  Created by Robert Grube on 1/30/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import PKHUD
import SendBirdSDK
import UserNotifications
import Firebase

struct Profile: Codable {
    var bio: String?
    var coverImage: String?
    var displayName: String?
    var firstName: String?
    var lastName: String?
    var profileImage: String?
    var themeSong: Music?
    var currentSong: UserCurrent?
    var userId : String
    var numFollowers: Int?
    var numFollowing: Int?
}

extension Profile {
        
    func save() {
                
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.lotusProfile)
        } else {
            print("ERROR ENCODING PROFILE")
        }
    }
    
    static func load() -> Profile? {
        
        if let savedProfile = UserDefaults.standard.object(forKey: UserDefaultsKeys.lotusProfile) as? Data {
            let decoder = LotusJSONDecoder()
            if let loadedProfile = try? decoder.decode(Profile.self, from: savedProfile) {
                Globals.sharedInstance.myProfile = loadedProfile
                let pushManager = PushNotificationManager(userID: Globals.sharedInstance.myProfile!.userId)
                pushManager.registerForPushNotifications()
                if loadedProfile.profileImage != nil {
                    NotificationCenter.default.post(name: .profileImageUpdated, object: nil)
                }
                
                return loadedProfile
            } else {
                print("ERROR LOADING PROFILE")
            }
        }
        
        return nil
    }
    
    func asUser() -> User {
        return User(id: userId, bio: bio, displayName: displayName, firstName: firstName, image: profileImage, lastName: lastName)
    }
}
