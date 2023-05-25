//
//  FollowListViewController.swift
//  lotus
//
//  Created by Robert Grube on 2/14/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Firebase

class FollowListViewController: UIViewController, TableHeaderSearchViewDelegate {
  
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchView: TableHeaderSearchView!
    var data : [User] = []
    var allData : [User] = []
    var following: [User]?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.delegate = self
        titleLabel.text = title
        tableView.register(UINib(nibName: TableViewCells.userTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.userTableViewCell)
        
    }
    func getProfileData(){
        let group = DispatchGroup()
        group.enter()
        guard let me = Globals.sharedInstance.myProfile else { return }
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
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.allData = self.data
        self.getProfileData()
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func headerSearchFor(term: String) {
        if (term == ""){
            self.allData = self.data
            self.tableView.reloadData()
        } else {
            let sword = term.lowercased()
            self.allData = self.data.filter{ $0.displayName!.lowercased().contains(sword) || $0.firstName!.lowercased().contains(sword) || $0.lastName!.lowercased().contains(sword) }
            self.tableView.reloadData()
        }
    }
    
    func headerSearchDidBecomeActive() {
      
    }
    
    func headerCancelButtonClick() {
        self.allData = self.data
        self.tableView.reloadData()
    }
}

extension FollowListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.userTableViewCell, for: indexPath) as! UserTableViewCell
        cell.setData(user: allData[indexPath.row])
        cell.followButton.isHidden = false
        if(self.following != nil){
            let followingThisPerson = self.following!.filter { $0.id == allData[indexPath.row].id}
            if(followingThisPerson.count > 0) {
                cell.followButton.setTitle("FOLLOWING", for: .normal)
            } else {
                cell.followButton.setTitle("FOLLOW", for: .normal)
            }
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = allData[indexPath.row]
        AccountServices.getProfile(userId: user.id) { (profile, error) in
            guard let profile = profile else { return }
            let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
            vc.profile = profile
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
extension FollowListViewController : UserTableViewCellDelegate {
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
