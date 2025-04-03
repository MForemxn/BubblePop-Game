//
//  BubblePop_GameApp.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

@main
struct BubblePop_GameApp: App {
    @StateObject private var gameSettings = GameSettings()
    @StateObject private var gameState = GameState()
    @StateObject private var gameManager: GameManager
    
    init() {
        let settings = GameSettings()
        let state = GameState()
        state.gameSettings = settings
        
        // Use StateObject wrapper for initialization
        let manager = GameManager(gameState: state, gameSettings: settings)
        _gameSettings = StateObject(wrappedValue: settings)
        _gameState = StateObject(wrappedValue: state)
        _gameManager = StateObject(wrappedValue: manager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameSettings)
                .environmentObject(gameState)
                .environmentObject(gameManager)
        }
    }
}
