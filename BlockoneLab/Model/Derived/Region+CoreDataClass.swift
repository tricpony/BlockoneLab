//
//  Region+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData

@objc(Region)
public class Region: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
