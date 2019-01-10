//
//  Favorite+CoreDataClass.swift
//  
//
//  Created by aarthur on 1/9/19.
//
//

import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
