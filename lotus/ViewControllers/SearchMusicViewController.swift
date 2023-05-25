//
//  SearchMusicViewController.swift
//  lotus
//
//  Created by Robert Grube on 2/15/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import PKHUD

class SearchMusicViewController: UIViewController {

    @IBOutlet var headerView: HeaderView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: MusicTableViewHeader!
        
    var music: [Music] = []
    var pendingHistory: [TimelineHistory] = []
    var bookmarks: [Bookmark] = []
    
    private var currentPage = 0
    private var totalPages = 1
    
    var showingHistory = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.delegate = self
        tableView.register(UINib(nibName: TableViewCells.compactMusicTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.compactMusicTableViewCell)
        tableView.register(UINib(nibName: TableViewCells.bookmarkTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.bookmarkTableViewCell)
        tableView.register(UINib(nibName: TableViewCells.pendingHistoryCompactTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.pendingHistoryCompactTableViewCell)

        tableViewHeader.searchView.searchTextField.placeholder = "SEARCH MUSIC"
        tableViewHeader.delegate = self
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refresh
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(musicTapped(_:)), name: Notification.Name(rawValue: "musicTapped"), object: nil)
        loadData()
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @objc func musicTapped(_ notification: Notification) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @objc func loadData(){
        let dispatch = DispatchGroup()
        
        dispatch.enter()
        BookmarkServices.getBookmarks { (bookmarks, error) in
            if let book = bookmarks?.content {
                self.bookmarks = book
            }
            dispatch.leave()
        }
        
        dispatch.enter()
        ContentServices.getRecentlyPlayed { (music, error) in
            
            print("COUNT: \(music?.count ?? -1)")
            
            UserActionServices.getPendingHistory { (history, error) in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                } else if let history = history, let arr = history.content {
                    self.pendingHistory = arr
                }
                dispatch.leave()
            }
        }
        dispatch.notify(queue: .main) {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(noPlayerSelected), name: .noMusicPlayerSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartPlayingMusic), name: .didStartPlayingMusic, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .noMusicPlayerSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didStartPlayingMusic, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension SearchMusicViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch tableViewHeader.selectedDataType {
        case .bookmarks:
            return max(bookmarks.count, 1)
        case .playlists:
            return max(pendingHistory.count, 1)
        case .history:
            return max(pendingHistory.count, 1)
        case .songs:
            return max(music.count, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableViewHeader.selectedDataType {
        case .bookmarks:
          if(bookmarks.count == 0){
              let cell = UITableViewCell()
              cell.backgroundColor = .lotusBackground
              cell.textLabel?.text = "No bookmarks added."
              cell.textLabel?.textColor = .white
              return cell
          }
          let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.bookmarkTableViewCell, for: indexPath) as! BookmarkTableViewCell
          cell.bookmarkView.delegate = self
          cell.bookmarkView.setData(bookmark: bookmarks[indexPath.row])
          return cell
          
        case .playlists:
          if(pendingHistory.count == 0){
              let cell = UITableViewCell()
              cell.backgroundColor = .lotusBackground
              cell.textLabel?.text = ""
              cell.textLabel?.numberOfLines = 0
              cell.textLabel?.textColor = .white
              return cell
          }
          
          let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.pendingHistoryCompactTableViewCell, for: indexPath) as! PendingHistoryCompactTableViewCell
          cell.setData(timelineHistory: pendingHistory[indexPath.row])
          cell.delegate = self
          
          return cell
        case .songs:
            if(music.count == 0){
                let cell = UITableViewCell()
                cell.backgroundColor = .lotusBackground
                cell.textLabel?.text = "No results found."
                cell.textLabel?.textColor = .white
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.compactMusicTableViewCell, for: indexPath) as! CompactMusicTableViewCell
            cell.delegate = self
            cell.setData(music: music[indexPath.row])
            return cell
        case .history:
          if(pendingHistory.count == 0){
              let cell = UITableViewCell()
              cell.backgroundColor = .lotusBackground
              cell.textLabel?.text = ""
              cell.textLabel?.numberOfLines = 0
              cell.textLabel?.textColor = .white
              return cell
          }
          
          let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.pendingHistoryCompactTableViewCell, for: indexPath) as! PendingHistoryCompactTableViewCell
          cell.setData(timelineHistory: pendingHistory[indexPath.row])
          cell.delegate = self
          
          return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableViewHeader.selectedDataType {
        case .bookmarks:
            let book = bookmarks[indexPath.row]
            play(music: book.music)
        case .history:
            let hist = pendingHistory[indexPath.row]
            play(music: hist.history?.music)
        case .songs:
            let song = music[indexPath.row]
            play(music: song)
        case .playlists:
            let hist = pendingHistory[indexPath.row]
            play(music: hist.history?.music)
        }
    }
    
    func play(music: Music?){
        guard let music = music else { return }
        MusicPlayer.play(music: music)
    }
}

extension SearchMusicViewController : MusicTableViewHeaderDelegate {
    func headerTabSelected(dataType: MusicTableData) {
        tableViewHeader.selectedDataType = dataType
        tableView.reloadData()
    }
    
    func headerSearchFor(term: String) {
        ContentServices.search(term: term) { (music, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else if let music = music, let arr = music.content {
                self.music = arr
                self.tableView.reloadData()
            }
        }
    }
    
    
}

extension SearchMusicViewController : BookmarkViewDelegate {
    func postBookmark(bookmark: Bookmark) {
      
        let menu = UIAlertController(title: "Menu", message: bookmark.music?.title ?? "", preferredStyle: .actionSheet)
            
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
                let bookmarkmusic = bookmark.music!
                bookmarkmusic.userId = Globals.sharedInstance.myProfile?.userId ?? ""
                bookmarkmusic.userComment = comment
                ContentServices.postBookmark(music: bookmarkmusic) { (newhistory, error) in
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
            vc.music = bookmark.music!
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
  
    func bookmarkRemoved(bookmark: Bookmark) {
        guard let contentId = bookmark.music?.contentId else { return }
        
        BookmarkServices.removeBookmark(musicId: contentId) { (bookmark, error) in
            self.loadData()
        }
    }
}

extension SearchMusicViewController : CompactMusicTableViewCellDelegate {
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
        let bookmark = UIAlertAction(title: "Add to Bookmarks", style: .default) { (action) in
          
          BookmarkServices.saveBookmark(musicId: music.contentId ?? "", historyId: "") { (bookmark, error) in
              if bookmark != nil{
                  let okAlert = UIAlertController(title: "Added to Bookmarks", message: nil, preferredStyle: .alert)
                  let okAct = UIAlertAction(title: "OK", style: .default, handler: nil)
                  okAlert.addAction(okAct)
                  DispatchQueue.main.async {
                      self.present(okAlert, animated: true, completion: nil)
                  }
              }
          }
        }
        menu.addAction(bookmark)
      
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
extension SearchMusicViewController : PendingHistoryCompactTableViewCellDelegate {
    func addPending(history: TimelineHistory) {
      
          let menu = UIAlertController(title: "Menu", message: history.history?.music?.title ?? "", preferredStyle: .actionSheet)
            
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
                  let bookmarkmusic = history.history!.music
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
          menu.addAction(postsong)
          
          let sendsong = UIAlertAction(title: "Send Song", style: .default) { (action) in
            let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.choosePeoplesViewController) as! ChoosePeoplesViewController
            vc.music = history.history!.music
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
    
    func openMenu(history: TimelineHistory) {
        guard var me = Globals.sharedInstance.myProfile else { return }
        let alert = UIAlertController(title: "Menu", message: history.history?.music?.title ?? "", preferredStyle: .actionSheet)
        let bookmark = UIAlertAction(title: "Add to Bookmarks", style: .default) { (action) in
          BookmarkServices.saveBookmark(musicId: history.history?.music?.contentId ?? "", historyId: history.actionId) { (bookmark, error) in
              if bookmark != nil{
                  let okAlert = UIAlertController(title: "Added to Bookmarks", message: nil, preferredStyle: .alert)
                  let okAct = UIAlertAction(title: "OK", style: .default, handler: nil)
                  okAlert.addAction(okAct)
                  DispatchQueue.main.async {
                      self.present(okAlert, animated: true, completion: nil)
                  }
              }
          }
        }
        alert.addAction(bookmark)
      
        let theme = UIAlertAction(title: "Set as Theme Song", style: .default) { (action) in
            me.themeSong = history.history?.music
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
        alert.addAction(theme)
      
        let delete = UIAlertAction(title: "Remove from history", style: .destructive) { (action) in
            UserActionServices.removeAction(actionId: history.actionId) { (newHistory, error) in
                if let idx = self.pendingHistory.firstIndex(of: history){
                    if(self.pendingHistory.count > 1){
                        self.pendingHistory.remove(at: idx)
                        self.tableView.deleteRows(at: [IndexPath(item: idx, section: 0)], with: .automatic)
                    } else {
                        self.loadData()
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //
        }
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
