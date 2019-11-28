//
//  NotesItem.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Foundation
import RealmSwift

/**
 The note items that the user creates with speech dictation. 
 */
@objcMembers
class ThoughtItem: Object {
    enum Property: String {
        case id, text, isCompleted
    }

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
