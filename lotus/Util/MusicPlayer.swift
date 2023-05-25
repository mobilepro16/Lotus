//
//  MusicPlayer.swift
//  lotus
//
//  Created by Robert Grube on 2/18/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import StoreKit

enum MusicPlatform : String {
    case apple = "Apple"
    case spotify = "Spotify"
    case none = "None"
}

class MusicPlayer: NSObject {
 
    static func play(music: Music){
        
        if (Globals.sharedInstance.musicPlatform == .none){
            NotificationCenter.default.post(name: .noMusicPlayerSelected, object: self)
            return
        }
        ContentServices.createCurrent(music: music) { (history, error) in }
        if(canPlay(music: music, platform: Globals.sharedInstance.musicPlatform)){
            play(music: music, platform: Globals.sharedInstance.musicPlatform)
        } else {
            print("MUSIC PLAYER: Cannot play \(music.debugName) on \(Globals.sharedInstance.musicPlatform)")
        }
    }
    
    static func play(music: Music, platform: MusicPlatform){
        print("MUSIC PLAYER: Playing \(music.debugName) on \(platform)")
        switch platform {
        case .apple:
            AppleMusicPlayer.play(music: music)
        case .spotify:
            Globals.sharedInstance.play(music: music)
        case .none:
            print("none")
        }
    }
    
    static func pause(){
        NotificationCenter.default.post(name: .musicPaused, object: nil)
        switch Globals.sharedInstance.musicPlatform {
        
        case .apple:
            AppleMusicPlayer.pause()
        case .spotify:
            ContentServices.pauseSpotify() { (resp, error) in }
        case .none:
            print("No music player selected")
        }
    }
    
    static func resume(){
        NotificationCenter.default.post(name: .musicResumed, object: nil)
        switch Globals.sharedInstance.musicPlatform {
        
        case .apple:
            AppleMusicPlayer.resume()
        case .spotify:
            ContentServices.resumeSpotify() { (resp, error) in
                guard let resp = resp, let uri = resp.uri else { return }
                if(resp.playing == false){
                    Globals.sharedInstance.spotifyAppRemote.authorizeAndPlayURI(uri)
                }
            }
        case .none:
            print("No music player selected")
        }
    }
    
    static func canPlay(music: Music, platform: MusicPlatform) -> Bool {
        switch platform {
        case .apple:
            return SKCloudServiceController.authorizationStatus() == .authorized && music.appleId != nil && music.appleId?.count ?? 0 > 0
        case .spotify:
            return music.spotifyUri != nil && music.spotifyUri?.count ?? 0 > 0
        case .none:
            return false
        }
    }
}
