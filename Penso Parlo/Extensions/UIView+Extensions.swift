//
//  UIView+Extensions.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 3/13/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

extension UIView {
    func addGradient(with layer: CAGradientLayer,
                     gradientFrame: CGRect? = nil,
                     colorSet: [UIColor],
                     locations: [Double]) {

        layer.frame = gradientFrame ?? self.bounds
        layer.frame.origin = .zero

        layer.colors = colorSet.map { $0.cgColor }
        layer.locations = locations.map { $0 as NSNumber }
        layer.zPosition = -1

        self.layer.insertSublayer(layer, below: self.layer)
    }
}
