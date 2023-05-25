//
//  ProfileViewController.swift
//  lotus
//
//  Created by Robert Grube on 1/6/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class ProfileViewController: UIViewController {
    
    enum UploadPhotoType : Int {
        case cover
        case profile
    }
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var profileImageView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var nameView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var followersView: UIView!
    @IBOutlet var followingView: UIView!
    @IBOutlet var numFollowersLabel: UILabel!
    @IBOutlet var numFollowingLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var activityStackView: UIStackView!
    
    // MARK: tabs
    
    @IBOutlet var activityTabButton: UIButton!
    @IBOutlet var historyTabButton: UIButton!
    @IBOutlet var artistsTabButton: UIButton!
    @IBOutlet var albumsTabButton: UIButton!
    @IBOutlet var bookmarksTabButton: UIButton!
    
    var themeSongView: ListeningToView?
    var currentlyListeningToView: CurrentlyListeningView?
    
    var profile: Profile!
    
    var following: [User]?
    var activity: [TimelineHistory]?
    var artists: [Artist]?
    var albums: [Album]?
    var bookmarks: [Bookmark]?
    
    var uploadPhotoType: UploadPhotoType = .profile
    var presentMode : Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated(_:)), name: Notification.Name(rawValue: "profileUpdated"), object: nil)
        setup()
        updateUI()
        getProfileData()
    }
    @objc func profileUpdated(_ notification: Notification){
        guard let newprofile = notification.userInfo?["newProfile"] as? Profile else {
           return
        }
        self.profile = newprofile
        updateUI()
        getProfileData()
    }
    func updateUI(){
        DispatchQueue.main.async {
            self.nameLabel.text = "\(self.profile.firstName ?? "") \(self.profile.lastName ?? "")"
            self.usernameLabel.text = "\(self.profile.displayName ?? "@displayname")"
            
            let input = self.profile.bio ?? ""
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

            let attributedString = NSMutableAttributedString(string: self.profile.bio ?? "")
          
            for match in matches {
                guard let range = Range(match.range, in: input) else { continue }
                let url = input[range]
              attributedString.setAttributes([.link: url], range: match.range)
             
              
            }
            self.bioLabel.attributedText = attributedString
            self.bioLabel.isUserInteractionEnabled = true
            self.bioLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(self.tapLabel(gesture:))))
            self.numFollowersLabel.text = "\(self.profile.numFollowers ?? 0)"
            self.numFollowingLabel.text = "\(self.profile.numFollowing ?? 0)"
            
            if let themeSong = self.profile.themeSong {
                if let tsv = self.themeSongView {
                    tsv.setData(music: themeSong)
                } else {
                    let tsv = ListeningToView()
                    tsv.setData(music: themeSong)
                    self.stackView.insertArrangedSubview(tsv, at: 2)
                    self.themeSongView = tsv
                }
            }
            
            if let current = self.profile.currentSong, let currentSong = current.music {
                if let clt = self.currentlyListeningToView {
                    clt.setData(music: currentSong)
                    clt.delegate = self
                } else {
                    let currentView = CurrentlyListeningView()
                    currentView.setData(music: currentSong)
                    currentView.titleLabel.text = "NOW LISTENING TO"
                    self.stackView.insertArrangedSubview(currentView, at: 2)
                    self.currentlyListeningToView = currentView
                    self.currentlyListeningToView?.delegate = self
                }
                
            }
            
            if let profImage = self.profile.profileImage, let profUrl = URL(string: imageUrlPrefix + profImage){
              self.profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
            }
            if let coverImage = self.profile.coverImage, let coverUrl = URL(string: imageUrlPrefix + coverImage){
              self.coverImage.sd_setImage(with: coverUrl, placeholderImage: UIImage(named: "fake-cover"), options: .refreshCached, completed: nil)
            }
            self.followButton.isHidden = false
            if let me = Globals.sharedInstance.myProfile {
                if(me.userId == self.profile.userId){
                    // Hide follow button if we're looking at our own profile
                    self.followButton.isHidden = false
                    self.followButton.setTitle("EDIT PROFILE", for: .normal)
                } else if(self.following == nil){
                    // If this is not your own profile and you don't know who you're following yet, hide the follow button
                    self.followButton.isHidden = true
                } else {
                    // This is not your profile, so check if you're following that person and hide button accordingly
                    let followingThisPerson = self.following!.filter { $0.id == self.profile.userId }
                    if(followingThisPerson.count > 0) {
                      self.followButton.setTitle("UNFOLLOW", for: .normal)
                    } else {
                      self.followButton.setTitle("FOLLOW", for: .normal)
                    }
                }
            }
            if let history = self.activity {
                self.activityStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
                
                for h in history {
                    let vw = TimelineView()
                    vw.setData(timelineHistory: h)
                    vw.delegate = self
                    
                    self.activityStackView.addArrangedSubview(vw)
                }
            }
        }
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(followersTapped))
        self.followersView.addGestureRecognizer(followerTap)
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(followingTapped))
        self.followingView.addGestureRecognizer(followingTap)
    }
  @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
      let input = self.profile.bio ?? ""
      let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
      let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
      for match in matches {
          guard let range = Range(match.range, in: input) else { continue }
          let url = input[range]
          if gesture.didTapAttributedTextInLabel(label: self.bioLabel, inRange: match.range) {
              let vc = WebViewController()
              vc.url = URL(string: String(url))!
              self.present(vc, animated: true, completion: nil)
          }
      }
  }
    func setup(){
        
        self.scrollView.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.clipsToBounds = true
      
        profileImage.layer.borderWidth = 0.6
        profileImage.layer.borderColor = UIColor.white.cgColor
          
        followButton.layer.cornerRadius = followButton.bounds.height / 2
        followButton.clipsToBounds = true
        
        historyTabButton.removeFromSuperview()
        bookmarksTabButton.removeFromSuperview()
        
    }
    
    func getProfileData(){
        guard let me = Globals.sharedInstance.myProfile else { return }
        let dispatch = DispatchGroup()
        
        dispatch.enter()
        AccountServices.getProfile(userId: self.profile.userId) { (profile, error) in
            guard let profile = profile else { return }
            self.profile = profile
            dispatch.leave()
        }
        
        dispatch.enter()
        AccountServices.getFollowing(userId: me.userId) { (following, error) in
            if let f = following, let arr = f.content {
                self.following = arr
            }
            dispatch.leave()
        }
        
        ContentServices.getActivity(userId: profile.userId, pageSize: 150) { (history, error) in
            if let act = history?.content {
                self.activity = act
              self.updateUI()
            }
        }

        dispatch.notify(queue: .main) {
            self.updateUI()
        }
    }
    
    func getArtists(completion: @escaping () -> Void){
        UserActionServices.getArtists(userId: profile.userId) { (artists, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else if let artists = artists, let arr = artists.content {
                self.artists = arr
            }
            completion()
        }
    }
    
    func getAlbums(completion: @escaping () -> Void){
        UserActionServices.getAlbums(userId: profile.userId) { (albums, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else if let albums = albums, let arr = albums.content {
                self.albums = arr
            }
            completion()
        }
    }
    
    @IBAction func activityTabClicked(_ sender: Any) {
        updateTabView(tabButton: activityTabButton)
        self.showActivity()
        
    }
    
    @IBAction func historyTabClicked(_ sender: Any) {
        updateTabView(tabButton: historyTabButton)
    }
    
    @IBAction func artistsTabClicked(_ sender: Any) {
        updateTabView(tabButton: artistsTabButton)
        if self.artists != nil {
            self.showArtists()
        } else {
            self.getArtists() {
                self.showArtists()
            }
        }
    }
    
    @IBAction func albumsTabClicked(_ sender: Any) {
        updateTabView(tabButton: albumsTabButton)
        if self.albums != nil {
            self.showAlbums()
        } else {
            self.getAlbums {
                self.showAlbums()
            }
        }
    }
    
    @IBAction func bookmarksTabClicked(_ sender: Any) {
        updateTabView(tabButton: bookmarksTabButton)
        
        
        self.showBookmarks()
    }
    
    func updateTabView(tabButton: UIButton){
        
        let tabs = [activityTabButton,historyTabButton, artistsTabButton, albumsTabButton, bookmarksTabButton]
        for t in tabs {
            if(t == tabButton){
                t?.setTitleColor(.white, for: .normal)
            } else {
                t?.setTitleColor(UIColor.lotusTabUnselected, for: .normal)
            }
        }
    }
    
    func showActivity(){
        guard let activity = self.activity else { return }
        self.activityStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for history in activity {
            let vw = TimelineView()
            vw.setData(timelineHistory: history)
            vw.delegate = self
            
            self.activityStackView.addArrangedSubview(vw)
        }
    }
    
    func showAlbums(){
        guard let albums = self.albums else { return }
        self.activityStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for album in albums {
            let vw = AlbumView()
            vw.setData(album: album)
            self.activityStackView.addArrangedSubview(vw)
        }
    }
    
    func showArtists(){
        guard let artists = self.artists else { return }
        self.activityStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for artist in artists {
            let vw = ArtistView()
            vw.setData(artist: artist)
            self.activityStackView.addArrangedSubview(vw)
        }
    }
    
    func showBookmarks(){
        guard let bookmarks = self.bookmarks else { return }
        self.activityStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for bookmark in bookmarks {
            let vw = BookmarkView()
            vw.setData(bookmark: bookmark)
            vw.delegate = self
            self.activityStackView.addArrangedSubview(vw)
        }
    }
    
    @IBAction func bioButtonClicked(_ sender: Any) {
        
        if let me = Globals.sharedInstance.myProfile{
            if(me.userId == self.profile.userId){
                let alert = UIAlertController(title: "Edit your bio", message: nil, preferredStyle: .alert)
                alert.addTextField()
                alert.textFields![0].placeholder = "Edit your bio"
                alert.textFields![0].text = profile.bio
                let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
                    self.profile.bio = alert.textFields![0].text
                    AccountServices.edit(profile: self.profile) { (newProfile, error) in
                        if let newProfile = newProfile {
                            self.profile = newProfile
                            self.updateUI()
                        }
                    }
                }
               let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
                    //
                }

                alert.addAction(submitAction)
                alert.addAction(cancelAction)

                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
    

    @IBAction func backTapped(_ sender: Any) {
        DispatchQueue.main.async {
          if (self.presentMode == true) {
            self.dismiss(animated: true, completion: nil)
          } else {
            self.navigationController?.popViewController(animated: true)
          }
        }
    }
    
    @IBAction func followTapped(_ sender: Any) {
      if let me = Globals.sharedInstance.myProfile{
        if (me.userId == self.profile.userId){
          let vc = self.storyboard?.instantiateViewController(identifier: "ProfileEditViewController") as! ProfileEditViewController
          vc.profile = self.profile
          DispatchQueue.main.async {
              self.navigationController?.pushViewController(vc, animated: true)
          }
          return
        } else {
          let followingThisPerson = self.following!.filter { $0.id == self.profile.userId }
            if(followingThisPerson.count > 0) {
                AccountServices.unfollow(userId: self.profile.userId) { (data) in
                    self.updateUI()
                    self.getProfileData()
                    
                }
            } else{
            
                AccountServices.follow(userId: self.profile.userId) { (data) in
                    let user = User(id: self.profile.userId)
                    self.following?.append(user)
                    self.updateUI()
                    self.getProfileData()
                    let usersRef = Firestore.firestore().collection("users_table").document(self.profile.userId)
                    usersRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let token = document.get("fcmToken") as! String
                            print("Document data: \(token)")
                            let sender = PushNotificationSender()
                            sender.sendPushNotification(to: token , title: "", body: (Globals.sharedInstance.myProfile!.displayName! + " just followed you."))
                        } else {
                            print("Document does not exist")
                        }
                    }
                  
                }
            }
        }
      }
    }
    
    @objc func followersTapped(){
        AccountServices.getFollowers(userId: profile.userId) { (followers, error) in
            if let f = followers, let arr = f.content {
                let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.followListViewController) as! FollowListViewController
                vc.data = arr
                vc.title = "FOLLOWERS"
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func followingTapped(){
        AccountServices.getFollowing(userId: profile.userId) { (following, error) in
            if let f = following, let arr = f.content {
                let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.followListViewController) as! FollowListViewController
                vc.data = arr
                vc.title = "FOLLOWING"
                self.following = arr
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func profileImageTapped(){
        uploadPhotoType = .profile
        choosePhoto()
    }
    
    @objc func coverImageTapped(){
        uploadPhotoType = .cover
        choosePhoto()
    }
    
    func choosePhoto(){
        guard let myProfile = Globals.sharedInstance.myProfile else { return }
        if(myProfile.userId == profile.userId){
            let imageSheet = UIAlertController(title: "Upload new photo", message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
                self.uploadPhotoFrom(source: .camera)
            }
            let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                self.uploadPhotoFrom(source: .photoLibrary)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
            imageSheet.addAction(camera)
            imageSheet.addAction(library)
            imageSheet.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(imageSheet, animated: true)
            }
        }
    }
    
    func uploadPhotoFrom(source: UIImagePickerController.SourceType){
        let vc = UIImagePickerController()
        vc.sourceType = source
        vc.allowsEditing = true
        vc.delegate = self
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
    
    @objc func nameTapped(){
        
        guard let myProfile = Globals.sharedInstance.myProfile else { return }
        if(myProfile.userId != profile.userId){
            // Shouldn't get here, but we can't edit someone else's profile
            return
        }
        
        let alert = UIAlertController(title: "Edit your name?", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields![0].placeholder = "First Name"
        alert.textFields![1].placeholder = "Last Name"
        alert.textFields![2].placeholder = "Display Name"
        
        alert.textFields![0].text = profile.firstName
        alert.textFields![1].text = profile.lastName
        alert.textFields![2].text = profile.displayName
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
            self.profile.firstName = alert.textFields![0].text
            self.profile.lastName = alert.textFields![1].text
            self.profile.displayName = alert.textFields![2].text
            self.updateUI()
            AccountServices.edit(profile: self.profile) { (newProfile, error) in
                if let newProfile = newProfile {
                    self.profile = newProfile
                    self.updateUI()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            //
        }

        alert.addAction(submitAction)
        alert.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didStartPlayingMusic, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigateToLogin, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartPlayingMusic), name: .didStartPlayingMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noPlayerSelected), name: .noMusicPlayerSelected, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension ProfileViewController : TimelineViewDelegate {
  func cellUserClicked(history: TimelineHistory) {
  }
  
  
  func cellPlayClicked(history: TimelineHistory) {
      if let music = history.history?.music {
          MusicPlayer.play(music: music)
          self.profile.currentSong?.music = music
          self.updateUI()
      }
  }
  func addPending(history: TimelineHistory) {
      
        guard let history = history.history else { return }
        let menu = UIAlertController(title: "Menu", message: history.music?.title ?? "", preferredStyle: .actionSheet)
    
        let postsong = UIAlertAction(title: "Post Song", style: .default) { (action) in
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
              let bookmarkmusic = history.music
              bookmarkmusic!.userId = Globals.sharedInstance.myProfile?.userId ?? ""
              bookmarkmusic!.userComment = comment
              ContentServices.postBookmark(music: bookmarkmusic!) { (newhistory, error) in
                self.showAlert(title: "Done", message: nil)
                self.getProfileData()
              }
              
          }
          let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
              //
          }
          
          alert.addAction(save)
          alert.addAction(cancel)
          
          self.present(alert, animated: true, completion: nil)
        }
        menu.addAction(postsong)
        
        let sendsong = UIAlertAction(title: "Send Song", style: .default) { (action) in
          let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.choosePeoplesViewController) as! ChoosePeoplesViewController
          vc.music = history.music
          DispatchQueue.main.async {
              self.present(vc, animated: true, completion: nil)
          }
        }
        menu.addAction(sendsong)
    
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        menu.addAction(cancel)
    
        DispatchQueue.main.async {
            self.present(menu, animated: true, completion: nil)
        }
  }
  func cellCommentsClicked(history: TimelineHistory) {
      guard let history = history.history else { return }
      ContentServices.getComments(historyId: history.id) { (comments, error) in
          if let comments = comments, let array = comments.content{
              let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.historyCommentViewController) as! HistoryCommentViewController
              vc.history = history
              vc.comments = array
              DispatchQueue.main.async {
                  self.navigationController?.pushViewController(vc, animated: true)
              }
          }
      }
  }
  
  func cellMenuClicked(history: TimelineHistory) {
      guard var me = Globals.sharedInstance.myProfile else { return }
      
      let menu = UIAlertController(title: "Menu", message: history.history?.music?.title ?? "", preferredStyle: .actionSheet)
      
      if let music = history.history?.music{
          let play = UIAlertAction(title: "Play Song", style: .default) { (action) in
              MusicPlayer.play(music: music)
          }
          menu.addAction(play)
          
          let theme = UIAlertAction(title: "Set as Theme Song", style: .default) { (action) in
              me.themeSong = music
              AccountServices.edit(profile: me) { (profile, error) in
                  if profile != nil{
                      let okAlert = UIAlertController(title: "Theme Song Set", message: nil, preferredStyle: .alert)
                      let okAct = UIAlertAction(title: "OK", style: .default, handler: nil)
                      okAlert.addAction(okAct)
                      DispatchQueue.main.async {
                          if(me.userId == self.profile.userId){
                            self.profile.themeSong = music
                            self.updateUI()
                          }
                          self.present(okAlert, animated: true, completion: nil)
                      }
                  }
              }
          }
          menu.addAction(theme)
        
       
      
        if(history.user?.id == me.userId){
          let editcaption = UIAlertAction(title: "Edit Caption", style: .default) { (action) in
            let alert = UIAlertController(title: "Edit caption", message: nil, preferredStyle: .alert)
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
                UserActionServices.editAction(actionId: history.actionId, comment: comment) { (newHistory, error) in
                  self.getProfileData()
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                //
            }
            
            alert.addAction(save)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
          }
          menu.addAction(editcaption)
          
            let delete = UIAlertAction(title: "Delete Post", style: .default) { (action) in
              let alert = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
              let delete = UIAlertAction(title: "Delete post", style: .destructive) { (action) in
                    UserActionServices.deleteAction(actionId: history.actionId) { (history, error) in
                      self.getProfileData()
                    }
              }
              let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

              }
              alert.addAction(delete)
              alert.addAction(cancel)
              self.present(alert, animated: true, completion: nil)
              

            }
            menu.addAction(delete)
        }
        
      }
      
      
      let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      menu.addAction(cancel)
      DispatchQueue.main.async {
          self.present(menu, animated: true, completion: nil)
      }
  }
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        switch self.uploadPhotoType {
        case .cover:
            self.coverImage.image = image
            AccountServices.uploadCoverImage(image: image) { (data) in
                //
            }
            
        case .profile:
            self.profileImage.image = image
            AccountServices.uploadProfileImage(image: image) { (data) in
                NotificationCenter.default.post(name: .profileImageUpdated, object: nil, userInfo: ["profileImage":image])
            }
        }
    }
}

extension ProfileViewController : BookmarkViewDelegate {
    func bookmarkRemoved(bookmark: Bookmark) {
        BookmarkServices.getBookmarks { (bookmarks, error) in
            if let book = bookmarks?.content {
                self.bookmarks = book
            }
        }
    }
    func postBookmark(bookmark: Bookmark) {
    }
}
extension ProfileViewController : CurrentlyListeningViewDelegate {
  func cellSharesClicked(music: Music) {
    let menu = UIAlertController(title: "Menu", message: music.title ?? "", preferredStyle: .actionSheet)
          
    let postsong = UIAlertAction(title: "Post Song", style: .default) { (action) in
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
            music.userId = Globals.sharedInstance.myProfile?.userId ?? ""
            music.userComment = comment
            ContentServices.postBookmark(music: music) { (newhistory, error) in
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
    menu.addAction(postsong)
    
    let sendsong = UIAlertAction(title: "Send Song", style: .default) { (action) in
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.choosePeoplesViewController) as! ChoosePeoplesViewController
        vc.music = music
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    menu.addAction(sendsong)

    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    menu.addAction(cancel)

    DispatchQueue.main.async {
        self.present(menu, animated: true, completion: nil)
    }
  }
  
  func cellMenuClicked(music: Music) {
    guard var me = Globals.sharedInstance.myProfile else { return }
    
    let menu = UIAlertController(title: "Menu", message: music.title ?? "", preferredStyle: .actionSheet)
    
    let play = UIAlertAction(title: "Play Song", style: .default) { (action) in
        MusicPlayer.play(music: music)
    }
    menu.addAction(play)
    
    let theme = UIAlertAction(title: "Set as Theme Song", style: .default) { (action) in
        me.themeSong = music
        AccountServices.edit(profile: me) { (profile, error) in
            if profile != nil{
                let okAlert = UIAlertController(title: "Theme Song Set", message: nil, preferredStyle: .alert)
                let okAct = UIAlertAction(title: "OK", style: .default, handler: nil)
                okAlert.addAction(okAct)
                DispatchQueue.main.async {
                    self.present(okAlert, animated: true, completion: nil)
                }
            }
        }
    }
    menu.addAction(theme)
        
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    menu.addAction(cancel)
    DispatchQueue.main.async {
        self.present(menu, animated: true, completion: nil)
    }
  }
}
