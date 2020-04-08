//
//  TabBarController.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 06/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import UIKit
class TabBarController : UITabBarController,UITabBarControllerDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.firstIndex(of: viewController)
        if index == 1 {
            let tableViewController = viewController as! TableViewController 
            tableViewController.countriesData = (tabBarController.viewControllers![0] as! MapViewController).countriesData
        }else if index == 2{
            let favoritesTableViewController =  viewController as! FavoritesTableViewController
            favoritesTableViewController.countriesData = (tabBarController.viewControllers![0] as! MapViewController).countriesData
        }
        return true
    }
}
