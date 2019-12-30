//
//  SettingsViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 The view controller that displays settings items.
 */
class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewController()
        self.tableView.setupTableView()
    }

    /**
      Updates the thought item and returns back to the previous view controller.

      - parameter sender:The back button on the navigation controller.
     */
    @IBAction private func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
