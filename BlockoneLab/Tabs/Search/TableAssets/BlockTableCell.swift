//
//  BlockTableCell.swift
//  BlockoneLab
//
//  Created by aarthur on 8/30/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class BlockTableCell: UITableViewCell {
    static let cell_id = "BlockCellID"

    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.drawCountBadge()
    }

    func drawCountBadge() {
        let desiredLineWidth:CGFloat = 1.5
        let hw:CGFloat = desiredLineWidth/2
        let circlePath = UIBezierPath(ovalIn: self.countBackgroundView.bounds.insetBy(dx: hw, dy: hw))
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = self.countBackgroundView.backgroundColor?.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        shapeLayer.opacity = 0.45
        shapeLayer.name = "shape"
        self.countBackgroundView.layer.addSublayer(shapeLayer)
        self.countBackgroundView.backgroundColor = UIColor.clear
    }
    
    func fadeInCountBadge() {
        var shapeLayer: CAShapeLayer? = nil
        let sublayers = self.countBackgroundView.layer.sublayers
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity");

        for layer in sublayers! {
            if layer.name == "shape" {
                shapeLayer = (layer as! CAShapeLayer)
                break
            }
        }
        
        animation.fromValue = shapeLayer?.opacity
        animation.toValue = 1
        animation.duration = 1.0
        shapeLayer?.add(animation, forKey: nil)
    }
    
}
