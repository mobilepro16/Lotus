//
//  LoginViewController.swift
//  lotus
//
//  Created by Robert Grube on 1/24/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import AuthenticationServices
import FacebookLogin
import WebKit

class LoginViewController: UIViewController {

    @IBOutlet var loginProviderStackView: UIStackView!
    @IBOutlet weak var footerlabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let accessToken = AccessToken.current {
            self.loginWith(service: .facebook, token: accessToken.tokenString)
        }
        
        setupProviderLoginView()
      
    }
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

          // **Perform sign in action here**

          return false
      }
    func setupProviderLoginView() {
  
        let myAttribute = [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ]
        let myString = NSMutableAttributedString(string: "By signing up/in for Lotus services, you're indicating that you agree to our ")
        let attrString1 = NSAttributedString(string: "Terms of Service Agreement", attributes: myAttribute)
        let attrString2 = NSAttributedString(string: " and ")
        let attrString3 = NSAttributedString(string: "Privacy Policy", attributes: myAttribute)
        let attrString4 = NSAttributedString(string: ".")
        myString.append(attrString1)
        myString.append(attrString2)
        myString.append(attrString3)
        myString.append(attrString4)
        
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        authorizationButton.layer.masksToBounds = true
        authorizationButton.cornerRadius = 50
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = "By signing up/in for Lotus services, you're indicating that you agree to our Terms of Service Agreement and Privacy Policy."
        let termsRange = (text as NSString).range(of: "Terms of Service Agreement")
         // comment for now
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        if gesture.didTapAttributedTextInLabel(label: self.footerlabel, inRange: termsRange) {
          let vc = WebViewController()
          vc.url = URL(string: "https://drive.google.com/file/d/1vWe9MYjQOn8i5-Sc_Z77LiZXAnHoAU3l/view")!
          self.present(vc, animated: true, completion: nil)
        } else if gesture.didTapAttributedTextInLabel(label: self.footerlabel, inRange: privacyRange) {
          let vc = WebViewController()
          vc.url = URL(string: "https://drive.google.com/file/d/1TBpEL1aB0SEouHYXj2q7qNpl839MqBdG/view")!
          self.present(vc, animated: true, completion: nil)
         } else {
             print("Tapped none")
         }
    }
  
    func loginWith(service: LoginService, token: String, firstName: String? = nil, lastName: String? = nil){
        AuthServices.getAuthFrom(service: service, token: token, firstName: firstName, lastName: lastName) { (token, error) in
            if let t = token {
                Globals.sharedInstance.token = t
                t.save()
                weak var pvc = self.presentingViewController
                AccountServices.getMyProfile { (profile, error) in
                    profile?.save()
                    if(profile?.numFollowers ?? 0 > 0 || profile?.numFollowing ?? 0 > 0){
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true) {
                          let vc = self.storyboard?.instantiateViewController(identifier: "SignupViewController") as! SignupViewController
                          vc.modalPresentationStyle = .fullScreen
                          vc.profile = profile
                          DispatchQueue.main.async {
                              pvc?.present(vc, animated: true, completion: nil)
                          }
                      }
                    }
                }
            }
        }
    }
    
  @IBAction func createButtonClicked(_ sender: Any) {
      let vc = self.storyboard?.instantiateViewController(identifier: "SignupViewController") as! SignupViewController
      vc.modalPresentationStyle = .fullScreen
      DispatchQueue.main.async {
        self.present(vc, animated: true, completion: nil)
      }
  }
  override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(notification:)), name: .didReceiveError, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .didReceiveError, object: nil)
    }

     @objc
       func handleAuthorizationAppleIDButtonPress() {
           let appleIDProvider = ASAuthorizationAppleIDProvider()
           let request = appleIDProvider.createRequest()
           request.requestedScopes = [.fullName, .email]
           
           let authorizationController = ASAuthorizationController(authorizationRequests: [request])
           authorizationController.delegate = self
           authorizationController.presentationContextProvider = self
           authorizationController.performRequests()
       }

}

extension LoginViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        print("didCompleteWithAuthorization")
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let authorizationCodeData = appleIDCredential.authorizationCode else { return }
            guard let authorizationCode = String(data:authorizationCodeData, encoding: .utf8) else { return }
                        
            let firstName = appleIDCredential.fullName?.givenName
            let lastName = appleIDCredential.fullName?.familyName
            self.loginWith(service: .apple, token: authorizationCode, firstName: firstName, lastName: lastName)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
          _ = passwordCredential.user
          _ = passwordCredential.password
            
            //todo username password login
                
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController : LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        switch result {
            
        case .none:
            print(error?.localizedDescription ?? "FACEBOOK ERROR")
        case .some(_):
            if let uid = result?.token?.userID {
                print("FACEBOOK USER: \(uid)")
            }
            
            if let tokenString = result?.token?.tokenString {
                self.loginWith(service: .facebook, token: tokenString)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("facebook logged out")
    }
}

extension UITapGestureRecognizer {
   
   func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
       guard let attributedText = label.attributedText else { return false }

       let mutableStr = NSMutableAttributedString.init(attributedString: attributedText)
       mutableStr.addAttributes([NSAttributedString.Key.font : label.font!], range: NSRange.init(location: 0, length: attributedText.length))
       
       // If the label have text alignment. Delete this code if label have a default (left) aligment. Possible to add the attribute in previous adding.
       let paragraphStyle = NSMutableParagraphStyle()
       paragraphStyle.alignment = .center
       mutableStr.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))

       // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
       let layoutManager = NSLayoutManager()
       let textContainer = NSTextContainer(size: CGSize.zero)
       let textStorage = NSTextStorage(attributedString: mutableStr)
       
       // Configure layoutManager and textStorage
       layoutManager.addTextContainer(textContainer)
       textStorage.addLayoutManager(layoutManager)
       
       // Configure textContainer
       textContainer.lineFragmentPadding = 0.0
       textContainer.lineBreakMode = label.lineBreakMode
       textContainer.maximumNumberOfLines = label.numberOfLines
       let labelSize = label.bounds.size
       textContainer.size = labelSize
       
       // Find the tapped character location and compare it to the specified range
       let locationOfTouchInLabel = self.location(in: label)
       let textBoundingBox = layoutManager.usedRect(for: textContainer)
       let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                         y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
       let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                    y: locationOfTouchInLabel.y - textContainerOffset.y);
       let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
       return NSLocationInRange(indexOfCharacter, targetRange)
   }
   
}
