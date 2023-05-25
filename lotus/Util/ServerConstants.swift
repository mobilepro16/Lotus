//
//  ServerConstants.swift
//  lotus
//
//  Created by Robert Grube on 1/29/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import Alamofire

var environment: Server = .staging


var baseUrlString : String {
    switch environment {
    case .development:
        return "http://167.71.96.175/lotus-develop/"
    case .staging:
        return "http://3.142.160.209:8080/"
    case .production:
        return ""
    }
}

var imageUrlPrefix = "https://lotusimage.s3.us-east-2.amazonaws.com/"
let applicationDelegate =  UIApplication.shared.delegate as! AppDelegate

enum Server {
    case development
    case staging
    case production
    
    var displayString : String {
        switch self {
        case .development:
            return "d"
        case .staging:
            return "s"
        case .production:
            return "p"
        }
    }
}

struct HttpFunctions {
    static let createAccount = "api/account/create"
    static let getAuthFromService = "api/auth/token/service"
    static let refreshToken = "api/auth/token/refresh"
    static let getMyProfile = "api/v1/account/me"
    static let editProfile = "api/v1/account/edit"
    static let profileImage = "api/v1/account/image/profile"
    static let coverImage = "api/v1/account/image/cover"
    static let createHistory = "api/v1/content/create/history"
    static let postBookmark = "api/v1/actions/songs"
    static let getHistory = "api/v1/content/get/history/"
    static let createCurrent = "api/v1/content/create/current"
    static let removeCurrent = "api/v1/content/remove/current"
    static let deleteHistory = "api/v1/content/delete/history/"
    static let follow = "api/v1/follow/create"
    static let unfollow = "api/v1/follow/unfollow"
    static let createComment = "api/v1/comments/create"
    static let deleteComment = "api/v1/comments/delete/"
    static let getAllUsers = "api/v1/account/allusers?size=300"
    static let getAllMusic = "api/v1/account/allmusic"
    static let createParty = "api/v1/party/create"
    static let deleteParty = "api/v1/party/delete"
    static let joinParty = "api/v1/party/join"
    static let leaveParty = "api/v1/party/leave"
    static let pauseParty = "api/v1/party/pause"
    static let playParty = "api/v1/party/play"
    static let getNotifications = "api/v1/notifications"
    static let deleteNotification = "api/v1/notifications/delete/"
    static let notificationsRead = "api/v1/notifications/read"
    static let search = "api/v1/content/search?size=100"
    static let accountSearch = "api/v1/account/search"
    
    static let createLike = "api/v1/like/create/"
    static let deleteLike = "api/v1/like/delete/"
    
    static let getPendingHistory = "api/v1/actions/pending-history?sort=start,desc&size=150"
//  static let getPendingHistory = "api/v1/actions/pending-history?size=150"
  
    static let addAction = "api/v1/actions/add/"
    static let editAction = "api/v1/actions/"
    static let removeAction = "api/v1/actions/remove/"
    static let deleteAction = "api/v1/actions/"
    static func getProfileFor(userId: String) -> String{
        return "api/v1/account/get/\(userId)"
    }
    static func getFollowersFor(userId: String) -> String{
        return "api/v1/follow/\(userId)/list/followers"
    }
    static func getFollowingFor(userId: String) -> String{
        return "api/v1/follow/\(userId)/list/following"
    }
    static func getHistoryFor(userId: String, page : Int, pageSize: Int) -> String{
        return "api/v1/actions/\(userId)?sort=sharedDate,desc&page=\(page)&size=\(pageSize)"
    }
    static func getContentFor(contentId: String) -> String{
        return "api/v1/content/get/\(contentId)"
    }
    
    static func getCommentsFor(historyId: String) -> String{
       return "api/v1/comments/get/\(historyId)?sort=createdAt,asc"
    }
    
    static func getTimelineFor(page : Int, pageSize: Int) -> String{
        return "api/v1/actions/action-wall?sort=shared_date,desc&page=\(page)&size=\(pageSize)"
    }
    
    static let registerService = "api/v1/account/services"
    static let appleGetRecentlyPlayed = "api/v1/content/apple/recently-played"
    static let spotifySwapToken = "api/v1/service-token/spotify/swap"
    static let spotifyRefreshToken = "api/v1/service-token/spotify/refresh"
    static let spotifyGetRecentlyPlayed = "api/v1/content/spotify/recently-played"
    static let spotifyPlaySong = "api/v1/service-token/spotify/play"
    static let spotifyPauseSong = "api/v1/service-token/spotify/pause"
    static let spotifyResumeSong = "api/v1/service-token/spotify/resume"
    static let spotifySeek = "api/v1/service-token/spotify/seek"
    
    static func getAlbumsFor(userId: String) -> String{
        return "api/v1/actions/\(userId)/albums"
    }
    
    static func getArtistsFor(userId: String) -> String{
        return "api/v1/actions/\(userId)/artists"//?cbust=\(Date().timeIntervalSince1970)"
    }
    
    static let bookmarks = "api/v1/bookmarks"
}

var defaultHeaders : HTTPHeaders {
    var headers: HTTPHeaders = [
        "Content-Type":"application/json",
        "Accept": "application/json",
    ]
    
    if let t = Globals.sharedInstance.token {
        headers["Authorization"] = "Bearer \(t.token)"
        print("Bearer \(t.token)")
    }
    return headers
}

var defaultHeadersNoAuth : HTTPHeaders {
    return [
        "Content-Type":"application/json",
        "Accept": "application/json",
    ]
}
struct SendBirdConstants {
    static let AppID = "4296632C-BA53-44BB-A66E-09111E72D970"
    static let ApiToken = "e14aae0dc7d0140564ec40856b9182e6016ddaa0"
    static let requestURL = "https://api-4296632C-BA53-44BB-A66E-09111E72D970.sendbird.com"
    static let ApiURL = "https://api.sendbird.com"
}
enum DefaultKeys: String{
    case authKey
    case email
    case password
    case rememberMe
    case userDetails
    case autoLogin
    case deviceToken
    case profileCompleted
    case profileImg
    case seek
    case name
}
