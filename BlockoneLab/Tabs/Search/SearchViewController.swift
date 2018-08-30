//
//  SearchViewController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    @IBOutlet weak var emptyResultsLabel: UILabel!
    let pinwheel = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    lazy var unfilteredFetchedResultsController: NSFetchedResultsController<Block> = {
        let fetchRequest = CoreDataUtility.fetchRequestForAllBlocks(ctx: self.managedObjectContext)
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.managedObjectContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        aFetchedResultsController.delegate = self
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return aFetchedResultsController as! NSFetchedResultsController<Block>
    }()

    func loadServiceActivityIndicator() {
        let activityButton = UIBarButtonItem(customView: self.pinwheel)
        self.navigationItem.leftBarButtonItem = activityButton
        self.pinwheel.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadServiceActivityIndicator()
        
        //enable auto cell height that uses constraints
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 45

        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "Search"
        self.emptyResultsLabel.isHidden = CoreDataUtility.fetchBlockCount(in: self.managedObjectContext) > 0
        
        //fetch block chain data
        self.performBlockChainInfoService()
    }

    func performBlockChainInfoService() {
        let serviceRequest = ServiceManager()

        serviceRequest.startService(forMethod: .get_info, args: nil) { (error: Error?, payload: Dictionary<String,Any>?) in
            if error != nil {
                let nserror = error! as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }

            if let content = payload {
                if BlockchainInfo.createBlockChainInfo(blockChainInfo: content, inContext: self.managedObjectContext) {
                    
                    DispatchQueue.main.async {
                        self.refreshBarButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.fetchLatestBlocks(howMany: 20)
    }

    func fetchLatestBlocks(howMany: Int8) {
        let chainInfo = CoreDataUtility.fetchBlockChainInfo(in: self.managedObjectContext)
        guard let latestFixedBlockID = chainInfo?.lastIrreversibleBlockID else{
            return
        }
        
        //delete the old ones first
        Block.clearAllBlocks(in: self.managedObjectContext)
        self.managedObjectContext.mr_saveToPersistentStoreAndWait()
        self.pinwheel.isHidden = false
        self.pinwheel.startAnimating()
        self.refreshBarButton.isEnabled = false

        DispatchQueue.global(qos: .background).async {
            let ctx = NSManagedObjectContext.mr_context(withParent: self.managedObjectContext)
            self.performGetBlockService(howMany: howMany, hash: latestFixedBlockID, inContext: ctx)
        }
    }
    
    func performGetBlockService(howMany: Int8, hash: String, inContext ctx: NSManagedObjectContext) {
        if howMany == 0 {
            DispatchQueue.main.async {
                self.pinwheel.stopAnimating();
                self.refreshBarButton.isEnabled = true
            }
            return
        }
        
        DispatchQueue.main.async {
            self.emptyResultsLabel.isHidden = CoreDataUtility.fetchBlockCount(in: ctx) > 0
        }

        let serviceRequest = ServiceManager()
        let argPayload = ["block_num_or_id":hash]

        serviceRequest.startService(forMethod: .get_block, args: argPayload, completionClosure: { (error: Error?, payload: Dictionary<String,Any>?) in
            if error != nil {
                let nserror = error! as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }

            if let content = payload, let freshBlock = Block.createBlock(blockInfo: content, inContext: ctx) {
                guard let previousHash = freshBlock.previousBlockHash else{
                    return
                }
                
                self.performGetBlockService(howMany: howMany-1, hash: previousHash, inContext: ctx)
            }
        })
    }

    func fetchedResultsController() -> NSFetchedResultsController<Block> {
        return unfilteredFetchedResultsController
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Table View
    
    func cellIdentifier(at indexPath: IndexPath) -> String {
        return "BlockCell"
    }
    
    func nextCellForTableView(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath))
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: self.cellIdentifier(at: indexPath))
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController().sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController().sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.nextCellForTableView(tableView, at: indexPath)
        let block: Block = fetchedResultsController().object(at: indexPath)
        
        cell.textLabel!.text = String(indexPath.row+1) + " " + (block.producer ?? "Producer Unknown")
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.splitViewController?.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
