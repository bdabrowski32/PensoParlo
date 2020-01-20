//
//  Collection+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 1/16/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import Foundation

/**
 Collection extensions for basic arithmetic.
 */
extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { reduce(0, +) }
}

extension Collection where Element == Float {
    /// Returns the average of all elements in the array
    var average: Element { isEmpty ? 0 : total / Element(count) }
}
