//
//  GameSettings.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 4/4/2025.
//

import Foundation

class GameSettings: ObservableObject {
    static let shared = GameSettings()
    
    @Published var gameTime: Int {
        didSet {
            UserDefaults.standard.set(gameTime, forKey: "gameTime")
        }
    }
    
    @Published var maxBubbles: Int {
        didSet {
            UserDefaults.standard.set(maxBubbles, forKey: "maxBubbles")
        }
    }
    
    init() {
        // Use temporary variables to initialize properties first
        let savedGameTime = UserDefaults.standard.integer(forKey: "gameTime")
        let initialGameTime = savedGameTime == 0 ? 60 : savedGameTime
        UserDefaults.standard.set(initialGameTime, forKey: "gameTime")
        
        let savedMaxBubbles = UserDefaults.standard.integer(forKey: "maxBubbles")
        let initialMaxBubbles = savedMaxBubbles == 0 ? 15 : savedMaxBubbles
        UserDefaults.standard.set(initialMaxBubbles, forKey: "maxBubbles")
        
        // Now assign to properties
        self.gameTime = initialGameTime
        self.maxBubbles = initialMaxBubbles
    }
    
    func resetToDefault() {
        gameTime = 60
        maxBubbles = 15
    }
}
