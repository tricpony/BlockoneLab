//
//  DetailViewController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController {
    var block: Block? = nil
    @IBOutlet weak var emptySelectionLabel: UILabel!
    @IBOutlet weak var pinWheel: UIActivityIndicatorView!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var producerSigLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var previousHashLabel: UILabel!
    @IBOutlet weak var bundleNbrLabel: UILabel!
    @IBOutlet weak var scheduleVersionLabel: UILabel!
    @IBOutlet weak var approvalDateLabel: UILabel!
    @IBOutlet weak var transactionCountLabel: UILabel!
    
    
    var forceDoneButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadServiceActivityIndicator()
        self.configUI()
    }

    override func engageActivityIndicator(spin: Bool) {
        DispatchQueue.main.async {
            self.pinWheel.isHidden = !spin
            if spin {
                self.pinWheel.startAnimating()
            }
            else{
                self.pinWheel.stopAnimating()
            }
        }
    }

    func configUI() {
        self.engageActivityIndicator(spin: false)
        if self.block == nil {
            self.emptySelectionLabel.isHidden = false
        }else
            if (self.block?.hasAnyEmptyTransactionData())! {
                if let emptyTransactions = self.block?.emptyTransactions() {
                    
                    self.engageActivityIndicator(spin: true)
                    DispatchQueue.global(qos: .background).async {
                        let ctx = NSManagedObjectContext.mr_context(withParent: self.managedObjectContext)
                        for nextEmptyTrans in emptyTransactions {
                            if let id = nextEmptyTrans.transactionID {
                                self.performGetTransactionService(hash: id, inContext: ctx, isLastCall:(nextEmptyTrans == emptyTransactions.last))
                            }
                        }
                    }
                }

        }
        
        if Display.isIphone() || self.forceDoneButton == true {
            var done: UIBarButtonItem
            
            //on the non-plus phone size class the split view detail expands as a modal, presenting buttom to top
            //unclear if this is caused by a flaw in my code or Apple or if it is expected behavior
            //but I could never force a normal push navigation without breaking another size class
            //consequently, unless we add this button there is no way back to the master view controller
            done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissCompactModal))
            self.navigationItem.leftBarButtonItem = done
        }
        self.fillBlockDataLabels()
    }
    
    func fillBlockDataLabels() {
        self.producerLabel.text = self.block?.producer
        self.producerSigLabel.text = self.block?.producerSignature
        self.hashLabel.text = self.block?.currentBlockHash
        self.previousHashLabel.text = self.block?.previousBlockHash
        
        if let blockNbr = self.block?.blockNum {
            self.bundleNbrLabel.text = String(blockNbr)
        }
        if let version = self.block?.scheduleVersion {
            self.scheduleVersionLabel.text = String(version)
        }
        
        if let date = self.block?.blockTimestamp {
            self.approvalDateLabel.text = self.displayDateValue(date as Date)
        }
    }
    
    // MARK: - EOS API Service Calls
    
    func performGetTransactionService(hash: String, inContext: NSManagedObjectContext, isLastCall: Bool) {
        let serviceRequest = ServiceManager()
        let argPayload = ["id":hash]
        
        serviceRequest.startService(forMethod: .get_transaction, args: argPayload) { (error: Error?, payload: Dictionary<String,Any>?) in
            if isLastCall {
                self.engageActivityIndicator(spin: false)
            }
            if error != nil {
                let nserror = error! as NSError
                self.presentAlert(title: "Network Alert", message: nserror.localizedDescription, handler: {
                    self.dismissCompactModal()
                })
                return
            }
            
            if let content = payload {
                Transaction.fillTransactionDetail(hash: hash, from: content, inContext: inContext)
            }
        }
    }

}
