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
class GroupSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupCellDelegate {

    // MARK: - Member Properties

    @IBOutlet private weak var newGroupButton: NewGroupButton!

    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var closeButton: UIBarButtonItem!

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var viewTitle: UINavigationItem!

    /// Listens to changes in the ThoughtsGroups realm.
    private var thoughtGroupToken: NotificationToken?

    /// The groups to display in the view.
    private var groups: Results<ThoughtGroup>?

    /// The thought item to update with the selected group.
    var thoughtItem: ThoughtItem?

    private let gradientLayer = CAGradientLayer()

    override var prefersStatusBarHidden: Bool {
        return true
    }


    // MARK: - View Lifecycle Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 120
        self.tableView.separatorStyle = .none
        self.tableView.layer.zPosition = -1
        self.groups = ThoughtGroup.all()
        self.setupButtonActions()

//        self.setupShadowLayer()

//        self.navBar.prefersLargeTitles = true

//        self.navBar.layer.cornerRadius = 8
//        self.navBar.isTranslucent = true
//        self.gradientLayer.startPoint = CGPoint(x: -0.3, y: 0.5)
//        self.gradientLayer.cornerRadius = 8
//
//        self.navBar.addGradient(with: self.gradientLayer,
//                                gradientFrame: self.navBar.layer.bounds,
//                                colorSet: [#colorLiteral(red: 0.3489752412, green: 0.7369459271, blue: 0.5592894554, alpha: 1), #colorLiteral(red: 0.3489752412, green: 0.8607151908, blue: 0.635782392, alpha: 1)],
//                                locations: [0.0, 1.0])
    }

     private func setupShadowLayer() {
        let layerBounds = self.navBar.layer.bounds

         let shadowRect = CGRect(x: layerBounds.origin.x,
                                 y: layerBounds.origin.y,
                                 width: layerBounds.width,
                                 height: layerBounds.height)
//         let shadowInsets = UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40)
        let shadowInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

         self.navBar.layer.masksToBounds = false
         self.navBar.layer.shadowOpacity = 0.23
         self.navBar.layer.shadowRadius = 30
         self.navBar.layer.shadowOffset = CGSize(width: 0, height: 50)
         self.navBar.layer.shadowColor = #colorLiteral(red: 0.262745098, green: 0.2745098039, blue: 0.3098039216, alpha: 1)
         self.navBar.layer.shadowPath = CGPath(roundedRect: shadowRect.inset(by: shadowInsets),
                                               cornerWidth: 1,
                                               cornerHeight: 1,
                                               transform: nil)
    }

    /**
     Deletes the group.
     - parameter group: The group to delete.
     */
    func deleteGroup(_ group: ThoughtGroup) {
        group.delete()
    }

    func setupButtonActions() {
        self.newGroupButton.onButtonPressHandler = { [weak self] in
            // Adds the thought group to the realm.
            ThoughtGroup.add(name: "")

            let addNewGroup = { [weak self] in
                guard let groups = self?.groups else {
                    return
                }

                // Select the top indexPath
                self?.tableView.selectRow(at: IndexPath(row: 0, section: 0), // Select the top indexPath
                                          animated: true,
                                          scrollPosition: .top)

                // Get a reference to the selected row.
                guard let selectedIndexPath = self?.tableView.indexPathForSelectedRow else {
                    return
                }

                // Get a reference to the cell at the selected row
                let cell = self?.tableView.cellForRow(at: selectedIndexPath) as? GroupTableViewCell

                // Set the cells thoughtGroup object to the selected row. Used for updating the empty group.
                cell?.thoughtGroup = groups[selectedIndexPath.row]
                cell?.addNewCell()
            }

            self?.observeTableViewChanges(initialAction: addNewGroup)
        }
    }

    func observeTableViewChanges(initialAction: (() -> Void)?) {
        self.thoughtGroupToken = self.groups?.observe { changes in
            guard let tableView = self.tableView else {
                return
            }

            switch changes {
            case .initial:
                print("initial called")
                // Reloads tableview with new empty cell.
                tableView.reloadData()
                initialAction?()

            case .update(_, let deletions, let insertions, let updates):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
            case .error:
                break
            }
        }
    }

    @IBAction private func closeView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            let emptyThoughtGroups = ThoughtGroup.all()?.filter({ $0.name?.isEmpty == true })
            for thoughtGroup in emptyThoughtGroups! {
                self.deleteGroup(thoughtGroup)
            }
        }
    }

    func disableCellEditing() {
        guard let groupCells = self.tableView.visibleCells as? [GroupTableViewCell] else {
            return
        }

        for cell in groupCells where !cell.textField.isEditing {
            cell.isUserInteractionEnabled = false
            cell.editButton.isHidden = true
        }
    }

    func enableCellEditing() {
        guard let groupCells = self.tableView.visibleCells as? [GroupTableViewCell] else {
            return
        }

        for cell in groupCells where !cell.textField.isEditing {
            cell.isUserInteractionEnabled = true
            cell.editButton.isHidden = false
        }
    }

    // MARK: - Tableview Data Source Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupTableViewCell
        guard let group = self.groups?[indexPath.row], let groupCell = cell else {
            return UITableViewCell()
        }

        groupCell.delegate = self
        groupCell.textField?.text = group.name

        return groupCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let groupCell = cell as? GroupTableViewCell else {
            return
        }

        groupCell.contentView.layer.masksToBounds = true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteButton = UIContextualAction(style: .normal, title: nil) { _, _, success in
            guard let group = self.groups?[indexPath.row] else {
                return
            }

            self.deleteGroup(group)
            self.observeTableViewChanges(initialAction: nil)
            success(true)
        }

        deleteButton.image = #imageLiteral(resourceName: "DeleteThoughtButton")
        deleteButton.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9843137255, alpha: 1)

        return UISwipeActionsConfiguration(actions: [deleteButton])
    }

    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
