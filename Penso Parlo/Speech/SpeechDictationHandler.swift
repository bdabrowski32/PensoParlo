//
//  SpeechDictationHandler.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/31/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import Speech
import UIKit

/**
 This class handles all speech recognition duties
 */
class SpeechDictationHandler: NSObject, SFSpeechRecognizerDelegate {

    /// Used to generate and process audio signals and perform audio input and output.
    private let audioEngine = AVAudioEngine()

    /// Used to check for the availability of the speech recognition service, and to initiate the speech recognition process.
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()

    /// Request to recognize speech from the device's microphone.
    private let request = SFSpeechAudioBufferRecognitionRequest()

    /// Task object used to monitor the speech recognition progress.
    private var recognitionTask: SFSpeechRecognitionTask?

    /// Actions to perform when speech dictation is completed.
    private var dictationCompleted: () -> Void

    /// The delegate to pass speech information to.
    private weak var delegate: SpeechDictationDelegate?

    /**
     Initializes the class

     - parameter delegate: The delegate to pass speech dictation information to.
     - parameter dictationCompleted: The actions to perform when speech dictation is complete.
     */
    init(delegate: SpeechDictationDelegate, dictationCompleted: @escaping () -> Void) {
        self.delegate = delegate
        self.dictationCompleted = dictationCompleted

        super.init()

        self.speechRecognizer?.delegate = self
    }

    /**
     Prepares the audio engine for speech recognition.
     */
    private func startAudioEngine() {
        let node = self.audioEngine.inputNode
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
    func startSpeechDictation() {
        self.startAudioEngine()

        guard let speechRecognizer = self.speechRecognizer, speechRecognizer.isAvailable else {
            print("A speech recognizer is not available right now.")
            // TODO: PENSO-11 Check for network connectivity
            return
        }

        self.delegate?.setSpeechIndicatorColor(to: UIColor.green)
        self.recognitionTask = speechRecognizer.recognitionTask(with: self.request) { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.delegate?.setDetectedText(to: bestString)

                var lastString = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }

                guard self.checkForStop(resultString: lastString) == false else {
                    let finalBestString = bestString.components(separatedBy: " ").dropLast().joined(separator: " ")
                    self.delegate?.setDetectedText(to: finalBestString)
                    ThoughtItem.add(text: finalBestString)
                    print("Already stopped recording.")
                    return
                }
            } else if let error = error {
                print(error)
            }
        }
    }

    /**
     Turns off the audio engine.
     */
    private func checkForStop(resultString: String) -> Bool {
        // TODO: PENSO-12 Handle speech timeout correctly.
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
        self.delegate?.setSpeechIndicatorColor(to: UIColor.red)
        self.audioEngine.stop()
        self.recognitionTask?.cancel()
        self.dictationCompleted()
    }

    // MARK: - Speech Recognizer Delegate Methods

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // TODO: PENSO-11 Check for network connectivity
        // Probably need to dismiss the view or something along those lines.
    }
}
