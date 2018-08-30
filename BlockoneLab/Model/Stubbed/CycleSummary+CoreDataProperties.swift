//
//  CycleSummary+CoreDataProperties.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData


extension CycleSummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CycleSummary> {
        return NSFetchRequest<CycleSummary>(entityName: "CycleSummary")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var region: Region?
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension CycleSummary {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}
