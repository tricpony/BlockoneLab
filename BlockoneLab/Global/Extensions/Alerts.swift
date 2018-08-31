//
//  Alerts.swift
//  BlockoneLab
//
//  Created by aarthur on 8/31/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

extension UIViewController {

    typealias MethodType = () -> Void

    func presentAlert(title: String, message: String, handler: @escaping MethodType) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction.init(title: "OK", style: .default) { (action: UIAlertAction) in
            handler()
        }
        
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
}
