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
    case get_transaction
    
    func serviceAddress() -> String {
        return API.endPoint + self.rawValue
    }
}

struct API {
    static let endPoint = "https://api.eosnewyork.io/v1/chain/"
    static let formatter = DateFormatter()
    
    static func dateFormatter() -> DateFormatter {
        // "timestamp": "2018-08-30T14:07:59.500"
        if self.formatter.dateFormat.isEmpty {
            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            self.formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        }
        return self.formatter
    }

}
