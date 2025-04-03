//
//  SettingsView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameSettings: GameSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var gameTime: String
    @State private var maxBubbles: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        self._gameTime = State(initialValue: "\(gameSettings.gameTime)")
        self._maxBubbles = State(initialValue: "\(gameSettings.maxBubbles)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Settings")) {
                    HStack {
                        Text("Game Time (seconds)")
                        Spacer()
                        TextField("10-120", text: $gameTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Maximum Bubbles")
                        Spacer()
                        TextField("5-30", text: $maxBubbles)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section(header: Text("Sound")) {
                    Toggle("Sound Effects", isOn: $gameSettings.soundEnabled)
                    Toggle("Background Music", isOn: $gameSettings.musicEnabled)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
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
    }
    
    func saveSettings() {
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
        presentationMode.wrappedValue.dismiss()
    }
    
    func resetToDefaults() {
        gameSettings.resetToDefaults()
        gameTime = "\(gameSettings.gameTime)"
        maxBubbles = "\(gameSettings.maxBubbles)"
    }
}
