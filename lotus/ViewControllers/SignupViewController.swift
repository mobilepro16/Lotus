//
//  SignupViewController.swift
//  lotus
//
//  Created by admin on 8/5/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

  @IBOutlet weak var appIcon: UIImageView!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var firstName: UITextField!
  @IBOutlet weak var lastName: UITextField!
  @IBOutlet weak var username: UITextField!
  @IBOutlet weak var createButton: UIButton!
  @IBOutlet weak var bio: UITextView!
  
  var profile: Profile!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        createButton.layer.borderColor = UIColor.white.cgColor
        createButton.layer.borderWidth = 1
        createButton.layer.cornerRadius = createButton.bounds.height / 2
    
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 1
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
    
        firstName.layer.borderColor = UIColor.white.cgColor
        firstName.layer.borderWidth = 1
        firstName.layer.cornerRadius = 10
        firstName.setLeftPaddingPoints(10)
        firstName.setRightPaddingPoints(10)
        firstName.attributedPlaceholder = NSAttributedString(string:firstName.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    
        lastName.layer.borderColor = UIColor.white.cgColor
        lastName.layer.borderWidth = 1
        lastName.layer.cornerRadius = 10
        lastName.setLeftPaddingPoints(10)
        lastName.setRightPaddingPoints(10)
        lastName.attributedPlaceholder = NSAttributedString(string:lastName.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        username.layer.borderColor = UIColor.white.cgColor
        username.layer.borderWidth = 1
        username.layer.cornerRadius = 10
        username.setLeftPaddingPoints(10)
        username.setRightPaddingPoints(10)
        username.attributedPlaceholder = NSAttributedString(string:username.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        bio.layer.borderColor = UIColor.white.cgColor
        bio.layer.borderWidth = 1
        bio.layer.cornerRadius = 10
        bio.text = "Bio..."
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        updateUI()
        // Do any additional setup after loading the view.
    }
  func updateUI(){
      DispatchQueue.main.async {
          self.firstName.text = self.profile.firstName ?? ""
          self.lastName.text = self.profile.lastName ?? ""
          self.username.text = "\(self.profile.displayName ?? "")"
          self.bio.text = self.profile.bio ?? "Bio..."
          if (self.profile.bio != "" && self.profile.bio != nil){
            self.bio.textColor = UIColor.white
          }
          if let profImage = self.profile.profileImage, let profUrl = URL(string: imageUrlPrefix + profImage){
            self.profileImage.sd_setImage(with: profUrl, placeholderImage: UIImage(named: "fake-user"), options:.refreshCached, completed: nil)
          }
      }
  }
  @objc func dismissKeyboard() {
      //Causes the view (or one of its embedded text fields) to resign the first responder status.
      view.endEditing(true)
  }
  @IBAction func backClicked(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
  }
  @IBAction func profilleImageClicked(_ sender: Any) {
    choosePhoto()
  }
  @IBAction func createAccountClicked(_ sender: Any) {
    if(self.firstName.text == ""){
      self.showAlert(title: "Invalid Data", message: "Please input first name.")
      return
    }
    if(self.lastName.text == ""){
      self.showAlert(title: "Invalid Data", message: "Please input last name.")
      return
    }
    if(self.username.text == ""){
      self.showAlert(title: "Invalid Data", message: "Please input username.")
      return
    }
    let username = self.username.text
    let set = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-").inverted
    if( username?.rangeOfCharacter(from: set) != nil ){
        self.showAlert(title: "Invalid Data", message: "Please input only lowercase letters, (.), (_), (-) and numbers for username.")
        return
    }
    self.profile.firstName = self.firstName.text
    self.profile.lastName = self.lastName.text
    self.profile.displayName = self.username.text
    if(self.bio.text != "Bio..."){
      self.profile.bio = self.bio.text
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
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
  }
  func choosePhoto(){
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
extension SignupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        self.profileImage.image = image
        AccountServices.uploadProfileImage(image: image) { (data) in
            NotificationCenter.default.post(name: .profileImageUpdated, object: nil, userInfo: ["profileImage":image])
        }
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
