//
//  Notification.swift
//  lotus
//
//  Created by Robert Grube on 3/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

enum LotusNotificationType : String, Codable {
    case follow = "Follow"
    case friend = "Friend"
    case party = "Party"
    case like = "Like"
    case comment = "Comment"
}

class LotusNotification: Codable, Equatable {
    static func == (lhs: LotusNotification, rhs: LotusNotification) -> Bool {
      return lhs.id == rhs.id
    }
    var createdAt: Date?
    var fromUser: User?
    var historyId: String?
    var historyImage: String?
    var id: String!
    var message: String?
    var type: LotusNotificationType!
    var userId: String?
    var isRead: Bool!
}
