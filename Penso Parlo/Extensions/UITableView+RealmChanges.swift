//
//  UITableView+RealmChanges.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

extension IndexPath {
    static func fromRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: 0)
    }
}

extension UITableView {
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
        self.beginUpdates()
        self.deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
        self.insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
        self.reloadRows(at: updates.map(IndexPath.fromRow), with: .automatic)
        self.endUpdates()
    }
}
