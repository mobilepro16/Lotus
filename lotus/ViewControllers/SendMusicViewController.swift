//
//  SendMusicViewController.swift
//  lotus
//
//  Created by admin on 4/16/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit
import PKHUD
import SendBirdSDK
import SwiftyJSON

protocol sendMusicDelegate
{
    func sendMusic(music: Music)
}

class SendMusicViewController: UIViewController, NotificationTableViewHeaderDelegate, UITableViewDelegate, UITableViewDataSource, PendingHistoryCompactTableViewCellDelegate {
 
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var viewHeader: NotificationsTableViewHeader!
  
  var music: [Music] = []
  var delegate: sendMusicDelegate?
  private var currentPage = 0
  private var totalPages = 1
  var pendingHistory: [TimelineHistory] = []
  
  var showingHistory = true
  
  override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: TableViewCells.pendingHistoryCompactTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.pendingHistoryCompactTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
    
        viewHeader.searchView.searchTextField.placeholder = "SEARCH MUSIC"
        viewHeader.headerTitle.text = "Music"
        viewHeader.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
  @objc func dismissKeyboard() {
      //Causes the view (or one of its embedded text fields) to resign the first responder status.
      view.endEditing(true)
  }
  override func viewWillDisappear(_ animated: Bool) {
      NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
      NotificationCenter.default.removeObserver(self, name: .didStartPlayingMusic, object: nil)
      NotificationCenter.default.removeObserver(self, name: .navigateToLogin, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
      NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(didStartPlayingMusic), name: .didStartPlayingMusic, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(noPlayerSelected), name: .noMusicPlayerSelected, object: nil)
      callNetworkModel(term: "")
  }
   
  func callNetworkModel(term: String){
      UserActionServices.getPendingHistory { (history, error) in
          if let error = error {
              self.showAlert(title: "Error", message: error.localizedDescription)
          } else if let history = history, let arr = history.content {
              var data = arr
              if(term != ""){
                data = arr.filter({$0.history?.music?.title?.lowercased().contains(term) == true || $0.history?.music?.artist!.lowercased().contains(term) == true})
              }
              self.pendingHistory = data.sorted(by: { (th1, th2) -> Bool in
                  th1.history?.start ?? Date() > th2.history?.start ?? Date()
              })
              self.tableView.reloadData()
          }
      }
  }
  func headerTabSelected(dataType: NotificationsTableData) {
      callNetworkModel(term: "")
  }
  
  func headerSearchFor(term: String) {
      callNetworkModel(term: term)
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return max(pendingHistory.count, 1)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let song = pendingHistory[indexPath.row].history!.music
      self.play(music: song)
  }
  func addPending(history: TimelineHistory) {
      let song = history.history!.music
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.sendMusic(music: song!)
      }
  }
  
  func openMenu(history: TimelineHistory) {
    guard var me = Globals.sharedInstance.myProfile else { return }
    let music = history.history!.music
    let menu = UIAlertController(title: "Menu", message: music!.title ?? "", preferredStyle: .actionSheet)
    let play = UIAlertAction(title: "Play Song", style: .default) { (action) in
        MusicPlayer.play(music: music!)
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
  
  func play(music: Music?){
      guard let music = music else { return }
      MusicPlayer.play(music: music)
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
