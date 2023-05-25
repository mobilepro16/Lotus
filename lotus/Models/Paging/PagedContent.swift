//
//  PagedContent.swift
//  lotus
//
//  Created by Robert Grube on 1/31/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct PagedContent<T : Codable> : Codable {

    var content: [T]?
    var empty: Bool?
    var first: Bool?
    var last: Bool?
    var number: Int?
    var numberOfElements: Int?
    var pageable: Pageable?
    var size: Int?
    var sort: Sort?
    var totalElements: Int?
    var totalPages: Int?
}
