//
//  BubblePop_GameApp.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

/// Main entry point for the BubblePop game application
@main
struct BubblePop_GameApp: App {
    /// Settings for the game (difficulty, game duration, etc.)
    @StateObject private var gameSettings: GameSettings
    
    /// Manager that controls the overall game flow
    @StateObject private var gameManager: GameManager
    
    /// Initialize the game settings and manager
    init() {
        let settings = GameSettings()
        _gameSettings = StateObject(wrappedValue: settings)
        _gameManager = StateObject(wrappedValue: GameManager(gameSettings: settings))
    }
    
    var body: some Scene {
        WindowGroup {
            // Set up the navigation stack with the game manager's navigation path
            NavigationStack(path: $gameManager.navigationPath) {
                // Start with the name entry screen
                NameEntryView(
                    gameManager: gameManager,
                    playerName: $gameManager.gameState.playerName,
                    onStartGame: {
                        gameManager.startGame()
                    }
                )
                // Define destinations for navigation
                .navigationDestination(for: AppView.self) { view in
                    switch view {
                    case .game:
                        // Main game screen
                        MainGameView(gameState: gameManager.gameState, gameManager: gameManager)
                    case .settings:
                        // Settings screen
                        SettingsView(gameSettings: gameSettings, onBack: {
                            gameManager.goBack()
                        })
                    case .highScores:
                        // High scores screen
                        HighScoresView(
                            leaderboardManager: gameManager.leaderboardManager,
                            onBack: { gameManager.goBack() }
                        )
                    case .nameEntry:
                        // This case shouldn't be reached through navigation
                        EmptyView()
                    }
                }
            }
        }
    }
}
