//
//  SpeechDictationHandler.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 12/31/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import AVFoundation
import os
import Speech
import UIKit

/**
 This class handles all speech recognition duties
 */
class SpeechDictationHandler: NSObject, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {

    // MARK: - Member Properties

    /// Used to generate and process audio signals and perform audio input and output.
    private let audioEngine = AVAudioEngine()

    /// Used to check for the availability of the speech recognition service, and to initiate the speech recognition process.
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()

    /// Request to recognize speech from the device's microphone.
    private let request = SFSpeechAudioBufferRecognitionRequest()

    /// Task object used to monitor the speech recognition progress.
    private var recognitionTask: SFSpeechRecognitionTask?

    /// The sum of appended decibel values from the microphone, used to gauge the rooms noise.
    private var decibelBaseline = [Float]()

    /// The audio recorder used to get decibel values when the user speaks into the microphone for the audio visualizer.
    private var audioRecorder: AVAudioRecorder?

    /// A timer object that allows the application to synchronize its drawing to the refresh rate of the display.
    /// Used for animating the audio visualizer.
    private var displayLink: CADisplayLink?

    /// The delegate to pass speech information to.
    private weak var delegate: SpeechDictationDelegate?

    /// The document directory to store the users audio recording.
    /// - Note: I tried to use a blank file, but would not let me. Not sure why we need this.
    private var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.m4a")
    }

    /**
     Initializes the class

     - parameter delegate: The delegate to pass speech dictation information to.
     */
    init(delegate: SpeechDictationDelegate) {
        self.delegate = delegate

        super.init()

        self.speechRecognizer?.delegate = self
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateAudioVisualizer))
    }

    // MARK: - Audio Visualizer Methods

    /**
     Sets up the audio recorder to measure input values from the users voice.

     - throws: Error if the audio recorder is unable to be created.
     */
    private func setupAudioRecorder() throws {
        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
        try AVAudioSession.sharedInstance().setActive(true)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue // Using lowest quality since we are just using for audio animation.
        ]

        audioRecorder = try AVAudioRecorder(url: self.documentDirectory, settings: settings)
        self.audioRecorder?.delegate = self
    }

    /**
     Starts the run loop that updates the metering value from the microphone. Constantly receives values from the microphone when
     audio recording is turned on.
     */
    private func startRunLoop() {
        guard let displayLink = self.displayLink else {
            os_log("Unable to get a reference to a display link for the audio visualizer.",
                   log: OSLog.default,
                   type: .error)
            return
        }

        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }

    /**
     Invalidates the display link. Once invalidated the microphone will no longer take in metering level (dB) for the audio visualizer.
     */
    private func stopRunLoop() {
        guard let displayLink = self.displayLink else {
            os_log("Display link is already nil. Not invalidating.",
                   log: OSLog.default,
                   type: .info)
            return
        }

        displayLink.invalidate()
    }

    /**
     Starts recording the user's audio session.
     */
    private func startRecording() {
        do {
            try self.setupAudioRecorder()
            self.audioRecorder?.record()
            self.startRunLoop()
        } catch {
            self.stopAudioRecoder(success: false)
        }
    }

    /**
     Gathers the audio data from the microphone and passes the new decibel value to the delegate to animate the audio visualizer.
     - Note: The peak power value must be greater than the calculated baseline in order to get passed to the view.
             Also, This method is called by the run loop and is called 60 frames per second.
     */
    @objc
    private func updateAudioVisualizer() {
        guard let audioRecorder = self.audioRecorder else {
            // TODO: PENSO-28 Setup a backup animation for when the audio recorder can't be created.
            os_log("The audio recorder is nil. We are not going to animate.",
                   log: OSLog.default,
                   type: .error)
            return
        }

        // Have to call this method in order to get the decibel value from the microphone.
        audioRecorder.updateMeters()
        audioRecorder.isMeteringEnabled = true
        let peakPower = audioRecorder.peakPower(forChannel: 0)

        // I have no idea why this is happeneing but when I do != -120 or != -160 then it doesn't work, have to compare with ==.
        // This check is to make sure that these generic values do not get calculated in the decibel baseline average. If they are
        // calculated in the average, then the baseline value is too low.
        if peakPower == -160.0 || peakPower == -120.0 {
            return
        }

        // Gathers 30 samples of audio data.
        guard self.decibelBaseline.count > 30 else {
            self.decibelBaseline.append(peakPower)
            return
        }

        // Adding 5 to the baseline average to decrease microphone/animation sensitivity.
        // Only update the animation if the peakPower value is above the decibel baseline.
        if peakPower > (self.decibelBaseline.average + 5) {
            self.delegate?.updateAudioVisualizer(with: peakPower)
        }
    }

    /**
     Stops the audio recorder.
     */
    private func stopAudioRecoder(success: Bool = true) {
        self.audioRecorder?.stop()
        self.audioRecorder = nil

        guard success else {
            os_log("Error setting up the audio recorder for the audio visualizer animation",
                   log: OSLog.default,
                   type: .error)
            return
        }
    }

    // MARK: - Speech Dictation Methods

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
        self.delegate?.currentlyDictating()
        self.startAudioEngine()
        self.startRecording()

        guard let speechRecognizer = self.speechRecognizer, speechRecognizer.isAvailable else {
            print("A speech recognizer is not available right now.")
            // TODO: PENSO-11 Check for network connectivity
            return
        }

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
            self.stopSpeechDictation()
            return true
        }

        return false
    }

    /**
     Turns off the audio engine and other tasks when speech dictation is ended.
     */
    private func stopSpeechDictation() {
        self.audioEngine.stop()
        self.recognitionTask?.cancel()
        self.stopAudioRecoder()
        self.stopRunLoop()
        self.delegate?.doneDictating()
    }

    // MARK: - Speech Recognizer Delegate Methods

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // TODO: PENSO-11 Check for network connectivity
        // Probably need to dismiss the view or something along those lines.
    }
}
