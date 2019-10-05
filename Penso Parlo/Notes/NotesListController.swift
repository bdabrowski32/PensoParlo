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

        // create a button or any UIView and add to subview
        let button = UIButton(type: .system)
        button.setTitle("PENSO", for: .normal)
        button.frame.size = CGSize(width: 700, height: 500)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)

        //set constrains
        button.translatesAutoresizingMaskIntoConstraints = false
        button.rightAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        button.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1).isActive = true
    }

    @objc
    func buttonAction(sender: UIButton!) {
        self.performSegue(withIdentifier: "StartSpeaking", sender: self)
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

    func deleteItem(_ item: NotesItem) {
        item.delete()
    }

// MARK: - Table View Data Source

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

// MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let item = items?[indexPath.row], editingStyle == .delete else { return }
        self.deleteItem(item)
    }
}


