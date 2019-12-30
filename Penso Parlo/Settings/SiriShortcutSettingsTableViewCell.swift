//
//  SiriShortcutSettingsTableViewCell.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/27/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Intents
import UIKit

/**
 The tableview cell used in the Siri Shortcut settings menu.
 */
class SiriShortcutSettingsTableViewCell: UITableViewCell {

    /**
     Displays to the user a thumbs up if the shortcut is created and a thumbsdown if the shortcut is not yet created.

     - parameter shortcuts: All of the shortcuts that are currently created for the app.
     - parameter activityType: The activity type to check to see if it is created or not.
     - parameter completion: Runs after all other function calls.
     */
    func setShortcutCreationIcon(shortcuts: [INVoiceShortcut]?, activityType: SiriShortcutActivityType, completion: () -> Void) {
        let createdShortcut = shortcuts?.filter({ $0.shortcut.userActivity?.activityType == activityType.rawValue })
        self.detailTextLabel?.text = createdShortcut?.isEmpty == false ? "👍" : "👎"
        completion()
    }
}
