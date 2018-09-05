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
    var isPresenting: Bool = false
    @IBOutlet weak var emptySelectionLabel: UILabel!
    @IBOutlet weak var pinWheel: UIActivityIndicatorView!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var producerSigLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var previousHashLabel: UILabel!
    @IBOutlet weak var blockNbrLabel: UILabel!
    @IBOutlet weak var scheduleVersionLabel: UILabel!
    @IBOutlet weak var approvalDateLabel: UILabel!
    @IBOutlet weak var transactionCountLabel: UILabel!
    @IBOutlet weak var transSwitchBanner: UIView!
    @IBOutlet weak var masterCanvas: UIView!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    @IBAction func presentTransactions(_ sender: Any) {
        let toggleSwitch = sender as? UISwitch
        
        if (toggleSwitch?.isOn)! {
            self.isPresenting = true
            self.performSegue(withIdentifier: "transactionSegue", sender: self)
        }else
        {
            self.isPresenting = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadServiceActivityIndicator()
        self.configUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
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
        self.emptySelectionLabel.isHidden = self.block != nil
        self.masterCanvas.isHidden = self.block == nil
        
        if Display.isIphone() {
            var done: UIBarButtonItem
            
            //on the non-plus phone size class the split view detail expands as a modal, presenting buttom to top
            //unclear if this is caused by a flaw in my code or Apple or if it is expected behavior
            //but I could never force a normal push navigation without breaking another size class
            //consequently, unless we add this button there is no way back to the master view controller
            done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissCompactModal))
            self.navigationItem.leftBarButtonItem = done
        }

        self.engageActivityIndicator(spin: false)
        guard let safeBlock = self.block else{
            return
        }

        if safeBlock.hasAnyEmptyTransactionData() {
            let emptyTransactions = safeBlock.emptyTransactions()
            
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
        
        self.fillBlockDataLabels()
    }
    
    func fillBlockDataLabels() {
        self.producerLabel.text = self.block?.producer
        self.producerSigLabel.text = self.block?.producerSignature
        self.hashLabel.text = self.block?.currentBlockHash
        self.previousHashLabel.text = self.block?.previousBlockHash
        
        if let blockNbr = self.block?.blockNum {
            self.blockNbrLabel.text = String(blockNbr)
        }
        if let version = self.block?.scheduleVersion {
            self.scheduleVersionLabel.text = String(version)
        }
        
        if let date = self.block?.blockTimestamp {
            self.approvalDateLabel.text = self.displayDateValue(date as Date)
        }
        
        if let count = self.block?.transactionCount() {
            self.transactionCountLabel.text = String(count) + " Transactions"
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
    
    // MARK: - Size Class
    
    @objc func rotated() {
        if self.isPresenting && (self.sizeClass().horizontal == .regular) {
            self.dismiss(animated: true, completion: nil)
            self.toggleSwitch.setOn(false, animated: false)
        }
        
        if UIDevice.current.orientation.isPortrait {
            self.toggleSwitch.isEnabled = true
        }else if Display.isIphonePlus() && UIDevice.current.orientation.isLandscape {
            self.toggleSwitch.isEnabled = false
        }
        
    }
    
    // MARK: - Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "transactionSegue" {
            let vc = segue.destination as? PopOverViewController
            vc?.block = self.block
            vc?.transitioningDelegate = self
            vc?.modalPresentationStyle = .custom
            vc?.originFrame = self.transSwitchBanner.frame
        }
    }

}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {

        let presentingFrame = source.view.convert(self.transSwitchBanner.frame, to: presented.view)
        let presentationController = DropDownPresentationController(presentedViewController: presented,
                                                                   presenting: source,
                                                                   origin: presentingFrame)
        return presentationController
    }

    /**
     This supports a custom controller transition executed by tapping the switch
     **/
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return DropDownAnimationController(originFrame: self.transSwitchBanner.frame, direction: .MOVE_IN)
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return DropDownAnimationController(originFrame: self.transSwitchBanner.frame, direction: .MOVE_OUT)
    }

}

