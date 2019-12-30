//
//  IndexPath+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/25/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

extension IndexPath {
    /**
     Takes the int value of a tableview row and returns it in an IndexPath object.

     - returns: An index path object.
     */
    static func fromRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: 0)
    }
}
