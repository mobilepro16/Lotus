//
//  MusicPlayerViewController.swift
//  lotus
//
//  Created by Robert Grube on 2/21/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var playerLabel: UILabel!
  
    var music : Music!
    
    var playing = true
    var isBookmarked = false
    var bookmarks: [Bookmark] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()

        if (Globals.sharedInstance.musicPlatform == .spotify){
            self.spotifyButton.setBackgroundImage(UIImage(named: "spotify2"), for: .normal)
            self.playerLabel.text = "Listening on Spotify Music"
        } else {
            self.spotifyButton.setBackgroundImage(UIImage(named: "apple2"), for: .normal)
            self.playerLabel.text = "Listening on Apple Music"
        }
        
        setData(music: music)
        
        if(playing){
            pauseButton.setBackgroundImage(UIImage(named: "pause_3rd"), for: .normal)
        } else {
            pauseButton.setBackgroundImage(UIImage(named: "play_3rd"), for: .normal)
        }
        if(isBookmarked){
            bookmarkButton.setBackgroundImage(UIImage(named: "icon_bookmark_active"), for: .normal)
        } else {
            bookmarkButton.setBackgroundImage(UIImage(named: "icon_bookmark_inactive"), for: .normal)
        }
        getBookmarkSongs()
  }
  func getBookmarkSongs(){
      let dispatch = DispatchGroup()
      
      dispatch.enter()
      BookmarkServices.getBookmarks { (bookmarks, error) in
          if let book = bookmarks?.content {
              self.bookmarks = book
              for bookmark in self.bookmarks {
                if bookmark.music?.contentId == self.music.contentId {
                    self.isBookmarked = true
                    self.bookmarkButton.setBackgroundImage(UIImage(named: "icon_bookmark_active"), for: .normal)
                    return
                }
              }
          }
          dispatch.leave()
      }
  }
    @IBAction func closeClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bookmarkClicked(_ sender: Any) {
      self.isBookmarked = !self.isBookmarked
      if(isBookmarked){
          BookmarkServices.saveBookmark(musicId: self.music?.contentId ?? "", historyId: "") { (bookmark, error) in
              self.bookmarkButton.setBackgroundImage(UIImage(named: "icon_bookmark_active"), for: .normal)
          }
      } else {
          BookmarkServices.removeBookmark(musicId: self.music.contentId ?? "") { (bookmark, error) in
              self.bookmarkButton.setBackgroundImage(UIImage(named: "icon_bookmark_inactive"), for: .normal)
          }
      }
    }
    @IBAction func postClicked(_ sender: Any) {
      let alert = UIAlertController(title: "Add a caption", message: nil, preferredStyle: .alert)
      alert.addTextField { (txt) in
          txt.placeholder = "Caption"
          txt.autocapitalizationType = .sentences
          txt.autocorrectionType = .yes
      }
     
      let save = UIAlertAction(title: "Post", style: .default) { [unowned alert] _ in
          
          var comment = ""
          if let tfs = alert.textFields {
              comment = tfs.first?.text ?? ""
          }
          let bookmarkmusic = self.music
          bookmarkmusic!.userId = Globals.sharedInstance.myProfile?.userId ?? ""
          bookmarkmusic!.userComment = comment
          ContentServices.postBookmark(music: bookmarkmusic!) { (newhistory, error) in
              self.showAlert(title: "Done", message: nil)
          }
          
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
          //
      }
      
      alert.addAction(save)
      alert.addAction(cancel)
      
      self.present(alert, animated: true, completion: nil)
    }
    func setData(music: Music){
        self.music = music
        titleLabel.text = music.title ?? ""
        artistLabel.text = music.artist ?? ""
        albumLabel.text = music.album ?? ""
        if let image = music.image, let url = URL(string: image){
            albumImage.sd_setImage(with: url)
        }
    }
    
    @IBAction func pauseClick(_ sender: Any) {
        playing = !playing
        if(playing){
            pauseButton.setBackgroundImage(UIImage(named: "pause_3rd"), for: .normal)
            MusicPlayer.resume()
        } else {
            pauseButton.setBackgroundImage(UIImage(named: "play_3rd"), for: .normal)
            MusicPlayer.pause()
        }
    }
}
