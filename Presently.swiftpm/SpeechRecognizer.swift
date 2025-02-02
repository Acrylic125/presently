import Foundation
import AVFoundation
import Speech
import SwiftUI
import Combine
import Accelerate

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

public struct PresentationTranscriptRawPart {
    var bestTranscript: SFTranscription
    var segments: [SFTranscriptionSegment]
    var partId: String
    var startTime: Int
}

final public class SpeechRecgonizer: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var audioSession: AVAudioSession?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var numberOfAudioAmplitudes = 30
    private var processSampleCooldown: Double = 0

    @Published var transcriptions: [PresentationTranscriptRawPart] = []
    @Published var state: SpeechRecognizerState = .inactive
    @Published var error: Error?
    @Published var audioAmplitudes: [CGFloat] = []

    private var transcriptionHook: (() -> Void)?
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
                let errorMessage = asErrorMessage(error: error)
                print("Error \(errorMessage)!")
                await self.setError(error: error)
            }
        }
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        self.speechRecognizer = speechRecognizer
    }
    
    @MainActor private func setState(state: SpeechRecognizerState) {
        self.state = state
    }
    
    @MainActor private func setError(error: Error) {
        self.state = .inactive
        self.error = error
    }
    
    @MainActor public func resetSession() {
        self.transcriptions = []
    }
    
    func startNext(partId: String) {
        Task {
            self.transcriptionHook = {
                self.transcriptionHook = nil
                self.start(partId: partId, softStart: true)
            }
            await self.reset(softReset: true)
        }
    }
    
    @MainActor private func addNewPart(partId: String) -> Int {
        self.transcriptions.append(
            .init(
                bestTranscript: .init(),
                segments: [],
                partId: partId,
                startTime: Int(Date().timeIntervalSince1970)
            )
        )
        let transcriptionIndex = self.transcriptions.count - 1
        return transcriptionIndex
    }
    
    func start(partId: String, shouldReset: Bool = true, softStart: Bool = false) {
        if let task = self.startStopTask {
            task.cancel()
        }
        
        self.startStopTask = Task {
            if (shouldReset) {
                await reset(softReset: softStart)
            }
            
            if let audioEngine = self.audioEngine, audioEngine.isRunning {
                print("Audio engine is already running. Please stop.")
                await self.setError(error: RecognizerError.recognizerStartFailed)
                return
            }
            
            if !softStart {
                await self.setState(state: .starting)
            }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
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
            inputNode.reset()
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                request.append(buffer)
                Task {
                    await self.processSampleBuffer(buffer)
                }
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
            
            let transcriptionIndex = await addNewPart(partId: partId)

            self.recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(
                    transcriptionIndex: transcriptionIndex,
                    audioEngine: audioEngine,
                    result: result,
                    error: error
                )
            })
            
            print("Started")
            if !softStart {
                await self.setState(state: .active)
            }
            self.audioEngine = audioEngine
            self.audioSession = audioSession
            self.recognitionRequest = request
        }
    }
   
    private func processSampleBuffer(_ buffer: AVAudioPCMBuffer) async {
        let now = Date().timeIntervalSince1970
        if now < processSampleCooldown {
            print("\(processSampleCooldown - now)")
            return
        }
        self.processSampleCooldown = now + 0.2
        
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = Int(buffer.frameLength)
        
        var amplitudes: [CGFloat] = []
        var amplitudesSamples: [Int] = []

        // Calculate RMS (Root Mean Square) to get amplitude
        let windowSize = frames / self.numberOfAudioAmplitudes
        for frame in 0..<frames {
            let amplitudeIndex = frame / windowSize
            while amplitudeIndex >= amplitudes.count {
                amplitudes.append(0)
                amplitudesSamples.append(0)
            }
            
            let sample = channelData[frame]
            amplitudes[amplitudeIndex] += CGFloat(sample * sample)
            amplitudesSamples[amplitudeIndex] += 1
        }
        
        var newAmplitudes: [CGFloat] = []
        let mid = CGFloat(self.numberOfAudioAmplitudes / 2)
        for i in 0..<amplitudes.count {
            let amplitude = amplitudes[i]
            let samples = amplitudesSamples[i]
            
            let rms = sqrt(amplitude / CGFloat(samples))
            // Convert to decibels
            let db = 20 * log10(rms)
            // Normalize to 0-1 range (assuming typical dB range of -160 to 0)
            let normalizedValue = CGFloat(max(0, min(1, (db + 160) / 160)))

            let q = min(max((pow(100, normalizedValue) / 100) - 0.2, 0) * 2, 1)
            let p = 0.5 + 0.5 * (1 - pow(abs(CGFloat(i) - mid) / mid, 2))
            let v = p * q
            newAmplitudes.append(
                v
            )
        }

        await self.setAudioAmplitudes(value: newAmplitudes)
    }
    
    func normalDistribution(x: Double, mean: Double = 0, standardDeviation: Double = 1) -> Double {
        let variance = standardDeviation * standardDeviation
        let numerator = exp(-pow(x - mean, 2) / (2 * variance))
        let denominator = standardDeviation * sqrt(2 * .pi)
        return numerator / denominator
    }
    
    func stop() {
        if let task = self.startStopTask {
            task.cancel()
        }
        self.startStopTask = Task {
            await reset()
        }
    }
    
    @MainActor private func setAudioAmplitudes(value: [CGFloat]) {
        self.audioAmplitudes = value
    }
    
    private func reset(softReset: Bool = false) async {
        if !softReset {
            await self.setState(state: .stopping)
        }
        recognitionTask?.finish()
        audioEngine?.stop()
        
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        if !softReset {
            await self.setState(state: .inactive)
        }
    }
    
    private func recognitionHandler(
        transcriptionIndex: Int,
        audioEngine: AVAudioEngine,
        result: SFSpeechRecognitionResult?,
        error: Error?
    ) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(
                transcriptionIndex,
                result.bestTranscription.formattedString,
                result.bestTranscription,
                result.isFinal
            )
        }
        self.transcriptionHook?()
    }
    
    private func transcribe(
        _ transcriptionIndex: Int,
        _ message: String,
        _ bestTranscription: SFTranscription,
        _ isFinal: Bool
    ) {
        if self.transcriptions.count <= 0 {
            print("No existing transcriptions found despite speech recognizer running")
            return
        }
        if (bestTranscription.segments.first { $0.confidence > 0 } == nil) {
            return
        }
        if transcriptionIndex < self.transcriptions.count {
            var cur = self.transcriptions[transcriptionIndex]
            cur.bestTranscript = bestTranscription
            cur.segments = bestTranscription.segments
            
            // Clone to publicize change
            var newTranscriptions: [PresentationTranscriptRawPart] = []
            for session in self.transcriptions {
                newTranscriptions.append(session)
            }
            newTranscriptions[transcriptionIndex] = cur
            self.transcriptions = newTranscriptions
        } else {
            print("Wtf? \(transcriptionIndex)")
        }
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
