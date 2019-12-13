//
//  ThoughtsLIstViewController+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 11/29/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Foundation
import Intents
import IntentsUI

extension ThoughtsListViewController: INUIAddVoiceShortcutViewControllerDelegate {

    /// The image shown on the shortcut activity.
    private static let addThoughtShortcutImageName = "LightbulbFAB_1"

    private static let suggestedInvocationPhrase = "Add a Thought"

    func addUserActivity(to viewController: UIViewController) {
        let activity = ThoughtItem.newNoteShortcut(thumbnail: UIImage(named: Self.addThoughtShortcutImageName))
        viewController.userActivity = activity
        activity.becomeCurrent()
    }

    func addNewThoughtShortcutPrompt() -> UIViewController {
        let activity = ThoughtItem.newNoteShortcut(thumbnail: UIImage(named: Self.addThoughtShortcutImageName))
        activity.suggestedInvocationPhrase = Self.suggestedInvocationPhrase

        let siriShortCutViewController = INUIAddVoiceShortcutViewController(shortcut: INShortcut(userActivity: activity))
        siriShortCutViewController.delegate = self

        return siriShortCutViewController
    }

    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error {
            let alert = UIAlertController(title: "Error", message: "Sorry, we were not able to create a Siri Shortcut.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            self.addVoiceShortcutViewControllerDidCancel(controller)

            print("Error creating siri shortcut: \(error)")
        } else {
            UserDefaults.standard.set(voiceShortcut?.identifier.uuidString, forKey: "AddThoughtShortcutIdentifier")
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

    func showShortcut() -> UIViewController? {
        guard UserDefaults.standard.bool(forKey: "canceledSiriShortcut") == false else {
            print("User has previously declined siri shortcut.")
            return nil
        }

        guard let shortcutId = UUID(uuidString: UserDefaults.standard.string(forKey: "AddThoughtShortcutIdentifier") ?? ""), !shortcutId.uuidString.isEmpty else {
            print("There is currently no shortcut set in user defaults.")
            return self.addNewThoughtShortcutPrompt()
        }

        var vc: UIViewController?
        INVoiceShortcutCenter.shared.getVoiceShortcut(with: shortcutId) { shortcut, _ in
            if shortcut == nil {
                vc = self.addNewThoughtShortcutPrompt()
            }
        }

        return vc
    }
}
