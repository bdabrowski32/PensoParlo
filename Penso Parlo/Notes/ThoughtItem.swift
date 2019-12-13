//
//  NotesItem.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import CoreSpotlight
import Intents
import MobileCoreServices
import RealmSwift
import UIKit

/**
 The note items that the user creates with speech dictation. 
 */
@objcMembers
class ThoughtItem: Object {
    enum Property: String {
        case id, text, isCompleted
    }

    public static let newNoteActivityType = "com.bdcreative.NewNote"

    /// Unique string for each note item.
    dynamic var id = UUID().uuidString

    /// Text of the note item
    dynamic var text = ""

    dynamic var isCompleted = false

    override static func primaryKey() -> String? {
        return ThoughtItem.Property.id.rawValue
    }

    /**
     Creates and sets the text for the note item.
     */
    convenience init(_ text: String) {
        self.init()
        self.text = text
    }

    public static func newNoteShortcut(thumbnail: UIImage?) -> NSUserActivity {
        let activity = NSUserActivity(activityType: ThoughtItem.newNoteActivityType)
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(ThoughtItem.newNoteActivityType)

        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true

        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)

        activity.title = "Add a New Thought"
        attributes.contentDescription = "Jot it down before you forget!"
        attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: 1.0)
        activity.suggestedInvocationPhrase = "Thought" // maybe make this Penso if you can figure out how to get siri to understand it.
        activity.contentAttributeSet = attributes

        return activity
    }

    // MARK: - CRUD methods

    /**
     Gets all of the note items in the specified realm.

     - parameter realm: The realm where the note items are saved.
     - returns: All of the note items in a realm consumable object.
     */
    class func all(in realm: Realm = try! Realm()) -> Results<ThoughtItem> {
        return realm.objects(ThoughtItem.self)
            .sorted(byKeyPath: ThoughtItem.Property.isCompleted.rawValue)
    }

    /**
     Adds a note item to the realm.

     - parameter text: The text of the note item.
     - parameter realm: The realm where the note items are saved.
     - returns: The note item that was added to the realm.
     */
    @discardableResult
    class func add(text: String, in realm: Realm = try! Realm()) -> ThoughtItem {
        let item = ThoughtItem(text)
        try? realm.write {
            realm.add(item)
        }
        return item
    }

    func toggleCompleted() {
        guard let realm = realm else { return }
        try? realm.write {
            isCompleted = !isCompleted
        }
    }

    /**
     Deletes a note item from the realm.
     */
    func delete() {
        guard let realm = realm else { return }
        try? realm.write {
            realm.delete(self)
        }
    }

    func update(text: String) {
        guard let realm = realm else { return }
        try? realm.write {
            self.text = text
        }
    }
}
