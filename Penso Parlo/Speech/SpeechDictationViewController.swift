//
//  SpeechDictationViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 8/24/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Speech
import UIKit

/**
 This class displays the speech detection view within the storyboard.
 */
class SpeechDictationViewController: UIViewController, SpeechDictationDelegate {

    // MARK: - IBOutlets

    /// Displays the text that the user says.
    @IBOutlet private weak var detectedTextView: UITextView!

    /// The view that displays if the app is available to transcribe speech.
    @IBOutlet private weak var speechIndicator: UIView!

    /// The button that takes the user to the system settings when pressed
    /// Note: This is hidden by default and is only displayed when the user doesn't have the proper
    /// permissions for speech dictation
    @IBOutlet private weak var systemSettingsButton: SystemSettingsButton!

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

    // MARK: - Member Properties

    /// Handles speech dictation.
    private var speechDictationHandler: SpeechDictationHandler?

    /// Starts the siri shortcut workflow.
    var addSiriShortcutPrompt: (() -> Void)?

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

    func setDetectedText(to dictatedText: String) {
        self.detectedTextView.text = dictatedText
    }

    func setSpeechIndicatorColor(to color: UIColor) {
        self.speechIndicator.backgroundColor = color
    }

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
                    self.setSpeechIndicatorColor(to: UIColor.red)
                case .restricted:
                    self.setDetectedText(to: NSLocalizedString("HARDWARE_PERMISSION_RESTRICTED_MESSAGE",
                                                               tableName: "PensoParlo",
                                                               bundle: Bundle.main,
                                                               value: "Speech Recognition is restricted on this device.",
                                                               comment: "The message to display when speech recognition is restricted."))
                    self.setSpeechIndicatorColor(to: UIColor.red)
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
                self.setSpeechIndicatorColor(to: UIColor.red)
            case .granted:
                break
            case .undetermined:
                self.setSpeechIndicatorColor(to: UIColor.red)
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
        alertVC.addAction(UIAlertAction(title: Self.openSettingsButtonTitle, style: .default) { _ in
            self.tappedOpenSystemSettingsButton()
        })

        alertVC.addAction(UIAlertAction(title: Self.cancelButtonTitle, style: .cancel) { _ in
            // Displays permission not enabled message and button to go to system settings on the view when the cancel button is pressed.
            self.setDetectedText(to: localizedAlertStrings.message)
            self.systemSettingsButton.onButtonPressHandler = {
                self.tappedOpenSystemSettingsButton()
            }
            self.systemSettingsButton.isHidden = false
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
