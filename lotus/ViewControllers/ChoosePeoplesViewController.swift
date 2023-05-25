//
//  ChoosePeoplesViewController.swift
//  lotus
//
//  Created by admin on 5/14/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit
import PKHUD
import SendBirdSDK
import SwiftyJSON
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class ChoosePeoplesViewController: UIViewController, NotificationTableViewHeaderDelegate {

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
  
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var viewHeader: NotificationsTableViewHeader!
  @IBOutlet weak var tableView: UITableView!
  var allUsers: [User] = []
  var users: [User] = []
  var notifications: [LotusNotification] = []
  var parties: [Party] = []
  var music : Music!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: TableViewCells.userTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.userTableViewCell)
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
    
        viewHeader.searchView.searchTextField.placeholder = "SEARCH USERS"
        viewHeader.headerTitle.text = "Send Song"
        viewHeader.delegate = self
        
        sendButton.layer.cornerRadius = 6.0
        sendButton.layer.masksToBounds = true
    
        // Do any additional setup after loading the view.
        SendBirdInterface.sharedInstace.connectWith(USER_ID: Globals.sharedInstance.myProfile!.userId) { (result, error) in }
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        callNetworkModel()
    }
    
  @objc func dismissKeyboard() {
      //Causes the view (or one of its embedded text fields) to resign the first responder status.
      view.endEditing(true)
  }
  override func viewWillDisappear(_ animated: Bool) {
      NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
      NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
      
  }
  func callNetworkModel(){
      let group = DispatchGroup()
      group.enter()
      AccountServices.getFollowing(userId: Globals.sharedInstance.myProfile!.userId) { (following, error) in
          if let f = following, let arr1 = f.content {
            AccountServices.getFollowers(userId: Globals.sharedInstance.myProfile!.userId) { (followers, error) in
                if let f = followers, var arr2 = f.content {
                  if(arr1.count > 0) {
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
  
  func createNewChannel(otherUserName:String, otherUserId:String, phtotoUrl:String, isLast:String)
  {
      let groupName = (Globals.sharedInstance.myProfile!.displayName ?? "") + " - " + (otherUserName)
      let myID = Globals.sharedInstance.myProfile!.userId
      SendBirdInterface.sharedInstace.createChannel(userIDs: [myID, otherUserId], name: groupName, img: nil, isGroup: false) { (channel, error) in
          if error == nil
          {
            DispatchQueue.main.async {
                
                let params = SBDUserMessageParams(message: "Sent Song!")
                params?.customType = "Music"
                if (self.music.contentId != "") {
                    params?.message = ("Song - " + self.music.title!)
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try! jsonEncoder.encode(self.music)
                    let json = String(data: jsonData, encoding: .utf8)
                    params?.data = json!
                    channel!.sendUserMessage(with: params!, completionHandler: { (userMessage, error) in
                      
                        if (error != nil){
                          self.showAlert(title: ("You are not allowed to send song by " + otherUserName + "."), message: nil)
                        } else {
                            let usersRef = Firestore.firestore().collection("users_table").document(otherUserId)
                            usersRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let token = document.get("fcmToken") as! String
                                    print("Document data: \(token)")
                                    let sender = PushNotificationSender()
                                    sender.sendPushNotification(to: token , title: Globals.sharedInstance.myProfile?.displayName ?? "", body: ("Song - " + self.music.title!))
                                } else {
                                    print("Document does not exist")
                                }
                            }
                        }
                        if(isLast == "last"){
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                  
                }
            }

          }
          else
          {
              print("error--createNewChannel--\(String(describing: error?.localizedDescription))")
          }
      }
  }
  
  @IBAction func sendSongClicked(_ sender: Any) {

    var selectedCount = 0
    for x in 0..<users.count{
        if (users[x].bio == "selected") {
          selectedCount += 1
        }
    }
    if selectedCount == 0 {
        self.showAlert(title: "Please select users to send song.", message: nil)
    } else {
        var count1 = 0
        for x in 0..<users.count{
          if (users[x].bio == "selected") {
                count1 += 1
                DispatchQueue.main.async {
                    if(count1 == selectedCount){
                      self.createNewChannel(otherUserName: ((self.users[x].firstName ?? "") + " " + (self.users[x].lastName ?? "")) , otherUserId: self.users[x].id, phtotoUrl: self.users[x].image ?? "",isLast: "last")
                    } else {
                      self.createNewChannel(otherUserName: ((self.users[x].firstName ?? "") + " " + (self.users[x].lastName ?? "")) , otherUserId: self.users[x].id, phtotoUrl: self.users[x].image ?? "",isLast: "nolast")
                    }
                  }
              }
        }
    }
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
extension ChoosePeoplesViewController : UITableViewDelegate, UITableViewDataSource {
    
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
                cell.selectionStatus.isHidden = false
                cell.selectionStatus.isEnabled = true
                if (users[indexPath.row].bio == "selected") {
                  cell.selectionStatus.isSelected = true
                } else {
                  cell.selectionStatus.isSelected = false
                }
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
        let cell = self.tableView?.cellForRow(at: indexPath) as? UserTableViewCell
        if (users[indexPath.row].bio == "selected") {
          cell?.selectionStatus.isSelected = false
          users[indexPath.row].bio = "noselected"
        } else {
          users[indexPath.row].bio = "selected"
          cell?.selectionStatus.isSelected = true
        }
    }
}
