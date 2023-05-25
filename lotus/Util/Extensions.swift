//
//  Extensions.swift
//  lotus
//
//  Created by Robert Grube on 1/29/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension UIButton {
    func override(heightConstraint : CGFloat){
        self.constraints.forEach { (constraint) in
            if(constraint.firstAttribute == .height){
                constraint.constant = heightConstraint
            }
        }
    }
    
    
}

extension UIView {
    func removeDefaultConstraints(){
        self.constraints.forEach { (constraint) in
            if(constraint.firstAttribute == .height){
                constraint.isActive = false
            }
        }
    }
}

extension Notification.Name {
    static let didReceiveError = Notification.Name.init("didReceiveError")
    static let didStartPlayingMusic = Notification.Name.init("didStartPlayingMusic")
    static let noMusicPlayerSelected = Notification.Name.init("noMusicPlayerSelected")
    static let profileImageUpdated = Notification.Name.init("profileImageUpdated")
    static let navigateToLogin = Notification.Name.init("navigateToLogin")
    
    static let musicPaused = Notification.Name.init("musicPaused")
    static let musicResumed = Notification.Name.init("musicResumed")
}

extension UIViewController : SmallPlayerViewDelegate {   
    func smallPlayerTapped(music: Music, paused: Bool) {
        if let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.musicPlayerViewController) as? MusicPlayerViewController {
            vc.music = music
            vc.playing = !paused
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    @objc func noPlayerSelected(){
        self.showAlert(title: "No Music Player Selected", message: "Open settings and select a music player.")
    }
    
    @objc func didReceiveError(notification: Notification){
        if let error = notification.userInfo?["error"] as? LotusError{
            let messageString = "[\(error.status)] \(error.message) - \(error.path)"
            
            self.showAlert(title: error.error, message: messageString)
        }
    }
    
    @objc func didStartPlayingMusic(notification: Notification){
        if let music = notification.userInfo?["music"] as? Music{
//            for view in self.view.subviews{
//              if let subView = view as? SmallPlayerView {
//                subView.removeFromSuperview()
//                break
//              }
//            }
            let mp = SmallPlayerView()
            mp.setData(music: music)
            mp.delegate = self
            mp.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(mp)
            
//            if (mp.isDescendant(of: self.view)){
//                mp.removeFromSuperview()
//            } else {
//                //self.view.addSubview(mp)
//            }
            mp.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            mp.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            mp.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            mp.heightAnchor.constraint(equalToConstant: 54).isActive = true
        }
    }
    
    func showAlert(title: String? = nil, message: String? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension UIViewController : HeaderViewDelegate {
    func headerSettingsTapped() {
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.settingsViewController) as! SettingsViewController
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func headerProfileTapped() {
        
        guard let profile = Globals.sharedInstance.myProfile else {
            AccountServices.getMyProfile { (prof, error) in
                let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
                vc.profile = prof
                DispatchQueue.main.async {
                  self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
        vc.profile = profile
        DispatchQueue.main.async {
          self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
}

extension DateFormatter {
    
    static let allFormatters : [DateFormatter] = [.standard0ms, .standard2ms, .standard3ms, .standard6ms]
    
    static let iso: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let standard6ms: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let standard2ms: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let standard3ms: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let standard0ms: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension JSONDecoder {
    var dateDecodingStrategyFormatters: [DateFormatter]? {
        @available(*, unavailable, message: "This variable is meant to be set only")
        get { return nil }
        set {
            guard let formatters = newValue else { return }
            self.dateDecodingStrategy = .custom { decoder in

                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                for formatter in formatters {
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        }
    }
}

class LotusJSONDecoder : JSONDecoder {
    override init() {
        super.init()
        self.dateDecodingStrategyFormatters = DateFormatter.allFormatters
    }
}

extension Bundle {
  var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
extension UIImageView{
    func imageLoad(imageUrl:String)   {
//        let url = URL(string:imageUrl)
//        self.kf.indicatorType = .activity
//        self.kf.setImage(
//            with: url,
//            placeholder: UIImage(named: "profile"),
//            options: [
//                .transition(.fade(1)),
//                .cacheOriginalImage
//            ])
    }
    func imageLoadProfile(imageUrl:String)   {
//        let url = URL(string:imageUrl)
//        self.kf.indicatorType = .activity
//        self.kf.setImage(
//            with: url,
//            placeholder: UIImage(named: "profile"),
//            options: [
//                .transition(.fade(1)),
//                .cacheOriginalImage
//            ])
    }
}
