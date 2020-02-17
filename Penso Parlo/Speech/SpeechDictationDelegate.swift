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
    func setDetectedText(to dictatedText: String)

    /**
     Animates the audio visualizer with the updated power value.

     - parameter newPowerValue: The updated power value from the user voice level when speaking into the microphone.
     */
    func updateAudioVisualizer(with newPowerValue: Float)

    func currentlyDictating()

    func doneDictating()
}
