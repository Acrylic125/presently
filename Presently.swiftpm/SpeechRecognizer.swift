import Foundation
import AVFoundation
import Speech
import SwiftUI
import Combine

enum SpeechRecognizerState {
    case starting, active, stopping, inactive
}

enum RecognizerError: Error {
    case nilRecognizer
    case notAuthorizedToRecognize
    case notPermittedToRecord
    case recognizerIsUnavailable
    case recognizerStartFailed
    
    var message: String {
        switch self {
        case .nilRecognizer: return "Can't initialize speech recognizer"
        case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
        case .notPermittedToRecord: return "Not permitted to record audio"
        case .recognizerIsUnavailable: return "Recognizer is unavailable"
        case .recognizerStartFailed: return "Failed to start speech recognizer"
        }
    }
}

public struct PresentationCheckpoint {
    let partId: String
    let startTime: Int
}

public struct PresentationSessionTranscript {
    var bestTranscript: SFTranscription
    var segments: [SFTranscriptionSegment]
    var checkpoints: [PresentationCheckpoint]
}

final public class SpeechRecgonizer: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var audioSession: AVAudioSession?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var transcriptions: [PresentationSessionTranscript] = []
    @Published var state: SpeechRecognizerState = .inactive
    @Published var error: Error?
    
    private var startStopTask: Task<(), Error>?
    
    init() {
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer!.defaultTaskHint = .dictation
        
        self.speechRecognizer = speechRecognizer
    }
    
    @MainActor private func setState(state: SpeechRecognizerState) {
        self.state = state
    }
    
    @MainActor private func setError(error: Error) {
        self.state = .inactive
        self.error = error
    }
    
    @MainActor public func clockPart(
        partId: String
    ) {
        if self.transcriptions.count <= 0 {
            print("No existing checkpoints found despite clocking in part")
            return
        }
        self.transcriptions[self.transcriptions.count - 1].checkpoints.append(
            .init(
                partId: partId,
                startTime: Int(Date().timeIntervalSince1970 * 1_000)
            )
        )
    }

    @MainActor public func initSessionTranscriptions(
        partId: String
    ) {
        self.transcriptions = [
            .init(
                bestTranscript: .init(),
                segments: [],
                checkpoints: [
                    .init(
                        partId: partId,
                        startTime: Int(Date().timeIntervalSince1970 * 1_000)
                    )
                ]
            )
        ]
    }

    func start(shouldReset: Bool = true) {
        if let task = self.startStopTask {
            task.cancel()
        }
        
        self.startStopTask = Task {
            if (shouldReset) {
                await reset()
            }
            
            if let audioEngine = self.audioEngine, audioEngine.isRunning {
                print("Audio engine is already running. Please stop.")
                return
            }
            
            await self.setState(state: .starting)
            let audioEngine = AVAudioEngine()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Couldn't configure the audio session properly")
                await self.setError(error: error)
                return
            }
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.addsPunctuation = true
            request.shouldReportPartialResults = true
            guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
                print(RecognizerError.recognizerStartFailed.message)
                await self.setError(error: RecognizerError.recognizerStartFailed)
                return
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                request.append(buffer)
            }
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("Could not start audio engine!")
                audioEngine.stop()
                await self.setError(error: error)
                return
            }
            
            self.recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
            
            print("Started")
            await self.setState(state: .active)
            self.audioEngine = audioEngine
            self.audioSession = audioSession
            self.recognitionRequest = request
        }
    }
    
    func stop() {
        if let task = self.startStopTask {
            task.cancel()
        }
        self.startStopTask = Task {
            await reset()
        }
    }
    
    private func reset() async {
        await self.setState(state: .stopping)
        recognitionTask?.cancel()
        audioEngine?.stop()
        
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        await self.setState(state: .inactive)
    }
    
    private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(result.bestTranscription.formattedString, result.bestTranscription, result.isFinal)
        }
    }
    
    private func transcribe(_ message: String, _ bestTranscription: SFTranscription, _ isFinal: Bool) {
        if self.transcriptions.count <= 0 {
            print("No existing transcriptions found despite speech recognizer running")
            return
        }
//        print("--- \(isFinal)")
//        print(bestTranscription)
//        print("---")
//        if isFinal {
//            return
//        }
//        print("-----")
//        print(bestTranscription)
        if (bestTranscription.segments.first { $0.confidence > 0 } == nil) {
            print("No")
            return
        }
        var cur = self.transcriptions[self.transcriptions.count - 1]
        cur.bestTranscript = bestTranscription
        cur.segments = bestTranscription.segments
        
        // Clone to publicize change
        var newSessions: [PresentationSessionTranscript] = []
        for session in self.transcriptions {
            newSessions.append(session)
        }
        newSessions[newSessions.count - 1] = cur
        self.transcriptions = newSessions
    }

    private func transcribe(_ error: Error) {
        let errorMessage = asErrorMessage(error: error)
        print("Error \(errorMessage)!")
    }
    
}

func asErrorMessage(error: Error) -> String {
    var errorMessage = ""
    if let error = error as? RecognizerError {
        errorMessage += error.message
    } else {
        errorMessage += error.localizedDescription
    }
    return errorMessage
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}


extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
