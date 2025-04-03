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
        self.gameTime = UserDefaults.standard.integer(forKey: "gameTime")
        if self.gameTime == 0 {
            self.gameTime = 60 // Default value
            UserDefaults.standard.set(gameTime, forKey: "gameTime")
        }
        
        self.maxBubbles = UserDefaults.standard.integer(forKey: "maxBubbles")
        if self.maxBubbles == 0 {
            self.maxBubbles = 15 // Default value
            UserDefaults.standard.set(maxBubbles, forKey: "maxBubbles")
        }
    }
    
    func resetToDefault() {
        gameTime = 60
        maxBubbles = 15
    }
}
