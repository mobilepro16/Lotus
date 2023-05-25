//
//  Pageable.swift
//  lotus
//
//  Created by Robert Grube on 1/31/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct Pageable: Codable {
    var offset: Int?
    var pageNumber: Int?
    var pageSize: Int?
    var paged: Bool?
    var sort: Sort?
    var unpaged: Bool?
}
