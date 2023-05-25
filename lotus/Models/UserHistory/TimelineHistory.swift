//
//  TimelineHistory.swift
//  lotus
//
//  Created by Robert Grube on 2/27/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class TimelineHistory: Codable, Equatable {
       
    
    var actionId: String!
    var actionType: ActionType!
    var history : UserHistory?
    var isLiked: Bool = false
    var isBookmarked: Bool = false
    var message : String?
    var userComment: String?
    var topComment: Comment?
    var user : User?
    var sharedDate: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case actionId = "action_id"
        case actionType = "action_type"
        case history
        case isLiked
        case isBookmarked = "is_bookmarked"
        case message
        case userComment
        case topComment
        case user
        case sharedDate = "shared_date"
        
    }
    
    static func == (lhs: TimelineHistory, rhs: TimelineHistory) -> Bool {
        return lhs.actionId == rhs.actionId
    }
}

enum ActionType : String, Codable {
    case liked = "LIKED"
    case listened = "LISTENED"
    case commented = "COMMENTED"
    case added = "ADDED"
    case bookmarked = "BOOKMARKED"
    case favorited = "FAVORITED"
    case shared = "SHARED"
    case pending = "PENDING"
}
