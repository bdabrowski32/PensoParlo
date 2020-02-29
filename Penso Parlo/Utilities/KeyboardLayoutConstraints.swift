//
//  KeyboardLayoutConstraints.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/22/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

/**
 Raises the keyboard up and down.
 */
public class KeyboardLayoutConstraint: NSLayoutConstraint {

    /// The difference between the keyboard and the constraint.
    private var offset: CGFloat = 0

    /// The height of the keyboard.
    private var keyboardVisibleHeight: CGFloat = 0

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.offset = self.constant

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardLayoutConstraint.keyboardWillShowNotification(_:)),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardLayoutConstraint.keyboardWillHideNotification(_:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }

    // MARK: Notification

    /**
     Called when the keyboard should appear.
     */
    @objc
    func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                self.keyboardVisibleHeight = frameValue.cgRectValue.size.height
            }

            self.updateConstant()
            self.keyboardAnimation(userInfo: userInfo)
        }
    }

    /**
     Called when the keyboard should be hidden.
     */
    @objc
    func keyboardWillHideNotification(_ notification: NSNotification) {
        self.keyboardVisibleHeight = 0
        self.updateConstant()

        if let userInfo = notification.userInfo {
            self.keyboardAnimation(userInfo: userInfo)
        }
    }

    /**
     Updates the constant for the constraint that is using this class.
     */
    func updateConstant() {
        self.constant = self.offset + self.keyboardVisibleHeight
    }

    /**
     Animates the keyboard up and down.

     - parameter userInfo: The object received from the keyboard notification.
     */
    func keyboardAnimation(userInfo: [AnyHashable: Any]) {
        switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
        case let (.some(duration), .some(curve)):
            UIView.animate(
                withDuration: TimeInterval(duration.doubleValue),
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curve.uintValue),
                animations: {
                    UIApplication.shared.keyWindow?.layoutIfNeeded()
                    return
                },
                completion: { _ in })
        default:
            break
        }
    }
}
