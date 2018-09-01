//
//  TransactionTableCell.swift
//  BlockoneLab
//
//  Created by aarthur on 8/31/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class TransactionTableCell: UITableViewCell {
    static let cell_id = "TransactionCellID"

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
