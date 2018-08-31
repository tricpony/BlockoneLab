//
//  Block+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData

@objc(Block)
public class Block: NSManagedObject {

    class func clearAllBlocks(in ctx: NSManagedObjectContext) {
        Block.mr_deleteAll(matching: NSPredicate(value: true), in: ctx);
    }
    
    /**
     blockInfo looks like this:
     
     ["confirmed": 0,
     "header_extensions": <__NSArray0 0x60000000cdf0>(),
     "id": "000000056d75b0581b4fbb96affa36669a37173d21f46f8cb974f760e94bbe14",
     "block_num": 5,
     "schedule_version": 307,
     "producer_signature": SIG_K1_KhNJ1eK9FtrQy3tcoPPX3p3rB4vzdJobSwhqDugzB2qG9ZWaX9AYcuBPRaYDi2cTYG3m9GXNAr11Zxpgr25nnRtkzzEmn8,
     "timestamp": 2018-08-30T22:13:59.000,
     "producer": jedaaaaaaaaa,
     "action_mroot": 979ee4e884d368b64bfbb9d8526c71d73249a396766fa5e3e32a145ce682fc39,
     "new_producers": <null>,
     "ref_block_prefix": 1082921948,
     "previous": 00d40c050f031188eb44dc6a5965334bdace9e34098f7a4e1905c1caa9f3cc65,
     "id": 00d40c067b747baedc138c40c2de0e4eb3e7e943cebfd6be01f8e39055cf457b,
     "block_extensions": <__NSArray0 0x60000000cdf0>(),
     "transactions": <__NSArrayI 0x60c0002878a0>(
     {
     "cpu_usage_us" = 378;
     "net_usage_words" = 0;
     status = executed;
     trx = 726568181973c5b027d0f1a5d4e106d6e291370041f530af755e1d9b2909c546;
     },
     {
     "cpu_usage_us" = 362;
     "net_usage_words" = 0;
     status = executed;
     trx = b5e7ebcff0af61b6800b254b3a67d5c56ec60868c0f4a3d7cc7a1d17f7f6e6c8;
     },
     {
     "cpu_usage_us" = 358;
     "net_usage_words" = 0;
     status = executed;
     trx = 930242cde5b640b32d4df4a7a09b487846d648b319584922fa8ea4a2cab94399;
     },
     {
     "cpu_usage_us" = 941;
     "net_usage_words" = 29;
     status = executed;
     trx =     {
     compression = none;
     "context_free_data" =         (
     );
     id = adcb6f64f02ec5307ee41976901074ccc03a1ea8ef77e0daf760e8a2d9dc220c;
     "packed_context_free_data" = "";
     "packed_trx" = 436c885bb70a713e5079000000000100a6823403ea3055000000572d3ccdcd014086084ae1e8305500000000a8ed32328a014086084ae1e83055a0a662ff48958569010000000000000004454f5300000000695b20687474703a2f2f6c75636b796f732e696f205d5b454f532c20454f534441432c20424c41434b20737570706f727465645d20526f636b2d53636973736f72732d50617065722067616d65206261736564206f6e20454f5320736d61727420636f6e74726163742e00;
     signatures =         (
     "SIG_K1_KViwyzDm1AM8gVF5g9Ckt5YyWccnedVfTJ4QBm3rZEMWG5JsNTJLr5LTVaxw8CzwJBMExnNTZXdemrq42nE221qVuG3UAy"
     );
     transaction =         {
     actions =             (

     <snip>

     }
     
     Relevant root block data is at the top of this structure.  See Transaction class for detailed comments on the rest.
     **/
    @discardableResult class func createBlock(blockInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> Block? {
        let ctx = inContext
        let block: Block? = Block.mr_createEntity(in: ctx)

        if let time = blockInfo[API.TIMESTAMP] as? String {
            block?.blockTimestamp = API.dateFormatter().date(from: time) as NSDate?
        }
        block?.previousBlockHash = blockInfo[API.PREVIOUS] as? String
        block?.currentBlockHash = blockInfo[API.ID] as? String
        block?.transactionMRoot = blockInfo[API.TRANSACTION_MROOT] as? String
        block?.actionMRoot = blockInfo[API.ACTION_MROOT] as? String
        block?.blockMRoot = blockInfo[API.BLOCK_MROOT] as? String
        block?.producer = blockInfo[API.PRODUCER] as? String
        block?.scheduleVersion = (blockInfo[API.SCHEDULE_VERSION] as? Int16)!
        block?.producerSignature = blockInfo[API.PRODUCER_SIGNATURE] as? String
        block?.blockNum = (blockInfo[API.BLOCK_NUM] as? Int64)!
        block?.refBlockPrefix = (blockInfo[API.REF_BLOCK_PREFIX] as? Int64)!
        
        if let transactions = blockInfo[API.TRANSACTIONS] as? [Dictionary<String,Any>] {
            
            for transactionInfo in transactions {
                if let transaction = Transaction.createTransaction(trx: transactionInfo, inContext: inContext) {
                    block?.addToTransactions(transaction)
                }
            }
        }
                
        //save it
        ctx.mr_saveToPersistentStoreAndWait()

        return block
    }
    
    func transactionCount() -> Int {
        return self.transactions?.count ?? 0
    }

    func hasAnyEmptyTransactionData() -> Bool {
        let qualifier = CoreDataUtility.equalPredicate(key: "usageWords", value: 0)
        let results = self.transactions?.filtered(using: qualifier)
        
        return (results?.count)! > 0
    }
    
    func hasAllTransactionData() -> Bool {
        let qualifier = CoreDataUtility.greaterThanPredicate(key: "usageWords", value: 0)
        let results = self.transactions?.filtered(using: qualifier)
        
        return results?.count == self.transactions?.count
    }
    
    func emptyTransactions() -> [Transaction] {
        let qualifier = CoreDataUtility.equalPredicate(key: "usageWords", value: 0)
        let results: Set = (self.transactions?.filtered(using: qualifier))!
        
        return Array(results) as! [Transaction]
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
