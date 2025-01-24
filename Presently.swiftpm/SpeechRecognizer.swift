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

final public class SpeechRecgonizer: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var audioSession: AVAudioSession?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var transcriptions: [SFTranscription] = []
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
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    @MainActor private func setState(state: SpeechRecognizerState) {
        self.state = state
    }
    
    @MainActor private func setError(error: Error) {
        self.state = .inactive
        self.error = error
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
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            let audioEngine = AVAudioEngine()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                throw RecognizerError.recognizerStartFailed
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
            //            await self.setState(state: .stopping)
//            recognitionTask?.cancel()
//            audioEngine?.stop()
//            
//            audioEngine = nil
//            recognitionRequest = nil
//            recognitionTask = nil
//            await self.setState(state: .inactive)
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
    
//    @objc private func handleInterruption(notification: Notification) {
//        if let audioEngine = self.audioEngine {
//            print("Is running? \(audioEngine.isRunning )")
//        }
//        print("Notified!")
//    }

    private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(result.bestTranscription.formattedString, result.transcriptions)
        }
    }
    
    private func transcribe(_ message: String, _ transcriptions: [SFTranscription] ) {
        print(message)
        self.transcriptions = transcriptions
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

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
//actor SpeechRecognizer: ObservableObject {
//    enum RecognizerError: Error {
//        case nilRecognizer
//        case notAuthorizedToRecognize
//        case notPermittedToRecord
//        case recognizerIsUnavailable
//        
//        var message: String {
//            switch self {
//            case .nilRecognizer: return "Can't initialize speech recognizer"
//            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
//            case .notPermittedToRecord: return "Not permitted to record audio"
//            case .recognizerIsUnavailable: return "Recognizer is unavailable"
//            }
//        }
//    }
//    
//    @MainActor var transcript: String = ""
//    @MainActor var transcriptions: [SFTranscription] = []
//    @Published var state: SpeechRecognizerState = .inactive
//    
//    private var audioEngine: AVAudioEngine?
//    private var request: SFSpeechAudioBufferRecognitionRequest?
//    private var task: SFSpeechRecognitionTask?
//    private let recognizer: SFSpeechRecognizer?
//    private var reconcilationTimer: Timer?
//
//    /**
//     Initializes a new speech recognizer. If this is the first time you've used the class, it
//     requests access to the speech recognizer and the microphone.
//     */
//    init() {
//        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//        guard recognizer != nil else {
//            transcribe(RecognizerError.nilRecognizer)
//            return
//        }
//        
//        Task {
//            do {
//                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
//                    throw RecognizerError.notAuthorizedToRecognize
//                }
//                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
//                    throw RecognizerError.notPermittedToRecord
//                }
//            } catch {
//                transcribe(error)
//            }
//        }
//    }
//    
//    @MainActor func reconcilationLoop() {
//        self.reconcilationTimer?.invalidate()
//        self.reconcilationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            self.state = self.reduceState()
//        }
//    }
//    
//    private func reduceState() -> SpeechRecognizerState {
//        guard let audioEngine else {
//            return .inactive
//        }
//        if (audioEngine.isRunning) {
//            return .active
//        }
//        return .inactive
//    }
//    
//    @MainActor func startTranscribing() {
//         Task {
//             await transcribe()
//        }
//    }
//    
//    @MainActor func resetTranscript() {
//        Task {
//            await reset()
//        }
//    }
//    
//    @MainActor func stopTranscribing() {
//        Task {
//            await reset()
//        }
//    }
//    
//    /**
//     Begin transcribing audio.
//     
//     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
//     The resulting transcription is continuously written to the published `transcript` property.
//     */
//    private func transcribe() {
////        if (self.isLoading) {
////            return
////        }
//        
//        guard let recognizer, recognizer.isAvailable else {
//            self.transcribe(RecognizerError.recognizerIsUnavailable)
//            return
//        }
//        
//        do {
//            let (audioEngine, request) = try Self.prepareEngine()
//            
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(handleInterruption),
//                name: .AVAudioEngineConfigurationChange,
//                object: audioEngine
//            )
//            
//            // Also observe when the audio engine stops
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(handleInterruption),
//                name: AVAudioSession.interruptionNotification,
//                object: audioEngine
//            )
//            self.audioEngine = audioEngine
//            
//            self.request = request
//            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
//                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
//            })
//        } catch {
//            self.reset()
//            self.transcribe(error)
//        }
//    }
//    
//    @objc nonisolated private func handleInterruption(notification: Notification) {
//        Task { @MainActor in
//            // Check if the audio engine is still running
//            if let audioEngine = await self.audioEngine, !audioEngine.isRunning {
//                await self.reset()
//            }
//        }
//        print("Test!")
//    }
//
//    /// Reset the speech recognizer.
//    private func reset() {
//        task?.cancel()
//        audioEngine?.stop()
//        audioEngine = nil
//        request = nil
//        task = nil
//    }
//    
//    public func getAudioEngine() -> AVAudioEngine? {
//        return self.audioEngine
//    }
//    
//    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
//        let audioEngine = AVAudioEngine()
//        
//        let request = SFSpeechAudioBufferRecognitionRequest()
//        request.addsPunctuation = true
//        request.shouldReportPartialResults = true
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        let inputNode = audioEngine.inputNode
//        
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//            request.append(buffer)
//        }
//        audioEngine.prepare()
//        try audioEngine.start()
//        
//        return (audioEngine, request)
//    }
//    
//    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
//        let receivedFinalResult = result?.isFinal ?? false
//        let receivedError = error != nil
//        
//        if receivedFinalResult || receivedError {
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
//        
//        if let result {
//            transcribe(result.bestTranscription.formattedString, result.transcriptions)
//        }
//    }
//    
//    nonisolated private func transcribe(_ message: String, _ transcriptions: [SFTranscription] ) {
//        Task { @MainActor in
//            transcript = message
//            self.transcriptions = transcriptions
//        }
//    }
//    nonisolated private func transcribe(_ error: Error) {
//        var errorMessage = ""
//        if let error = error as? RecognizerError {
//            errorMessage += error.message
//        } else {
//            errorMessage += error.localizedDescription
//        }
//        Task { @MainActor [errorMessage] in
//            transcript = "<< \(errorMessage) >>"
//        }
//    }
//}


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
