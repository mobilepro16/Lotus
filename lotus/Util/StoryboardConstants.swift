//
//  StoryboardConstants.swift
//  lotus
//
//  Created by Robert Grube on 2/13/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct StoryboardConstants {
    static let loginViewController = "LoginViewController"
    static let settingsViewController = "SettingsViewController"
    static let profileViewController = "ProfileViewController"
    static let historyViewController = "HistoryViewController"
    static let historyCommentViewController = "HistoryCommentViewController"
    static let followListViewController = "FollowListViewController"
    static let musicPlayerViewController = "MusicPlayerViewController"
    static let chatViewController = "ChatViewController"
    static let createChannelViewController = "CreateChannelViewController"
    static let sendMusicViewController = "SendMusicViewController"
    static let choosePeoplesViewController = "ChoosePeoplesViewController"
}

struct TableViewCells {
    static let timelineMusicTableViewCell = "TimelineMusicTableViewCell"
    static let historyCommentTableViewCell = "HistoryCommentTableViewCell"
    static let userTableViewCell = "UserTableViewCell"
    static let musicTableViewCell = "MusicTableViewCell"
    static let compactMusicTableViewCell = "CompactMusicTableViewCell"
    static let notificationTableViewCell = "NotificationTableViewCell"
    static let timelineTableViewCell = "TimelineTableViewCell"
    static let pendingHistoryTableViewCell = "PendingHistoryTableViewCell"
    static let pendingHistoryCompactTableViewCell = "PendingHistoryCompactTableViewCell"
    static let bookmarkTableViewCell = "BookmarkTableViewCell"
    static let messageTableViewCell = "MessageTableViewCell"
}

struct GeneralConstants {
    static var defaultUserImage: UIImage {
        return UIImage(named: "fake-user")!
    }
}

struct UserDefaultsKeys {
    
    static let selectedMusicPlatform = "SelectedMusicPlatform"
    
    static let lotusToken = "LotusToken"
    static let lotusProfile = "LotusProfile"
    
    static let spotifyAccessToken = "SpotifyAccessToken"
    static let spotifyRefreshToken = "SpotifyRefreshToken"
}
