//
//  AppDelegate.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 5/22/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import os
import RealmSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// The backdrop of the app’s user interface and the object that dispatches events to your views.
    /// - Note: Screen is black when commenting this line out.
    var window: UIWindow?

    /// The navigation controller to use for presenting and navigating view.
    var navigationController: PensoNavigationController?

    /// The first view to appear. This is the entry point of the app. It is not launched from storyboard or there will be multiple instances when launching through siri shortcuts.
    let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThoughtsListViewController") as? ThoughtsListViewController

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.setupRootViewController()

        SyncManager.shared.logLevel = .off

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        self.rootViewController?.performSegue(withIdentifier: ThoughtsListViewController.speechDetectionViewSegue, sender: self)
        return true
    }

    /**
     Configures view hierarchy.
     */
    private func setupRootViewController() {
        guard let thoughtsListViewController = self.rootViewController else {
            os_log("Unable to setup Thoughts List View Controller.",
                   log: OSLog.default,
                   type: .error)
            return
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.navigationController = PensoNavigationController(rootViewController: thoughtsListViewController)
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
    }
}
