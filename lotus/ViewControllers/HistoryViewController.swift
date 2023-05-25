//
//  HistoryViewController.swift
//  lotus
//
//  Created by Robert Grube on 3/12/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet var historyView: HistoryView!
    @IBOutlet var tableView: UITableView!
    
    var history: UserHistory!
    var user: User!
    
    var comments : [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyView.setData(history: history, user: user)
        historyView.delegate = self

        tableView.register(UINib(nibName: TableViewCells.historyCommentTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.historyCommentTableViewCell)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(callNetworkModel), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        callNetworkModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
  @IBAction func backClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @objc func callNetworkModel(){
        ContentServices.getComments(historyId: history.id) { (comments, error) in
            self.tableView.refreshControl?.endRefreshing()
            if let comments = comments, let array = comments.content{
                self.comments = array
                self.tableView.reloadData()
            }
        }
    }
}

extension HistoryViewController : HistoryViewDelegate {
    func historyMenuClicked(historyView: HistoryView) {
        guard var me = Globals.sharedInstance.myProfile else { return }
        let menu = UIAlertController(title: "Menu", message: historyView.history.music?.title ?? "", preferredStyle: .actionSheet)
        
        if let music = historyView.history.music{
            
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
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menu.addAction(cancel)
        DispatchQueue.main.async {
            self.present(menu, animated: true, completion: nil)
        }
    }
    func postSongClicked(music: Music) {
      
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
    func historyCommentClicked(history: UserHistory) {
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.historyCommentViewController) as! HistoryCommentViewController
        vc.history = history
        vc.comments = comments
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func historyCommentClicked(history: TimelineHistory) {
        
        guard let uh = history.history else { return }
        
        let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.historyCommentViewController) as! HistoryCommentViewController
        vc.history = uh
        vc.comments = comments
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HistoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.historyCommentTableViewCell, for: indexPath) as! HistoryCommentTableViewCell
        cell.setData(comment: comments[indexPath.row])
        return cell
    }
}
