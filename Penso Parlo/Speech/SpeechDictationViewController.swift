//
//  SpeechDictationViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 8/24/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit
import Speech

/**
 This class displays the speech detection view within the storyboard.
 */
class SpeechDictationViewController: UIViewController, SpeechDictationDelegate {

    // MARK: - IBOutlets

    /// Displays the text that the user says.
    @IBOutlet private weak var detectedTextView: UITextView!

    @IBOutlet private weak var speechIndicator: UIView!

    // MARK: - Member Properties
    
    /// Handles speech dictation.
    private var speechDictationHandler: SpeechDictationHandler?

    /// Starts the siri shortcut workflow.
    var addSiriShortcutPrompt: (() -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()

        self.speechDictationHandler = SpeechDictationHandler(delegate: self) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                 self?.dismiss(animated: true) {
                     self?.addSiriShortcutPrompt?()
                 }
            }
        }

        self.speechDictationHandler?.startSpeechDictation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.speechDictationHandler = nil
    }

    // MARK: - Initialization

    /**
     Sets the speech dictation handler to nil when this view is deinitialized.
     */
    deinit {
        self.speechDictationHandler = nil
    }

    // MARK: - Speech Dictation Delegate

    func setDetectedText(with dictatedText: String) {
        self.detectedTextView.text = dictatedText
    }

    func setSpeechIndicatorColor(to color: UIColor) {
        self.speechIndicator.backgroundColor = color
    }

    /**
     Requests users authorization for speech dictation and updates button and labels on view accordingly.
     */
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized,
                     .notDetermined:
                    break
                case .denied:
                    self.detectedTextView.text = "User denied access to speech recognizer"
                case .restricted:
                    self.detectedTextView.text = "Speech recognition restricted on this device"
                @unknown default:
                    break
                }
            }
        }
    }
}
