//
//  Comment.swift
//  lotus
//
//  Created by Robert Grube on 2/12/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct Comment: Codable {
    var comment: String?
    var commentId: String?
    var createdAt: Date?
    var fromUser: User?
    var fromUserId: String?
    var historyId: String?
}
