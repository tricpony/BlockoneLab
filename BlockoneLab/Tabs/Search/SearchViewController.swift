//
//  SearchViewController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    @IBOutlet weak var emptyResultsLabel: UILabel!
    let searchController = UISearchController(searchResultsController: nil)
    var isLoading = false
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

    func filteredFetchedResultsController() -> NSFetchedResultsController<Block> {
        let fetchRequest = CoreDataUtility.fetchRequestForBlocksContaining(searchTerm: searchController.searchBar.text!, ctx: self.managedObjectContext)
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
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<Block> {
        let unfilteredFetchedResultsController = self.unfilteredFetchedResultsController
        let filteredFetchedResultsController = self.filteredFetchedResultsController
        
        if isFiltering() {
            return filteredFetchedResultsController()
        }
        unfilteredFetchedResultsController.delegate = self
        return unfilteredFetchedResultsController
    }
    
    func registerTableAssets() {
        var nib: UINib!
        
        nib = UINib.init(nibName: "BlockTableCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: BlockTableCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadServiceActivityIndicator()
        self.registerTableAssets()
        
        //enable auto cell height that uses constraints
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 45

        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "Search"
        self.emptyResultsLabel.isHidden = CoreDataUtility.fetchBlockCount(in: self.managedObjectContext) > 0
        self.setupSearchController(shouldEnable: CoreDataUtility.fetchBlockCount(in: self.managedObjectContext) > 0)
        
        //fetch block chain data
        self.performGetBlockChainInfoService()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let sizeClass = BaseViewController.sizeClass()
        if (sizeClass.vertical == .regular) && (sizeClass.horizontal == .compact) {
            (self.splitViewController as! SplitViewController).isOnFavorites = false
        }
    }

    func setupSearchController(shouldEnable: Bool) {
        if !shouldEnable {return}
        
        //on initial launch of app we make the service call to fetch the data which returns in a closure
        //in that case we must force the execution of this logic on the main thread to prevent a crash
        //on every launch thereafter setupSearchController gets called on the main thread and this GCD
        //call really does not matter
        DispatchQueue.main.async {
            self.searchController.searchResultsUpdater = self
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchBar.barTintColor = UIColor.black
            self.navigationItem.searchController = self.searchController
            self.searchController.searchBar.placeholder = "Search Producer"
            self.navigationItem.hidesSearchBarWhenScrolling = false
            self.definesPresentationContext = true
        }
    }
    
    // MARK: - EOS API Service Calls

    func performGetBlockChainInfoService() {
        let serviceRequest = ServiceManager()

        serviceRequest.startService(forMethod: .get_info, args: nil) { (error: Error?, payload: Dictionary<String,Any>?) in
            if error != nil {
                let nserror = error! as NSError
                self.presentAlert(title: "Network Alert", message: nserror.localizedDescription, handler: {

                })
                return
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
        self.engageActivityIndicator()
        self.refreshBarButton.isEnabled = false
        self.isLoading = true

        DispatchQueue.global(qos: .background).async {
            let ctx = NSManagedObjectContext.mr_context(withParent: self.managedObjectContext)
            self.performGetBlockService(howMany: howMany, hash: latestFixedBlockID, inContext: ctx)
        }
    }
    
    func performGetBlockService(howMany: Int8, hash: String, inContext ctx: NSManagedObjectContext) {
        if howMany == 0 {
            DispatchQueue.main.async {
                self.isLoading = false
                self.engageActivityIndicator(spin: false)
                self.refreshBarButton.isEnabled = true
                self.tableView.reloadData()
                
                //let the block chain info core data object point to the latest block core data object
                let blockChain = CoreDataUtility.fetchBlockChainInfo(in: self.managedObjectContext)
                let latestBlock = CoreDataUtility.fetchBlockMatching(ID: (blockChain?.lastIrreversibleBlockID)!, inContext: self.managedObjectContext)
                blockChain?.lastIrreversibleBlock = latestBlock
                self.managedObjectContext.mr_saveToPersistentStoreAndWait()
            }
            return
        }
        
        DispatchQueue.main.async {
            self.emptyResultsLabel.isHidden = CoreDataUtility.fetchBlockCount(in: ctx) > 0
            self.setupSearchController(shouldEnable: CoreDataUtility.fetchBlockCount(in: self.managedObjectContext) > 0)
        }

        let serviceRequest = ServiceManager()
        let argPayload = ["block_num_or_id":hash]

        serviceRequest.startService(forMethod: .get_block, args: argPayload, completionClosure: { (error: Error?, payload: Dictionary<String,Any>?) in
            if error != nil {
                let nserror = error! as NSError
                self.presentAlert(title: "Network Alert", message: nserror.localizedDescription, handler: {
                    
                })
                return
            }

            if let content = payload, let freshBlock = Block.createBlock(blockInfo: content, inContext: ctx) {
                guard let previousHash = freshBlock.previousBlockHash else{
                    return
                }
                
                self.performGetBlockService(howMany: howMany-1, hash: previousHash, inContext: ctx)
            }
        })
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
        return BlockTableCell.cell_id
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
        let cell: BlockTableCell = self.nextCellForTableView(tableView, at: indexPath) as! BlockTableCell
        let block: Block = fetchedResultsController().object(at: indexPath)
        
        if self.isFiltering() {
            let highlightedSearchTerm = NSMutableAttributedString(string: block.producer!)
            let range = block.producer?.range(of: searchController.searchBar.text!, options: .caseInsensitive)
            
            highlightedSearchTerm.addAttribute(.backgroundColor,
                                               value: UIColor.yellow,
                                               range: NSRange.init(location: (range?.lowerBound.encodedOffset)!,
                                                                   length: (range?.upperBound.encodedOffset)! - (range?.lowerBound.encodedOffset)!))
            cell.producerLabel?.attributedText = highlightedSearchTerm
        }
        else{
            cell.producerLabel.text = (block.producer ?? "Unknown")
        }
        cell.dateLabel.text = self.displayDateValue(block.blockTimestamp! as Date)
        cell.statusLabel.text = String(block.transactionCount()) + " Transactions"
        if !self.isLoading {
            cell.countLabel.text = String(indexPath.row+1)
        }
        else{
            cell.countLabel.text = ""
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.sizeClass().horizontal == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.performSegue(withIdentifier: "blockDetailSegue", sender: indexPath)
    }

    // MARK: - Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blockDetailSegue" {
            if let indexPath = sender as? IndexPath {
                let block: Block = fetchedResultsController().object(at: indexPath)
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                vc.block = block
                vc.navigationItem.title = block.producer
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
                
                //this clears the title of the back button to leave only the chevron
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }

}
