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

        self.setNavigationBarHidden(true, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
