//
//  CoreDataUtility.swift
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import Foundation

class CoreDataUtility {
    
    class func fetchBlockchainInfoCount(in ctx: NSManagedObjectContext) -> UInt {
        return BlockchainInfo.mr_countOfEntities(with: nil, in: ctx)
    }
    
    class func fetchBlockCount(in ctx: NSManagedObjectContext) -> UInt {
        return Block.mr_countOfEntities(with: nil, in: ctx)
    }
    
    class func fetchRequestForAllBlocks(ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = Block.mr_createFetchRequest(in: ctx)
        let sortOrder = NSSortDescriptor.init(key: "blockTimestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }
    
    class func fetchBlockChainInfo(in ctx: NSManagedObjectContext) -> BlockchainInfo? {
        var info: BlockchainInfo? = nil
        info = BlockchainInfo.mr_findFirst(in: ctx)
        return info
    }
        
    // MARK: - Pre-fabbed predicates
    
    class func equalPredicate(key: String, value: Any) -> NSPredicate {
        let lhs: NSExpression = NSExpression.init(forKeyPath: key)
        let rhs: NSExpression = NSExpression.init(forConstantValue: value)
        let q: NSPredicate = NSComparisonPredicate.init(leftExpression: lhs,
                                                        rightExpression: rhs,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: NSComparisonPredicate.Operator.equalTo,
                                                        options: NSComparisonPredicate.Options.diacriticInsensitive)
        
        return q
    }

    class func containsTypePredicate(key: String, value: Any) -> NSPredicate {
        let lhs: NSExpression = NSExpression.init(forKeyPath: key)
        let rhs: NSExpression = NSExpression.init(forConstantValue: value)
        let q: NSPredicate = NSComparisonPredicate.init(leftExpression: lhs,
                                                        rightExpression: rhs,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: NSComparisonPredicate.Operator.contains,
                                                        options: NSComparisonPredicate.Options.diacriticInsensitive)

        return q
    }
    
}
