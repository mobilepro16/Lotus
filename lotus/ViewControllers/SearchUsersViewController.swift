//
//  SearchUsersViewController.swift
//  lotus
//
//  Created by Robert Grube on 2/14/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import PKHUD
import Firebase

class SearchUsersViewController: UIViewController {

    @IBOutlet var headerView: HeaderView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: NotificationsTableViewHeader!
    
    var allUsers: [User] = []
    var users: [User] = []
    var notifications: [LotusNotification] = []
    var parties: [Party] = []
    var following: [User]?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.delegate = self
        tableView.register(UINib(nibName: TableViewCells.userTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.userTableViewCell)
        tableView.register(UINib(nibName: TableViewCells.notificationTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.notificationTableViewCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableViewHeader.searchView.searchTextField.placeholder = "SEARCH USERS"
        tableViewHeader.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
      
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

      NotificationCenter.default.addObserver(self, selector: #selector(notificationTapped(_:)), name: Notification.Name(rawValue: "notificationTapped"), object: nil)
  }
  func getProfileData(){
      guard let me = Globals.sharedInstance.myProfile else { return }
      AccountServices.getFollowing(userId: me.userId) { (following, error) in
          if let f = following, let arr = f.content {
              self.following = arr
          }
          self.tableView.reloadData()
      }
  }
  @objc func notificationTapped(_ notification: Notification) {
      self.navigationController?.popToRootViewController(animated: true)
      tableViewHeader.selectedDataType = .notifications
      self.tableView.reloadData()
      if(self.tableView.numberOfRows(inSection: 0) > 0){
          self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
      }
  }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func callNetworkModel(){
        let group = DispatchGroup()
        group.enter()
        AccountServices.getNotifications(page: 0, pageSize: 100) { (pagedObj, error) in
          if let pagedObj = pagedObj, let array = pagedObj.content, let _ = Globals.sharedInstance.myProfile {
                self.notifications = array
                self.notifications = self.notifications.sorted(by: { (n1, n2) -> Bool in
                    n1.createdAt ?? Date() > n2.createdAt ?? Date()
                })
                self.notifications = self.notifications.filter { Date().interval(ofComponent: .day, fromDate: $0.createdAt ?? Date()) < 10 }
            }
            group.leave()
        }
      
        guard let me = Globals.sharedInstance.myProfile else { return }
        group.enter()
        AccountServices.getFollowing(userId: me.userId) { (following, error) in
            if let f = following, let arr = f.content {
                self.following = arr
            }
            group.leave()
        }
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .noMusicPlayerSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didStartPlayingMusic, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noPlayerSelected), name: .noMusicPlayerSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartPlayingMusic), name: .didStartPlayingMusic, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        callNetworkModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AccountServices.readNotifications { (data) in
            print("NOTIFICATIONS MARKED AS READ")
        }
    }
}

extension SearchUsersViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewHeader.selectedDataType {
        case .notifications:
            return notifications.count
        case .parties:
            return parties.count
        case .users:
            return users.count == 0 ? 1 : users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewHeader.selectedDataType {
        case .notifications:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.notificationTableViewCell, for: indexPath) as! NotificationTableViewCell
            cell.setData(notification: notifications[indexPath.row])
            if ( self.following != nil ){
                let followingThisPerson = self.following!.filter { $0.id == notifications[indexPath.row].fromUser?.id }
                if(followingThisPerson.count > 0) {
                  cell.followButton.setTitle("FOLLOWING", for: .normal)
                } else {
                  cell.followButton.setTitle("FOLLOW", for: .normal)
                }
            }
            cell.delegate = self
            return cell
        case .parties:
            return UITableViewCell()
        case .users:
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableViewHeader.selectedDataType == .users){
            if(users.count == 0){ return }
            let user = users[indexPath.row]
            AccountServices.getProfile(userId: user.id) { (profile, error) in
                guard let profile = profile else { return }
                let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
                vc.profile = profile
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if (tableViewHeader.selectedDataType == .notifications){
            let notification = notifications[indexPath.row]
            if(notification.type == .like || notification.type == .comment){
                guard let hid = notification.historyId else { return }
                ContentServices.getHistory(historyId: hid) { (history, error) in
                    guard let history = history, let user = Globals.sharedInstance.myProfile else { return }
                    if let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.historyViewController) as? HistoryViewController {
                        vc.history = history
                        vc.user = user.asUser()
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            } else {
                AccountServices.getProfile(userId: notification.fromUser!.id) { (profile, error) in
                      guard let profile = profile else { return }
                      let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
                      vc.profile = profile
                      DispatchQueue.main.async {
                          self.navigationController?.pushViewController(vc, animated: true)
                      }
                  }
            }
          
        }
    }
}

extension SearchUsersViewController : NotificationTableViewHeaderDelegate {
    func headerTabSelected(dataType: NotificationsTableData) {
        if(dataType == .users){
            self.users = self.allUsers
        }
        tableView.reloadData()
    }
    
    func headerSearchDidBecomeActive() {
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
}
extension SearchUsersViewController : NotificationTableViewCellDelegate {
  func albumTapped(notification: LotusNotification) {
      guard let hid = notification.historyId else { return }
      ContentServices.getHistory(historyId: hid) { (history, error) in
          guard let history = history else { return }
          if let music = history.music {
              MusicPlayer.play(music: music)
          }
      }
  }
  
  func profileTapped(userId: String) {
      AccountServices.getProfile(userId: userId) { (profile, error) in
          guard let profile = profile else { return }
          let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
          vc.profile = profile
          DispatchQueue.main.async {
              self.navigationController?.pushViewController(vc, animated: true)
          }
      }
  }
  func menuClicked(notification: LotusNotification) {
      let alert = UIAlertController(title: "Menu", message: "", preferredStyle: .actionSheet)
      let delete = UIAlertAction(title: "Remove notification", style: .destructive) { (action) in
        AccountServices.deleteNotification(notificationId: notification.id) { (data) in
              if let idx = self.notifications.firstIndex(of: notification){
                  if(self.notifications.count > 1){
                      self.notifications.remove(at: idx)
                      self.tableView.deleteRows(at: [IndexPath(item: idx, section: 0)], with: .automatic)
                  }
              }
          }
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
      }
      alert.addAction(delete)
      alert.addAction(cancel)
      self.present(alert, animated: true, completion: nil)
  }
  
  func followTapped(userId: String) {
    AccountServices.follow(userId: userId) { (data) in
        self.getProfileData()
        let usersRef = Firestore.firestore().collection("users_table").document(userId)
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
  
  func unfollowTapped(userId: String) {
    AccountServices.unfollow(userId: userId) { (data) in
        self.getProfileData()
        
    }
  }
}
extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
}
