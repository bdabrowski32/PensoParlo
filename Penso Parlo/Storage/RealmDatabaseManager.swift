//
//  RealmDatabaseManager.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/1/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import os
import RealmSwift

/**
 This class manages realm databases and their configurations.
 */
class RealmDatabaseManager {

    // MARK: - Static Properties

    /// Realm configuration for the ThoughtItem objects.
    private static let thoughtItemConfig = Realm.Configuration(
        fileURL: RealmDatabaseManager.createRealmUrl(fileName: "thoughtItem.realm", in: .libraryDirectory),
        objectTypes: [ThoughtItem.self]
    )

    /// Realm configuration for the ThoughtGroup objects.
    private static let thoughtGroupConfig = Realm.Configuration(
        fileURL: RealmDatabaseManager.createRealmUrl(fileName: "thoughtGroup.realm", in: .libraryDirectory),
        objectTypes: [ThoughtGroup.self]
    )

    /// Instantiates the Realm Database Manager based on the thought item configuration.
    public static var thoughtItem: RealmDatabaseManager = {
        return RealmDatabaseManager(configuration: RealmDatabaseManager.thoughtItemConfig)
    }()

    /// Instantiates the Realm Database Manager based on the thought group configuration.
    public static var thoughtGroup: RealmDatabaseManager = {
        return RealmDatabaseManager(configuration: RealmDatabaseManager.thoughtGroupConfig)
    }()

    // MARK: - Member Properties

    /// The object used to setup each particular realm.
    let configuration: Realm.Configuration

    /// The realm object that is created with the passed in configuration.
    var realm: Realm? {
        do {
            return try Realm(configuration: self.configuration)
        } catch {
            os_log("Unable to create Realm object from provided configuration.",
                   log: OSLog.default,
                   type: .error)
        }

        return nil
    }

    // MARK: - Initialization

    /**
     Initializes a new Realm Database Manager with the given configuration

     - parameter configuration: The settings used to a particular realm.
     */
    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    // MARK: - Helper Methods

    /**
     Creates a URL to the passed in realm file.

     - parameter fileName: The file name to use to create the URL.
     - parameter directory: The directory to create the URL in.
     - returns: The URL for the realm file.
     */
    class func createRealmUrl(fileName: String, in directory: FileManager.SearchPathDirectory) -> URL? {
        return try? FileManager.default.url(for: directory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false).appendingPathComponent(fileName)
    }
}
