//
//  ChatViewController.swift
//  lotus
//
//  Created by admin on 4/1/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit
import IQKeyboardManager
import SendBirdSDK
import MobileCoreServices
import AVKit
import SKPhotoBrowser
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications


class ChatViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
 

  @IBOutlet weak var headerView: HeaderView!
  @IBOutlet weak var contactView: UIView!
  @IBOutlet weak var contactPhoto: UIImageView!
  @IBOutlet weak var contactName: UILabel!
  @IBOutlet weak var contactUsername: UILabel!
  @IBOutlet weak var textInputView: UIView!
  @IBOutlet weak var chatTableView: UITableView!
  @IBOutlet weak var musicButton: UIButton!
  @IBOutlet weak var typeMessage: UITextField!
  @IBOutlet weak var constraintTextViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var messageView: UIView!
  
  var imgPicker = UIImagePickerController()
  var messageArray = [SBDBaseMessage]()
  var photoBrowser = SKPhotoBrowser()
  var otherUser = SBDUser()
  var currentChannel : SBDGroupChannel?
  var  messageQuery : SBDPreviousMessageListQuery?
  
  var contactNameText = ""
  var contactUsernameText = ""
  var contactPhotoUrl = ""
  var noData = 1
  var apiHit = false
  var isBlocked = false
  
  var justLoad = true
  
  var timer = Timer()
  var isblocked = false
  var isGroup = false
  
  var isComeFriend = false
  var otherUserName = ""
  
  override func viewDidLoad() {
      super.viewDidLoad()
      headerView.delegate = self
      contactPhoto.layer.cornerRadius = contactPhoto.bounds.width / 2
      contactPhoto.clipsToBounds = true
  
      messageView.layer.cornerRadius = messageView.bounds.height / 2
      messageView.clipsToBounds = true
      messageView.layer.borderWidth = 0.3
      messageView.layer.borderColor = UIColor.darkGray.cgColor
      
      contactName.text = contactNameText
      contactPhoto.sd_setImage(with: URL(string: contactPhotoUrl), placeholderImage: UIImage(named: "fake-user"), options: [], completed: nil)
  
      typeMessage.layer.cornerRadius = typeMessage.bounds.height / 2
      typeMessage.clipsToBounds = true
      typeMessage.delegate = self
  
      chatTableView.delegate = self
      chatTableView.dataSource = self
      chatTableView.keyboardDismissMode = .onDrag
      chatTableView.tableFooterView = UIView()
      // Do any additional setup after loading the view.

      self.timer.invalidate()
      self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateUser), userInfo: nil, repeats: true)
      chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
      IQKeyboardManager.shared().isEnableAutoToolbar = true
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillOpenHide(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillOpenHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
  
      let photoTap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
      let usernameTap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
      self.contactPhoto.isUserInteractionEnabled = true
      self.contactName.isUserInteractionEnabled = true
      self.contactPhoto.addGestureRecognizer(photoTap)
      self.contactName.addGestureRecognizer(usernameTap)
  }
  deinit {
      self.timer.invalidate()
  }
  @objc func profileTapped(){
      let uid = self.otherUser.userId
      AccountServices.getProfile(userId: uid) { (profile, error) in
          guard let profile = profile else { return }
          let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
          vc.profile = profile
          DispatchQueue.main.async {
              self.navigationController?.pushViewController(vc, animated: true)
          }
      }
  }
  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.setNavigationBarHidden(true, animated: animated)
      SBDMain.add(self, identifier: self.description)
      // add notification observers
      NotificationCenter.default.addObserver(self, selector: #selector(self.getInitialMessages), name: UIApplication.willEnterForegroundNotification, object: nil)
      
      //Chat Setup
      if self.currentChannel != nil{
          self.getInitialMessages()
          SendBirdInterface.sharedInstace.ignoreChannel = self.currentChannel
          
          if let members = self.currentChannel?.members as? [SBDUser]{
              for member in members{
                  if member.userId != SendBirdInterface.sharedInstace.currentUser.userId {
                      self.isBlocked = ((member as? SBDMember)?.isBlockedByMe ?? false)
                  }
              }
          }
          if (self.isBlocked == true) {
            self.contactName.text = self.contactNameText + "(blocked)"
          } else {
            self.contactName.text = self.contactNameText
          }
          SendBirdInterface.sharedInstace.getMutedUsers(channel: self.currentChannel) { (users, error) in
              if users?.isEmpty == false{
                  for user in users!{
                      if user.userId != SendBirdInterface.sharedInstace.currentUser.userId {
                          self.isBlocked = true
                      }
                  }
              }
              if (self.isBlocked == true) {
                self.contactName.text = self.contactNameText + "(blocked)"
              } else {
                self.contactName.text = self.contactNameText
              }
          }
      } else{
          if !self.isGroup{
              self.createNewChannel()
          }
      }
      SendBirdInterface.sharedInstace.ignoreChannel = self.currentChannel
      self.currentChannel?.markAsRead()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
          SendBirdInterface.sharedInstace.unreadChannels()
      })
      CheckUserBlocked()
     
  }
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.setNavigationBarHidden(false, animated: animated)
      //IQKeyboardManager.shared().isEnabled = true
      IQKeyboardManager.shared().isEnableAutoToolbar = true
      SBDMain.removeChannelDelegate(forIdentifier: self.description)
      SendBirdInterface.sharedInstace.ignoreChannel = nil
      self.navigationController?.setNavigationBarHidden(false, animated: false)
      //Remove observer
      NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
  }
  override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      self.justLoad = false
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()  //if desired
      return true
  }
  func performAction() {
      if self.typeMessage.text!.trimmingCharacters(in: .whitespaces) != "" {
          let msgtxt = self.typeMessage.text!.trimmingCharacters(in: .whitespaces)
          SendBirdInterface.sharedInstace.sendMessage(channel: self.currentChannel, msg: self.typeMessage.text!.trimmingCharacters(in: .whitespaces)) { (message, error) in
              if message != nil{
                  self.addMessage(msg: message!)
              }
              if (error != nil){
                self.showAlert(title: ("You are not allowed to send message by " + self.otherUser.nickname! + "."), message: nil)
              } else {
                let usersRef = Firestore.firestore().collection("users_table").document(self.otherUser.userId)
                usersRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let token = document.get("fcmToken") as! String
                        print("Document data: \(token)")
                        let sender = PushNotificationSender()
                        sender.sendPushNotification(to: token , title: Globals.sharedInstance.myProfile!.displayName!, body: msgtxt)
                    } else {
                        print("Document does not exist")
                    }
                }
              }
          }
          self.typeMessage.text = ""
      }
  }
 
  @objc func keyboardWillOpenHide(_ notification: Notification){
      if let userInfo = notification.userInfo{
          let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
          var keyboardSize = notification.name == UIResponder.keyboardWillShowNotification ? rect?.size.height : 0
          
          if UIDevice().userInterfaceIdiom == .phone {
              switch UIScreen.main.nativeBounds.height {
              case 1136,1334,1920, 2208:
                  keyboardSize = notification.name == UIResponder.keyboardWillShowNotification ? rect?.size.height : 0
              case 2436,2688,1792:
                  keyboardSize = notification.name == UIResponder.keyboardWillShowNotification ? keyboardSize! - 70: 0
              default:
                  keyboardSize = notification.name == UIResponder.keyboardWillShowNotification ? rect?.size.height : 0
              }
          }
          self.bottomConstraint.constant = CGFloat(-Int(keyboardSize ?? 0))
          UIView.animate(withDuration: 0.2, animations: {
              self.view.layoutIfNeeded()
          }) { (completed) in
          }
      }
  }
  @IBAction func sendTapped(_ sender: Any) {
      if (self.typeMessage.text == ""){
          self.showAlert(title: "Please type a message.", message: nil)
          return
      }
      self.performAction()
  }
  
  @IBAction func backTapped(_ sender: Any) {
      DispatchQueue.main.async {
          self.navigationController?.popToRootViewController(animated: true)
      }
  }
  @IBAction func musicTapped(_ sender: Any) {
    let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.sendMusicViewController) as! SendMusicViewController
    DispatchQueue.main.async {
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
  }
  func scrollToBottom(animated : Bool){
      guard self.messageArray.count > 0 else{ return }
      DispatchQueue.main.async {
        if self.chatTableView.numberOfRows(inSection: 0) > 0{
            self.chatTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: animated)
        }
      }
  }
  func scrollToPosition(position: Int, animated : Bool) {
      if self.messageArray.count == 0 {
          return
      }
      self.chatTableView.scrollToRow(at: IndexPath.init(row: position, section: 0), at: UITableView.ScrollPosition.top, animated: animated)
  }
  
  @objc func OpenMedia(_ sender: UIButton){
      if let userMessage = self.messageArray[sender.tag] as? SBDFileMessage{
          if userMessage.type.hasPrefix("video"){
              //Video
              if let videoURL = URL(string: userMessage.url){
                  let player = AVPlayer(url: videoURL)
                  let vc = AVPlayerViewController()
                  vc.player = player
                  present(vc, animated: true) {
                      vc.player?.play()
                  }
              }
          } else{
              //Image
              let cell = chatTableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as? SentMusicTableViewCell
              var photo = SKPhoto.photoWithImageURL(userMessage.url)
              if let downloadImage = cell?.artPhoto.image{
                  photo = SKPhoto.photoWithImage(downloadImage)
              } else{
                  photo = SKPhoto.photoWithImageURL(userMessage.url)
              }
              // 2. create PhotoBrowser Instance, and present.
              self.photoBrowser = SKPhotoBrowser(photos: [photo])
              self.photoBrowser.initializePageIndex(0)
              self.present(self.photoBrowser, animated: true, completion: nil)
              
          }
      }
      
  }
  
  func addMessage(msg: SBDBaseMessage){
      if self.messageArray.count > 0{
          self.messageArray.insert(msg, at: 0)
      } else{
          self.messageArray = [msg]
      }
      self.chatTableView.reloadData()
      self.scrollToBottom(animated: true)
  }
  
  func createNewChannel(){
      let groupName = (Globals.sharedInstance.myProfile?.displayName ?? "") + " - " + (otherUser.nickname ?? "")
      let myID = SendBirdInterface.sharedInstace.currentUser.userId
      SendBirdInterface.sharedInstace.createChannel(userIDs: [myID, self.otherUser.userId], name: groupName, img: nil, isGroup: false) { (channel, error) in
          if channel != nil{
              self.currentChannel = channel
              self.getInitialMessages()
              SendBirdInterface.sharedInstace.ignoreChannel = self.currentChannel
              
              if let members = self.currentChannel?.members as? [SBDUser]{
                  for member in members{
                      if member.userId != SendBirdInterface.sharedInstace.currentUser.userId {
                          self.isBlocked = ((member as? SBDMember)?.isBlockedByMe ?? false)
                      }
                  }
              }
            if (self.isBlocked == true) {
              self.contactName.text = self.contactNameText + "(blocked)"
            } else {
              self.contactName.text = self.contactNameText
            }
              SendBirdInterface.sharedInstace.getMutedUsers(channel: self.currentChannel) { (users, error) in
                  if users?.isEmpty == false{
                      for user in users!{
                          if user.userId != SendBirdInterface.sharedInstace.currentUser.userId {
                              
                          }
                      }
                  }
                self.isBlocked = true
                if (self.isBlocked == true) {
                  self.contactName.text = self.contactNameText + "(blocked)"
                } else {
                  self.contactName.text = self.contactNameText
                }
              }
          }
      }
  }
  
  @objc func getInitialMessages(){
      self.apiHit = true
      SendBirdInterface.sharedInstace.getMessages(channel: self.currentChannel) { (messages, query, error) in
          self.messageQuery = query
          if (messages?.count ?? 0) > 0{
              self.noData = 1
              self.apiHit = false
              self.messageArray = messages!
              self.chatTableView.reloadData()
              self.scrollToBottom(animated: false)
              
              self.currentChannel?.markAsRead()
              DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                  SendBirdInterface.sharedInstace.unreadChannels()
              })
          } else{
              self.noData = 0
              self.apiHit = true
              print(error?.localizedDescription ?? "error")
              self.chatTableView.reloadData()
          }
      }
  }
  
  func getPagedMessages(){
      self.apiHit = true
      SendBirdInterface.sharedInstace.getPaginationMessages(channel: self.currentChannel, query: self.messageQuery) { (messages, error) in
          if (messages?.count ?? 0) > 0{
              self.noData = 1
              self.apiHit = false
              
              self.messageArray = self.messageArray + messages!
              self.chatTableView.reloadData()
              
              self.currentChannel?.markAsRead()
              DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                  SendBirdInterface.sharedInstace.unreadChannels()
              })
          } else{
              print(error?.localizedDescription ?? "error")
              self.noData = 0
              self.apiHit = true
              self.chatTableView.reloadData()
          }
      }
      
  }
      
//MARK:-  UITextView Delegates
  func textViewDidChange(_ textView: UITextView) {
    
  }
  @IBAction func menuClicked(_ sender: Any) {
    let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
    let delete = UIAlertAction(title: "Delete Chat", style: .default) { (action) in
      let alert = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
      let deleteconfirm = UIAlertAction(title: "Delete Chat Room", style: .destructive) { (action) in
        self.currentChannel?.delete(completionHandler: { (_: SBDError?) in
          DispatchQueue.main.async {
              self.navigationController?.popToRootViewController(animated: true)
          }
        })
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

      }
      alert.addAction(deleteconfirm)
      alert.addAction(cancel)
      self.present(alert, animated: true, completion: nil)
    }
    menu.addAction(delete)
    if(self.isBlocked == false){
        let block = UIAlertAction(title: "Block User", style: .default) { (action) in
            self.currentChannel?.muteUser(withUserId: self.otherUser.userId, completionHandler: { (_: SBDError?) in
              self.showAlert(title: (self.otherUser.nickname! + " is blocked."), message: nil)
              self.isBlocked = true
              self.contactName.text = self.contactNameText + "(blocked)"
            })
        }
        menu.addAction(block)
    } else {
        let unblock = UIAlertAction(title: "Unblock User", style: .default) { (action) in
            self.currentChannel?.unmuteUser(withUserId: self.otherUser.userId, completionHandler: { (_: SBDError?) in
              self.showAlert(title: (self.otherUser.nickname! + " is unblocked."), message: nil)
              self.isBlocked = false
              self.contactName.text = self.contactNameText
            })
        }
        menu.addAction(unblock)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    menu.addAction(cancel)
    DispatchQueue.main.async {
        self.present(menu, animated: true, completion: nil)
    }
  }
//MARK:-  UIPopover Controller Delegate
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
      return UIModalPresentationStyle.none
  }
  
  func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
      return true
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.messageArray.count + self.noData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != self.messageArray.count else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorTableViewCell")as! IndicatorTableViewCell
            cell.indicator.startAnimating()
            return cell
        }
      
      let message = self.messageArray[indexPath.row]
      if message is SBDUserMessage {
          let userMessage = message as! SBDUserMessage
         
          let sender = userMessage.sender
          let messageType = userMessage.customType
          if ( messageType != "Music") {
              var cellID = "sentMessageCell"
              if sender?.userId == "\(Globals.sharedInstance.myProfile?.userId ?? "0")"{
                  cellID = "sentMessageCell"
              } else{
                  cellID = "receivedMessageCell"
              }
              let cell = tableView.dequeueReusableCell(withIdentifier: cellID)as! SentMessageTableViewCell
              cell.message.text = userMessage.message
              cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
              var profile = ""
              if sender?.userId == "\(Globals.sharedInstance.myProfile?.userId ?? "0")"{
                  profile = imageUrlPrefix + (Globals.sharedInstance.myProfile?.profileImage ?? "")
              } else{
                  profile = sender?.profileUrl ?? ""
              }
              cell.profilePhoto.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "fake-user"), options: [], completed: nil)
              cell.profilePhoto.contentMode = .scaleAspectFill
              
              if self.messageArray.indices.contains(indexPath.row + 1){
                  TimeConvertor.dateChanged(prevMessage: self.messageArray[indexPath.row + 1], message: message) { (show, date) in
                      if show == true{
                          cell.splitDateView.isHidden = false
                          cell.separatorViewHeight.constant = 40
                          cell.splitDate.text = date
                      } else{
                          cell.splitDateView.isHidden = true
                          cell.separatorViewHeight.constant = 0
                        cell.splitDate.text = ""
                      }
                  }
              } else{
                  let formatter = DateFormatter()
                  formatter.dateStyle = DateFormatter.Style.medium
                  let dateNS = NSDate(timeIntervalSince1970: Double(message.createdAt) / 1000.0)
                  let date = formatter.string(from: dateNS as Date)
                  cell.splitDateView.isHidden = false
                  cell.separatorViewHeight.constant = 40
                  cell.splitDate.text = date
              }
              return cell
          } else {
            let musicData = userMessage.data as String
            let jsonDecoder = JSONDecoder()
            let music = try! jsonDecoder.decode(Music.self, from: musicData.data(using: .utf8)!)
            var cellID = "sentMusicCell"
            if sender?.userId == "\(Globals.sharedInstance.myProfile?.userId ?? "0")"
            {
                cellID = "sentMusicCell"
            } else {
                cellID = "receivedMusicCell"
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID)as! SentMusicTableViewCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            

            cell.artPhoto.sd_setImage(with: URL(string: music.image!), placeholderImage: UIImage(named: "fake-submarine"), options: [], completed: nil)
            cell.artPhoto.contentMode = .scaleAspectFill
            cell.musicTitle.text = music.title
            cell.musicInfo.text = music.artist
            var profile = ""
            if sender?.userId == "\(Globals.sharedInstance.myProfile?.userId ?? "0")"{
                profile = imageUrlPrefix + (Globals.sharedInstance.myProfile?.profileImage ?? "")
            } else{
                profile = sender?.profileUrl ?? ""
            }
            cell.profilePhoto.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "fake-user"), options: [], completed: nil)
            cell.profilePhoto.contentMode = .scaleAspectFill
            
            if self.messageArray.indices.contains(indexPath.row + 1){
                TimeConvertor.dateChanged(prevMessage: self.messageArray[indexPath.row + 1], message: message) { (show, date) in
                    if show == true{
                        cell.splitDateView.isHidden = false
                        cell.separatorViewHeight.constant = 40
                        cell.splitDate.text = date
                    } else{
                        cell.splitDateView.isHidden = true
                        cell.separatorViewHeight.constant = 0
                        cell.splitDate.text = ""
                    }
                }
            }else{
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.medium
                let dateNS = NSDate(timeIntervalSince1970: Double(message.createdAt) / 1000.0)
                let date = formatter.string(from: dateNS as Date)
                cell.splitDateView.isHidden = false
                cell.separatorViewHeight.constant = 40
                cell.splitDate.text = date
            }
            
            return cell
            
          }
      }
      else if message is SBDFileMessage{
          let userMessage = message as! SBDFileMessage
          let sender = userMessage.sender
          var cellID = "sentMusicCell"
          if sender?.userId == "\(Globals.sharedInstance.myProfile?.userId ?? "0")"
          {
              cellID = "sentMusicCell"
          } else{
              cellID = "receivedMusicCell"
          }
          let cell = tableView.dequeueReusableCell(withIdentifier: cellID)as! SentMusicTableViewCell
          cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
          cell.artPhoto.sd_setImage(with: URL(string: userMessage.url), placeholderImage: UIImage(named: "fake-submarine"), options: [], completed: nil)
          var profile = ""
          if sender?.userId == "\(Globals.sharedInstance.myProfile?.userId ?? "0")"{
              profile = imageUrlPrefix + (Globals.sharedInstance.myProfile?.profileImage ?? "")
          } else{
              profile = sender?.profileUrl ?? ""
          }
          cell.profilePhoto.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "fake-user"), options: [], completed: nil)
          cell.profilePhoto.contentMode = .scaleAspectFill
          if self.messageArray.indices.contains(indexPath.row + 1){
              TimeConvertor.dateChanged(prevMessage: self.messageArray[indexPath.row + 1], message: message) { (show, date) in
                  if show == true{
                      cell.splitDateView.isHidden = false
                      cell.separatorViewHeight.constant = 40
                      cell.splitDate.text = date
                  } else{
                      cell.splitDateView.isHidden = true
                      cell.separatorViewHeight.constant = 0
                      cell.splitDate.text = ""
                  }
              }
          }else{
              let formatter = DateFormatter()
              formatter.dateStyle = DateFormatter.Style.medium
              let dateNS = NSDate(timeIntervalSince1970: Double(message.createdAt) / 1000.0)
              let date = formatter.string(from: dateNS as Date)
              cell.splitDateView.isHidden = false
              cell.separatorViewHeight.constant = 40
              cell.splitDate.text = date
          }
          
          return cell
      } else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell")as! ReceivedMessageTableViewCell
          cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
          cell.isHidden = true
          return cell
      }
    }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      guard indexPath.row != self.messageArray.count else{
          return 60
      }
      return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      if self.apiHit == false && indexPath.row == self.messageArray.count && self.messageArray.count > 0{
          self.getPagedMessages()
      }
  }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let message = self.messageArray[indexPath.row]
      if message is SBDUserMessage {
          let userMessage = message as! SBDUserMessage
          let messageType = userMessage.customType
          if ( messageType == "Music") {
            let musicData = userMessage.data as String
            let jsonDecoder = JSONDecoder()
            let music = try! jsonDecoder.decode(Music.self, from: musicData.data(using: .utf8)!)
            self.play(music: music)
          }
        
      }
    }
  func play(music: Music?){
      guard let music = music else { return }
      MusicPlayer.play(music: music)
  }
}


extension ChatViewController: UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    func alertcontroller(_ sender: UIButton){
        
        let alertcontroller = UIAlertController.init(title: "Choose Option" , message: nil, preferredStyle: .actionSheet)
        alertcontroller.view.tintColor = .darkGray
        let cancelAction = UIAlertAction(title: "Take Picture From Gallery", style: .default)
        { action in
            self.imgPicker.sourceType = .photoLibrary
            self.imgPicker.delegate = self
            self.imgPicker.mediaTypes = [String(kUTTypeImage)]
            DispatchQueue.main.async
                {
                    self.present(self.imgPicker, animated: true, completion: nil)
                    
            }
        }
        let OKAction = UIAlertAction(title: "Take Picture From Camera" , style: .default)
        {
            action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                self.imgPicker.delegate = self
                self.imgPicker.sourceType = UIImagePickerController.SourceType.camera;
                DispatchQueue.main.async
                {
                    self.present(self.imgPicker, animated: true, completion: nil)
                }
            }
        }
        alertcontroller.addAction(OKAction)
        alertcontroller.addAction(cancelAction)
        alertcontroller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alertcontroller.popoverPresentationController {
            popoverController.sourceView = sender as UIView
            popoverController.sourceRect = sender.bounds
        }
        self.present(alertcontroller, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imgPicker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            picker.dismiss(animated: false, completion: {
                if let imageData = chosenImage.jpegData(compressionQuality: 0){
                    SendBirdInterface.sharedInstace.sendImage(channel: self.currentChannel, fileData: imageData) { (message, error) in
                        if message != nil{
                            self.addMessage(msg: message!)
                        }
                    }
                    
                }
            })
        } else if info[UIImagePickerController.InfoKey.mediaType] as? String == "public.movie"{
            if let url = info[UIImagePickerController.InfoKey.mediaURL]as? URL{
                do {
                    let VideoData = try Data(contentsOf: url as URL)
                    picker.dismiss(animated: false, completion: {
                        SendBirdInterface.sharedInstace.sendVideo(channel: self.currentChannel, url: url, fileData: VideoData) { (message, error) in
                            if message != nil{
                                self.addMessage(msg: message!)
                            }
                        }
                    })
                } catch {
                    print("Unable to load data: \(error)")
                    picker.dismiss(animated: false, completion: nil)
                }
            }
            picker.dismiss(animated: false, completion: nil)
        } else{
            picker.dismiss(animated: false, completion: nil)
        }
    }
}
extension ChatViewController : SBDChannelDelegate{
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard sender == self.currentChannel else {
            return
        }
        self.currentChannel?.markAsRead()
        if self.currentChannel != sender as? SBDGroupChannel{
            return
        }
        
        if message is SBDUserMessage {
            // Do something when the received message is a UserMessage.
            self.addMessage(msg: message)
        }
        else if message is SBDFileMessage {
            self.addMessage(msg: message)
            // Do something when the received message is a FileMessage.
        }
        else if message is SBDAdminMessage {
            // Do something when the received message is an AdminMessage.
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        print("update")
    }
    
    @objc func updateUser(){
        SendBirdInterface.sharedInstace.getUserByID(userID: self.otherUser.userId) { (user, error) in
            if user != nil{
                self.chatTableView.reloadData()
            }
        }
    }
    
    func CheckUserBlocked()
    {
        // In case of retrieving certain blocked users using the UserID filter
        let blockedUserListQuery = SBDMain.createBlockedUserListQuery()
        blockedUserListQuery?.userIdsFilter = [self.otherUser.userId]
        blockedUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            guard error == nil else {       // Error.
                return
            }
            print("blcoked users---\(String(describing: users))")
            if (users?.count)! > 0
            {
                self.isblocked = true
            }
            else
            {
                self.isblocked = false
            }
        })
    }
}
extension ChatViewController : sendMusicDelegate {
  func sendMusic(music: Music) {
      let params = SBDUserMessageParams(message: "Sent Song!")
      params?.customType = "Music"
      if (music.contentId != "") {
          params?.message = ("Song - " + music.title!)
          let jsonEncoder = JSONEncoder()
          let jsonData = try! jsonEncoder.encode(music)
          let json = String(data: jsonData, encoding: .utf8)
          params?.data = json!
          self.currentChannel!.sendUserMessage(with: params!, completionHandler: { (userMessage, error) in
              
              if userMessage != nil{
                  self.addMessage(msg: userMessage!)
              }
              if (error != nil){
                self.showAlert(title: ("You are not allowed to send song by " + self.otherUser.nickname! + "."), message: nil)
              } else {
                  let usersRef = Firestore.firestore().collection("users_table").document(self.otherUser.userId)
                  usersRef.getDocument { (document, error) in
                      if let document = document, document.exists {
                          let token = document.get("fcmToken") as! String
                          print("Document data: \(token)")
                          let sender = PushNotificationSender()
                          sender.sendPushNotification(to: token , title: Globals.sharedInstance.myProfile!.displayName!, body: ("Song - " + music.title!))
                      } else {
                          print("Document does not exist")
                      }
                  }
              }
          })
        
      }
    }
}
