//
//  WebContentViewController.swift
//  lotus
//
//  Created by admin on 7/3/21.
//  Copyright © 2021 Seisan. All rights reserved.
//

import UIKit
import WebKit

class WebContentViewController: UIViewController {

  @IBOutlet weak var webView: WKWebView!
  var urlString : String?
  override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: urlString!)
        let request = URLRequest(url: url!)
    
        webView.navigationDelegate = self
        webView.load(request)
        // Do any additional setup after loading the view.
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
extension WebContentViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started to load")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
}
