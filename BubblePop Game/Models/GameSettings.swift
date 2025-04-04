//
//  GameSettings.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI

class GameSettings: ObservableObject {
    // Published properties
    @Published var bubbleSpeed: BubbleSpeed {
        didSet {
            saveSettings()
        }
    }
    
    // MARK: - Bubble Speed Enum
    enum BubbleSpeed: String, CaseIterable {
        case slow
        case medium
        case fast
    }
    
    // MARK: - Default Values
    private let defaultGameTime = 60
    private let defaultMaxBubbles = 15
    private let defaultSoundEnabled = true
    private let defaultMusicEnabled = true
    private let defaultBubbleSpeed: BubbleSpeed = .medium
    
    // MARK: - UserDefaults Keys
    private let gameTimeKey = "GameTime"
    private let maxBubblesKey = "MaxBubbles"
    private let soundEnabledKey = "SoundEnabled"
    private let musicEnabledKey = "MusicEnabled"
    private let bubbleSpeedKey = "BubbleSpeed"
    
    // Properties with initialization issues
    @Published var gameTime: Int
    @Published var maxBubbles: Int
    private var soundEnabled: Bool
    private var musicEnabled: Bool
    
    // MARK: - Initialization
    init() {
        // Initialize with placeholder values
        self.gameTime = 0
        self.maxBubbles = 0
        self.soundEnabled = false
        self.musicEnabled = false
        self.bubbleSpeed = .medium
        
        // Now load from UserDefaults after initialization
        self.loadSettings()
    }
    
    private func loadSettings() {
        // Load saved settings or use defaults
        self.gameTime = UserDefaults.standard.integer(forKey: gameTimeKey)
        if self.gameTime == 0 {
            self.gameTime = defaultGameTime
        }
        
        self.maxBubbles = UserDefaults.standard.integer(forKey: maxBubblesKey)
        if self.maxBubbles == 0 {
            self.maxBubbles = defaultMaxBubbles
        }
        
        self.soundEnabled = UserDefaults.standard.object(forKey: soundEnabledKey) as? Bool ?? defaultSoundEnabled
        self.musicEnabled = UserDefaults.standard.object(forKey: musicEnabledKey) as? Bool ?? defaultMusicEnabled
        
        if let savedSpeed = UserDefaults.standard.string(forKey: bubbleSpeedKey),
           let speed = BubbleSpeed(rawValue: savedSpeed) {
            self.bubbleSpeed = speed
        } else {
            self.bubbleSpeed = defaultBubbleSpeed
        }
    }
    
    // MARK: - Methods
    func saveSettings() {
        UserDefaults.standard.set(gameTime, forKey: gameTimeKey)
        UserDefaults.standard.set(maxBubbles, forKey: maxBubblesKey)
        UserDefaults.standard.set(soundEnabled, forKey: soundEnabledKey)
        UserDefaults.standard.set(musicEnabled, forKey: musicEnabledKey)
        UserDefaults.standard.set(bubbleSpeed.rawValue, forKey: bubbleSpeedKey)
    }
    
    // Add getters and setters for your properties
    var gameTimeValue: Int {
        get { return gameTime }
        set {
            gameTime = newValue
            saveSettings()
        }
    }
    
    var maxBubblesValue: Int {
        get { return maxBubbles }
        set {
            maxBubbles = newValue
            saveSettings()
        }
    }
    
    var isSoundEnabled: Bool {
        get { return soundEnabled }
        set {
            soundEnabled = newValue
            saveSettings()
        }
    }
    
    var isMusicEnabled: Bool {
        get { return musicEnabled }
        set {
            musicEnabled = newValue
            saveSettings()
        }
    }
}
