//
//  SettingsView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

/// View for adjusting game settings and preferences
struct SettingsView: View {
    // MARK: - Properties
    
    /// Settings object to modify
    @ObservedObject var gameSettings: GameSettings
    
    /// Callback for when the back button is pressed
    let onBack: () -> Void
    
    /// Callback for when settings are changed
    let onSettingsChanged: () -> Void
    
    /// Current game time in string form (for text field)
    @State private var gameTime: String
    
    /// Current max bubbles in string form (for text field)
    @State private var maxBubbles: String
    
    /// Controls whether to show validation alert
    @State private var showAlert = false
    
    /// Message to display in the validation alert
    @State private var alertMessage = ""
    
    // MARK: - Initialization
    
    /// Initialize the settings view with game settings and callbacks
    init(gameSettings: GameSettings, onBack: @escaping () -> Void, onSettingsChanged: @escaping () -> Void = {}) {
        self.gameSettings = gameSettings
        self.onBack = onBack
        self.onSettingsChanged = onSettingsChanged
        self._gameTime = State(initialValue: "\(gameSettings.gameTime)")
        self._maxBubbles = State(initialValue: "\(gameSettings.maxBubbles)")
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // Game duration and bubble count settings
            Section(header: Text("Game Settings")) {
                // Game duration setting
                HStack {
                    Text("Game Time (seconds)")
                    Spacer()
                    TextField("10-120", text: $gameTime)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: gameTime) { oldValue, newValue in
                            validateAndSave()
                        }
                }
                
                // Maximum bubble count setting
                HStack {
                    Text("Maximum Bubbles")
                    Spacer()
                    TextField("5-30", text: $maxBubbles)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: maxBubbles) { oldValue, newValue in
                            validateAndSave()
                        }
                }
            }
            
            // Sound settings
            Section(header: Text("Sound")) {
                // Sound effects toggle
                Toggle("Sound Effects", isOn: $gameSettings.soundEnabled)
                    .onChange(of: gameSettings.soundEnabled) { oldValue, newValue in
                        gameSettings.saveSettings()
                        onSettingsChanged()
                    }
                
                // Music toggle
                Toggle("Background Music", isOn: $gameSettings.musicEnabled)
                    .onChange(of: gameSettings.musicEnabled) { oldValue, newValue in
                        gameSettings.saveSettings()
                        onSettingsChanged()
                    }
            }
            
            // Bubble speed setting
            Section(header: Text("Bubble Appearance")) {
                HStack {
                    Text("Bubble Speed")
                    Spacer()
                    Picker("Bubble Speed", selection: $gameSettings.bubbleSpeed) {
                        Text("Slow").tag(GameSettings.BubbleSpeed.slow)
                        Text("Medium").tag(GameSettings.BubbleSpeed.medium)
                        Text("Fast").tag(GameSettings.BubbleSpeed.fast)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 180)
                    .onChange(of: gameSettings.bubbleSpeed) { oldValue, newValue in
                        gameSettings.saveSettings()
                        onSettingsChanged()
                    }
                }
            }
            
            // Reset settings section
            Section {
                Button("Reset to Default Settings") {
                    resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Settings"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Methods
    
    /// Validate input values and save if valid
    func validateAndSave() {
        // Validate game time
        guard let gameTimeInt = Int(gameTime), gameTimeInt >= 10 && gameTimeInt <= 120 else {
            alertMessage = "Game time must be between 10 and 120 seconds."
            showAlert = true
            return
        }
        
        // Validate maximum bubbles
        guard let maxBubblesInt = Int(maxBubbles), maxBubblesInt >= 5 && maxBubblesInt <= 30 else {
            alertMessage = "Maximum bubbles must be between 5 and 30."
            showAlert = true
            return
        }
        
        // Save valid settings
        gameSettings.gameTime = gameTimeInt
        gameSettings.maxBubbles = maxBubblesInt
        gameSettings.saveSettings()
        onSettingsChanged()
    }
    
    /// Reset all settings to default values
    func resetToDefaults() {
        gameSettings.resetToDefaults()
        gameTime = "\(gameSettings.gameTime)"
        maxBubbles = "\(gameSettings.maxBubbles)"
        gameSettings.saveSettings()
        onSettingsChanged()
    }
}

#Preview {
    let settings = GameSettings()
    return SettingsView(gameSettings: settings, onBack: {})
}
