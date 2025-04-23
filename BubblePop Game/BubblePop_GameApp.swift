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
        
        // Configure app to support all orientations
        setupOrientationSupport()
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
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                    case "game":
                        // Main game screen
                        MainGameView(gameState: gameManager.gameState, gameManager: gameManager)
                    case "settings":
                        // Settings screen
                        SettingsView(gameSettings: gameSettings, onBack: {
                            gameManager.goBack()
                        })
                    case "highScores":
                        // High scores screen
                        HighScoresView(
                            leaderboardManager: gameManager.leaderboardManager,
                            onBack: { gameManager.goBack() }
                        )
                    default:
                        // This case shouldn't be reached through navigation
                        EmptyView()
                    }
                }
            }
        }
    }
    
    /// Configure the app to support all orientations
    private func setupOrientationSupport() {
        // Set the supported interface orientations
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
        }
        
        // Add observer for orientation changes to update UI
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            // This will trigger layout updates across the app
            // Any additional orientation-specific logic can be added here
        }
    }
}
