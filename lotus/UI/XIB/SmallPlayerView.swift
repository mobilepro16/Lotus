//
//  SmallPlayerView.swift
//  lotus
//
//  Created by Robert Grube on 2/20/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import MediaPlayer

protocol SmallPlayerViewDelegate {
    func smallPlayerTapped(music: Music, paused: Bool)
}

class SmallPlayerView: CustomNibView {
    
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var spotifyButton: UIImageView!
    @IBOutlet weak var spotifyWidth: NSLayoutConstraint!
  
    var playing = true
    
    var music: Music!
    
    var delegate: SmallPlayerViewDelegate?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(didStartPlayingMusic), name: .didStartPlayingMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicPaused), name: .musicPaused, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicResumed), name: .musicResumed, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.nowPlayingChanged(_:)),
                name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                object: nil
            )
        }
        
        songTitleLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openBigPlayer))
        songTitleLabel.addGestureRecognizer(tap)
    }
    
    @objc func musicPaused(){
        playing = false
        pauseButton.setImage(UIImage(named: "music_play"), for: .normal)
    }
  
    @objc func musicResumed(){
        playing = true
        pauseButton.setImage(UIImage(named: "music_pause"), for: .normal)
    }
    
    @objc func openBigPlayer(){
        self.delegate?.smallPlayerTapped(music: music, paused: !playing)
    }

    @objc func nowPlayingChanged(_ notification: Notification){
        print("now playing changed")
        self.removeFromSuperview()
    }
    
    @objc func didStartPlayingMusic(){
        self.removeFromSuperview()
    }
    
    func setData(music: Music){
        self.music = music
        songTitleLabel.text = music.title ?? ""
        if let image = music.image, let url = URL(string: image){
            albumImage.sd_setImage(with: url)
        }
        artistLabel.text = music.artist ?? ""
        if (Globals.sharedInstance.musicPlatform == .spotify){
            self.spotifyButton.image = UIImage(named: "spotify2")
        } else {
          self.spotifyButton.image = UIImage(named: "apple2")
        }
    }
    
    @IBAction func closeClick(_ sender: Any) {
            MusicPlayer.pause()
            self.removeFromSuperview()
    }
    
    @IBAction func pauseClick(_ sender: Any) {
        playing = !playing
        if(playing){
            pauseButton.setImage(UIImage(named: "music_pause"), for: .normal)
            MusicPlayer.resume()
        } else {
            pauseButton.setImage(UIImage(named: "music_play"), for: .normal)
            MusicPlayer.pause()
        }
    }
}
