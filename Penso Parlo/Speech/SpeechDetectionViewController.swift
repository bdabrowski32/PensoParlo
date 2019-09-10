//
//  SpeechDetectionViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 8/24/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Speech
import UIKit

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet private weak var detectedTextLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!

    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()

    var recognitionTask: SFSpeechRecognitionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
    }

    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }

        guard let speechRecognizer = SFSpeechRecognizer() else {
            print("A recognizer is not supported for the current locale.")
            return
        }

        guard speechRecognizer.isAvailable else {
            print("A recognizer is not avialable right now.")
            return
        }

        self.startButton.isEnabled = false
        self.recognitionTask = speechRecognizer.recognitionTask(with: self.request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString

                var lastString = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[..<indexTo]) //.substring(from: indexTo)
                }

                self.checkForStop(resultString: lastString)
            } else if let error = error {
                print(error)
            }
        })
    }

    func checkForStop(resultString: String) {
        if resultString == "penso" { // Dont want to say stop because that may be a cimmon word
            self.audioEngine.stop()
            self.startButton.isEnabled = true
        }
    }

    private func checkLastString(in bestTranscription: SFTranscription) {

    }

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .notDetermined:
                    self.startButton.isEnabled = false
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognizer"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .authorized:
                    self.startButton.isEnabled = true
                @unknown default:
                    self.startButton.isEnabled = false
                }
            }
        }
    }
}
