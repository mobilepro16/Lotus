//
//  SendBirdInterface.swift
//  TravelGee
//
//  Created by apple on 31/01/19.
//  Copyright © 2019 cql8. All rights reserved.
//

import UIKit
import SendBirdSDK
import AVFoundation
import NotificationView
import MBProgressHUD
//import LGSideMenuController

class SendBirdInterface: NSObject , NotificationViewDelegate{
    
    static let sharedInstace = SendBirdInterface()
    var receivedPushChannelUrl: String?
    var currentUser = SBDUser()
    var blockedUsers = [String]()
    
    var ignoreChannel : SBDGroupChannel?
    var messageSenderID = ""
    var currentChannel : SBDGroupChannel?
    //MARK: Login
    
    override init() {
        super.init()
        SBDMain.add(self, identifier: self.description)
        self.unreadChannels()
    }
    
    
    func loginSBD(userID: String){
        if SBDMain.getConnectState() == SBDWebSocketConnectionState.open{
            SBDMain.disconnect {
            }
        }
        self.connectWith(USER_ID: userID) { (result, error) in
        }
    }
    
    
    //MARK: Build Connections
    func connectWith(USER_ID: String, compeletion: @escaping(Bool , Error?)-> Void){
        SBDMain.connect(withUserId: USER_ID) { (user, error) in
            if  error != nil {
                // Error.
                print(error?.localizedDescription ?? "")
                compeletion(false, error)
            } else {
                print("Connected with \(USER_ID)")
                self.unreadChannels()
                if SBDMain.getPendingPushToken() != nil{
                    SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, unique: true, completionHandler: { (status, error) in
                        print(status)
                    })
                }
          
                var pic = imageUrlPrefix + (Globals.sharedInstance.myProfile?.profileImage ?? "")
                if (pic == imageUrlPrefix) {
                  pic = "https://i.postimg.cc/cJJr0QM2/Screen-Shot-2021-03-10-at-10-50-51-PM.png"
                }
                self.updateUser(name: (Globals.sharedInstance.myProfile?.firstName)! +  " " + (Globals.sharedInstance.myProfile?.lastName)!, pic: pic)
                self.currentUser = SBDMain.getCurrentUser() ?? SBDUser()
                self.updateMetaData()
                compeletion(true,nil)
            }
        }
    }
    
    //MARK: Update Data
    
    func updateUser(name: String?, pic: String?){
        SBDMain.updateCurrentUserInfo(withNickname: name, profileUrl: pic, completionHandler: { (error) in
            if error != nil {
                // Error handling.
                print(error?.localizedDescription ?? "")
                //                rootVC?.showalertview(messagestring: error?.localizedDescription ?? "")
            } else{
                print("User Updated on SendBird")
                self.currentUser = SBDMain.getCurrentUser() ?? SBDUser()
                self.updateMetaData()
            }
        })}
    
    
    func updateMetaData(){
        
        let userInfo = Globals.sharedInstance.myProfile

        let data  = [
            "email":userInfo?.bio ?? "",
            "id":"\( userInfo?.userId ?? "0")",
            "description": userInfo?.bio ?? ""
        ]
        self.currentUser.updateMetaData(data) { (result, error) in
        }
    }
    
    
    
    
    //MARK: Chat Channels
    
//    func createChannel(userIDs: [String],name: String?,compeletion: @escaping(SBDGroupChannel? , Error?)-> Void){
//        let params = SBDGroupChannelParams()
//        params.name = name ?? "Group"
//            params.addUserIds(userIDs)
//        params.isDistinct = true
//        params.coverImage = Data()
//        params.operatorUserIds = userIDs
//
//        SBDGroupChannel.createChannel(with: params) { (channel, error) in
//            if channel != nil {
//                print("New Group Created")
//                compeletion(channel, nil)
//            } else{
//                compeletion(nil, error)
//            }
//        }
//    }
    
    func createChannel(userIDs: [String],name: String?, img: Data?, isGroup: Bool,compeletion: @escaping(SBDGroupChannel? , Error?)-> Void){
        let params = SBDGroupChannelParams()
        params.name = name ?? "Chat"
        params.addUserIds(userIDs)
        params.isDistinct = true
        params.coverImage = img ?? Data()
        params.operatorUserIds = userIDs
        if isGroup{
            params.data = "group"
        }
        SBDGroupChannel.createChannel(with: params) { (channel, error) in
            if channel != nil {
                print("New Group Created")
                compeletion(channel, nil)
            } else{
                compeletion(nil, error)
            }
        }
    }
    
    func getChat(channel_url: String){
        SBDOpenChannel.getWithUrl(channel_url) { (channel, error) in
            guard error == nil else {   // Error.
                return
            }
            channel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
        }
    }
    
    func getChannelWithURL(channel_url: String , completion: @escaping(SBDBaseChannel? , Error?)-> Void){
        SBDOpenChannel.getWithUrl(channel_url) { (channel, error) in
            if error == nil{
                completion(channel , nil)
            } else{
                completion(nil , error)
            }
        }
    }
    
    //MARK: Send Messages
    
    func sendMessage(channel: SBDGroupChannel?, msg: String , compeletion: @escaping(SBDBaseMessage? , Error?)-> Void){
        channel?.sendUserMessage(msg) { (message, error) in
            guard error == nil else {   // Error.
                compeletion(nil , error)
                return
            }
            compeletion(message , nil)
        }
    }
    
    
    func sendImage(channel: SBDGroupChannel?, fileData: Data , compeletion: @escaping(SBDBaseMessage? , Error?)-> Void){
        channel?.sendFileMessage(withBinaryData: fileData, filename: "image", type: "image/gif", size: UInt((fileData.count)), data: "", completionHandler: { (message, error) in
            if error != nil{
                compeletion(nil , error)
            } else{
                compeletion(message , nil)
            }
        })
    }
    
    
    func sendVideo(channel: SBDGroupChannel?,url: URL, fileData: Data , compeletion: @escaping(SBDBaseMessage? , Error?)-> Void){
        channel?.sendFileMessage(withBinaryData: fileData, filename: "video", type: "video/quicktime", size: UInt((fileData.count)), data: "", completionHandler: { (message, error) in
            if error != nil{
                compeletion(nil , error)
            } else{
                compeletion(message , nil)
            }
        })
    }
    
    //MARK: Previous Messages
    func getMessages(channel: SBDGroupChannel?, compeletion: @escaping([SBDBaseMessage]?,SBDPreviousMessageListQuery?, Error?)-> Void){
        let previousMessageQuery = channel?.createPreviousMessageListQuery()
        previousMessageQuery?.loadPreviousMessages(withLimit: 20, reverse: true, completionHandler: { (messages, error) in
            if (messages?.count ?? 0) > 0{
                compeletion(messages, previousMessageQuery, nil)
            } else{
                compeletion(nil, nil, error)
            }
        })
    }
    
    
    
    func getPaginationMessages(channel: SBDGroupChannel?,query: SBDPreviousMessageListQuery?, compeletion: @escaping([SBDBaseMessage]?, Error?)-> Void){
        
        query?.loadPreviousMessages(withLimit: 10, reverse: true, completionHandler: { (messages, error) in
            if (messages?.count ?? 0) > 0{
                compeletion(messages, nil)
            } else{
                compeletion(nil, error)
            }
        })
    }
    
    
    
    //MARK: Get Users
    
    func getUsers(compeletion: @escaping([SBDUser]? , SBDApplicationUserListQuery? , Error?)-> Void) {
        // In case of retrieving all users
        let applicationUserListQuery = SBDMain.createApplicationUserListQuery()
        //   applicationUserListQuery?.limit = 10
        applicationUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            if (users?.count ?? 0 ) > 0 {
                compeletion(users , applicationUserListQuery ,  nil)
            } else{
                compeletion(nil , applicationUserListQuery , error)
            }
        })
    }
    
    
    func getNextUsers(query: SBDApplicationUserListQuery?, compeletion: @escaping([SBDUser]? , Error?)-> Void) {
        // In case of retrieving all users
        //    query?.limit = 10
        guard query?.hasNext != false else{
            compeletion(nil ,  nil)
            return
        }
        
        query?.loadNextPage(completionHandler: { (users, error) in
            if (users?.count ?? 0) > 0 {
                compeletion(users ,  nil)
            } else{
                compeletion(nil  , error)
            }
        })
    }
    
    func getUserByID(userID: String, compeletion: @escaping(SBDUser? , Error?)-> Void) {
        // In case of retrieving all users
        let applicationUserListQuery = SBDMain.createApplicationUserListQuery()
        applicationUserListQuery?.userIdsFilter = [userID]
        applicationUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            if (users?.count ?? 0 ) > 0 {
                compeletion(users?.first , nil)
            } else{
                compeletion(nil , error)
            }
        })
    }
    
    func getBlockedUsers(compeletion: @escaping([SBDUser]? , Error?)-> Void) {
        let applicationUserListQuery = SBDMain.createBlockedUserListQuery()
        applicationUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            if (users?.count ?? 0 ) > 0 {
                compeletion(users , nil)
            } else{
                compeletion(nil , error)
            }
        })
    }
    
    
    func getMutedUsers(channel: SBDGroupChannel?, compeletion: @escaping([SBDUser]? , Error?)-> Void) {
        let applicationUserListQuery = channel?.createMemberListQuery()
        applicationUserListQuery?.mutedMemberFilter = SBDGroupChannelMutedMemberFilter.muted
        applicationUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            if (users?.count ?? 0 ) > 0 {
                compeletion(users , nil)
            } else{
                compeletion(nil , error)
            }
        })
    }
    
    
    
    func blockUnblockUser(user: SBDUser, status: String,completion: @escaping(Bool, Error?)-> Void){
        if status == "1"{
            // In case of blocking a user
            SBDMain.blockUser(user) { (user, error) in
                if error == nil{
                    completion(true, nil)
                } else{
                    completion(false, error)
                }
            }
            
        } else{
            // In case of unblocking a user
            SBDMain.unblockUser(user) { (error) in
                if error == nil{
                    completion(true, nil)
                } else{
                    completion(false, error)
                }
            }
            
        }
    }
    
    
    func muteUnmuteUser(channel: SBDGroupChannel?, user: SBDUser, status: String,completion: @escaping(Bool, Error?)-> Void){
        if status == "1"{
            // In case of blocking a user
            if channel?.myRole == SBDRole.operator {
                channel?.muteUser(user) { (error) in
                    if error == nil{
                        completion(true, nil)
                    } else{
                        completion(false, error)
                    }
                }
            }
            
        } else{
            // In case of unblocking a user
            if channel?.myRole == SBDRole.operator {
                channel?.unmuteUser(user) { (error) in
                    if error == nil{
                        completion(true, nil)
                    } else{
                        completion(false, error)
                    }
                }
            }
            
        }
    }
    
    
    
    
    func checkOnline(UserID: String,compeletion: @escaping(Bool?, Error?)-> Void){
        let applicationUserListQuery = SBDMain.createApplicationUserListQuery()
        applicationUserListQuery?.userIdsFilter = [UserID]
        applicationUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            guard error == nil else {   // Error.
                compeletion(nil, error)
                return
            }
            if users?[0].connectionStatus == SBDUserConnectionStatus.online {
                // SBDUserConnectionStatus consists of offline, online, and nonAvailable.
                compeletion(true, nil)
            } else{
                compeletion(false, nil)
            }
        })
    }
    
    //MARK: Get Channels
    func getChannels(compeletion: @escaping([SBDGroupChannel]? , SBDGroupChannelListQuery? , Error?)-> Void) {
        let query = SBDGroupChannel.createMyGroupChannelListQuery()
        //     query?.limit = 10
        query?.order = SBDGroupChannelListOrder.latestLastMessage
        query?.loadNextPage(completionHandler: { (channels, error) in
            if (channels?.count ?? 0) > 0 {
                
                compeletion(channels , query, nil)
                //                let filtered = channels?.filter({(($0.members as? [SBDMember])?.filter({$0.userId != self.currentUser.userId}).first?.isBlockingMe == false) && (($0.members as? [SBDMember])?.filter({$0.userId != self.currentUser.userId}).first?.isBlockedByMe == false)})
                
                //                if (filtered?.count ?? 0) > 0{
                //                 compeletion(filtered , query, nil)
                //                } else{
                //                    compeletion(nil , query, nil)
                //                }
            } else{
                compeletion(nil , query, error)
            }
        })
    }
    
    func getNextChannels(query: SBDGroupChannelListQuery?,compeletion: @escaping([SBDGroupChannel]? , Error?)-> Void) {
        //  query?.limit = 10
        query?.loadNextPage(completionHandler: { (channels, error) in
            if (channels?.count ?? 0) > 0 {
                
                compeletion(channels , nil)
                
                //                let filtered = channels?.filter({(($0.members as? [SBDMember])?.filter({$0.userId != self.currentUser.userId}).first?.isBlockingMe == false) && (($0.members as? [SBDMember])?.filter({$0.userId != self.currentUser.userId}).first?.isBlockedByMe == false)})
                //
                //                if (filtered?.count ?? 0) > 0{
                //                    compeletion(filtered , nil)
                //                } else{
                //                    compeletion(nil, nil)
                //                }
                
            } else{
                compeletion(nil , error)
            }
        })
    }
    
    
    func getChannelForIDs(myID: String, otherID : String ,compeletion: @escaping(SBDGroupChannel? , Error?)-> Void){
        let query = SBDGroupChannel.createMyGroupChannelListQuery()
        query?.userIdsExactFilter = [myID , otherID]
        query?.loadNextPage(completionHandler: { (channels, error) in
            if (channels?.count ?? 0) > 0 {
                compeletion(channels?.first , nil)
            } else{
                compeletion(nil , error)
            }
        })
    }
    
    func filterChannel(compeletion: @escaping([SBDGroupChannel]? , SBDGroupChannelListQuery? , Error?)-> Void) {
        let query = SBDGroupChannel.createMyGroupChannelListQuery()
        //  query?.limit = 10
        
        query?.loadNextPage(completionHandler: { (channels, error) in
            if (channels?.count ?? 0) > 0 {
                compeletion(channels , query , nil)
            } else{
                compeletion(nil , query, error)
            }
        })
    }
    
    
    
    func clearChat(channel: SBDGroupChannel?,compeletion: @escaping(Bool)-> Void){
        channel?.resetMyHistory(completionHandler: { (error) in
            compeletion(error == nil)
        })
    }
    
    
    //MARK: Logout
    
    func logoutSBD(){
        self.unregisterPushNotifiations()
        SBDMain.disconnect(completionHandler: nil)
    }
    
    
    
    //MARK: Notifications
    
    func registerNotification(token: Data){
        SBDMain.registerDevicePushToken(token, unique: true) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    // Registration is pending.
                    // If you get this status, invoke `+ registerDevicePushToken:unique:completionHandler:` with `[SBDMain getPendingPushToken]` after connection.
                }
                else {
                    // Registration succeeded.
                    print("Registered for Sendbird notification")
                }
            }
            else {
                // Registration failed.
                print("Failed to register for Sendbird notification")
            }
        }
    }
    
    func unregisterPushNotifiations(){
        SBDMain.unregisterAllPushToken(completionHandler: nil)
    }
    
    
    func muteNotification(channel : SBDGroupChannel?, status: String, completion: @escaping(String)-> Void){
        
        let push = (status == "3") ? false : true
        
        channel?.setPushPreferenceWithPushOn(push, completionHandler: { (error) in
            if error != nil{
                var msg = "Unable to Mute"
                if push == false{
                    msg = "Unable to Mute"
                } else{
                    msg = "Unable to Unmute"
                }
                completion(error?.localizedDescription ?? msg)
            } else{
                var msg = "User Muted Successfully"
                if push == false{
                    msg = "User Muted Successfully"
                } else{
                    msg = "User Unmuted Successfully"
                }
                completion(error?.localizedDescription ?? msg)
            }
        })
    }
    
    
    //MARK: Thumbnail from URL
    
    func createThumbNail_Image (_ url: URL!) -> Data?{
        let asset = AVURLAsset(url: NSURL(fileURLWithPath: url.path ) as URL, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let img = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            
            return  thumbnail.jpegData(compressionQuality: 0)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}


extension SendBirdInterface : SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender != self.ignoreChannel{
            self.currentChannel = sender as? SBDGroupChannel
            self.presentNoti(message)
            self.unreadChannels()
        }
    }
    
    
    func unreadChannels(){
        SBDMain.getTotalUnreadChannelCount { (totalUnreadChannelCount, error) in
            if (totalUnreadChannelCount) == 0{
//                tabBadgeCount(value: nil)
            } else{
//                tabBadgeCount(value: String(totalUnreadChannelCount))
            }
        }
    }
    
    func presentNoti(_ message: SBDBaseMessage){
//        guard (userInfo.isMessages ?? "0") == "1" else {return}
        
          let userInfo = Globals.sharedInstance.myProfile
        
        if let userMessage = message as? SBDUserMessage{
          guard userMessage.sender?.userId != "\(userInfo?.userId ?? "0")" else {return}
            
            self.messageSenderID = userMessage.sender?.userId ?? ""
            let notificationView = NotificationView.default
            notificationView.hideAfter(2.5)
            notificationView.delegate = self
            notificationView.title = userMessage.sender?.nickname ?? ""
            notificationView.body = userMessage.message
            notificationView.image = UIImage(named: "logo")
            notificationView.show()
        } else if let userMessage = message as? SBDFileMessage{
          guard userMessage.sender?.userId != "\(userInfo?.userId ?? "0")" else {return}
            
            self.messageSenderID = userMessage.sender?.userId ?? ""
            let notificationView = NotificationView.default
            notificationView.hideAfter(2.5)
            notificationView.delegate = self
            notificationView.title = userMessage.sender?.nickname ?? ""
            notificationView.body = "Image"
            notificationView.image = UIImage(named: "logo")
            notificationView.show()
        }
    }
  /*
    //Handel Foreground Notification Action
    func notificationViewDidTap(_ notificationView: NotificationView) {
         self.openChat(senderID: self.messageSenderID)
    }

    func openChat(senderID: String){
        DispatchQueue.main.async {
//            if let window = UIApplication.shared.keyWindow{
//                MBProgressHUD.showAdded(to: window.rootViewController!.view, animated: true)
//            }
            applicationDelegate.showLoader()
        }
     
        SendBirdInterface.sharedInstace.getUserByID(userID: senderID) { (user, error) in
            if user != nil{
                SendBirdInterface.sharedInstace.getUserByID(userID: user?.userId ?? "") { (user, error) in
                    if user != nil{
                        DispatchQueue.main.async {
//                            if let window = UIApplication.shared.keyWindow{
//                                MBProgressHUD.hide(for: window.rootViewController!.view, animated: true)
//                            }
                            applicationDelegate.hIdelOader()
                        }
                        
                        print("Open Chat")
                        let nav = Home.instantiateViewController(withIdentifier: "HomeNav") as! UINavigationController
                         let vc = Home.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                        let chatController = Home.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
                        chatController.otherUser = user!
                        chatController.currentChannel = self.currentChannel
                        if self.currentChannel!.data == "group"
                        {
                            chatController.isGroup = true
                        }
                        nav.viewControllers = [vc,chatController]
                        nav.setNavigationBarHidden(true, animated: true)
                        applicationDelegate.window?.rootViewController = nav
                        applicationDelegate.window?.makeKeyAndVisible()
                        
                    } else{
                        DispatchQueue.main.async {
//                            if let window = UIApplication.shared.keyWindow{
//                                MBProgressHUD.hide(for: window.rootViewController!.view, animated: true)
//                            }
                            applicationDelegate.hIdelOader()
                        }
                        
                        //appDelegate.window?.rootViewController?.showAlert(messageStr:  error?.localizedDescription ?? "User not Connect to Chat", type: .error)
                    }
                }
            } else{
                DispatchQueue.main.async {
//                    if let window = UIApplication.shared.keyWindow{
//                        MBProgressHUD.hide(for: window.rootViewController!.view, animated: true)
//                    }
                    applicationDelegate.hIdelOader()
                }
                
                //appDelegate.window?.rootViewController?.showAlert(messageStr:  error?.localizedDescription ?? "User not Connect to Chat", type: .error)
               
            }
        }
    }
 */
    func getGroupChannelWithURL(channel_url: String , completion: @escaping(SBDGroupChannel? , Error?)-> Void){
        SBDGroupChannel.getWithUrl(channel_url) { (channel, error) in
            if error == nil{
                completion(channel , nil)
            } else{
                completion(nil , error)
            }
        }
    }
}
