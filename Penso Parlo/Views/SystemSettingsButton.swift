//
//  SystemSettingsButton.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 Button that handles opening system settings.
 */
@IBDesignable
public class SystemSettingsButton: MasterButton {

    /**
     Loads xib file and adds it to the view.
     */
    override func loadFromXib() {
        let bundle = Bundle(for: SystemSettingsButton.self)

        bundle.loadNibNamed("SystemSettingsButton", owner: self, options: nil)
        super.loadFromXib()
    }
}
