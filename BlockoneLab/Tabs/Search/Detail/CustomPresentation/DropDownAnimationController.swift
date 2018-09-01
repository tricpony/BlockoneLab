//
//  DropDownAnimationController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/31/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

enum DropDownAnimationDirection {
    case MOVE_IN
    case MOVE_OUT
}

protocol PopoverProtocol {
    func invalidateIntrinsicContentSize()
    func invalidateIntrinsicContentSize() -> CGSize
}

class DropDownAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    private let direction: DropDownAnimationDirection

    init(originFrame: CGRect, direction: DropDownAnimationDirection) {
        self.originFrame = originFrame
        self.direction = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.direction == .MOVE_IN ? 0.15:0.25;
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = self.transitionDuration(using: transitionContext)

        if self.direction == .MOVE_IN {
            //tried to use new swift 4 protocol syntax here - [Class & Protocol] but compiler would not cooperate
            guard let to_vc = (transitionContext.viewController(forKey: .to) as? PopOverViewController) else {
                    return
            }
            
            let presentedFrame = transitionContext.finalFrame(for: to_vc )
            let x = presentedFrame.origin.x
            let y = presentedFrame.origin.y
            let w = presentedFrame.size.width
            let flatFrame = CGRect(x: x, y: y, width: w, height: 0)
            transitionContext.containerView.addSubview(to_vc.view)
            
            if self.direction == .MOVE_IN {
                to_vc.view.frame = flatFrame
                
                UIView.animate(withDuration: duration, animations: {
                    to_vc.view.frame = CGRect(x: x, y: y, width: w, height: to_vc.intrinsicContentSize().height)
                }) { (finished: Bool) in
                    UIView.animate(withDuration: 0.05, animations: {
                        to_vc.view.frame = CGRect(x: x, y: y, width: w, height: to_vc.intrinsicContentSize().height)
                    }, completion: { (finis: Bool) in
                        transitionContext.completeTransition(finis)
                    })
                }
                
            }

        }else
        {
            guard let from_vc = transitionContext.viewController(forKey: .from) else {
                    return
            }

            let presentedFrame = transitionContext.finalFrame(for: from_vc )
            let x = presentedFrame.origin.x
            let y = presentedFrame.origin.y
            let w = presentedFrame.size.width

            UIView.animate(withDuration: duration, animations: {
                from_vc.view.frame = CGRect(x: x, y: y, width: w, height: 0)
            }) { (finished: Bool) in
                transitionContext.completeTransition(finished)
            }
            
        }
        
    }
    
}
