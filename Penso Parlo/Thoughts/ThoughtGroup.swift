//
//  ThoughtGroup.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/1/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import RealmSwift

/**
 Model object for groups that hold thoughts. Same principle as folders.
 */
@objcMembers
class ThoughtGroup: Object {
    enum Property: String {
        case id, name
    }

    /// Unique string for each note item.
    dynamic var id = UUID().uuidString

    /// The name of the group.
    dynamic var name: String?

    /// The unique id of the group, used for finding in realm.
    override static func primaryKey() -> String? {
        return ThoughtGroup.Property.id.rawValue
    }

    /**
     Creates and sets the name of the thought group.

     - parameter name: The name of the group.
     */
    convenience init(name: String) {
        self.init()
        self.name = name
    }

    /**
     Retrieves all of the groups from the realm.

     - returns: The thought group.
     */
    class func all() -> Results<ThoughtGroup>? {
        guard let realm = RealmDatabaseManager.thoughtGroup.realm else {
            return nil
        }

        return realm.objects(ThoughtGroup.self).sorted(byKeyPath: ThoughtGroup.Property.name.rawValue)
    }

    class func getThoughtGroup(byName name: String) -> ThoughtGroup? {
        return ThoughtGroup.all()?.filter(NSPredicate(format: "name == %@", name)).first
    }

    class func getThoughtGroup(byId id: String) -> ThoughtGroup? {
        return ThoughtGroup.all()?.first(where: { $0.id == id })
    }

    /**
     Creates and adds the thought group object to realm.

     - parameter name: The name of the group to add.
     */
    @discardableResult
    class func add(name: String) -> ThoughtGroup {
        guard let realm = RealmDatabaseManager.thoughtGroup.realm else {
            return ThoughtGroup()
        }

        let group = ThoughtGroup(name: name)
        try? realm.write {
            realm.add(group)
        }

        return group
    }

    /**
     Deletes a thought group from the realm.
     */
    func delete() {
        guard let realm = RealmDatabaseManager.thoughtGroup.realm else { return }
        try? realm.write {
            realm.delete(self)
        }
    }

    /**
     Updates the thought group name with the passed in value

     - parameter name: The new name of the group.
     */
    func update(name: String) {
        guard let realm = RealmDatabaseManager.thoughtGroup.realm else { return }
        try? realm.write {
            self.name = name
        }
    }
}
