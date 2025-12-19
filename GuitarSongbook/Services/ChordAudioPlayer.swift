//
//  ChordAudioPlayer.swift
//  GuitarSongbook
//
//  Plays guitar chord sounds using real guitar string samples
//

import AVFoundation
import Foundation

class ChordAudioPlayer {
    static let shared = ChordAudioPlayer()

    private let audioEngine = AVAudioEngine()
    private var audioPlayers: [AVAudioPlayer] = []

    // Guitar string names for file loading: E, A, D, G, B, e
    private let stringNames = ["E2", "A2", "D3", "G3", "B3", "E4"]

    private init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // Play a chord given finger positions
    func playChord(fingers: [Int]) {
        guard fingers.count == 6 else { return }

        // Stop any currently playing sounds
        stopAllPlayers()

        // Debug: Print what we're playing
        print("🎸 Playing chord with fingers: \(fingers)")

        // TEST: Just play the first non-muted string to test pitch shifting
        // Comment this out after testing
        if let firstString = fingers.enumerated().first(where: { $0.element >= 0 }) {
            print("⚠️ TEST MODE: Only playing string \(firstString.offset) at fret \(firstString.element)")
            playString(stringIndex: firstString.offset, fret: firstString.element)
            return
        }

        // Play each string with a slight stagger (strum effect)
        // This makes chords sound more realistic and distinct
        var delay: TimeInterval = 0.0
        let strumDelay: TimeInterval = 0.04 // 40ms between strings

        for (stringIndex, fret) in fingers.enumerated() {
            if fret >= 0 { // -1 means don't play this string
                print("  String \(stringIndex) (\(stringNames[stringIndex])): fret \(fret)")

                // Schedule string to play after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.playString(stringIndex: stringIndex, fret: fret)
                }

                delay += strumDelay
            }
        }
    }

    private func playString(stringIndex: Int, fret: Int) {
        guard stringIndex >= 0 && stringIndex < stringNames.count else { return }

        let stringName = stringNames[stringIndex]

        // Look for the audio file in the bundle
        // Expected filename format: "guitar_E2.wav", "guitar_A2.wav", etc.
        guard let url = Bundle.main.url(forResource: "guitar_\(stringName)", withExtension: "wav") ??
                        Bundle.main.url(forResource: "guitar_\(stringName)", withExtension: "mp3") ??
                        Bundle.main.url(forResource: stringName, withExtension: "wav") ??
                        Bundle.main.url(forResource: stringName, withExtension: "mp3") else {
            print("Could not find audio file for string \(stringName)")
            // Fallback to synthesized sound if sample not found
            playSynthesizedString(stringIndex: stringIndex, fret: fret)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)

            // IMPORTANT: Must enable rate BEFORE setting it!
            player.enableRate = true
            player.prepareToPlay()

            // Apply pitch shifting based on fret
            // Each fret is one semitone, so we adjust the playback rate
            // Rate = 2^(semitones/12)
            if fret > 0 {
                let semitones = Double(fret)
                let rate = Float(pow(2.0, semitones / 12.0))

                // Clamp rate to AVAudioPlayer's allowed range (0.5 to 2.0)
                let clampedRate = min(max(rate, 0.5), 2.0)
                player.rate = clampedRate

                print("    → Using rate: \(clampedRate) for \(semitones) semitones")
            } else {
                player.rate = 1.0
                print("    → Open string (rate: 1.0, no pitch shift)")
            }

            player.volume = 0.7
            player.play()

            // Store player to prevent deallocation
            audioPlayers.append(player)

            print("    ✓ Playing sample from: \(url.lastPathComponent)")

        } catch {
            print("    ✗ Failed to play audio file: \(error)")
            // Fallback to synthesized sound
            playSynthesizedString(stringIndex: stringIndex, fret: fret)
        }
    }

    // Fallback synthesized sound (simplified version of old implementation)
    private func playSynthesizedString(stringIndex: Int, fret: Int) {
        // Standard guitar tuning frequencies (Hz) for open strings: E A D G B e
        let openStringFrequencies: [Double] = [
            82.41,  // E2
            110.00, // A2
            146.83, // D3
            196.00, // G3
            246.94, // B3
            329.63  // E4
        ]

        guard stringIndex >= 0 && stringIndex < openStringFrequencies.count else { return }

        let openFrequency = openStringFrequencies[stringIndex]
        let frequency = openFrequency * pow(2.0, Double(fret) / 12.0)

        // Simple beep fallback (user should add audio files for real sound)
        print("⚠️ Using synthesized fallback for string \(stringIndex) fret \(fret) - Add audio samples for better sound!")

        // Generate a short beep
        playToneBeep(frequency: frequency, duration: 1.5)
    }

    private func playToneBeep(frequency: Double, duration: TimeInterval) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        let mixer = audioEngine.mainMixerNode
        let mixerFormat = mixer.outputFormat(forBus: 0)
        audioEngine.connect(player, to: mixer, format: mixerFormat)

        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("Failed to start audio engine: \(error)")
                return
            }
        }

        let sampleRate = mixerFormat.sampleRate
        let channelCount = mixerFormat.channelCount
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: mixerFormat, frameCapacity: frameCount) else {
            return
        }

        buffer.frameLength = frameCount

        let amplitude: Float = 0.1
        let angularFrequency = Float(2.0 * Double.pi * frequency / sampleRate)

        for channel in 0..<Int(channelCount) {
            guard let samples = buffer.floatChannelData?[channel] else { continue }

            for frame in 0..<Int(frameCount) {
                // Quick decay envelope
                let envelope = Float(1.0 - (Double(frame) / Double(frameCount)))
                samples[frame] = sin(angularFrequency * Float(frame)) * amplitude * envelope
            }
        }

        player.scheduleBuffer(buffer, completionHandler: nil)
        player.play()
    }

    private func stopAllPlayers() {
        // Stop AVAudioPlayers
        for player in audioPlayers {
            player.stop()
        }
        audioPlayers.removeAll()
    }

    func stop() {
        stopAllPlayers()
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
}
