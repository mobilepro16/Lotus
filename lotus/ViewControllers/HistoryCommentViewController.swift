//
//  HistoryCommentViewController.swift
//  lotus
//
//  Created by Robert Grube on 2/13/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class HistoryCommentViewController: UIViewController {
    
    @IBOutlet var musicView: MusicView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputTextViewContainerView: UIView!
    @IBOutlet var inputTextView: UITextView!
    
    
    @IBOutlet var constraint_inputTextView_height: NSLayoutConstraint!
    @IBOutlet var constraint_inputView_bottom: NSLayoutConstraint!
    
    
    var history: UserHistory!
    var comments: [Comment]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextViewContainerView.layer.cornerRadius = 18
        inputTextViewContainerView.clipsToBounds = true
        inputTextViewContainerView.layer.borderWidth = 0.6
        inputTextViewContainerView.layer.borderColor = UIColor.gray.cgColor
      
        inputTextView.text = "Add a comment..."
        inputTextView.textColor = UIColor.lightGray
      
        tableView.register(UINib(nibName: TableViewCells.historyCommentTableViewCell, bundle: nil), forCellReuseIdentifier: TableViewCells.historyCommentTableViewCell)
       
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(callNetworkModel), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        if let music = history.music {
            musicView.setData(music: music)
            musicView.titleText.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
  @IBAction func backClicked(_ sender: Any) {
      self.navigationController?.popViewController(animated: true)
  }
  @IBAction func postCommentClicked(_ sender: Any) {
        if inputTextView.textColor == UIColor.lightGray {
            return
        }
        if let txt = inputTextView.text, txt.count > 0 {
            ContentServices.createComment(text: txt, historyId: history.id) { (comment, error) in
                self.inputTextView.text = ""
                self.inputTextView.resignFirstResponder()
                self.constraint_inputTextView_height.constant = 34
                let usersRef = Firestore.firestore().collection("users_table").document(self.history.userId!)
                usersRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let token = document.get("fcmToken") as! String
                        print("Document data: \(token)")
                        let sender = PushNotificationSender()
                        sender.sendPushNotification(to: token , title: "", body: (Globals.sharedInstance.myProfile!.displayName! + " commented on your post."))
                    } else {
                        print("Document does not exist")
                    }
                }
              
                if let comment = comment{
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func callNetworkModel(){
        self.inputTextView.resignFirstResponder()
        ContentServices.getComments(historyId: history.id) { (comments, error) in
            self.tableView.refreshControl?.endRefreshing()
            if let comments = comments, let array = comments.content{
                self.comments = array
                self.tableView.reloadData()
            }
        }
    }
    
    func resizeText(){
        let size = self.inputTextView.contentSize
        self.constraint_inputTextView_height.constant = size.height
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        self.constraint_inputView_bottom.constant = (keyboardFrame.height - 70) * (-1)
        UIView.animate(withDuration: 2) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 2, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.constraint_inputView_bottom.constant = 0
        UIView.animate(withDuration: 2, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension HistoryCommentViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.historyCommentTableViewCell, for: indexPath) as! HistoryCommentTableViewCell
        cell.setData(comment: comments[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension HistoryCommentViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        self.resizeText()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.textColor == UIColor.lightGray) {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text.isEmpty) {
            textView.text = "Add a comment..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension HistoryCommentViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
         self.dismiss(animated: true, completion: nil)
    }
}
extension HistoryCommentViewController : HistoryCommentTableViewCellDelegate {
  func deleteCommentClicked(comment: Comment) {
      let alert = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
      let delete = UIAlertAction(title: "Delete Comment", style: .destructive) { (action) in
          ContentServices.deleteComment(commentId: comment.commentId!) { (data) in
              self.callNetworkModel()
          }
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
          //
      }
      alert.addAction(delete)
      alert.addAction(cancel)
      self.present(alert, animated: true, completion: nil)
      
  }
  func profileClicked(userId: String) {
      AccountServices.getProfile(userId: userId) { (profile, error) in
          guard let profile = profile else { return }
          let vc = self.storyboard?.instantiateViewController(identifier: StoryboardConstants.profileViewController) as! ProfileViewController
          vc.profile = profile
          DispatchQueue.main.async {
              self.navigationController?.pushViewController(vc, animated: true)
          }
      }
  }
  
}
