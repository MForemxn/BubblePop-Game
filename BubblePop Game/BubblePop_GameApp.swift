//
//  BubblePop_GameApp.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

@main
struct BubblePop_GameApp: App {
    @StateObject private var gameSettings: GameSettings
    @StateObject private var gameManager: GameManager
    
    init() {
        let settings = GameSettings()
        _gameSettings = StateObject(wrappedValue: settings)
        _gameManager = StateObject(wrappedValue: GameManager(gameSettings: settings))
    }
    
    var body: some Scene {
        WindowGroup {
            switch gameManager.currentView {
            case .nameEntry:
                NameEntryView(
                    gameManager: gameManager,
                    playerName: $gameManager.gameState.playerName,
                    onStartGame: {
                        gameManager.currentView = .game
                    }
                )
            case .game:
                MainGameView(gameState: gameManager.gameState, gameManager: gameManager)
            case .settings:
                NavigationStack {
                    SettingsView(gameSettings: gameSettings, onBack: {
                        gameManager.currentView = .nameEntry
                    })
                }
            case .highScores:
                NavigationStack {
                    HighScoresView(
                        leaderboardManager: gameManager.leaderboardManager,
                        onBack: { gameManager.currentView = .nameEntry }
                    )
                }
            }
        }
    }
}
