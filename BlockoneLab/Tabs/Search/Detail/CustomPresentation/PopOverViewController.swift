//
//  PopOverViewController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/31/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class PopOverViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var originFrame: CGRect = .zero
    var originY: CGFloat = 0
    var block: Block? = nil
    lazy var managedObjectContext: NSManagedObjectContext = {
        return NSManagedObjectContext.mr_default()
    }()
    lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = {
        let fetchRequest = CoreDataUtility.fetchRequestForTransactions(inBlock: self.block!, ctx: self.managedObjectContext)
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
        
        return aFetchedResultsController as! NSFetchedResultsController<Transaction>
    }()
    
    func applyBorder() {
        let layer = self.view.layer
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = 6.25
    }
    
    func registerTableAssets() {
        var nib: UINib!
        
        nib = UINib.init(nibName: "TransactionTableCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: TransactionTableCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyBorder()
        self.registerTableAssets()
        
        //enable auto cell height that uses constraints
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 145
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.originFrame = (self.presentingViewController?.view.convert(self.originFrame, to: self.view))!
        self.originY = self.originFrame.maxY + (self.originFrame.size.height * 2.0) + 5.0
    }
    
    
    // MARK: - PopoverProtocol
    
    func invalidateIntrinsicContentSize() {
        self.tableView.invalidateIntrinsicContentSize()
    }
    
    func intrinsicContentSize() -> CGSize {
        let itb = self.tableView as! IntrinsicTableView
        let size = itb.intrinsicContentSize()
        
        return self.maxSize(of: size)
    }

    //find the frame of the presented view converted to presenting view's coord system
    //then make sure our pop over does not extend beyond the bottom of the presenting
    //view's frame -- clip the content
    func maxSize(of intrinsicContentSize: CGSize) -> CGSize {
        let presentingVC = self.presentingViewController
        let presentingFrame = presentingVC?.view.frame
        var realSize = intrinsicContentSize
        let y = self.originY
        let maxHeight = (presentingFrame?.size.height)! - (y + 3.0)
        
        if intrinsicContentSize.height > maxHeight {
            realSize = CGSize(width: intrinsicContentSize.width, height: maxHeight)
        }
        
        return realSize
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
        return TransactionTableCell.cell_id
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
        let cell = self.nextCellForTableView(tableView, at: indexPath) as! TransactionTableCell
        let transaction: Transaction = fetchedResultsController.object(at: indexPath)
        
        cell.fromLabel.text = transaction.from ?? "Sender Unknown"
        cell.toLabel.text = transaction.to ?? "Recipient Unknown"
        cell.amountLabel.text = transaction.quantity ?? "Amount Unknown"
        cell.accountLabel.text = transaction.account ?? "Acct Uknown"
        cell.memoLabel.text = transaction.memo ?? "No Memo"
        cell.typeLabel.text = transaction.name ?? "Type Unknown"
        cell.byLabel.text = transaction.actor ?? "Actor Unknown"
        
        cell.accessoryType = UITableViewCellAccessoryType.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
