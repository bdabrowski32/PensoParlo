//
//  SiriShortcutHandler.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 11/29/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Intents
import IntentsUI
import os

class SiriShortcutHandler: NSObject, INUIAddVoiceShortcutViewControllerDelegate {

    // MARK: - Member Properties

    /// Keeps track of the shortcut that is currently displaying to the user.
    /// This is so we can give the user another chance to create a shortcut if they cancel it.
    private var inProgressShortcutType: SiriShortcutActivityType?

    /// The view controller to display the Siri Shortcut view.
    var parentViewController: UIViewController?

    /// Collection of Siri Shortcuts.
    var voiceShortcuts: [INVoiceShortcut]?

    // MARK: - Initialization

    /**
     Fetches the siri shortcuts from the siri shortcut center.

     - parameter viewController: The parent view controller that will display the Siri Shortcut View.
     */
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController

        super.init()
        self.updateVoiceShortcuts()
    }

    // MARK: - Voice Shortcut View Controller Delegate Methods

    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error {
            let alert = UIAlertController(title: "Error", message: Self.shortcutCreationErrorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.parentViewController?.present(alert, animated: true, completion: nil)

            self.addVoiceShortcutViewControllerDidCancel(controller)

            os_log("Error creating siri shortcut: %@",
                   log: OSLog.default,
                   type: .error,
                   error as NSError)
        } else {
            // Add the newly created shortcut to the array of shortcuts, so we don't continue to prompt the user to create a shortcut.
            if let newShortcut = voiceShortcut {
                self.voiceShortcuts?.append(newShortcut)
            }

            self.parentViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        // Dismisses Add Shortcut View.
        self.parentViewController?.dismiss(animated: true, completion: nil)

        let alert = UIAlertController(title: Self.canceledShortcutTitle,
                                      message: Self.canceledShortcutBody,
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: Self.addShortcutButtonLabel, style: .default, handler: { _ in
            if let inProgressShortcutType = self.inProgressShortcutType {
                if let showShortcut = self.showCreateShortcutView(for: inProgressShortcutType) {
                    self.parentViewController?.present(showShortcut, animated: true, completion: nil)
                }
            }
        }))

        alert.addAction(UIAlertAction(title: Self.cancelShortcutButtonLabel, style: .cancel, handler: { _ in
            UserDefaults.standard.set(true, forKey: Self.canceledSiriShortcutKey)
        }))

        self.parentViewController?.present(alert, animated: true, completion: nil)
    }

    // MARK: - Helper Methods

    /**
     Donates the user activity to the system when this method is called. The passed in view controller is the view controller that is displayed when the shortcut
     is performed.

     - parameter activityType: The user activity type to donate to the system.
     - parameter viewController: The view controller to present when the user activity is invoked.
     */
    func add(userActivity activityType: SiriShortcutActivityType, to viewController: UIViewController) {
        let activity = SiriShortcutActivityFactory.createShortcut(for: activityType)
        viewController.userActivity = activity
        activity.becomeCurrent()
    }

    /**
     Checks to see if the activity is created. If it is then we do not want to prompt the user to create it again.
     If it is not created, then we display the system UI to create the shortcut.

     - parameter activityType: The activity type to display in the 'Create Shortcut' view.
     - returns: The system UI to create the Siri Shortcut.
     */
    func showCreateShortcutView(for activityType: SiriShortcutActivityType) -> UIViewController? {
        if self.shouldShowCreateShortcutView(for: activityType) {
            self.inProgressShortcutType = activityType
            return self.getCreateShortcutView(for: activityType)
        } else {
            return nil
        }
    }

    /**
     Configures the systems 'Create Shortcut' view.

     - parameter activityType:The activity type to display on the 'Create Shortcut' view.
     - returns: The systems 'Create Shortcut' view
     */
    private func getCreateShortcutView(for activityType: SiriShortcutActivityType) -> UIViewController {
        let activity = SiriShortcutActivityFactory.createShortcut(for: activityType)
        activity.suggestedInvocationPhrase = activity.title

        let siriShortCutViewController = INUIAddVoiceShortcutViewController(shortcut: INShortcut(userActivity: activity))
        siriShortCutViewController.delegate = self

        return siriShortCutViewController
    }

    /**
     Checks the system to see if the shortcut is already created.

     - parameter activityType: The activity type that is being checked for creation.
     - returns: If the shortcut is already created or not.
     */
    private func shouldShowCreateShortcutView(for activityType: SiriShortcutActivityType) -> Bool {
        // If the canceled siri shortcut key is false then continue, if it is true then we do not want to
        // show the 'Create Shortcut' view because the user does not want to create the shortcut.
        guard UserDefaults.standard.bool(forKey: Self.canceledSiriShortcutKey) == false else {
            os_log("User has previously declined siri shortcut.",
                   log: OSLog.default,
                   type: .info)
            return false
        }

        // If there is no activity type that matches the passed in activity type, then we want to show the 'Create Shortcut' view.
        guard self.voiceShortcuts?.filter({ $0.shortcut.userActivity?.activityType == activityType.rawValue }).isEmpty == true else {
            os_log("There are currently no voice shortcuts created with activity type: %@",
                   log: OSLog.default,
                   type: .info,
                   activityType.rawValue)

            return false
        }

        return true
    }

    /**
     Fetches all shortcuts from the system and updates the voice shortcuts member variable.
     */
    private func updateVoiceShortcuts() {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { voiceShortcutsFromCenter, error in
            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
                self.voiceShortcuts = voiceShortcutsFromCenter
            } else {
                if let error = error as NSError? {
                    os_log("Failed to fetch voice shortcuts with error: %@", log: OSLog.default, type: .error, error)
                }
            }
        }
    }
}
