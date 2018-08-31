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

    /**
     regionInfo looks like this:

     "region": 0,
     "cycles_summary": [
     [{
     "read_locks": [],
     "write_locks": [],
     "transactions": [{
     "status": "executed",
     "kcpu_usage": 2,
     "net_usage_words": 38,
     "id": "9880c128683e24845ccd282ebe026bd522f7fa9c6278d885f6ed35164c680669"
     }]
     }]
     ]

     **/
    class func createRegion(regionInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> Region? {
        let region = Region.mr_createEntity(in: inContext)
        region?.regionNum = (regionInfo["region"] as? Int32)!
        if let summaries = regionInfo["cycles_summary"] as? [Dictionary<String,Any>] {
            for summaryInfo in summaries {
                if let summary = CycleSummary.createCycleSummary(summaryInfo: summaryInfo, inContext: inContext) {
                    region?.addToCycleSummaries(summary)
                }
            }
        }
        return region
    }
    
    func transactionCount() -> Int {
        let transCount = self.cycleSummaries?.value(forKey: "transactionCount") as! [Int]
        
        return transCount.reduce(0, +)
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
