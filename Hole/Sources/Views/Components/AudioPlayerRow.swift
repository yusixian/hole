import SwiftUI
import AVFoundation
import Observation

@MainActor
@Observable
private final class AudioPlayback: NSObject, AVAudioPlayerDelegate {
    var isPlaying: Bool = false
    var progress: Double = 0
    private var player: AVAudioPlayer?
    private var tickTask: Task<Void, Never>?

    func toggle(url: URL) {
        if isPlaying {
            stop()
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.play()
            player = p
            isPlaying = true
            startTicking()
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        tickTask?.cancel()
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    private func startTicking() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 200_000_000)
                guard let self else { return }
                await MainActor.run {
                    if let p = self.player, p.duration > 0 {
                        self.progress = p.currentTime / p.duration
                    }
                }
            }
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.stop() }
    }
}

struct AudioPlayerRow: View {
    @Environment(\.theme) private var theme
    @State private var playback = AudioPlayback()
    let attachment: VoiceAttachment

    private var url: URL? {
        AttachmentStorage.absoluteURL(forRelative: attachment.fileURL)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Button {
                    if let url { playback.toggle(url: url) }
                } label: {
                    Image(systemName: playback.isPlaying ? "stop.fill" : "play.fill")
                        .frame(width: 32, height: 32)
                        .foregroundStyle(theme.palette.surface)
                        .background(theme.palette.accent)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 2) {
                    Text(durationString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.palette.text)
                    progressBar
                }
                Spacer()
            }
            if !attachment.transcript.isEmpty {
                Text(attachment.transcript)
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.text)
                    .lineSpacing(4)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.palette.accent.opacity(0.05))
            }
        }
        .padding(12)
        .background(theme.palette.surface)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(theme.palette.text.opacity(0.1))
                    .frame(height: 2)
                Rectangle()
                    .fill(theme.palette.accent)
                    .frame(width: geo.size.width * playback.progress, height: 2)
            }
        }
        .frame(height: 2)
    }

    private var durationString: String {
        let total = Int(attachment.durationSec)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
