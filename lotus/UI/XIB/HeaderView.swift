//
//  HeaderView.swift
//  lotus
//
//  Created by Robert Grube on 1/2/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate {
    func headerSettingsTapped()
    func headerProfileTapped()
}

class HeaderView: CustomNibView {
    
    @IBOutlet var profileButton: UIButton!
    
    var delegate: HeaderViewDelegate?

    override func setup() {
        
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.clipsToBounds = true
        if let me = Globals.sharedInstance.myProfile, let img = me.profileImage, let url = URL(string: imageUrlPrefix + img) {
            profileButton.sd_setImage(with: url, for: .normal, placeholderImage: UIImage(named: "fake-user"), options: .refreshCached) { (image, error, cacheType, url) in
                self.profileButton.imageView?.contentMode = .scaleAspectFill
            }
        } else {
            if(Globals.sharedInstance.myProfile == nil){
                _ = Token.load()
                AccountServices.getMyProfile { (profile, error) in
                    if let prof = profile {
                        Globals.sharedInstance.myProfile = prof
                        if let img = prof.profileImage, let url = URL(string: imageUrlPrefix + img) {
                            self.profileButton.sd_setImage(with: url, for: .normal, placeholderImage: UIImage(named: "fake-user"), options: .refreshCached) { (image, error, cacheType, url) in
                                self.profileButton.imageView?.contentMode = .scaleAspectFill
                            }
                        }
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileImageUpdated(notification:)), name: .profileImageUpdated, object: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        self.delegate?.headerSettingsTapped()
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        self.delegate?.headerProfileTapped()
    }
    
    @objc func profileImageUpdated(notification: Notification){
        if let image = notification.userInfo?["profileImage"] as? UIImage{
            profileButton.setImage(image, for: .normal)
        } else {
            if let me = Globals.sharedInstance.myProfile, let img = me.profileImage, let url = URL(string: imageUrlPrefix + img) {
              profileButton.sd_setImage(with: url, for: .normal, placeholderImage: UIImage(named: "fake-user"), options: .refreshCached) { (image, error, cacheType, url) in
                    self.profileButton.imageView?.contentMode = .scaleAspectFill
                }
            }
        }
    }
}
