//
//  KeyboardToolbar.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/16/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

/**
 The toolbar that appears above the keyboard.
 */
class KeyboardToolbar: UIToolbar {

    /// The button that dismisses the keyboard.
    @IBOutlet private weak var dismissButton: UIBarButtonItem!

    /// The action to perform when the dismiss button is pressed
    var dismissButtonPressed: (() -> Void)?

    /**
     Dismisses the keyboard.
     */
    @IBAction func dismissKeyboard(_ sender: UIBarButtonItem) {
        self.dismissButtonPressed?()
    }
}
