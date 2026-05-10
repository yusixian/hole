import Foundation
import Speech

enum SpeechTranscriber {
    static func transcribe(url: URL, locale: Locale = .current) async -> String {
        let authorized = await requestAuthorization()
        guard authorized else { return "" }
        let recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer()
        guard let recognizer, recognizer.isAvailable else { return "" }
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false

        return await withCheckedContinuation { continuation in
            var resumed = false
            recognizer.recognitionTask(with: request) { result, error in
                guard !resumed else { return }
                if let error {
                    let nsError = error as NSError
                    if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1700 {
                        return
                    }
                    resumed = true
                    continuation.resume(returning: "")
                    return
                }
                guard let result, result.isFinal else { return }
                resumed = true
                continuation.resume(returning: result.bestTranscription.formattedString)
            }
        }
    }

    private static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
