//
//  NotesListController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import RealmSwift
import UIKit

class NotesListController: UITableViewController {

    private var items: Results<NotesItem>?
    private var itemsToken: NotificationToken?

    // MARK: - ViewController life-cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        items = NotesItem.all()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemsToken = items?.observe { [weak tableView] changes in
            guard let tableView = tableView else { return }

            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
            case .error: break
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        itemsToken?.invalidate()
    }

    // MARK: - Actions

    @IBAction func addItem() {
        // TO-DO: Add action when the user wants to add something manually to the list.
    }

    func toggleItem(_ item: NotesItem) {
        item.toggleCompleted()
    }

    func deleteItem(_ item: NotesItem) {
        item.delete()
    }
}

    // MARK: - Table View Data Source

    extension NotesListController {
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items?.count ?? 0
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NotesTableViewCell,
                let item = items?[indexPath.row] else {
                    return NotesTableViewCell(frame: .zero)
            }

            cell.configureWith(item) { [weak self] item in
                self?.toggleItem(item)
            }

            return cell
        }
    }

    // MARK: - Table View Delegate

    extension NotesListController {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            guard let item = items?[indexPath.row],
                editingStyle == .delete else { return }

            deleteItem(item)
        }
    }
