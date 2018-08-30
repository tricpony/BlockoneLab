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
    @NSManaged public var status: String?
    @NSManaged public var kcpu_usage: Int32
    @NSManaged public var usageWords: Int32
    @NSManaged public var transactionID: String?
    @NSManaged public var cycleSummary: CycleSummary?

}
