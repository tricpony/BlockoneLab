//
//  Block+CoreDataProperties.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData


extension Block {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Block> {
        return NSFetchRequest<Block>(entityName: "Block")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var previousBlockHash: String?
    @NSManaged public var blockTimestamp: NSDate?
    @NSManaged public var transactionMRoot: String?
    @NSManaged public var actionMRoot: String?
    @NSManaged public var blockMRoot: String?
    @NSManaged public var producer: String?
    @NSManaged public var scheduleVersion: Int16
    @NSManaged public var producerSignature: String?
    @NSManaged public var currentBlockHash: String?
    @NSManaged public var blockNum: Int64
    @NSManaged public var refBlockPrefix: Int64
    @NSManaged public var blockInfo: BlockchainInfo?
    @NSManaged public var regions: NSSet?

}

// MARK: Generated accessors for regions
extension Block {

    @objc(addRegionsObject:)
    @NSManaged public func addToRegions(_ value: Region)

    @objc(removeRegionsObject:)
    @NSManaged public func removeFromRegions(_ value: Region)

    @objc(addRegions:)
    @NSManaged public func addToRegions(_ values: NSSet)

    @objc(removeRegions:)
    @NSManaged public func removeFromRegions(_ values: NSSet)

}
