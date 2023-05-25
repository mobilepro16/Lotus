//
//  CreateChannelViewController.swift
//  lotus
//
//  Created by admin on 4/9/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit
import PKHUD
import SendBirdSDK
import SwiftyJSON

class CreateChannelViewController: UIViewController, NotificationTableViewHeaderDelegate {
  func headerTabSelected(dataType: NotificationsTableData) {
      self.users = self.allUsers
      tableView.reloadData()
  }
  
  func headerSearchFor(term: String) {
    AccountServices.searchUsers(term: term) { (users, error) in
        if let u = users?.content {
            self.users = u
        } else {
            self.users = []
        }
        self.tableView.reloadData()
    }
  }
  

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var viewHeader: NotificationsTableViewHeader!
  
  var allUsers: [User] = []
  var users: [User] = []
  var notifications: [LotusNotification] = []
  var parties: [Party] = []
  
  override func viewDidLoad() {
      super.viewDidLoad()
      tableView.register(UINib(nibName: TableViewCells.userTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.userTableViewCell)
      tableView.delegate = self
      tableView.dataSource = self
  
      viewHeader.searchView.searchTextField.placeholder = "SEARCH USERS"
      viewHeader.headerTitle.text = "New Chat"
      viewHeader.delegate = self
  
       //Looks for single or multiple taps.
       let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
       tap.cancelsTouchesInView = false
       view.addGestureRecognizer(tap)
       // Do any additional setup after loading the view.
  }
  @objc func dismissKeyboard() {
      //Causes the view (or one of its embedded text fields) to resign the first responder status.
      view.endEditing(true)
  }
  override func viewWillDisappear(_ animated: Bool) {
      NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
      navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
      navigationController?.setNavigationBarHidden(true, animated: animated)
      NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
      callNetworkModel()
  }
  func callNetworkModel(){
      let group = DispatchGroup()
      
      group.enter()
      AccountServices.getFollowing(userId: Globals.sharedInstance.myProfile!.userId) { (following, error) in
          if let f = following, let arr1 = f.content {
            AccountServices.getFollowers(userId: Globals.sharedInstance.myProfile!.userId) { (followers, error) in
                if let f = followers, var arr2 = f.content {
                  if (arr1.count > 0){
                    for i in 0...arr1.count - 1 {
                      if(arr2.count > 0){
                        for j in 0...arr2.count - 1 {
                          if(arr1[i].id == arr2[j].id) {
                            arr2.remove(at: j)
                            break
                          }
                        }
                      }
                    }
                  }
                  let arr = arr1 + arr2
                  
                  self.users = arr
                  self.allUsers = arr
                group.leave()
                }
            }
          }
      }
      group.notify(queue: .main) {
          self.tableView.reloadData()
      }
  }
  
  func createNewChannel(otherUserName:String, otherUserId:String, phtotoUrl:String)
  {
    SendBirdInterface.sharedInstace.connectWith(USER_ID: "\(Globals.sharedInstance.myProfile!.userId )" ) { (result, error) in
          let groupName = (Globals.sharedInstance.myProfile!.displayName ?? "") + " - " + (otherUserName)
          let myID = SendBirdInterface.sharedInstace.currentUser.userId
          SendBirdInterface.sharedInstace.createChannel(userIDs: [myID, otherUserId], name: groupName, img: nil, isGroup: false) { (channel, error) in
              if error == nil
              {
                  let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.chatViewController) as! ChatViewController
                  vc.modalPresentationStyle = .fullScreen
                  let groupchannel = channel
                  if groupchannel?.data == "group"
                  {
                      vc.isGroup = true
                  }
                  vc.currentChannel = channel
                   vc.isComeFriend = true
                   vc.otherUserName = otherUserName
                  vc.contactNameText = otherUserName
                  vc.contactUsernameText = otherUserName
                  vc.contactPhotoUrl = imageUrlPrefix + phtotoUrl
                  
                  SendBirdInterface.sharedInstace.getUserByID(userID: otherUserId) { (user, error) in
                      if user != nil{
                          vc.otherUser = user!
                          DispatchQueue.main.async {
                              self.navigationController?.pushViewController(vc, animated: true)
                          }
                      }
                  }
              }
              else
              {
                  print("error--createNewChannel--\(String(describing: error?.localizedDescription))")
              }
          }
      }
  }
}
extension CreateChannelViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return users.count == 0 ? 1 : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if(self.users.count > 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.userTableViewCell, for: indexPath) as! UserTableViewCell
                cell.setData(user: users[indexPath.row])
                return cell
            } else {
                let cell = UITableViewCell()
                cell.backgroundColor = UIColor.lotusBackground
                cell.textLabel?.text = "No users found."
                cell.textLabel?.textColor = .white
                return cell
            }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if(self.users.count > 0){
        self.createNewChannel(otherUserName: users[indexPath.row].firstName! + " " + users[indexPath.row].lastName! , otherUserId: users[indexPath.row].id, phtotoUrl: users[indexPath.row].image ?? "")
      }
    }
}
