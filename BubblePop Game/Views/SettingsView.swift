//
//  SettingsView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameSettings: GameSettings
    let onBack: () -> Void  // Closure to handle navigation
    let onSettingsChanged: () -> Void  // Closure to update game state when settings change
    
    @State private var gameTime: String
    @State private var maxBubbles: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(gameSettings: GameSettings, onBack: @escaping () -> Void, onSettingsChanged: @escaping () -> Void = {}) {
        self.gameSettings = gameSettings
        self.onBack = onBack
        self.onSettingsChanged = onSettingsChanged
        self._gameTime = State(initialValue: "\(gameSettings.gameTime)")
        self._maxBubbles = State(initialValue: "\(gameSettings.maxBubbles)")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Game Settings")) {
                HStack {
                    Text("Game Time (seconds)")
                    Spacer()
                    TextField("10-120", text: $gameTime)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: gameTime) { _ in
                            validateAndSave()
                        }
                }
                
                HStack {
                    Text("Maximum Bubbles")
                    Spacer()
                    TextField("5-30", text: $maxBubbles)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: maxBubbles) { _ in
                            validateAndSave()
                        }
                }
            }
            
            Section(header: Text("Sound")) {
                Toggle("Sound Effects", isOn: $gameSettings.soundEnabled)
                    .onChange(of: gameSettings.soundEnabled) { _ in
                        gameSettings.saveSettings()
                        onSettingsChanged()
                    }
                Toggle("Background Music", isOn: $gameSettings.musicEnabled)
                    .onChange(of: gameSettings.musicEnabled) { _ in
                        gameSettings.saveSettings()
                        onSettingsChanged()
                    }
            }
            
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
                    .onChange(of: gameSettings.bubbleSpeed) { newValue in
                        gameSettings.saveSettings()
                        onSettingsChanged()
                    }
                }
            }
            
            Section {
                Button("Reset to Default Settings") {
                    resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    onBack()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Settings"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func validateAndSave() {
        guard let gameTimeInt = Int(gameTime), gameTimeInt >= 10 && gameTimeInt <= 120 else {
            alertMessage = "Game time must be between 10 and 120 seconds."
            showAlert = true
            return
        }
        
        guard let maxBubblesInt = Int(maxBubbles), maxBubblesInt >= 5 && maxBubblesInt <= 30 else {
            alertMessage = "Maximum bubbles must be between 5 and 30."
            showAlert = true
            return
        }
        
        gameSettings.gameTime = gameTimeInt
        gameSettings.maxBubbles = maxBubblesInt
        gameSettings.saveSettings()
        onSettingsChanged()
    }
    
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


// test comment
