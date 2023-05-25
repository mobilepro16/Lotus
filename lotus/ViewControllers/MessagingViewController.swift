//
//  MessagingViewController.swift
//  lotus
//
//  Created by Robert Grube on 2/26/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import SendBirdSDK
import SwiftyJSON

class MessagingViewController: UIViewController {
  
    
    @IBOutlet var headerView: HeaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeader: MessageTableViewHeader!
  
    var isComefromGroup = false
    var allUsers = [SBDGroupChannel]()
    var allSearchUsers = [SBDGroupChannel]()
    var query : SBDGroupChannelListQuery?
    var noData = 1
    var apiHit = false
    var isComefromSide = false
  
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.delegate = self
     
        tableView.register(UINib(nibName: TableViewCells.messageTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.messageTableViewCell)
        tableView.register(UINib(nibName: TableViewCells.notificationTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.notificationTableViewCell)
      
        tableViewHeader.searchView.searchTextField.placeholder = "SEARCH USERS"
        tableViewHeader.headerTitle.text = "Messages"
        tableViewHeader.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
      
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
      
        NotificationCenter.default.addObserver(self, selector: #selector(chatTapped(_:)), name: Notification.Name(rawValue: "chatTapped"), object: nil)
    }
    @objc func chatTapped(_ notification: Notification) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SendBirdInterface.sharedInstace.connectWith(USER_ID: Globals.sharedInstance.myProfile!.userId) { (result, error) in
            self.getUsers()
        }
        SendBirdInterface.sharedInstace.unreadChannels()
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.Connect), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        //Remove observer
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
   @objc func Connect(){
      SendBirdInterface.sharedInstace.connectWith(USER_ID: Globals.sharedInstance.myProfile!.userId) { (result, error) in
              self.getUsers()
          }
    }
  
    @objc func getUsers(){
        self.apiHit = true
        SendBirdInterface.sharedInstace.getChannels { (channels, query ,  error) in
            self.query = query
            if  (channels?.count ?? 0) > 0{
                self.apiHit = false
                self.noData = 1
                self.allUsers = channels!
                self.allSearchUsers = self.allUsers
                self.tableView.reloadData()
                
            } else{
                self.apiHit = true
                self.noData = 0
                self.allUsers.removeAll()
                self.allSearchUsers = self.allUsers
                self.tableView.reloadData()
            }
        }
    }
    func getPagedUsers(){
        self.apiHit = true
        SendBirdInterface.sharedInstace.getNextChannels(query: self.query) { (channels, error) in
            if  (channels?.count ?? 0) > 0{
                self.apiHit = false
                self.noData = 1
                self.allUsers = (self.allUsers + channels!)
                self.allSearchUsers = self.allUsers
                self.tableView.reloadData()
            } else{
                self.noData = 0
                self.apiHit = true
                self.tableView.reloadData()
            }
        }
    }
}
extension MessagingViewController : SBDChannelDelegate {
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        SendBirdInterface.sharedInstace.unreadChannels()
        guard sender as? SBDGroupChannel != nil else{
            return
        }
        if let index = self.allSearchUsers.firstIndex(of: sender as! SBDGroupChannel ){
            self.allSearchUsers[index] = sender as! SBDGroupChannel
            let indexPath = IndexPath.init(row: index, section: 0)
            if self.tableView.cellForRow(at: indexPath) != nil{
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        } else{
            self.getUsers()
        }
    }
}

extension MessagingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.allSearchUsers.count + self.noData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      guard indexPath.row != self.allSearchUsers.count else{
          let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorTableViewCell")as! IndicatorTableViewCell
          cell.indicator.startAnimating()
          return cell
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.messageTableViewCell, for: indexPath) as! MessageTableViewCell
      cell.selectionStyle = .none
      let data = self.allSearchUsers[indexPath.row]
      
      if let members = data.members as? [SBDUser]{
          for member in members{
              if member.userId != SendBirdInterface.sharedInstace.currentUser.userId {
                  let image = member.profileUrl ?? ""
                  if members.count > 2 {
                      cell.profilePhoto.sd_setImage(with: URL(string: "\(data.coverUrl!)"), placeholderImage: UIImage(named: "fake-user"), options: [], completed: nil)
                      cell.profileName.text = data.name
                      cell.profileId.text = "@" + member.nickname!
                  } else {
                    if (image != ""){
                      cell.profilePhoto.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "fake-user"), options: [], completed: nil)
                    } else{
                      cell.profilePhoto.image = UIImage(named: "fake-user")
                    }
                      cell.profileName.text = member.nickname ?? "Not Active"
                      cell.profileId.text = "@" + member.nickname!
                  }
                  print ("member.metaData\(String(describing: member.metaData))")

              }
          }
      }
      
      let messageData = data.lastMessage
      
      if let lastMessage = messageData as? SBDUserMessage{
          cell.lasttime.text = TimeConvertor.convertToTime(dateInt: lastMessage.createdAt)
          cell.lastMessage.text = lastMessage.message
      } else if messageData == nil {
          cell.lasttime.text = " "
          cell.lastMessage.text = " "
      } else{
          cell.lasttime.text = TimeConvertor.convertToTime(dateInt: messageData?.createdAt ?? 0)
          cell.lastMessage.text = "image"
      }

      let unreadCount = Int(data.unreadMessageCount)
      if unreadCount == 0{
          cell.unReadCountBack.isHidden = true
      } else if unreadCount > 99{
          cell.unReadCountBack.isHidden = false
      } else{
          cell.unReadCountBack.isHidden = false
      }

      return cell
      
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.apiHit == false && indexPath.row == self.allSearchUsers.count && self.allSearchUsers.count > 0{
            self.getPagedUsers()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.chatViewController) as! ChatViewController
      vc.modalPresentationStyle = .fullScreen
      let data = self.allSearchUsers[indexPath.row]
       if data.data != "group"{
           if let members = data.members as? [SBDUser]{
               for member in members{
                   if member.userId != SendBirdInterface.sharedInstace.currentUser.userId {
                       vc.otherUser = member
                   }
               }
           }
       } else{
           vc.isGroup = true
       }
       vc.currentChannel = data
      vc.contactNameText = vc.otherUser.nickname ?? "Not Active"
      vc.contactUsernameText = vc.otherUser.nickname ?? "Not Active"
      vc.contactPhotoUrl = vc.otherUser.profileUrl ?? ""
      DispatchQueue.main.async {
          self.navigationController?.pushViewController(vc, animated: true)
      }
    }
}
extension MessagingViewController : MessageTableViewHeaderDelegate {
 
    func headerSearchDidBecomeActive() {
        allSearchUsers = allUsers
        self.tableView.reloadData()
    }
    func createChannel() {
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.createChannelViewController) as! CreateChannelViewController
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func headerSearchFor(term: String) {
        let myID = SendBirdInterface.sharedInstace.currentUser.userId
        let text = term.lowercased()
        if text.isEmpty == false{
            let data = allUsers.filter({(($0.data != "group") && (($0.members as? [SBDMember])?.filter({$0.userId != myID}).first?.nickname?.lowercased().contains(text) == true)) == true || (($0.data == "group") && ($0.name).lowercased().contains(text) == true) == true})
            allSearchUsers = data
        } else{
            allSearchUsers = allUsers
        }
        self.tableView.reloadData()
    }
}
extension MessagingViewController : UITextFieldDelegate
{
    @objc func textFieldDidChange(_ textField: UITextField) {
        let myID = SendBirdInterface.sharedInstace.currentUser.userId
        let text = textField.text?.lowercased() ?? ""
        
        if textField.text?.isEmpty == false{
            
            let data = allUsers.filter({(($0.data != "group") && (($0.members as? [SBDMember])?.filter({$0.userId != myID}).first?.nickname?.lowercased().contains(text) == true)) == true || (($0.data == "group") && ($0.name).lowercased().contains(text) == true) == true})
            
            allSearchUsers = data
        } else{
            allSearchUsers = allUsers
        }
        self.tableView.reloadData()
    }
    
}
