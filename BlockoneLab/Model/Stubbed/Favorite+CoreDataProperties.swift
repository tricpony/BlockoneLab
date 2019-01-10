//
//  Favorite+CoreDataProperties.swift
//  
//
//  Created by aarthur on 1/9/19.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }
    
    @NSManaged public var createDate: NSDate?
    @NSManaged public var block: Block?

}
