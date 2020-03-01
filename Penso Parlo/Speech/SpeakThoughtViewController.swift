//
//  SpeakThoughtViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 8/24/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Lottie
import os
import Speech
import UIKit

/**
 This class displays the speak thought view within the storyboard.
 */
class SpeakThoughtViewController: AddThoughtViewController, SpeechDictationDelegate {

    // MARK: - IBOutlets

    /// The button that takes the user to the system settings when pressed
    /// Note: This is hidden by default and is only displayed when the user doesn't have the proper
    /// permissions for speech dictation
    @IBOutlet private weak var systemSettingsButton: SystemSettingsButton!

    /// Allows the user an option to continue speaking. Replaces the audio visualizer when the user is no longer speaking.
    @IBOutlet private weak var continueThoughtButton: ContinueThoughtButton!

    // MARK: - Static Properties

    /// String displayed on the button that takes the user to the system settings when they do not have proper device permissions.
    private static let openSettingsButtonTitle = NSLocalizedString("HARDWARE_PERMISSION_SETTINGS_BUTTON_TITLE",
                                                                   tableName: "PensoParlo",
                                                                   bundle: Bundle.main,
                                                                   value: "Open Settings",
                                                                   comment: "The button title to open system settings.")

    /// String displayed on the  cancel button when the user is alerted that they do not have proper device permissions.
    private static let cancelButtonTitle = NSLocalizedString("HARDWARE_PERMISSION_CANCEL_BUTTON_TITLE",
                                                             tableName: "PensoParlo",
                                                             bundle: Bundle.main,
                                                             value: "Cancel",
                                                             comment: "The button title to cancel the alert.")

    /// The text that is displayed before speech dictation has started.
    private static let defaultPromptText = NSLocalizedString("DEFAULT_USER_PROMPT_TEXT",
                                                             tableName: "PensoParlo",
                                                             bundle: Bundle.main,
                                                             value: "Whats on your mind?",
                                                             comment: "The text that is displayed when the user opens the speech view.")

    /// The animation speed to play the animation when it is going up in frames.
    private static let animationUpSpeed: CGFloat = 3

    /// The animation speed to play the animation when it is going down in frames.
    private static let animationDownSpeed: CGFloat = 1

    /// The last frame to play for the animation.
    private static let animationEndFrame: AnimationFrameTime = 24

    /// The first frame to play for the animation.
    private static let animationStartFrame: AnimationFrameTime = 0

    // MARK: - Member Properties

    /// Starts the siri shortcut workflow.
    var addSiriShortcutPrompt: (() -> Void)?

    /// Handles speech dictation.
    private var speechDictationHandler: SpeechDictationHandler?

    /// The animation to show on-screen
    private var audioVisualizer = AnimationView(name: "audio_visualizer")

    /// The previous decibel power value that was used to animatie the audio visualizer.
    private var previousPowerValue: Float?

    // MARK: - View Lifecycle

    /**
     Called everytime the view appears.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.requestMicrophonePermission()
        self.requestSpeechAuthorization()
    }

    /**
     Called only when the view first loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentTextView.text = Self.defaultPromptText
        self.setupAudioVisualizer()
        self.speechDictationHandler = SpeechDictationHandler(delegate: self)

        self.speechDictationHandler?.startSpeechDictation()
        self.setupDoneButtonActions()
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

    func setDetectedText(to dictatedText: String) {
        self.contentTextView.text = dictatedText

        if !self.contentTextView.text.isEmpty && self.contentTextView.text != Self.defaultPromptText {
            self.selectGroupButton.isEnabled = true
        }
    }

    func updateAudioVisualizer(with newPowerValue: Float) {
        if let previousPowerValue = self.previousPowerValue {
            if previousPowerValue < newPowerValue {
                self.audioVisualizer.animationSpeed = Self.animationUpSpeed
                self.playAnimation(to: Self.animationEndFrame)
            } else if previousPowerValue > newPowerValue {
                audioVisualizer.animationSpeed = Self.animationDownSpeed
                self.playAnimation(to: Self.animationStartFrame)
            }
        }

        self.previousPowerValue = newPowerValue
    }

    func currentlyDictating() {
        self.continueThoughtButton.isHidden = true
        self.audioVisualizer.isHidden = false
    }

    func doneDictating() {
        self.continueThoughtButton.isHidden = false
        self.audioVisualizer.isHidden = true
    }

    // MARK: - Audio Visualizer Helper Methods

    /**
     Plays the animation to the frame that is passed in. The animation always starts at the frame that the animation was at when this method was last called.
     This ensures a smooth animation, so that it doesn't start from the beginning every time and maintains responsiveness to the audio input.

     - parameter frame: The animation frame to play the animation to.
     */
    private func playAnimation(to frame: AnimationFrameTime) {
        self.audioVisualizer.play(fromFrame: self.audioVisualizer.realtimeAnimationFrame,
                                  toFrame: frame,
                                  loopMode: .playOnce) { [weak self] animationCompleted in

            if animationCompleted {
                self?.audioVisualizer.animationSpeed = Self.animationDownSpeed
                self?.audioVisualizer.play(fromFrame: self?.audioVisualizer.realtimeAnimationFrame,
                                           toFrame: Self.animationStartFrame,
                                           loopMode: .playOnce,
                                           completion: nil)
            }
        }
    }

    /**
     Positions the audio visualizer animation on the view.
     */
    private func setupAudioVisualizer() {
        self.audioVisualizer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.audioVisualizer.center.x = self.view.center.x
        self.audioVisualizer.center.y = self.view.center.y + 100
        self.audioVisualizer.contentMode = .scaleAspectFill

        self.view.addSubview(self.audioVisualizer)
    }

    // MARK: - Button Setup

    override func setupDoneButtonActions(completion:(() -> Void)? = nil) {
        self.doneButton.onButtonPressHandler = { [weak self] in
            if self?.contentTextView.text != Self.defaultPromptText && self?.contentTextView.text.isEmpty == false {
                self?.addThoughtToQuickThoughts()
            }

            // Getting this error if I call super in a closure.
            // Using 'super' in a closure where 'self' is explicitly captured is not yet supported
            self?.setupDoneButtonActionsSuper()
        }
    }

    /**
     Adding this method because of compiler error. This is the best way to handle this in swift right now.
     Error: Using 'super' in a closure where 'self' is explicitly captured is not yet supported
     */
    private func setupDoneButtonActionsSuper() {
        super.setupDoneButtonActions { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.addSiriShortcutPrompt?()
            }
        }
    }

    // MARK: - Permission Handling Methods

    /**
     Requests users authorization for speech dictation and updates views accordingly.
     */
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized,
                     .notDetermined:
                    break
                case .denied:
                    self.showPermissionNotEnabledAlert(for: "Speech Recognition")
                    // TODO: PENSO-28 Play animation showing that we aren't able to record audio like how google does it.
                case .restricted:
                    self.setDetectedText(to: NSLocalizedString("HARDWARE_PERMISSION_RESTRICTED_MESSAGE",
                                                               tableName: "PensoParlo",
                                                               bundle: Bundle.main,
                                                               value: "Speech Recognition is restricted on this device.",
                                                               comment: "The message to display when speech recognition is restricted."))
                    // TODO: PENSO-28 Play animation showing that we aren't able to record audio like how google does it.
                @unknown default:
                    break
                }
            }
        }
    }

    /**
     Requests users authorization for microphone usage and updates views accordingly.
     */
    private func requestMicrophonePermission() {
        OperationQueue.main.addOperation {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .denied:
                self.showPermissionNotEnabledAlert(for: "Microphone")
                // TODO: PENSO-28 Play animation showing that we aren't able to record audio like how google does it.
            case .granted:
                break
            case .undetermined:
                // TODO: PENSO-28 Play animation showing that we aren't able to record audio like how google does it.
                break
            @unknown default:
                break
            }
        }
    }

    /**
     Sets up and displays an alert when the user does not have proper device permissions to begin speech dictation.

     - parameter permission: The permission that is not enabled.
     */
    private func showPermissionNotEnabledAlert(for permission: String) {
        let localizedAlertStrings = Self.localizedAlertStrings(for: permission)

        let alertVC = UIAlertController(title: localizedAlertStrings.title, message: localizedAlertStrings.message, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: Self.openSettingsButtonTitle, style: .default) { [weak self] _ in
            self?.tappedOpenSystemSettingsButton()
        })

        alertVC.addAction(UIAlertAction(title: Self.cancelButtonTitle, style: .cancel) { [weak self] _ in
            // Displays permission not enabled message and button to go to system settings on the view when the cancel button is pressed.
            self?.setDetectedText(to: localizedAlertStrings.message)
            self?.systemSettingsButton.onButtonPressHandler = { [weak self] in
                self?.tappedOpenSystemSettingsButton()
            }
            self?.systemSettingsButton.isHidden = false
        })

        self.present(alertVC, animated: true, completion: nil)
    }

    /**
     Configures localized strings for the alerts that are displayed to the user when they do not have proper device permissions

     - parameter permission: The permission that is not enabled.
     - returns: The title and the message of the alert to display.
     */
    private class func localizedAlertStrings(for permission: String) -> (title: String, message: String) {
        let title = NSLocalizedString("HARDWARE_PERMISSION_ALERT_TITLE",
                                      tableName: "PensoParlo",
                                      bundle: Bundle.main,
                                      value: "\(permission) is not enabled.",
                                      comment: "The title displayed when a certain piece of hardware is not enabled.")

        let message = NSLocalizedString("HARDWARE_PERMISSION_ALERT_MESSAGE",
                                        tableName: "PensoParlo",
                                        bundle: Bundle.main,
                                        value: "In order to use Speech-to-Text functionality, please enable '\(permission)' in settings by pressing the 'Open Settings' button below.",
                                        comment: "The message displayed when a certain piece of hardware is not enabled.")

        return (title, message)
    }

    /**
     Opens the system settings.
     */
    private func tappedOpenSystemSettingsButton() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
