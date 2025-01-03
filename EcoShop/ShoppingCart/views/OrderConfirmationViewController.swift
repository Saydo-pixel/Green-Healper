//
//  OrderConfirmationViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/26/24.
//

import UIKit

class OrderConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    @IBAction func trackOrderBtnTapped(_ sender: UIButton) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window,
              let tabBarController = window.rootViewController as? UITabBarController else {
            print("Error: Unable to fetch TabBarController or Window")
            return
        }

        let ordersTabIndex = 3
        if let ordersNavController = tabBarController.viewControllers?[ordersTabIndex] as? UINavigationController {
            // Reset navigation stack
            ordersNavController.popToRootViewController(animated: false)
        }

        // Switch to the Orders tab
        tabBarController.selectedIndex = ordersTabIndex
    }
}
