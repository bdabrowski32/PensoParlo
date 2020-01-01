//
//  SpeechDictationDelegate.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/31/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 Delegate protocol to allow the speech handling class to pass information back to view controllers.
 */
protocol SpeechDictationDelegate: class {

    /**
     Sets the text view with the text that was detected from speech dictation.

     - parameter dictatedText: The words that were spoken into the microphone by the user.
     */
    func setDetectedText(with dictatedText: String)

    /**
     The view that indicates that the microphone is listening

     - parameter color: The color to change the view to based on if the microphone is listening or not
     */
    func setSpeechIndicatorColor(to color: UIColor)
}
