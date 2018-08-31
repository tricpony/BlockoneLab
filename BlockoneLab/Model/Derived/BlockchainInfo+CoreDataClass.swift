//
//  BlockchainInfo+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData

@objc(BlockchainInfo)
public class BlockchainInfo: NSManagedObject {

    /**
     blockChainInfo looks like this:
     
     {
     "server_version":"817b1d01",
     "chain_id":"aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906",
     "head_block_num":13720231,
     "last_irreversible_block_num":13719904,
     "last_irreversible_block_id":"00d159602f6109134741582ba58c218a146a48387f3bf87bd20bd48b01dea216",
     "head_block_id":"00d15aa709baa835f6ed8c2ba29a4f430591d63c806c29357da0eb2bfa47c59d",
     "head_block_time":"2018-08-29T21:30:13.500",
     "head_block_producer":"eosbeijingbp",
     "virtual_block_cpu_limit":26182050,
     "virtual_block_net_limit":1048576000,
     "block_cpu_limit":195544,
     "block_net_limit":1048288}
     **/
    @discardableResult class func createBlockChainInfo(blockChainInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> Bool {
        let ctx = inContext
        var chainInfo: BlockchainInfo? = nil
        
        if CoreDataUtility.fetchBlockchainInfoCount(in: ctx) > 0 {
            chainInfo = CoreDataUtility.fetchBlockChainInfo(in: ctx)
        }
        else{
            chainInfo = BlockchainInfo.mr_createEntity(in: ctx)
        }
        chainInfo?.serverVersion = blockChainInfo[API.SERVER_VERSION] as? String
        chainInfo?.headBlockNum = (blockChainInfo[API.HEAD_BLOCK_NUM] as? Int64)!
        chainInfo?.lastIrreversibleBlockNum = (blockChainInfo[API.LAST_IRREVERSIBLE_BLOCK_NUM] as? Int64)!
        chainInfo?.lastIrreversibleBlockID = blockChainInfo[API.LAST_IRREVERSIBLE_BLOCK_ID] as? String
        chainInfo?.chainID = blockChainInfo[API.CHAIN_ID] as? String
        chainInfo?.headBlockID = blockChainInfo[API.HEAD_BLOCK_ID] as? String
        chainInfo?.headBlockProducer = blockChainInfo[API.HEAD_BLOCK_PRODUCER] as? String
        
        //save it
        ctx.mr_saveToPersistentStoreAndWait()
        
        //if we don't have this then nothing else will work
        return chainInfo?.lastIrreversibleBlockID != nil
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
