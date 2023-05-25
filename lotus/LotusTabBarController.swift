//
//  LotusTabBarController.swift
//  lotus
//
//  Created by Robert Grube on 1/6/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class LotusTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = UIImage(named: "gradient") {
            let resizable = img.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), resizingMode: .stretch)
            tabBar.backgroundImage = resizable
        }
        
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(named: "tabbarcolor") ?? UIColor.gray
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 0){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "timelineTapped"), object: nil)
        } else if(item.tag == 2){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationTapped"), object: nil)
        } else if(item.tag == 1){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "musicTapped"), object: nil)
        } else if(item.tag == 3){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "chatTapped"), object: nil)
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
