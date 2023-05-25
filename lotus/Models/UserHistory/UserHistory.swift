//
//  UserHistory.swift
//  lotus
//
//  Created by Robert Grube on 2/11/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

class UserHistory: Codable {
    var id: String
    var commentCount: Int?
    var contentId: String?
    var createdDate: Date?
    var end: Date?
    var music: Music?
    var start: Date?
    var type: LotusContentType?
    var userComment: String?
    var userId: String?
    var likesCount: Int?
    var isLiked: Bool = false
    var isBookmarked: Bool = false
}
