//
//  GroupCellDelegate.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 3/14/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

/**
 Delegate protocol to allow the speech handling class to pass information back to view controllers.
 */
protocol GroupCellDelegate: class {

    func disableCellEditing()

    func enableCellEditing()

    func observeTableViewChanges(initialAction: (() -> Void)?)

    func presentAlert(alert: UIAlertController)
}
