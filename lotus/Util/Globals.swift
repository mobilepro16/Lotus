//
//  Globals.swift
//  lotus
//
//  Created by Robert Grube on 1/30/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class Globals: NSObject {
    
    static let sharedInstance: Globals = Globals()
    
    var token : Token?
    var myProfile: Profile?
    
    var dataRefreshTimer: Timer?
    
    var musicPlatform: MusicPlatform = .none
    
    let semaphore = DispatchSemaphore(value: 1)
    
    override private init() {
        super.init()
        
//        dataRefreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { (tmr) in
//            ContentServices.getSpotifyRecentlyPlayed { (music, error) in
//                //
//            }
//        })
        
        if let plat = UserDefaults.standard.object(forKey: UserDefaultsKeys.selectedMusicPlatform) as? String {
            self.musicPlatform = MusicPlatform(rawValue: plat) ?? .none
        }
    }
    
    let SpotifyClientID = "785014358e60486e8caa05055523321c"
    let SpotifyRedirectURL = URL(string: "http://3.142.160.209:8080/")!
//    let SpotifyAccessToken = "BQBzUkfUN1gRQZ_m6PbP5q1rYIGFNk8l4xE0Dl2NCL-zG5GH-SpcIRuDAeL-CCPirCcECjTBbwnxQ5cU3QXu8JIsSCqcnnI33oUGjMOxO_7I0q7bjve7Gm19S3RzX2ORQQUyEX_Efb2Xl9Erp-Q8"

    lazy var spotifyConfiguration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    lazy var spotifyAppRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: spotifyConfiguration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: baseUrlString + HttpFunctions.spotifySwapToken),
            let tokenRefreshURL = URL(string: baseUrlString + HttpFunctions.spotifyRefreshToken) {
        self.spotifyConfiguration.tokenSwapURL = tokenSwapURL
        self.spotifyConfiguration.tokenRefreshURL = tokenRefreshURL
//        self.spotifyConfiguration.playURI = ""
      }
      let manager = SPTSessionManager(configuration: self.spotifyConfiguration, delegate: self)
//        manager.alwaysShowAuthorizationDialog = true
      return manager
    }()
    
    func play(music: Music){
        
        guard let uri = music.spotifyUri else {
            print("ERROR : NO SPOTIFY URI")
            return
        }
        
        ContentServices.playSpotify(uri: uri) { (response, error) in
            NotificationCenter.default.post(name: .didStartPlayingMusic, object: nil, userInfo: ["music":music])
            if let r = response, r.playing == true {
                print("Playing track from API")
            } else {
                self.spotifyAppRemote.authorizeAndPlayURI(uri)
                print("play")
            }
        }
    }
    
    func spotifySeek(count: Int = 0){
        print("CALLING SEEK: \(count)")
        ContentServices.seekSpotify { (spot, error) in
            guard let spot = spot else { return }
            if(spot.playing == false && count <= 30 ){
                self.spotifySeek(count: count + 1)
            }
        }
    }
    
    func pause(){
        if let player = spotifyAppRemote.playerAPI {
            player.pause(nil)
            print("paused")
        } else {
            print("no player")
        }
    }
}

extension Globals : SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        
        print("SPOTIFY AUTH IN SETTINGS:")
        print("SPOTIFY ACCESS TOKEN    : \(session.accessToken)")
        print("SPOTIFY REFRESH TOKEN   : \(session.refreshToken)")
                
        let spot = SpotifyToken(accessToken: session.accessToken, refreshToken: session.refreshToken)
        spot.save()
                
        AccountServices.connect(service: .spotify, token: session.accessToken, refresh: session.refreshToken) {
            print("CONNECTED")
        }
        
        DispatchQueue.main.async {
            self.spotifyAppRemote.connectionParameters.accessToken = session.accessToken
            self.spotifyAppRemote.connect()
        }
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {        
        print("SPOTIFY AUTH FAILED")
        print(error.localizedDescription)
        print(error)
        print("-----")
    }    
}

extension Globals : SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.spotifyAppRemote = appRemote
        print("REMOTE DID ESTABLISH CONNECTION")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?)")
        print(error?.localizedDescription ?? "")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?)")
        print(error?.localizedDescription ?? "")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
      print("player state changed")
    }
}
