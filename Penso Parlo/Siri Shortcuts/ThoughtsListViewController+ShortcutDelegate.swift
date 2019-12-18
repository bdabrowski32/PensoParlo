//
//  ThoughtsLIstViewController+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 11/29/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import CoreSpotlight
import Foundation
import Intents
import IntentsUI
import MobileCoreServices
import os

extension ThoughtsListViewController: INUIAddVoiceShortcutViewControllerDelegate {

    // MARK: - Static Properties

    /// The image shown on the shortcut activity.
    private static let addThoughtShortcutImageName = "LightbulbFAB_1"

    /// The activity type for the 'New Thought' Siri Shortcut.
    private static let addThoughtActivityType = "com.bdcreative.NewThought"

    /// Name of the 'Add Thought' Activity for Siri Shortcuts.
    private static let addThoughtActivityName = NSLocalizedString("ACCOUNT_LIST_ITEM_FEEDBACK",
                                                                  tableName: "PensoParlo",
                                                                  bundle: Bundle.main,
                                                                  value: "Add a Thought",
                                                                  comment: "The feedback string in the list item")

    // MARK: - Voice Shortcut View Controller Delegate Methods

    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error {
            let alert = UIAlertController(title: "Error", message: "Sorry, we were not able to create a Siri Shortcut.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            self.addVoiceShortcutViewControllerDidCancel(controller)

            print("Error creating siri shortcut: \(error)")
        } else {
            // Add the newly created shortcut to the array of shortcuts, so we don't continue to prompt the user to create a shortcut.
            if let newShortcut = voiceShortcut {
                self.voiceShortcuts?.append(newShortcut)
            }

            self.dismiss(animated: true, completion: nil)
        }
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        // Dismisses Add Shortcut View.
        self.dismiss(animated: true, completion: nil)

        let alert = UIAlertController(title: "Create a Shortcut Later",
                                      message: """
                                                If you change your mind in the future, you can go to Settings within Penso Parlo
                                                to add a shortcut for easy, voice activated note-taking
                                               """,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add Shortcut", style: .default, handler: { _ in
            if let showShortcut = self.showShortcut() {
                self.present(showShortcut, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            UserDefaults.standard.set(true, forKey: "canceledSiriShortcut")
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Helper Methods

    /**
     Creates and configures the user activity that is donated to siri for shortcut functionality.

     - parameter thumbnail: The image to use for the siri shortcut thumbnail.
     - returns: The user activity to donate to siri.
     */
    public static func newThoughtShortcut(thumbnail: UIImage?) -> NSUserActivity {
        let activity = NSUserActivity(activityType: Self.addThoughtActivityType)
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(Self.addThoughtActivityType)

        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true

        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)

        activity.title = Self.addThoughtActivityName
        attributes.contentDescription = "Jot it down before you forget!"
        attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: 1.0)
        activity.suggestedInvocationPhrase = Self.addThoughtActivityName
        activity.contentAttributeSet = attributes

        return activity
    }

    /**
     Configures the systems 'Create Shortcut' view.

     - returns: The systems 'Create Shortcut' view
     */
    func getSystemCreateShortcutView() -> UIViewController {
        let activity = Self.newThoughtShortcut(thumbnail: UIImage(named: Self.addThoughtShortcutImageName))
        activity.suggestedInvocationPhrase = Self.addThoughtActivityName

        let siriShortCutViewController = INUIAddVoiceShortcutViewController(shortcut: INShortcut(userActivity: activity))
        siriShortCutViewController.delegate = self

        return siriShortCutViewController
    }

    /**
     Adds the user activity to passed in view controller. When the shortcut is invoked through siri, it will present the passed in view controller.

     - parameter viewController: The view controller to present when the user activity is invoked.
     */
    func addUserActivity(to viewController: UIViewController) {
        let activity = Self.newThoughtShortcut(thumbnail: UIImage(named: Self.addThoughtShortcutImageName))
        viewController.userActivity = activity
        activity.becomeCurrent()
    }

    /**
     Checks to see if the 'new thought' activity is created. If it is then we do not want to prompt the user to create it again.
     If it is not created, then we display the system UI to create the shortcut.

     - returns: The system UI to create the Siri Shortcut.
     */
    func showSystemCreateShortcutView() -> UIViewController? {
        guard UserDefaults.standard.bool(forKey: "canceledSiriShortcut") == false else {
            print("User has previously declined siri shortcut.")
            return nil
        }

        guard self.voiceShortcuts?.filter({ $0.shortcut.userActivity?.activityType == Self.addThoughtActivityType }).isEmpty == false else {
            os_log("There are currently no voice shortcuts created with activity type: %@",
                   log: OSLog.default,
                   type: .info,
                   Self.addThoughtActivityType)

            return self.getSystemCreateShortcutView()
        }

        return nil
    }

    /**
     Fetches all shortcuts from the system and updates the voice shortcuts member variable.
     */
    func updateVoiceShortcuts() {
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
