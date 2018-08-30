//
//  BlockchainInfo+CoreDataProperties.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData


extension BlockchainInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlockchainInfo> {
        return NSFetchRequest<BlockchainInfo>(entityName: "BlockchainInfo")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var serverVersion: String?
    @NSManaged public var headBlockNum: Int64
    @NSManaged public var lastIrreversibleBlockID: String?
    @NSManaged public var lastIrreversibleBlockNum: Int64
    @NSManaged public var headBlockTime: NSDate?
    @NSManaged public var chainID: String?
    @NSManaged public var headBlockID: String?
    @NSManaged public var headBlockProducer: String?
    @NSManaged public var lastIrreversibleBlock: Block?

}
