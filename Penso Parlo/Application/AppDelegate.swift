//
//  AppDelegate.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 5/22/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import RealmSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SyncManager.shared.logLevel = .off

        self.initializeRealm()
        return true
    }

    private func initializeRealm() {
        let realm = try! Realm()
        guard realm.isEmpty else { return }
    }
}
