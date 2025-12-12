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
    private var actualSampleRate: Float = 44100 // Will be set from actual audio format
    private let bufferSize: AVAudioFrameCount = 8192 // Increased for better frequency resolution
    private var frequencyHistory: [Float] = [] // For smoothing
    private let historySize = 5
    
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
            try session.setCategory(.record, mode: .measurement, options: [.allowBluetoothHFP])
            try session.setPreferredSampleRate(44100)
            try session.setPreferredIOBufferDuration(0.01) // Lower latency
            try session.setActive(true)
            
            audioEngine = AVAudioEngine()
            guard let audioEngine = audioEngine else { return }
            
            inputNode = audioEngine.inputNode
            guard let inputNode = inputNode else { return }
            
            let format = inputNode.outputFormat(forBus: 0)
            actualSampleRate = Float(format.sampleRate) // Use actual device sample rate
            
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
            self.frequencyHistory = []
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        // Apply windowing to reduce spectral leakage
        var windowedData = [Float](repeating: 0, count: frameLength)
        vDSP_hann_window(&windowedData, vDSP_Length(frameLength), Int32(vDSP_HANN_NORM))
        
        var processedData = [Float](repeating: 0, count: frameLength)
        vDSP_vmul(channelData, 1, windowedData, 1, &processedData, 1, vDSP_Length(frameLength))
        
        // Check if there's enough signal (lowered threshold for sensitivity)
        var rms: Float = 0
        vDSP_rmsqv(processedData, 1, &rms, vDSP_Length(frameLength))
        
        // Lower threshold to pick up quieter strings
        guard rms > 0.003 else {
            DispatchQueue.main.async {
                if self.currentFrequency > 0 {
                    // Don't immediately clear, allow some persistence
                    self.frequencyHistory = []
                } else {
                    self.currentFrequency = 0
                    self.currentNote = "-"
                    self.centsOff = 0
                }
            }
            return
        }
        
        // Detect pitch using improved autocorrelation
        let rawFrequency = detectPitchImproved(data: processedData, count: frameLength)
        
        guard rawFrequency > 50 && rawFrequency < 1000 else {
            DispatchQueue.main.async {
                self.frequencyHistory = []
            }
            return
        }
        
        // Add to history for smoothing
        frequencyHistory.append(rawFrequency)
        if frequencyHistory.count > historySize {
            frequencyHistory.removeFirst()
        }
        
        // Calculate smoothed frequency (median filter)
        let sortedFreqs = frequencyHistory.sorted()
        let smoothedFrequency: Float
        if sortedFreqs.count > 0 {
            let mid = sortedFreqs.count / 2
            smoothedFrequency = sortedFreqs.count % 2 == 0
                ? (sortedFreqs[mid - 1] + sortedFreqs[mid]) / 2
                : sortedFreqs[mid]
        } else {
            smoothedFrequency = rawFrequency
        }
        
        // Find closest note
        let (note, octave, cents) = findClosestNote(frequency: smoothedFrequency)
        
        DispatchQueue.main.async {
            self.currentFrequency = smoothedFrequency
            self.currentNote = note
            self.currentOctave = octave
            self.centsOff = cents
            
            // Auto-detect which string is being played
            self.targetNote = Self.guitarStrings.min(by: { string1, string2 in
                abs(string1.frequency - smoothedFrequency) < abs(string2.frequency - smoothedFrequency)
            })
        }
    }
    
    private func detectPitchImproved(data: [Float], count: Int) -> Float {
        // Improved autocorrelation with normalization (YIN-like approach)
        let minPeriod = Int(actualSampleRate / 1000.0) // Max frequency ~1000 Hz
        let maxPeriod = Int(actualSampleRate / 60.0)   // Min frequency ~60 Hz
        
        guard maxPeriod < count / 2 else { return 0 }
        
        var maxCorrelation: Float = -Float.infinity
        var bestPeriod = minPeriod
        
        // Calculate autocorrelation for each possible period
        for period in minPeriod..<maxPeriod {
            var correlation: Float = 0
            var normalization: Float = 0
            
            // Calculate normalized autocorrelation
            for i in 0..<(count - period) {
                correlation += data[i] * data[i + period]
                normalization += data[i] * data[i]
            }
            
            // Normalize by the energy to avoid bias toward longer periods
            if normalization > 0 {
                let normalizedCorrelation = correlation / sqrt(normalization)
                
                if normalizedCorrelation > maxCorrelation {
                    maxCorrelation = normalizedCorrelation
                    bestPeriod = period
                }
            }
        }
        
        // Require a minimum correlation threshold (lowered for better sensitivity)
        guard maxCorrelation > 0.15 else { return 0 }
        
        // Refine the period estimate using parabolic interpolation
        if bestPeriod > minPeriod && bestPeriod < maxPeriod - 1 {
            let prevPeriod = bestPeriod - 1
            let nextPeriod = bestPeriod + 1
            
            var prevCorr: Float = 0
            var nextCorr: Float = 0
            var prevNorm: Float = 0
            var nextNorm: Float = 0
            
            for i in 0..<(count - prevPeriod) {
                prevCorr += data[i] * data[i + prevPeriod]
                prevNorm += data[i] * data[i]
            }
            for i in 0..<(count - nextPeriod) {
                nextCorr += data[i] * data[i + nextPeriod]
                nextNorm += data[i] * data[i]
            }
            
            let prevNormCorr = prevNorm > 0 ? prevCorr / sqrt(prevNorm) : 0
            let nextNormCorr = nextNorm > 0 ? nextCorr / sqrt(nextNorm) : 0
            
            // Parabolic interpolation for sub-sample accuracy
            let denom = 2 * (2 * maxCorrelation - prevNormCorr - nextNormCorr)
            if abs(denom) > 0.001 {
                let offset = (nextNormCorr - prevNormCorr) / denom
                let refinedPeriod = Float(bestPeriod) + offset
                return actualSampleRate / refinedPeriod
            }
        }
        
        return actualSampleRate / Float(bestPeriod)
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

