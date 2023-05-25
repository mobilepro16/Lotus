//
//  ViewController.swift
//  lotus
//
//  Created by Robert Grube on 1/2/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {
    
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var tableView: UITableView!
    
    private var firstDataKickoff = false
    private var currentPage = 0
    private var totalPages = 1
    private var pageSize = 20
    
    var data : [TimelineHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        headerView.delegate = self
        tableView.register(UINib(nibName: TableViewCells.timelineMusicTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.timelineMusicTableViewCell)
        tableView.register(UINib(nibName: TableViewCells.timelineTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.timelineTableViewCell)
        
        
        if let token = Token.load() {
            firstDataKickoff = true
            token.print()
//            ContentServices.getRecentlyPlayed { (music, error) in
//                self.refreshData()
//            }
        } else {
            navigateToLogin()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(timelineTapped(_:)), name: Notification.Name(rawValue: "timelineTapped"), object: nil)
    }
    @objc func timelineTapped(_ notification: Notification) {
        self.navigationController?.popToRootViewController(animated: true)
        self.refreshData()
        if (self.tableView.numberOfRows(inSection: 0) > 0){
          self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(firstDataKickoff == false){
            firstDataKickoff = true
            refreshData()
        }
    }
    
    @objc func refreshData(){
        currentPage = 0
        callNetworkModel()
    }
    
    func callNetworkModel(){
        print("CALLING NETWORK MODEL")
        print("CURRENT PAGE: \(currentPage), TOTAL PAGES: \(totalPages)")
        
        guard currentPage < totalPages else { return }
        
        if(currentPage != 0 && currentPage * pageSize != data.count){
            print("TRYING TO GET DATA TOO SOON")
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        
        print("MAKING SERVICE CALL")
        
        
        ContentServices.getTimeline(page: currentPage, pageSize: pageSize) { (pagedObj, error) in
            self.tableView.refreshControl?.endRefreshing()
            
            if let pagedObj = pagedObj, let array = pagedObj.content, let total = pagedObj.totalPages, let pageNum = pagedObj.number, let pageSize = pagedObj.size {
                self.totalPages = total
                if(self.currentPage == 0){
                    self.currentPage += 1
                    self.data = array
                } else {
                    if(self.data.count == (pageNum * pageSize)){
                        self.currentPage += 1
                        self.data.append(contentsOf: array)
                    } else {
                        print("DON'T NEED THIS DATA")
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(noPlayerSelected), name: .noMusicPlayerSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartPlayingMusic), name: .didStartPlayingMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToLogin), name: .navigateToLogin, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .noMusicPlayerSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didStartPlayingMusic, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigateToLogin, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func navigateToLogin(){
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.loginViewController) as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension TimelineViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.timelineTableViewCell, for: indexPath) as! TimelineTableViewCell
        
        cell.delegate = self
        if(indexPath.row < data.count){
            cell.setData(history: data[indexPath.row])
        } else {
            callNetworkModel()
            let cell = UITableViewCell()
            cell.backgroundColor = .lotusBackground
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension TimelineViewController : TimelineTableViewCellDelegate {
    func cellUserClicked(history: TimelineHistory) {
        guard let uid = history.user?.id else { return }
        AccountServices.getProfile(userId: uid) { (profile, error) in
            guard let profile = profile else { return }
            let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
            vc.profile = profile
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func cellPlayClicked(history: TimelineHistory) {
        if let music = history.history?.music {
            MusicPlayer.play(music: music)
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
                  self.refreshData()
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
                        self.refreshData()
                    }
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
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
                          self.refreshData()
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
