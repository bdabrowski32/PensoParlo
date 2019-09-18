//
//  NotesItem.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class NotesItem: Object {
    enum Property: String {
        case id, text, isCompleted
    }

    dynamic var id = UUID().uuidString
    dynamic var text = ""
    dynamic var isCompleted = false

    override static func primaryKey() -> String? {
        return NotesItem.Property.id.rawValue
    }

    convenience init(_ text: String) {
        self.init()
        self.text = text
    }
}

    // MARK: - CRUD methods

extension NotesItem {
    static func all(in realm: Realm = try! Realm()) -> Results<NotesItem> {
        return realm.objects(NotesItem.self)
            .sorted(byKeyPath: NotesItem.Property.isCompleted.rawValue)
    }

    @discardableResult
    static func add(text: String, in realm: Realm = try! Realm()) -> NotesItem {
        let item = NotesItem(text)
        try! realm.write {
            realm.add(item)
        }
        return item
    }

    func toggleCompleted() {
        guard let realm = realm else { return }
        try! realm.write {
            isCompleted = !isCompleted
        }
    }

    func delete() {
        guard let realm = realm else { return }
        try! realm.write {
            realm.delete(self)
        }
    }
}
