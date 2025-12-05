//
//  AudioPitchDetector.swift
//  GuitarSongbook
//
//  Real-time pitch detection for guitar tuner
//

import AVFoundation
import Accelerate

class AudioPitchDetector: ObservableObject {
    @Published var currentFrequency: Float = 0
    @Published var currentNote: String = "-"
    @Published var currentOctave: Int = 0
    @Published var centsOff: Float = 0 // -50 to +50, 0 = perfectly in tune
    @Published var isListening: Bool = false
    @Published var hasPermission: Bool = false
    @Published var targetNote: GuitarString? = nil
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let sampleRate: Float = 44100
    private let bufferSize: AVAudioFrameCount = 4096
    
    // Standard guitar tuning frequencies
    static let guitarStrings: [GuitarString] = [
        GuitarString(name: "E", octave: 4, frequency: 329.63, stringNumber: 1),
        GuitarString(name: "B", octave: 3, frequency: 246.94, stringNumber: 2),
        GuitarString(name: "G", octave: 3, frequency: 196.00, stringNumber: 3),
        GuitarString(name: "D", octave: 3, frequency: 146.83, stringNumber: 4),
        GuitarString(name: "A", octave: 2, frequency: 110.00, stringNumber: 5),
        GuitarString(name: "E", octave: 2, frequency: 82.41, stringNumber: 6),
    ]
    
    // All note frequencies for detection
    private let noteFrequencies: [(note: String, frequency: Float)] = {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        var frequencies: [(String, Float)] = []
        
        // Generate frequencies from C1 to C7
        for octave in 1...6 {
            for (index, note) in noteNames.enumerated() {
                let noteNumber = (octave + 1) * 12 + index
                let frequency = 440.0 * pow(2.0, Float(noteNumber - 69) / 12.0)
                frequencies.append((note, frequency))
            }
        }
        return frequencies
    }()
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            hasPermission = true
        case .denied:
            hasPermission = false
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasPermission = granted
                }
            }
        @unknown default:
            hasPermission = false
        }
    }
    
    func startListening() {
        guard hasPermission else {
            checkPermission()
            return
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            
            audioEngine = AVAudioEngine()
            guard let audioEngine = audioEngine else { return }
            
            inputNode = audioEngine.inputNode
            guard let inputNode = inputNode else { return }
            
            let format = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
                self?.processAudioBuffer(buffer)
            }
            
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isListening = true
            }
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func stopListening() {
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        
        DispatchQueue.main.async {
            self.isListening = false
            self.currentFrequency = 0
            self.currentNote = "-"
            self.centsOff = 0
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        // Check if there's enough signal
        var rms: Float = 0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameLength))
        
        // Threshold to ignore silence/noise
        guard rms > 0.01 else {
            DispatchQueue.main.async {
                self.currentFrequency = 0
                self.currentNote = "-"
                self.centsOff = 0
            }
            return
        }
        
        // Detect pitch using autocorrelation
        let frequency = detectPitch(data: channelData, count: frameLength)
        
        guard frequency > 50 && frequency < 1000 else { return } // Guitar range
        
        // Find closest note
        let (note, octave, cents) = findClosestNote(frequency: frequency)
        
        DispatchQueue.main.async {
            self.currentFrequency = frequency
            self.currentNote = note
            self.currentOctave = octave
            self.centsOff = cents
            
            // Auto-detect which string is being played
            self.targetNote = Self.guitarStrings.min(by: { string1, string2 in
                abs(string1.frequency - frequency) < abs(string2.frequency - frequency)
            })
        }
    }
    
    private func detectPitch(data: UnsafeMutablePointer<Float>, count: Int) -> Float {
        // Autocorrelation-based pitch detection
        let minPeriod = Int(sampleRate / 500) // Max frequency 500 Hz
        let maxPeriod = Int(sampleRate / 60)  // Min frequency 60 Hz
        
        var maxCorrelation: Float = 0
        var bestPeriod = 0
        
        for period in minPeriod..<min(maxPeriod, count / 2) {
            var correlation: Float = 0
            
            for i in 0..<(count - period) {
                correlation += data[i] * data[i + period]
            }
            
            if correlation > maxCorrelation {
                maxCorrelation = correlation
                bestPeriod = period
            }
        }
        
        guard bestPeriod > 0 else { return 0 }
        
        return sampleRate / Float(bestPeriod)
    }
    
    private func findClosestNote(frequency: Float) -> (note: String, octave: Int, cents: Float) {
        // Calculate note number from frequency
        let noteNumber = 12 * log2(frequency / 440) + 69
        let roundedNote = round(noteNumber)
        
        // Calculate cents off
        let cents = (noteNumber - roundedNote) * 100
        
        // Get note name and octave
        let noteIndex = Int(roundedNote) % 12
        let octave = Int(roundedNote) / 12 - 1
        
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let note = noteNames[noteIndex < 0 ? noteIndex + 12 : noteIndex]
        
        return (note, octave, Float(cents))
    }
    
    func selectString(_ string: GuitarString) {
        targetNote = string
    }
}

// MARK: - Guitar String Model

struct GuitarString: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let octave: Int
    let frequency: Float
    let stringNumber: Int
    
    var displayName: String {
        "\(name)\(octave)"
    }
    
    static func == (lhs: GuitarString, rhs: GuitarString) -> Bool {
        lhs.stringNumber == rhs.stringNumber
    }
}

