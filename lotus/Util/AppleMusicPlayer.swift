//
//  AppleMusicPlayer.swift
//  lotus
//
//  Created by Robert Grube on 2/17/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit

class AppleMusicPlayer: NSObject {
    
    static let player = MPMusicPlayerApplicationController.systemMusicPlayer
    
    static func connectToAppleMusic(completion: @escaping (_ goodToGo: Bool, _ showSignUp: Bool) -> Void){
        
               
        let controller = SKCloudServiceController()
        controller.requestCapabilities { capabilities, error in
            if capabilities.contains(.musicCatalogPlayback) {
                // User has Apple Music account
                print("WE HAVE APPLE MUSIC")
                completion(true, false)
            }
            else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                // User can sign up to Apple Music
                print("WE COULD SIGN UP?")
                completion(false, true)
            } else {
                
                print("NEITHER")
                
                completion(false, false)
            }
        }
    }
    
    static func requestAuthorization(){
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            switch status {
            case .authorized:
                print("All good - the user tapped 'OK', so you're clear to move forward and start playing.")
            case .denied:
                print("The user tapped 'Don't allow'. Read on about that below...")
            case .notDetermined:
                print("The user hasn't decided or it's not clear whether they've confirmed or denied.")
            case .restricted:
                print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
            @unknown default:
             print("unknown default")
         }
            
        }
    }
    
//    func checkIfPlaybackIsAvailable() {
//        let serviceController = SKCloudServiceController()
//
//        serviceController.requestCapabilities { (capabilities, error) in
//            switch capabilities {
//            case .addToCloudMusicLibrary:
//                //
//            case .musicCatalogPlayback:
//                //
//            case .musicCatalogSubscriptionEligible:
//                //
//
//            default:
//                //
//            }
//        }
//    }
    
    static func play(storeId: String){
        if(SKCloudServiceController.authorizationStatus() == .authorized){
            DispatchQueue.main.async {
                player.setQueue(with: [storeId])
                player.repeatMode = .none
                player.play()
            }
        } else {
            print("APPLE MUSIC UNAUTHORIZED")
        }
    }
    
    static func play(music: Music){
        guard let appleMusicId = music.appleId else { return }
        play(storeId: appleMusicId)
        NotificationCenter.default.post(name: .didStartPlayingMusic, object: nil, userInfo: ["music":music])
    }
    
    static func pause(){
        DispatchQueue.main.async {
            player.pause()
        }
    }
    
    static func resume(){
        DispatchQueue.main.async {
            player.play()
        }
    }
}
