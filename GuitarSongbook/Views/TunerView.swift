//
//  TunerView.swift
//  GuitarSongbook
//
//  Guitar tuner with real-time pitch detection
//

import SwiftUI

struct TunerView: View {
    @StateObject private var pitchDetector = AudioPitchDetector()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background - warm tone
                Color.warmBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if !pitchDetector.hasPermission {
                        permissionView
                    } else {
                        // Main tuner content
                        VStack(spacing: 16) {
                            Spacer()

                            // Current note display
                            noteDisplay

                            // Tuning indicator
                            tuningIndicator

                            // Frequency display
                            frequencyDisplay

                            Spacer()

                            // Tuning selector
                            tuningSelector

                            // String selector
                            stringSelector

                            // Start/Stop button
                            tunerButton
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Tuner")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear {
            pitchDetector.stopListening()
        }
    }
    
    // MARK: - Permission View
    
    private var permissionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "mic.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.appAccent)
            }
            
            Text("Microphone Access Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("The tuner needs access to your microphone to detect the pitch of your guitar strings.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            } label: {
                Text("Open Settings")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.appAccent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Note Display
    
    private var noteDisplay: some View {
        VStack(spacing: 8) {
            // Current detected note
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(pitchDetector.currentNote)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundColor(noteColor)

                if pitchDetector.currentNote != "-" {
                    Text("\(pitchDetector.currentOctave)")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .offset(y: -20)
                }
            }
            .frame(height: 120)

            // In tune indicator
            if pitchDetector.isListening && pitchDetector.currentNote != "-" {
                Text(tuningStatus)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(noteColor)
                    .animation(.easeInOut(duration: 0.2), value: tuningStatus)
            }
        }
    }
    
    // MARK: - Tuning Indicator
    
    private var tuningIndicator: some View {
        VStack(spacing: 16) {
            // Gauge
            GeometryReader { geometry in
                let width = geometry.size.width
                let center = width / 2
                let needleOffset = CGFloat(pitchDetector.centsOff / 50) * (width / 2 - 20)
                
                ZStack {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 16)
                    
                    // Color zones
                    HStack(spacing: 0) {
                        // Flat zone (red)
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                        
                        // Slightly flat (yellow)
                        Rectangle()
                            .fill(Color.orange.opacity(0.3))
                        
                        // In tune zone (green)
                        Rectangle()
                            .fill(Color.green.opacity(0.5))
                            .frame(width: 40)
                        
                        // Slightly sharp (yellow)
                        Rectangle()
                            .fill(Color.orange.opacity(0.3))
                        
                        // Sharp zone (red)
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                    }
                    .frame(height: 16)
                    .cornerRadius(8)
                    
                    // Center line
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 3, height: 24)
                        .position(x: center, y: 8)
                    
                    // Needle
                    if pitchDetector.isListening && pitchDetector.currentNote != "-" {
                        Circle()
                            .fill(noteColor)
                            .frame(width: 24, height: 24)
                            .shadow(color: noteColor.opacity(0.5), radius: 4)
                            .position(x: center + needleOffset, y: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: needleOffset)
                    }
                }
            }
            .frame(height: 24)
            .padding(.horizontal, 20)
            
            // Labels
            HStack {
                Text("♭ Flat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("In Tune")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("Sharp ♯")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Frequency Display
    
    private var frequencyDisplay: some View {
        VStack(spacing: 4) {
            if pitchDetector.isListening && pitchDetector.currentFrequency > 0 {
                Text(String(format: "%.1f Hz", pitchDetector.currentFrequency))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                
                if let target = pitchDetector.targetNote {
                    Text("Target: \(String(format: "%.1f Hz", target.frequency))")
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            } else if pitchDetector.isListening {
                Text("Play a string...")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 50)
    }
    
    // MARK: - Tuning Selector

    private var tuningSelector: some View {
        VStack(spacing: 12) {
            Text("TUNING")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Picker("Tuning", selection: $pitchDetector.selectedTuning) {
                Text("Standard").tag("Standard")
                Text("Drop D").tag("Drop D")
                Text("Drop C").tag("Drop C")
                Text("Half Step Down").tag("Half Step Down")
                Text("Open D").tag("Open D")
                Text("Open G").tag("Open G")
            }
            .pickerStyle(.menu)
            .padding(12)
            .warmCard()
        }
    }

    // MARK: - String Selector

    private var stringSelector: some View {
        VStack(spacing: 12) {
            Text("SELECT STRING")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(pitchDetector.guitarStrings) { string in
                    Button {
                        pitchDetector.selectString(string)
                    } label: {
                        VStack(spacing: 4) {
                            Text(string.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(string.stringNumber)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 48, height: 56)
                        .background(
                            pitchDetector.targetNote == string
                                ? Color.appAccent
                                : Color(.systemGray5)
                        )
                        .foregroundColor(
                            pitchDetector.targetNote == string
                                ? .white
                                : .primary
                        )
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .warmCard()
    }
    
    // MARK: - Tuner Button
    
    private var tunerButton: some View {
        Button {
            if pitchDetector.isListening {
                pitchDetector.stopListening()
            } else {
                pitchDetector.startListening()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: pitchDetector.isListening ? "stop.fill" : "mic.fill")
                    .font(.title3)
                
                Text(pitchDetector.isListening ? "Stop Tuner" : "Start Tuner")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(pitchDetector.isListening ? Color.red : Color.appAccent)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Helpers
    
    private var noteColor: Color {
        guard pitchDetector.currentNote != "-" else { return .secondary }
        
        let cents = abs(pitchDetector.centsOff)
        if cents < 5 {
            return .green
        } else if cents < 15 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var tuningStatus: String {
        let cents = pitchDetector.centsOff
        
        if abs(cents) < 5 {
            return "In Tune! ✓"
        } else if cents < -15 {
            return "Too Flat ↓"
        } else if cents < 0 {
            return "Slightly Flat"
        } else if cents > 15 {
            return "Too Sharp ↑"
        } else {
            return "Slightly Sharp"
        }
    }
}

#Preview {
    TunerView()
}

