//
//  UIViewController+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

extension UIViewController {

    /**
     Helper method to make the setup of view controllers consistent across the app. 
     */
    func setupViewController(largeTitle: UINavigationItem.LargeTitleDisplayMode = .never) {
        self.navigationItem.largeTitleDisplayMode = largeTitle
    }
}
