//
//  DropDownPresentationController.swift
//  BlockoneLab
//
//  Created by aarthur on 8/31/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class PassThruView: UIView {
    var targetView: UIView? = nil
    
    /**
     This will pass thru tap events to the underlying view controller during presentation
    **/
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hit = super.hitTest(point, with: event)
        if hit == self {
            hit = self.targetView?.hitTest(self.convert(point, to: self.targetView), with: event)
        }
        
        return hit
    }
}

class DropDownPresentationController: UIPresentationController {
    private let originFrame: CGRect
    private let passThruView: PassThruView
    private let widthBuffer: CGFloat = 4.0
    private let heightBuffer: CGFloat = 2.0
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, origin: CGRect) {
        self.originFrame = origin
        
        //insert a view that will pass tap events thru
        self.passThruView = PassThruView()
        self.passThruView.targetView = presentingViewController?.view
        self.passThruView.backgroundColor = UIColor.clear
        
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }

    override func containerViewWillLayoutSubviews() {
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        var w = parentSize.width - (widthBuffer * 2.0)
        let h = parentSize.height - (originFrame.maxY + heightBuffer)
        let sizeClass = BaseViewController.sizeClass()
        
        if sizeClass.vertical == .regular || sizeClass.horizontal == .regular {
            if let presentingVC: UISplitViewController = presentingViewController as? UISplitViewController {
                let detailVC:UIViewController!
                
                detailVC = presentingVC.viewControllers.last
                w = detailVC.view.frame.size.width - (widthBuffer * 2.0)
            }
        }
        
        return CGSize(width: w, height: h)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero

        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        var x = widthBuffer
        let y  = self.originFrame.maxY + heightBuffer
        let sizeClass = BaseViewController.sizeClass()
        
        if sizeClass.vertical == .regular || sizeClass.horizontal == .regular {
            if let presentingVC: UISplitViewController = presentingViewController as? UISplitViewController {
                let detailVC:UIViewController!
                
                detailVC = presentingVC.viewControllers.last
                x = presentingVC.view.frame.size.width - (detailVC.view.frame.size.width - widthBuffer)
            }
        }
        
        frame.origin.x = x
        frame.origin.y = y
        
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        self.passThruView.frame = (self.containerView?.bounds)!
        self.containerView?.insertSubview(self.passThruView, at: 0)
    }
    
    override func dismissalTransitionWillBegin() {
        self.passThruView.removeFromSuperview()
    }

    func shouldPresentInFullscreen() -> Bool {
        return false
    }
}
