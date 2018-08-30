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
     
     {
     "previous": "00000004471d48fe40706e73ce27f9cf7bac1704ae55279c7a58c0173718a711",
     "timestamp": "2018-04-18T16:24:23.500",
     "transaction_mroot": "e366c0cc3519bb0f2ddaec20928fa4d6aae546194bb1c4205c67be429147ed4a",
     "action_mroot": "77e5e91b594ab4ebc44ebc8c7ecdc9d26409c5a07452d3b20a4840562fdeb658",
     "block_mroot": "4ef85b0d212f3fffabdd65680d32dd7dded3461d9df226a6e3dc232e42978f8b",
     "producer": "eosio",
     "schedule_version": 0,
     "new_producers": null,
     "producer_signature": "EOSJzEdFDsueKCerL7a6AdxMxiT851cEiugFB7ux1PAGn5eMmco8j32NsaKupxibheQGVFEqyEdjMub67VZjKmsLzuNxxKtUA",
     "regions": [{
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
     }],
     "input_transactions": [],
     "id": "000000056d75b0581b4fbb96affa36669a37173d21f46f8cb974f760e94bbe14",
     "block_num": 5,
     "ref_block_prefix": 2528857883
     }
     **/
    @discardableResult class func createBlock(blockInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> Block? {
        let ctx = inContext
        let block: Block? = Block.mr_createEntity(in: ctx)

        block?.previousBlockHash = blockInfo["previous"] as? String
        block?.currentBlockHash = blockInfo["id"] as? String
        block?.transactionMRoot = blockInfo["transaction_mroot"] as? String
        block?.actionMRoot = blockInfo["action_mroot"] as? String
        block?.blockMRoot = blockInfo["block_mroot"] as? String
        block?.producer = blockInfo["producer"] as? String
        block?.scheduleVersion = (blockInfo["schedule_version"] as? Int16)!
        block?.producerSignature = blockInfo["producer_signature"] as? String
        
        //save it
        ctx.mr_saveToPersistentStoreAndWait()

        return block
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
