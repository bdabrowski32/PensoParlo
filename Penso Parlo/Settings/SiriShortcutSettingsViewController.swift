//
//  SiriShortcutSettingsViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 The view that displays all of the Siri Shortcuts that are available to the user.
 */
class SiriShortcutSettingsViewController: UITableViewController {

    /// Handles all Siri Shortcut related actions and views.
    var siriShortcutHandler: SiriShortcutHandler?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.siriShortcutHandler = SiriShortcutHandler(parentViewController: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadTableView(_:)),
                                               name: SiriShortcutHandler.shortcutUpdatedNotification,
                                               object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewController()
        self.tableView.setupTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.siriShortcutHandler = nil
        super.viewWillDisappear(animated)
    }

    /**
      Updates the thought item and returns back to the previous view controller.

      - parameter sender: The back button on the navigation controller.
     */
    @IBAction private func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SiriShortcutSettingsTableViewCell else {
            return
        }

        switch indexPath.row {
        case 0:
            cell.setShortcutCreationIcon(shortcuts: self.siriShortcutHandler?.voiceShortcuts, activityType: .addThoughtActivityType) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.present((self.siriShortcutHandler?.showCreateShortcutView(for: .addThoughtActivityType))!, animated: true, completion: nil)
        default:
            break
        }

        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    /**
     Reloads the table view.

     - parameter notification: The notification object that this method is listening to.
     */
    @objc
    func reloadTableView(_ notification: Notification) {
        self.tableView.reloadData()
    }
}
