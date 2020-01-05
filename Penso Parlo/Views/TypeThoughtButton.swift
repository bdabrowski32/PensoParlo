//
//  TypeThoughtButton.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 Button that handles starting speech dictation.
 */
@IBDesignable
public class TypeThoughtButton: MasterButton {

    /**
     Loads xib file and adds it to the view.
     */
    override func loadFromXib() {
        let bundle = Bundle(for: TypeThoughtButton.self)

        bundle.loadNibNamed("TypeThoughtButton", owner: self, options: nil)
        super.loadFromXib()
    }
}
