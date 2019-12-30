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

/**
 This class handles all Siri Shortcut related actions. It handles displaying views related to Siri Shortcuts and donating shortcuts to the system.
 */
class SiriShortcutHandler: NSObject, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {

    // MARK: - Static Properties

    /// Notification that is posted when a siri shortcut is updated.
    public static let shortcutUpdatedNotification = Notification.Name("ShortcutUpdated")

    // MARK: - Member Properties

    /// Keeps track of the shortcut that is currently displaying to the user.
    /// This is so we can give the user another chance to create a shortcut if they cancel it.
    private var inProgressShortcutType: SiriShortcutActivityType?

    /// The view controller to display the Siri Shortcut view.
    private var parentViewController: UIViewController?

    /// Collection of Siri Shortcuts.
    var voiceShortcuts: [INVoiceShortcut]?

    private var isThoughtsListView: Bool {
        return self.parentViewController?.title == Self.thoughtsListViewName
    }

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

    // MARK: - Add Voice Shortcut View Controller Delegate Methods

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

            self.postShortcutUpdateNotification()
            self.parentViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        // Dismisses Add Shortcut View.
        self.postShortcutUpdateNotification()
        self.parentViewController?.dismiss(animated: true, completion: nil)

        // Only want to display this alert if the user is not in the Settings menu.
        if self.isThoughtsListView {
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
    }

    // MARK: - Edit Voice Shortcut View Controller Methods

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        self.shortcutWasEdited()
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        self.shortcutWasEdited()
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        self.parentViewController?.dismiss(animated: true, completion: nil)
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
        } else if !self.isThoughtsListView {
            return self.getEditShortcutView(for: activityType)
        }

        return nil
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
     Configures the systems 'Edit Shortcut' view.

     - parameter activityType: The activity type to display on the 'Edit Shortcut' view.
     - returns: The systems 'Edit Shortcut' view
     */
    private func getEditShortcutView(for activityType: SiriShortcutActivityType) -> UIViewController? {
        guard let voiceShortcutToEdit = self.voiceShortcuts?.first(where: { $0.shortcut.userActivity?.activityType == activityType.rawValue }) else {
            return nil
        }

        let siriShortCutViewController = INUIEditVoiceShortcutViewController(voiceShortcut: voiceShortcutToEdit)
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
        guard !self.isThoughtsListView || UserDefaults.standard.bool(forKey: Self.canceledSiriShortcutKey) == false else {
            os_log("User has previously declined siri shortcut.",
                   log: OSLog.default,
                   type: .info)
            return false
        }

        // If there is no activity type that matches the passed in activity type, then we want to show the 'Create Shortcut' view.
        guard self.voiceShortcuts?.filter({ $0.shortcut.userActivity?.activityType == activityType.rawValue }).isEmpty == true else {
            os_log("This shortcut is already created for activity type: %@",
                   log: OSLog.default,
                   type: .info,
                   activityType.rawValue)

            return false
        }

        os_log("There are currently no voice shortcuts created with activity type: %@",
               log: OSLog.default,
               type: .info,
               activityType.rawValue)

        return true
    }

    /**
     Fetches all shortcuts from the system and updates the voice shortcuts member variable.
     */
    private func updateVoiceShortcuts(completion: ((NSError?) -> Void)? = nil) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { voiceShortcutsFromCenter, error in
            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
                self.voiceShortcuts = voiceShortcutsFromCenter
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } else {
                if let error = error as NSError? {
                    os_log("Failed to fetch voice shortcuts with error: %@",
                           log: OSLog.default,
                           type: .error,
                           error)
                    DispatchQueue.main.async {
                        completion?(error)
                    }
                }
            }
        }
    }

    /**
     Actions to perform after shortcut was edited.
     */
    private func shortcutWasEdited() {
        self.updateVoiceShortcuts { error in
            if error == nil {
                self.postShortcutUpdateNotification()
            }
            self.parentViewController?.dismiss(animated: true, completion: nil)
        }
    }

    /**
     Posts the shortcut updated notification.
     */
    private func postShortcutUpdateNotification() {
        NotificationCenter.default.post(name: Self.shortcutUpdatedNotification, object: nil)
    }
}
