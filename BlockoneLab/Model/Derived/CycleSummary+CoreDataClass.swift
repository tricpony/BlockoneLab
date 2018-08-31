//
//  CycleSummary+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData

@objc(CycleSummary)
public class CycleSummary: NSManagedObject {

    /**
     summaryInfo looks like this:
     
     [
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
     
     **/
    class func createCycleSummary(summaryInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> CycleSummary? {
        let summary = CycleSummary.mr_createEntity(in: inContext)
        if let transactions = summaryInfo["transactions"] as? [Dictionary<String,Any>] {
            for transactionInfo in transactions {
                if let transaction = Transaction.createTransaction(trx: transactionInfo, inContext: inContext) {
                    summary?.addToTransactions(transaction)
                }
            }
        }
        
        return summary
    }
    
    func transactionCount() -> Int {
        return self.transactions?.count ?? 0
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
