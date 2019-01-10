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
        let q = self.equalPredicate(key: "stale", value: false)
        let fetchRequest = Block.mr_requestAll(with: q, in: ctx)
        let sortOrder = NSSortDescriptor.init(key: "blockTimestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }
    
    class func fetchRequestForBlocksContaining(searchTerm: String, ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let q = self.containsTypePredicate(key: "producer", value: searchTerm)
        let rq = self.equalPredicate(key: "stale", value: false)
        let fetchRequest = Block.mr_requestAll(with: NSCompoundPredicate.init(andPredicateWithSubpredicates: [q,rq]), in: ctx)
        let sortOrder = NSSortDescriptor.init(key: "producer", ascending: true)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }
    
    class func fetchRequestForTransactions(inBlock: Block, ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let q = self.equalPredicate(key: "block", value: inBlock)
        let fetchRequest = Transaction.mr_requestAll(with: q, in: ctx)
        let sortOrder = NSSortDescriptor.init(key: "createDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }
    
    class func fetchedRequestForAllFavorites(ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = Favorite.mr_createFetchRequest();
        let sortOrder = NSSortDescriptor.init(key: "createDate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }

    class func fetchBlockChainInfo(in ctx: NSManagedObjectContext) -> BlockchainInfo? {
        var info: BlockchainInfo? = nil
        info = BlockchainInfo.mr_findFirst(in: ctx)
        return info
    }
    
    class func fetchBlockMatching(ID: String, inContext: NSManagedObjectContext) -> Block? {
        let qualifier = self.equalPredicate(key: "currentBlockHash", value: ID)
        
        return Block.mr_findFirst(with: qualifier, in: inContext)
    }
    
    class func fetchTransactionMatching(hash: String, inContext: NSManagedObjectContext) -> Transaction? {
        let qualifier = self.equalPredicate(key: "transactionID", value: hash)
        
        return Transaction.mr_findFirst(with: qualifier, in: inContext)!
    }
    
    class func fetchNewFavorites(inContext: NSManagedObjectContext) -> [NSManagedObject] {
        let qualifier = self.equalPredicate(key: "block.stale", value: false)
        
        return Favorite.mr_findAll(with: qualifier, in: inContext) ?? []
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
                                                        options: NSComparisonPredicate.Options.caseInsensitive)

        return q
    }
    
    class func greaterThanPredicate(key: String, value: Any) -> NSPredicate {
        let lhs: NSExpression = NSExpression.init(forKeyPath: key)
        let rhs: NSExpression = NSExpression.init(forConstantValue: value)
        let q: NSPredicate = NSComparisonPredicate.init(leftExpression: lhs,
                                                        rightExpression: rhs,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: NSComparisonPredicate.Operator.greaterThan,
                                                        options: NSComparisonPredicate.Options.normalized)
        
        return q
    }
}
