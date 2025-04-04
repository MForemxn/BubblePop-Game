//
//  GameSettings.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI

class GameSettings: ObservableObject {
    // MARK: - Published Properties
    @Published var gameTime: Int {
        didSet {
            saveSettings()
        }
    }
    @Published var maxBubbles: Int {
        didSet {
            saveSettings()
        }
    }
    @Published var soundEnabled: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var musicEnabled: Bool {
        didSet {
            saveSettings()
        }
    }
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

    // MARK: - Initialization
    init() {
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
        UserDefaults.standard.synchronize()
    }

    func resetToDefaults() {
        gameTime = defaultGameTime
        maxBubbles = defaultMaxBubbles
        soundEnabled = defaultSoundEnabled
        musicEnabled = defaultMusicEnabled
        bubbleSpeed = defaultBubbleSpeed
        saveSettings()
    }
}
