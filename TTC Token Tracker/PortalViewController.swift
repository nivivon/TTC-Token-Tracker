//
//  PortalViewController.swift
//  TTC Token Tracker
//
//  Created by Niv Yahel on 2014-09-25.
//  Copyright (c) 2014 Niv Yahel. All rights reserved.
//

import UIKit

class PortalViewController: UITabBarController, UITabBarControllerDelegate {

    func tabBarController(tabBarController: UITabBarController!, shouldSelectViewController viewController: UIViewController!) -> Bool {
        let tabViewControllers: NSArray = tabBarController.viewControllers
        let fromView: UIView = tabBarController.selectedViewController.view
        let toView: UIView = viewController.view
        let fromVC: UIViewController = tabBarController.selectedViewController
        let toVC: UIViewController = viewController
        if (fromView == toView) {
            return true
        }
        let fromindex: Int = tabViewControllers.indexOfObject(tabBarController.selectedViewController)
        let toIndex: Int = tabViewControllers.indexOfObject(viewController)
        
        UIView.transitionFromView(fromView,
            toView: toView,
            duration: 0.3,
            options: (toIndex > fromindex ? UIViewAnimationOptions.TransitionFlipFromLeft : UIViewAnimationOptions.TransitionFlipFromRight),
            completion: { finished in
                self.selectedIndex = toIndex
            })
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}