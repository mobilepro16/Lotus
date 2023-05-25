//
//  SettingsViewController.swift
//  lotus
//
//  Created by Robert Grube on 1/8/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import StoreKit
import WebKit

class SettingsViewController: UIViewController {

    
    @IBOutlet var spotifyButton: UIButton!
    @IBOutlet var appleButton: UIButton!
    @IBOutlet var versionLabel: UILabel!
    
    @IBOutlet var selectMusicPlayerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.selectMusicPlayerButton.isHidden = true
        updateSelectMusicButtonText()
    }
    

    @IBAction func backTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func spotifyClick(_ sender: Any) {
        if (Globals.sharedInstance.musicPlatform == .spotify) { return }
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userReadRecentlyPlayed, .userReadPrivate, .userModifyPlaybackState, .userReadPlaybackState]
        Globals.sharedInstance.sessionManager.initiateSession(with: scope, options: .clientOnly)
        Globals.sharedInstance.musicPlatform = .spotify
        UserDefaults.standard.set(MusicPlatform.spotify.rawValue, forKey: UserDefaultsKeys.selectedMusicPlatform)
        self.updateSelectMusicButtonText()
    }
    
    @IBAction func appleMusicClick(_ sender: Any) {
        if (Globals.sharedInstance.musicPlatform == .apple) { return }
        self.getAppleMusicToken()
        self.requestAppleMusicAuth()
        Globals.sharedInstance.musicPlatform = .apple
        UserDefaults.standard.set(MusicPlatform.apple.rawValue, forKey: UserDefaultsKeys.selectedMusicPlatform)
        self.updateSelectMusicButtonText()
    }
    
    func updateSelectMusicButtonText(){
        switch Globals.sharedInstance.musicPlatform {
        case .apple:
            self.appleButton.setTitle("CONNECTED TO APPLE MUSIC", for: .normal)
            self.spotifyButton.setTitle("CONNECT TO SPOTIFY", for: .normal)
            self.appleButton.backgroundColor = UIColor(red: 0.18, green: 0.68, blue: 0.84, alpha: 1)
            self.spotifyButton.backgroundColor = UIColor.clear
            self.appleButton.layer.borderColor = UIColor(red: 0.18, green: 0.68, blue: 0.84, alpha: 1).cgColor
            self.spotifyButton.layer.borderColor = UIColor.white.cgColor
        case .spotify:
            self.appleButton.setTitle("CONNECT TO APPLE MUSIC", for: .normal)
            self.spotifyButton.setTitle("CONNECTED TO SPOTIFY", for: .normal)
            self.appleButton.backgroundColor = UIColor.clear
            self.spotifyButton.backgroundColor = UIColor(red: 0.18, green: 0.68, blue: 0.84, alpha: 1)
            self.appleButton.layer.borderColor = UIColor.white.cgColor
            self.spotifyButton.layer.borderColor = UIColor(red: 0.18, green: 0.68, blue: 0.84, alpha: 1).cgColor
        case .none:
            self.appleButton.setTitle("CONNECT TO APPLE MUSIC", for: .normal)
            self.spotifyButton.setTitle("CONNECT TO SPOTIFY", for: .normal)
            self.appleButton.backgroundColor = UIColor.clear
            self.spotifyButton.backgroundColor = UIColor.clear
            self.appleButton.layer.borderColor = UIColor.white.cgColor
            self.spotifyButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBAction func logOutClick(_ sender: Any) {
        Token.deleteToken()
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false) {
            let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.loginViewController) as! LoginViewController
            vc.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                pvc?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func selectMusicPlayerClick(_ sender: Any) {
        let selectMusicSheet = UIAlertController(title: "Select Music Player", message: nil, preferredStyle: .actionSheet)
        let spotifyAction = UIAlertAction(title: "Spotify", style: .default) { (action) in
            Globals.sharedInstance.musicPlatform = .spotify
            UserDefaults.standard.set(MusicPlatform.spotify.rawValue, forKey: UserDefaultsKeys.selectedMusicPlatform)
            self.updateSelectMusicButtonText()
        }
        let appleAction = UIAlertAction(title: "Apple", style: .default) { (action) in
            Globals.sharedInstance.musicPlatform = .apple
            UserDefaults.standard.set(MusicPlatform.apple.rawValue, forKey: UserDefaultsKeys.selectedMusicPlatform)
            self.updateSelectMusicButtonText()
            self.requestAppleMusicAuth()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        selectMusicSheet.addAction(appleAction)
        selectMusicSheet.addAction(spotifyAction)
        selectMusicSheet.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(selectMusicSheet, animated: true, completion: nil)
        }
    }
    
    func getAppleMusicToken(){
        let controller = SKCloudServiceController()
        let developerToken = ""
      
        controller.requestUserToken(forDeveloperToken: developerToken) { userToken, error in
            // Use this value for recommendation requests.
        }
    }
    
    func requestAppleMusicAuth(){
        SKCloudServiceController.requestAuthorization { (authStatus) in
            switch authStatus {
            case .notDetermined:
                self.showAlert(title: "Authorization not determined")
            case .denied:
                self.showAlert(title: "Authorization denied")
            case .restricted:
                self.showAlert(title: "Authorization is restricted on this device")
            case .authorized:
                self.checkCapabilities()
            @unknown default:
                print("SETTINGS VIEW CONTROLLER - requestAuthorization - unknown default")
            }
        }
    }
    
  @IBAction func privacyClicked(_ sender: Any) {
    let vc = WebViewController()
    vc.url = URL(string: "https://drive.google.com/file/d/1TBpEL1aB0SEouHYXj2q7qNpl839MqBdG/view")!
    self.present(vc, animated: true, completion: nil)
  }
  @IBAction func termsClicked(_ sender: Any) {
    let vc = WebViewController()
    vc.url = URL(string: "https://drive.google.com/file/d/1vWe9MYjQOn8i5-Sc_Z77LiZXAnHoAU3l/view")!
    self.present(vc, animated: true, completion: nil)
  }
  @IBAction func aboutClicked(_ sender: Any) {
    let vc = WebViewController()
    vc.url = URL(string: "https://lot.us/#/")!
    self.present(vc, animated: true, completion: nil)
  }
  @IBAction func contactClicked(_ sender: Any) {
    let vc = WebViewController()
    vc.url = URL(string: "https://lot.us/#/contact")!
    self.present(vc, animated: true, completion: nil)
  }
  func checkCapabilities(){
        DispatchQueue.main.async {
            let controller = SKCloudServiceController()
            controller.requestCapabilities { capabilities, error in
                if let error = error{
                    self.showAlert(title: error.localizedDescription)
                    return
                }
                
                switch capabilities {
                    
                case .addToCloudMusicLibrary, .musicCatalogPlayback:
                    
                    self.showAlert(title: "Apple Music is ready to go!")
                    
                case .musicCatalogSubscriptionEligible:
                    DispatchQueue.main.async {
                        let vc = SKCloudServiceSetupViewController()
                        vc.delegate = self

                        let options: [SKCloudServiceSetupOptionsKey: Any] = [
                            .action: SKCloudServiceSetupAction.subscribe,
                            .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic
                        ]

                        vc.load(options: options) { success, error in
                            if success {
                                self.present(vc, animated: true)
                            }
                        }
                    }
                default:
                    print("SETTINGS VIEW CONTROLLER - requestCapabilities - default")
                }
                
            }
        }
    }
}

extension SettingsViewController : SKCloudServiceSetupViewControllerDelegate {
    func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
        
    }
}

