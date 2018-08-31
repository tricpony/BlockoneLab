//
//  BaseViewController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    lazy var managedObjectContext: NSManagedObjectContext = {
        MagicalRecord.setupCoreDataStack(withStoreNamed:"BlockoneLab")
        return NSManagedObjectContext.mr_default()
    }()
    let pinwheel = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    func loadServiceActivityIndicator() {
        let activityButton = UIBarButtonItem(customView: self.pinwheel)
        self.navigationItem.leftBarButtonItem = activityButton
        self.pinwheel.isHidden = true
    }

    func engageActivityIndicator(spin: Bool = true) {
        DispatchQueue.main.async {
            self.pinwheel.isHidden = !spin
            if spin {
                self.pinwheel.startAnimating()
            }
            else{
                self.pinwheel.stopAnimating()
            }
        }
    }
    
    class func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window: UIWindow = appDelegate.window!
        let vSizeClass: UIUserInterfaceSizeClass!
        let hSizeClass: UIUserInterfaceSizeClass!
        
        hSizeClass = window.traitCollection.horizontalSizeClass
        vSizeClass = window.traitCollection.verticalSizeClass
        
        return (vertical: vSizeClass, horizontal: hSizeClass)
    }
    
    func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        return BaseViewController.sizeClass()
    }

    @objc func dismissCompactModal() {
        self.dismiss(animated: true, completion: nil)
    }

}
