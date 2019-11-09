//
//  NotesListController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import RealmSwift
import UIKit

/**
 View controller for displaying note items.
 */
class NotesListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// The notes items displayed on the table view.
    private var items: Results<NotesItem>?

    /// Listens to changes in the NotesItem realm.
    private var itemsToken: NotificationToken?

    /// The tableview that displays the notes items
    @IBOutlet private weak var tableView: UITableView!

    /// The button that kicks off speech dictation.
    @IBOutlet private weak var addNoteButton: AddNotesButton!

    // MARK: - ViewController life-cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.items = NotesItem.all()

        self.addNoteButton.onButtonPressHandler = {
            self.performSegue(withIdentifier: "StartSpeaking", sender: self)
        }
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
        self.itemsToken?.invalidate()
    }

    // MARK: - Actions

    func toggleItem(_ item: NotesItem) {
        item.toggleCompleted()
    }

    /**
     Deletes the item.
     - parameter item: The item to delete.
     */
    func deleteItem(_ item: NotesItem) {
        item.delete()
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NotesTableViewCell,
            let item = items?[indexPath.row] else {
                return NotesTableViewCell(frame: .zero)
        }

        cell.configureWith(item) { [weak self] item in
            self?.toggleItem(item)
        }

        return cell
    }

    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let item = items?[indexPath.row], editingStyle == .delete else { return }
        self.deleteItem(item)
    }

    // MARK: - Helper Functions

    /**
     UI Configuration for the table view.
     */
    private func setupTableView() {
        self.tableView.rowHeight = 80
        self.tableView.separatorStyle = .none
    }
}
