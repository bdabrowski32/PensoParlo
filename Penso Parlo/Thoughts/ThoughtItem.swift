//
//  ThoughtItem.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import RealmSwift
import UIKit

/**
 The note items that the user creates with speech dictation. 
 */
@objcMembers
class ThoughtItem: Object {
    enum Property: String {
        case id, text, group, dateAdded, isCompleted
    }

    // MARK: - Member Properties

    /// Unique string for each note item.
    dynamic var id = UUID().uuidString

    /// Text of the thought item
    dynamic var text = ""

    /// Group that the thought item belongs to.
    dynamic var group = ""

    /// The date the thought was created.
    dynamic var dateAdded = Date()

    dynamic var isCompleted = false

    /// The unique id of the thought item, used for finding in realm.
    override static func primaryKey() -> String? {
        return ThoughtItem.Property.id.rawValue
    }

    /**
     Creates and sets the text, group and date for the thought item.

     - parameter text: The text that the user put in the thought item.
     - parameter group: The group that the thought item is a part of.
     - parameter dateAdded: The date that the thought item was created.
     */
    convenience init(_ text: String, group: String, dateAdded: Date = Date()) {
        self.init()
        self.text = text
        self.group = group
        self.dateAdded = dateAdded
    }

    // MARK: - CRUD methods

    /**
     Gets all of the note items in the specified realm.

     - returns: All of the thought items in a realm consumable object.
     */
    class func all() -> Results<ThoughtItem>? {
        guard let realm = RealmDatabaseManager.thoughtItem.realm else {
            return nil
        }

        return realm.objects(ThoughtItem.self).sorted(byKeyPath: ThoughtItem.Property.dateAdded.rawValue)
    }

    /**
     Adds a thought item to the realm.

     - parameter text: The text of the note item.
     - parameter group: The group that the thought item is apart of.
     */
    class func add(text: String, group: String = "Quick Thoughts") {
        guard let realm = RealmDatabaseManager.thoughtItem.realm else {
            return ThoughtItem("", group: group)
        }

        let item = ThoughtItem(text, group: group)
        try? realm.write {
            realm.add(item)
        }
    }

    func toggleCompleted() {
        guard let realm = RealmDatabaseManager.thoughtItem.realm else { return }
        try? realm.write {
            isCompleted = !isCompleted
        }
    }

    /**
     Deletes a note item from the realm.
     */
    func delete() {
        guard let realm = RealmDatabaseManager.thoughtItem.realm else { return }
        try? realm.write {
            realm.delete(self)
        }
    }

    /**
     Updates the thought item in realm with the passed in text.

     - parameter text: The text to update the thought item with.
     */
    func update(text: String) {
        guard let realm = RealmDatabaseManager.thoughtItem.realm else { return }
        try? realm.write {
            self.text = text
        }
    }
}
