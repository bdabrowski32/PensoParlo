//
//  PensoNavigationController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 The main navigation controller for the app.
 */
class PensoNavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.removeNavBarBorder()
        self.configureTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     Removes the shadow under the nav bar.
     */
    func removeNavBarBorder() {
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    /**
     Configures the title attributes in the Navigation Bar. This sets the font and the font size for both the large and small title.
     */
    func configureTitle() {
        self.navigationBar.prefersLargeTitles = true

        // Set small title font and size
        UINavigationBar.appearance().titleTextAttributes =  [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 17)!]

        // Set large title font and size
        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 34)!]
        }
    }
}
