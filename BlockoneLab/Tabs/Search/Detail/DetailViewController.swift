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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }

    func configUI() {
        self.pinWheel.isHidden = true
        if self.block == nil {
            self.emptySelectionLabel.isHidden = false
        }else{

        }
    }
}
