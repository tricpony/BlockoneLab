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
        switch self {
        case .get_transaction:
            return API.endPoint + "history/" + self.rawValue
        default:
            return API.endPoint + "chain/" + self.rawValue
        }
    }
}

struct API {
    static let endPoint = "https://api.eosnewyork.io/v1/"
    static let formatter = DateFormatter()
    
    static func dateFormatter() -> DateFormatter {
        // "timestamp": "2018-08-30T14:07:59.500"
        if self.formatter.dateFormat.isEmpty {
            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            self.formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        }
        return self.formatter
    }

    // MARK: - get_info EOS API Service Call keys
    
    static let SERVER_VERSION = "server_version"
    static let HEAD_BLOCK_NUM = "head_block_num"
    static let LAST_IRREVERSIBLE_BLOCK_NUM = "last_irreversible_block_num"
    static let LAST_IRREVERSIBLE_BLOCK_ID = "last_irreversible_block_id"
    static let CHAIN_ID = "chain_id"
    static let HEAD_BLOCK_ID = "head_block_id"
    static let HEAD_BLOCK_PRODUCER = "head_block_producer"
    
    // MARK: - get_block EOS API Service Call keys

    static let TIMESTAMP = "timestamp"
    static let PREVIOUS = "previous"
    static let ID = "id"
    static let TRANSACTION_MROOT = "transaction_mroot"
    static let ACTION_MROOT = "action_mroot"
    static let BLOCK_MROOT = "block_mroot"
    static let PRODUCER = "producer"
    static let SCHEDULE_VERSION = "schedule_version"
    static let PRODUCER_SIGNATURE = "producer_signature"
    static let BLOCK_NUM = "block_num"
    static let REF_BLOCK_PREFIX = "ref_block_prefix"
    static let TRANSACTIONS = "transactions"
    static let TRANSACTION = "transaction"
    static let ACTIONS = "actions"
    static let ACCOUNT = "account"
    static let NAME = "name"
    static let AUTHORIZATION = "authorization"
    static let ACTOR = "actor"
    static let PERMISSION = "actor"
    static let DATA = "data"
    static let FROM = "from"
    static let TO = "to"
    static let MEMO = "memo"
    static let QUANTITY = "quantity"
    
    // MARK: - get_transaction EOS API Service Call keys

    static let TRACES = "traces"
    static let ACT = "act"


}
