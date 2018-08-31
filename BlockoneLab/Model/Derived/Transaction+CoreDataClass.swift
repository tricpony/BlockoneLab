//
//  Transaction+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/29/18.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {

    /**
     transactionInfo looks like this:
     
     , "transactions": <__NSArrayI 0x60c0002878a0>(
     {
     "cpu_usage_us" = 378;
     "net_usage_words" = 0;
     status = executed;
     trx = 726568181973c5b027d0f1a5d4e106d6e291370041f530af755e1d9b2909c546;
     },
     
     <snip>

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
     {
     account = "eosio.token";
     authorization =                     (
     {
     actor = eosilsee1234;
     permission = active;
     }
     );
     data =                     {
     from = eosilsee1234;
     memo = "[ http://luckyos.io ][EOS, EOSDAC, BLACK supported] Rock-Scissors-Paper game based on EOS smart contract.";
     quantity = "0.0001 EOS";
     to = ha2tembzgene;
     };
     "hex_data" = 4086084ae1e83055a0a662ff48958569010000000000000004454f5300000000695b20687474703a2f2f6c75636b796f732e696f205d5b454f532c20454f534441432c20424c41434b20737570706f727465645d20526f636b2d53636973736f72732d50617065722067616d65206261736564206f6e20454f5320736d61727420636f6e74726163742e;
     name = transfer;
     }
     );
     "context_free_actions" =             (
     );
     "delay_sec" = 0;
     expiration = "2018-08-30T22:14:27";
     "max_cpu_usage_ms" = 0;
     "max_net_usage_words" = 0;
     "ref_block_num" = 2743;
     "ref_block_prefix" = 2035302001;
     "transaction_extensions" =             (
     );
     };
     };
     },

     <snip>
     
     Observe that when net_usage_words == 0 trx is a transaction hash, when net_usage_words > 0 trx is the full transaction node
     **/
    class func createTransaction(trx transactionInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> Transaction? {
        let transaction = Transaction.mr_createEntity(in: inContext)
        
        transaction?.status = transactionInfo["status"] as? String
        transaction?.usageWords = (transactionInfo["net_usage_words"] as? Int32)!
        
        if transaction?.usageWords == 0 {
            transaction?.transactionID = transactionInfo["trx"] as? String
        }
        else{
            if let fullTransactionInfo = transactionInfo["trx"] as? Dictionary<String,Any> {
                transaction?.transactionID = fullTransactionInfo["id"] as? String
                
                /*
                 $$$$ Full Trans: ["transaction": {
                 actions =     (
                 {
                 account = "eosio.token";
                 authorization =             (
                 {
                 actor = gu2damztgmge;
                 permission = active;
                 }
                 );
                 data =             {
                 from = gu2damztgmge;
                 memo = "83--";
                 quantity = "1.0000 EOS";
                 to = eosbetdice11;
                 };
                 "hex_data" = a09864f94b9384661082422e65753055102700000000000004454f53000000000438332d2d;
                 name = transfer;
                 }
                 );

                 For brevity, only using the first object in this array - plus I don't really understand what it means
                */
                if let rawTransactionInfo = fullTransactionInfo["transaction"] as? Dictionary<String,Any>,
                    let actionsInfoArray = rawTransactionInfo["actions"] as? [Dictionary<String,Any>],
                    let accountInfo = actionsInfoArray.first {
                    
                    transaction?.account = accountInfo["account"] as? String
                    if let authorizationInfoArray = accountInfo["authorization"] as? [Dictionary<String,String>],
                        let authorizationInfo = authorizationInfoArray.first {
                        transaction?.actor = authorizationInfo["actor"]
                        transaction?.permission = authorizationInfo["permission"]
                    }
                    
                    /*
                     from = eosilsee1234;
                     memo = "[ http://luckyos.io ][EOS, EOSDAC, BLACK supported] Rock-Scissors-Paper game based on EOS smart contract.";
                     quantity = "0.0001 EOS";
                     to = ha2tembzgene;
                     */
                    if let tradeInfo = accountInfo["data"] as? Dictionary<String,Any> {
                        transaction?.from = tradeInfo["from"] as? String
                        transaction?.to = tradeInfo["to"] as? String
                        transaction?.quantity = tradeInfo["quantity"] as? String
                        transaction?.memo = tradeInfo["memo"] as? String
                    }
                }
                
            }
            
        }
        
        return transaction
    }
    
    func hasTransactionData() -> Bool {
        return self.usageWords > 0
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
