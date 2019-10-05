//
//  SpeechDetectionViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 8/24/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Speech
import UIKit

/**
 This class displays the speech detection view within the storyboard. Handles all speech recognition duties.
 */
class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {

    /// Displays the text that the user says.
    @IBOutlet private weak var detectedTextLabel: UILabel!

    @IBOutlet private weak var speechIndicator: UIView!

    /// Used to generate and process audio signals and perform audio input and output.
    private let audioEngine = AVAudioEngine()

    /// Used to check for the availability of the speech recognition service, and to initiate the speech recognition process.
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()

    /// Request to recognize speech from the device's microphone.
    private let request = SFSpeechAudioBufferRecognitionRequest()

    /// Task object used to monitor the speech recognition progress.
    private var recognitionTask: SFSpeechRecognitionTask?

    override func viewWillAppear(_ animated: Bool) {
        self.speechIndicator.backgroundColor = UIColor.green
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
        self.dictateSpeech()
    }

    deinit {
        self.recognitionTask = nil
    }

    /**
     Prepares the audio engine for speech recognition.
     */
    private func startAudioEngine() {
        let node = audioEngine.inputNode
        node.installTap(onBus: 0, bufferSize: 1_024, format: node.outputFormat(forBus: 0)) { buffer, _ in
            self.request.append(buffer)
        }

        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch {
            return print(error)
        }
    }

    /**
     Performs speech dictation and updates the labels on the view.
     */
    func dictateSpeech() {
        self.startAudioEngine()

        guard let speechRecognizer = SFSpeechRecognizer() else {
            print("A recognizer is not supported for the current locale.")
            return
        }

        guard speechRecognizer.isAvailable else {
            print("A recognizer is not avialable right now.")
            return
        }

        self.recognitionTask = speechRecognizer.recognitionTask(with: self.request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString

                var lastString = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }

                guard self.checkForStop(resultString: lastString) == false else {
                    self.detectedTextLabel.text = bestString.components(separatedBy: " ").dropLast().joined(separator: " ")
                    NotesItem.add(text: self.detectedTextLabel.text ?? "nil")
                    print("Already stopped recording.")
                    return
                }
            } else if let error = error {
                print(error)
            }
        })
    }

    /**
     Turns off the audio engine.
     */
    private func checkForStop(resultString: String) -> Bool {
        if resultString == "stop" { // Dont want to say stop because that may be a common word
            self.performStop()
            return true
        }

        return false
    }

    /**
     Turns off the audio engine and other tasks when speech dictation is ended.
     */
    private func performStop() {
        self.speechIndicator.backgroundColor = UIColor.red
        self.audioEngine.stop()
        self.recognitionTask?.cancel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
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
                    self.detectedTextLabel.text = "User denied access to speech recognizer"
                case .restricted:
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                @unknown default:
                    break
                }
            }
        }
    }
}
