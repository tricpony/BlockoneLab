//
//  FavoritesViewController.swift
//  BlockoneLab
//
//  Created by aarthur on 1/9/19.
//  Copyright © 2019 Gigabit LLC. All rights reserved.
//

import UIKit

class FavoritesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    lazy var managedObjectContext: NSManagedObjectContext = {
        return NSManagedObjectContext.mr_default()
    }()
    
    lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        
        formatter.dateFormat = "EEE, MMM d, hh:mm:ss aaa"
        return formatter
    }()

    lazy var fetchedResultsController: NSFetchedResultsController<Favorite> = {
        let fetchRequest = CoreDataUtility.fetchedRequestForAllFavorites(ctx: self.managedObjectContext)
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
        
        return aFetchedResultsController as! NSFetchedResultsController<Favorite>
    }()

    func registerTableAssets() {
        var nib: UINib!
        
        nib = UINib.init(nibName: "BlockTableCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: BlockTableCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableAssets()
        
        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()
        self.title = "Favorites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let sizeClass = BaseViewController.sizeClass()
        if (sizeClass.vertical == .regular) && (sizeClass.horizontal == .compact) {
            (self.splitViewController as! SplitViewController).isOnFavorites = true
        }
    }

    func displayDateValue(_ date: Date) -> String {
        return self.dateFormatter.string(from: date)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlockTableCell = self.nextCellForTableView(tableView, at: indexPath) as! BlockTableCell
        let fav: Favorite = fetchedResultsController.object(at: indexPath)
        
        if let block = fav.block {
        
            cell.countLabel.text = String(indexPath.row+1)
            cell.producerLabel.text = (block.producer ?? "Unknown")
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.dateLabel.text = self.displayDateValue(block.blockTimestamp! as Date)
            cell.statusLabel.text = String(block.transactionCount()) + " Transactions"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if BaseViewController.sizeClass().horizontal == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.performSegue(withIdentifier: "blockDetailSegue", sender: indexPath)
        
        if self.splitViewController?.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
        }

    }

    // MARK: - Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blockDetailSegue" {
            if let indexPath = sender as? IndexPath {
                let fav: Favorite = fetchedResultsController.object(at: indexPath)
                
                if let block = fav.block {
                    let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                    vc.block = block
                    vc.navigationItem.title = block.producer
                    vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    vc.navigationItem.leftItemsSupplementBackButton = true
                }
                
                //this clears the title of the back button to leave only the chevron
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }
    
}
