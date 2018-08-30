//
//  Region+CoreDataProperties.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: "Region")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var regionNum: Int32
    @NSManaged public var attribute: NSObject?
    @NSManaged public var cycleSummaries: NSSet?
    @NSManaged public var block: Block?

}

// MARK: Generated accessors for cycleSummaries
extension Region {

    @objc(addCycleSummariesObject:)
    @NSManaged public func addToCycleSummaries(_ value: CycleSummary)

    @objc(removeCycleSummariesObject:)
    @NSManaged public func removeFromCycleSummaries(_ value: CycleSummary)

    @objc(addCycleSummaries:)
    @NSManaged public func addToCycleSummaries(_ values: NSSet)

    @objc(removeCycleSummaries:)
    @NSManaged public func removeFromCycleSummaries(_ values: NSSet)

}
