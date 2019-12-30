//
//  SiriShortcutHandler+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/22/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Foundation

extension SiriShortcutHandler {

    // MARK: - Static Properties

    /// The User Defaults key used to keep track of when the user cancels the siri shortcut.
    /// If they cancel and do not create one, then we don't want to continue prompting them to create one.
    static let canceledSiriShortcutKey = "canceledSiriShortcut"

    /// The identifier for the Thoughts List view.
    static let thoughtsListViewName = "My Thoughts"

    /// The error message to show when not able to create the Siri Shortcut.
    static let shortcutCreationErrorMessage = NSLocalizedString("SHORTCUT_CREATION_ERROR",
                                                                tableName: "PensoParlo",
                                                                bundle: Bundle.main,
                                                                value: "Sorry, we were not able to create a Siri Shortcut.",
                                                                comment: "The error message to display when the shortcut is not created successfully.")

    /// The title for the alert to display.
    static let canceledShortcutTitle = NSLocalizedString("SHORTCUT_CANCEL_TITLE",
                                                         tableName: "PensoParlo",
                                                         bundle: Bundle.main,
                                                         value: "Create a Shortcut Later",
                                                         comment: "The title for the alert to display.")

    /// The message to display when the user cancels creating a Siri Shortcut.
    static let canceledShortcutBody = NSLocalizedString("SHORTCUT_CANCEL_BODY",
                                                        tableName: "PensoParlo",
                                                        bundle: Bundle.main,
                                                        value: """
                                                                Siri Shortcuts let you quickly do everyday tasks,
                                                                all with just a tap or by asking Siri.
                                                                If you decline to add the shortcut now,
                                                                you can still add it at anytime by going to Settings > Siri Shortcuts.
                                                                """,
                                                        comment: "The message to display when the user cancels creating a Siri Shortcut.")

    /// The label on the 'Add Shortcut' button in the 'Cancel Shortcut' alert.
    static let addShortcutButtonLabel = NSLocalizedString("SHORTCUT_ALERT_BUTTON_LABEL_ADD",
                                                          tableName: "PensoParlo",
                                                          bundle: Bundle.main,
                                                          value: "Add Shortcut",
                                                          comment: "The label on the 'Add Shortcut' button in the 'Cancel Shortcut' alert.")

    /// The label on the 'Cancel' button in the 'Cancel Shortcut' alert.
    static let cancelShortcutButtonLabel = NSLocalizedString("SHORTCUT_ALERT_BUTTON_LABEL_CANCEL",
                                                             tableName: "PensoParlo",
                                                             bundle: Bundle.main,
                                                             value: "Cancel",
                                                             comment: "The label on the 'Cancel' button in the 'Cancel Shortcut' alert.")
}
