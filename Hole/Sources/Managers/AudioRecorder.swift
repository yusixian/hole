import Foundation
import AVFoundation
import Observation

@MainActor
@Observable
final class AudioRecorder: NSObject {
    enum Phase: Equatable {
        case idle
        case recording
        case finished(URL, TimeInterval)
        case failed(String)
    }

    private(set) var phase: Phase = .idle
    private(set) var elapsed: TimeInterval = 0

    private var recorder: AVAudioRecorder?
    private var startedAt: Date?
    private var tickTask: Task<Void, Never>?
    private var tempURL: URL?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func start() async {
        guard phase != .recording else { return }
        guard await requestPermission() else {
            phase = .failed("permission_denied")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("rec-\(UUID().uuidString).m4a")
            tempURL = url
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 22050,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]
            let r = try AVAudioRecorder(url: url, settings: settings)
            r.isMeteringEnabled = true
            recorder = r
            r.record()
            phase = .recording
            startedAt = .now
            elapsed = 0
            startTicking()
        } catch {
            phase = .failed("\(error)")
        }
    }

    func stop() {
        guard phase == .recording, let recorder, let tempURL, let startedAt else {
            cleanupTicking()
            return
        }
        recorder.stop()
        cleanupTicking()
        let duration = Date().timeIntervalSince(startedAt)
        phase = .finished(tempURL, duration)
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func reset() {
        cleanupTicking()
        if case let .finished(url, _) = phase {
            try? FileManager.default.removeItem(at: url)
        }
        recorder = nil
        tempURL = nil
        startedAt = nil
        elapsed = 0
        phase = .idle
    }

    private func startTicking() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 200_000_000)
                guard let self else { return }
                if let started = self.startedAt, self.phase == .recording {
                    await MainActor.run {
                        self.elapsed = Date().timeIntervalSince(started)
                    }
                }
            }
        }
    }

    private func cleanupTicking() {
        tickTask?.cancel()
        tickTask = nil
    }
}
