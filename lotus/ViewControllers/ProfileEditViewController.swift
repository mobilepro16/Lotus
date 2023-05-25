//
//  ProfileEditViewController.swift
//  lotus
//
//  Created by admin on 6/24/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController {

  enum UploadPhotoType : Int {
      case cover
      case profile
  }
  
  @IBOutlet weak var cancelBtn: UIButton!
  @IBOutlet weak var doneBtn: UIButton!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var coverImageEditBtn: UIButton!
  @IBOutlet weak var profileImageEditBtn: UIButton!
  @IBOutlet weak var firstNameLabel: UITextField!
  @IBOutlet weak var lastNameLabel: UITextField!
  @IBOutlet weak var usernameLabel: UITextField!
  @IBOutlet weak var bioLabel: UITextView!
  
  var profile: Profile!
  var uploadPhotoType: UploadPhotoType = .profile
  
  override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateUI()
        // Do any additional setup after loading the view.
    }
  func updateUI(){
      DispatchQueue.main.async {
          self.firstNameLabel.text = self.profile.firstName ?? ""
          self.lastNameLabel.text = self.profile.lastName ?? ""
          self.usernameLabel.text = "\(self.profile.displayName ?? "")"
          self.bioLabel.text = self.profile.bio ?? "I'm a new user and haven't updated my bio yet."
          
          if let profImage = self.profile.profileImage, let profUrl = URL(string: imageUrlPrefix + profImage){
            self.profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
          }
          if let coverImage = self.profile.coverImage, let coverUrl = URL(string: imageUrlPrefix + coverImage){
            self.coverImage.sd_setImage(with: coverUrl, placeholderImage: UIImage(named: "fake-cover"), options: .refreshCached, completed: nil)
          }
      }
  }
  
  func setup(){
      profileImage.layer.cornerRadius = profileImage.bounds.width / 2
      profileImage.clipsToBounds = true
    
      profileImage.layer.borderWidth = 1.0
      profileImage.layer.borderColor = UIColor.white.cgColor
      
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
  @IBAction func closeTapped(_ sender: Any) {
    DispatchQueue.main.async {
        self.navigationController?.popViewController(animated: true)
    }
  }
  @IBAction func doneTapped(_ sender: Any) {
    if(self.firstNameLabel.text == ""){
      self.showAlert(title: "Invalid Data", message: "Please input first name.")
      return
    }
    if(self.lastNameLabel.text == ""){
      self.showAlert(title: "Invalid Data", message: "Please input last name.")
      return
    }
    if(self.usernameLabel.text == ""){
      self.showAlert(title: "Invalid Data", message: "Please input username.")
      return
    }
    let username = self.usernameLabel.text
    let set = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-").inverted
    if( username?.rangeOfCharacter(from: set) != nil ){
        self.showAlert(title: "Invalid Data", message: "Please input only lowercase letters, (.), (_), (-) and numbers for username.")
        return
    }
    self.profile.firstName = self.firstNameLabel.text
    self.profile.lastName = self.lastNameLabel.text
    self.profile.displayName = self.usernameLabel.text
    if(self.bioLabel.text != "I'm a new user and haven't updated my bio yet."){
      self.profile.bio = self.bioLabel.text
    }
    AccountServices.getAllUsers { (pagedObj, error) in
        if let pagedObj = pagedObj, let array = pagedObj.content {
          let users = array.filter { $0.displayName == self.profile.displayName && $0.id != self.profile.userId}
            if users.count > 0 {
                self.showAlert(title: "Invalid Data", message: "Username is already in use. Please input other username.")
                return
            } else {
                AccountServices.edit(profile: self.profile) { (newProfile, error) in
                    if let newProfile = newProfile {
                        self.profile = newProfile
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "profileUpdated"), object: nil, userInfo: ["newProfile" : newProfile])
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
  }
  @IBAction func coverImageEditTapped(_ sender: Any) {
      uploadPhotoType = .cover
      choosePhoto()
  }
  @IBAction func profileImageEditTapped(_ sender: Any) {
      uploadPhotoType = .profile
      choosePhoto()
  }
  func choosePhoto(){
      guard let myProfile = Globals.sharedInstance.myProfile else { return }
      if(myProfile.userId == profile.userId){
          let imageSheet = UIAlertController(title: "Upload new photo", message: nil, preferredStyle: .actionSheet)
          let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
              self.uploadPhotoFrom(source: .camera)
          }
          let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
              self.uploadPhotoFrom(source: .photoLibrary)
          }
          let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
          imageSheet.addAction(camera)
          imageSheet.addAction(library)
          imageSheet.addAction(cancel)
          
          DispatchQueue.main.async {
              self.present(imageSheet, animated: true)
          }
      }
  }
  
  func uploadPhotoFrom(source: UIImagePickerController.SourceType){
      let vc = UIImagePickerController()
      vc.sourceType = source
      vc.allowsEditing = true
      vc.delegate = self
      DispatchQueue.main.async {
          self.present(vc, animated: true)
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
extension ProfileEditViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        switch self.uploadPhotoType {
        case .cover:
            self.coverImage.image = image
            AccountServices.uploadCoverImage(image: image) { (data) in
         
            }
            
        case .profile:
            self.profileImage.image = image
            AccountServices.uploadProfileImage(image: image) { (data) in
                NotificationCenter.default.post(name: .profileImageUpdated, object: nil, userInfo: ["profileImage":image])
            }
        }
    }
}
extension String {
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz0123456789._-")
        return self.filter {okayChars.contains($0) }
    }
}
