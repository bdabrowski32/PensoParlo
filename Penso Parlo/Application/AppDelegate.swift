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

    var nav: UINavigationController?

    let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotesListController") as UIViewController

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        nav = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        SyncManager.shared.logLevel = .off
        self.removeNavBarBorder()

        self.initializeRealm()
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let speechDetectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpeechDetectionViewController") as UIViewController
        nav?.pushViewController(speechDetectionViewController, animated: false)
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
