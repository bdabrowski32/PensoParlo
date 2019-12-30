//
//  UITableView+RealmChanges.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

extension UITableView {

    /**
     Updates table view rows based on updated changes found when loading realm file.
     */
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
        self.beginUpdates()
        self.deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
        self.insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
        self.reloadRows(at: updates.map(IndexPath.fromRow), with: .automatic)
        self.endUpdates()
    }

    /**
     UI Configuration for the table view.
     */
    func setupTableView() {
        self.rowHeight = 80
        self.separatorStyle = .none
    }
}
