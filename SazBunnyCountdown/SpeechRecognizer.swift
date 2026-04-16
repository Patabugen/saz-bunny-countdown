import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isListening: Bool = false
    @Published var error: String?

    private lazy var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private lazy var audioEngine = AVAudioEngine()
    private var silenceTimer: Timer?
    private var onResult: ((String) -> Void)?

    func startListening(onResult: @escaping (String) -> Void) {
        self.onResult = onResult

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch status {
                case .authorized:
                    self.requestMicrophoneAndRecord()
                case .denied, .restricted:
                    self.error = "Speech recognition permission denied. Enable in System Settings > Privacy."
                case .notDetermined:
                    self.error = "Speech recognition permission not determined."
                @unknown default:
                    self.error = "Speech recognition unavailable."
                }
            }
        }
    }

    private func requestMicrophoneAndRecord() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if granted {
                    self.beginRecording()
                } else {
                    self.error = "Microphone access denied. Enable in System Settings > Privacy."
                }
            }
        }
    }

    func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }

    private func beginRecording() {
        stopListening()

        guard speechRecognizer != nil else {
            error = "Speech recognition is not available for this locale."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if speechRecognizer?.supportsOnDeviceRecognition == true {
            request.requiresOnDeviceRecognition = true
        }

        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isListening = true
        } catch {
            self.error = "Could not start audio engine: \(error.localizedDescription)"
            stopListening()
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                    self.resetSilenceTimer()
                }

                if error != nil || (result?.isFinal == true) {
                    self.finalize()
                }
            }
        }
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.finalize()
            }
        }
    }

    private func finalize() {
        guard isListening else { return }
        let text = transcript
        stopListening()
        if !text.isEmpty {
            onResult?(text)
        }
    }
}
