//
//  GroupSelectionViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 1/22/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import RealmSwift
import UIKit

/**
 This view allows the user to select a group to add their thoughts to.
 */
class GroupSelectionViewController: UIViewController, UITableViewDataSource {

    // MARK: - Member Properties

    /// The groups to display in the view.
    private var groups = ThoughtGroup.all()

    var thoughtItem: ThoughtItem?

    // MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Tableview Data Source Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        guard let group = self.groups?[indexPath.row] else {
            return UITableViewCell()
        }

        cell.textLabel?.text = group.name

        return cell
    }
}
