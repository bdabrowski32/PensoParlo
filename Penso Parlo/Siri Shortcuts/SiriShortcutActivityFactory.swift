//
//  SiriShortcutActivityFactory.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/21/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices
import UIKit

/**
 Configures the Siri Shortcut's properties.
 */
public class SiriShortcutActivityFactory {

    /// The name of the 'Add Thought' Siri Shortcut.
    private static let addThoughtActivityName = NSLocalizedString("ADD_THOUGHT_SIRI_SHORTCUT",
                                                                  tableName: "PensoParlo",
                                                                  bundle: Bundle.main,
                                                                  value: "Add a Thought",
                                                                  comment: "The name of the Siri Shortcut for adding a thought.")

    /**
     Creates a Siri Shortcut object based off of the passed in activity type.

     - parameter activityType: The Siri Shortcut to create.
     - returns: The configures Siri Shortcut object.
     */
    public static func createShortcut(for activityType: SiriShortcutActivityType) -> NSUserActivity {
        switch activityType {
        case .addThoughtActivityType:
            let activity = NSUserActivity(activityType: activityType.rawValue)
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(activityType.rawValue)
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true

            activity.title = Self.addThoughtActivityName
            activity.suggestedInvocationPhrase = Self.addThoughtActivityName

            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attributes.contentDescription = NSLocalizedString("ADD_THOUGHT_SIRI_SHORTCUT_DESCRIPTION",
                                                              tableName: "PensoParlo",
                                                              bundle: Bundle.main,
                                                              value: "Jot it down before you forget!",
                                                              comment: "This appears under the headline of the shortcut notification.")
            attributes.thumbnailData = #imageLiteral(resourceName: "LightbulbFAB_1").jpegData(compressionQuality: 1.0)

            activity.contentAttributeSet = attributes
            return activity
        }
    }
}
