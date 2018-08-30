//
//  API.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

enum API_Method: String {
    case get_info
    case get_block
    
    func serviceAddress() -> String {
        return API.endPoint + self.rawValue
    }
}

struct API {
    static let endPoint = "https://api.eosnewyork.io/v1/chain/"
}
