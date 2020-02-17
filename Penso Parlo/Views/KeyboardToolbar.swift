//
//  KeyboardToolbar.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/16/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

class KeyboardToolbar: UIToolbar {

    @IBOutlet private weak var dismissButton: UIBarButtonItem!

    var buttonPressed: (() -> Void)?

    @IBAction func dismissKeyboard(_ sender: UIBarButtonItem) {
        self.buttonPressed?()
    }
}
