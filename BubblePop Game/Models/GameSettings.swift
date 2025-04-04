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
        // Load values from UserDefaults into temporary variables
        let savedGameTime = UserDefaults.standard.integer(forKey: gameTimeKey)
        let savedMaxBubbles = UserDefaults.standard.integer(forKey: maxBubblesKey)
        let savedSoundEnabled = UserDefaults.standard.object(forKey: soundEnabledKey) as? Bool ?? defaultSoundEnabled
        let savedMusicEnabled = UserDefaults.standard.object(forKey: musicEnabledKey) as? Bool ?? defaultMusicEnabled
        let savedBubbleSpeedRaw = UserDefaults.standard.string(forKey: bubbleSpeedKey)
        let savedBubbleSpeed = savedBubbleSpeedRaw.flatMap { BubbleSpeed(rawValue: $0) } ?? defaultBubbleSpeed

        // Initialize all properties
        self.gameTime = savedGameTime == 0 ? defaultGameTime : savedGameTime
        self.maxBubbles = savedMaxBubbles == 0 ? defaultMaxBubbles : savedMaxBubbles
        self.soundEnabled = savedSoundEnabled
        self.musicEnabled = savedMusicEnabled
        self.bubbleSpeed = savedBubbleSpeed
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
