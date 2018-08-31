//
//  Transaction+CoreDataProperties.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var kcpu_usage: Int32
    @NSManaged public var status: String?
    @NSManaged public var transactionID: String?
    @NSManaged public var usageWords: Int32
    @NSManaged public var account: String?
    @NSManaged public var actor: String?
    @NSManaged public var permission: String?
    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var memo: String?
    @NSManaged public var quantity: String?
    @NSManaged public var cycleSummary: CycleSummary?
    @NSManaged public var block: Block?

}
