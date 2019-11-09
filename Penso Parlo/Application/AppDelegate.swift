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

    /// The backdrop of the app’s user interface and the object that dispatches events to your views.
    /// - Note: Screen is black when commenting this line out.
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SyncManager.shared.logLevel = .off
        self.removeNavBarBorder()

        self.initializeRealm()
        return true
    }

    /**
     Initializes Realm for persistence on launch.
     */
    private func initializeRealm() {
        let realm = try! Realm()
        guard realm.isEmpty else { return }
    }

    /**
     Removes the shadow under the nav bar.
     */
    private func removeNavBarBorder() {
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
}
