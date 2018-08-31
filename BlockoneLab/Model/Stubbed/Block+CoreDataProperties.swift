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
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension Block {
    
    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)
    
    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)
    
    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)
    
    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)
    
}

