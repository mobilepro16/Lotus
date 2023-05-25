//
//  User.swift
//  lotus
//
//  Created by Robert Grube on 2/13/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

struct User: Codable {
    
    var id : String
    var bio: String?
    var city: String?
    var country: String?
    var displayName: String?
    var firstName: String?
    var image : String?
    var lastName: String?
    var region: String?
}
