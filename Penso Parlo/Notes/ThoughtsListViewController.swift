//
//  ThoughtsListViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Intents
import IntentsUI
import RealmSwift
import UIKit

/**
 View controller for displaying note items.
 */
class ThoughtsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Static Properties

    /// The name of the cell that displays thought text.
    private static let thoughtCell = "ThoughtCell"

    /// The identifier for the segue to the Speech Detection View Controller
    static let speechDetectionViewSegue = "StartSpeaking"

    // MARK: - Member Properties

    /// The thought items displayed on the table view.
    private var thoughtItems: Results<ThoughtItem>?

    /// Listens to changes in the ThoughtsItem realm.
    private var thoughtItemToken: NotificationToken?

    // MARK: - IBOutlets

    /// The tableview that displays the notes items
    @IBOutlet private weak var tableView: UITableView!

    /// The button that kicks off speech dictation.
    @IBOutlet private weak var addThoughtButton: AddThoughtButton!

    // MARK: - ViewController life-cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.thoughtItems = ThoughtItem.all()

        self.addThoughtButton.onButtonPressHandler = {
            self.performSegue(withIdentifier: Self.speechDetectionViewSegue, sender: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        thoughtItemToken = thoughtItems?.observe { [weak tableView] changes in
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
        self.thoughtItemToken?.invalidate()
    }

    // MARK: - Actions

    func toggleItem(_ item: ThoughtItem) {
        item.toggleCompleted()
    }

    /**
     Deletes the item.
     - parameter item: The item to delete.
     */
    func deleteItem(_ item: ThoughtItem) {
        item.delete()
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thoughtItems?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.thoughtCell, for: indexPath) as? ThoughtTableViewCell,
            let item = self.thoughtItems?[indexPath.row] else {
                return ThoughtTableViewCell(frame: .zero)
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
        guard let item = self.thoughtItems?[indexPath.row], editingStyle == .delete else { return }
        self.deleteItem(item)
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editThoughtViewController = segue.destination as? EditThoughtViewController,
            let index = self.tableView.indexPathForSelectedRow?.row {
                editThoughtViewController.thoughtItem = self.thoughtItems?[index]
        } else if let speechDetectionViewController = segue.destination as? SpeechDetectionViewController {
            self.addUserActivity(to: speechDetectionViewController)
            speechDetectionViewController.addSiriShortcutPrompt = {
                if let showShortcut = self.showShortcut() {
                    self.present(showShortcut, animated: true, completion: nil)
                }
            }
        } else {
            print("Unable to get a reference to a view controller to segue to.")
        }
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
