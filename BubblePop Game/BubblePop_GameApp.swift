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
            NavigationStack(path: $gameManager.navigationPath) {
                NameEntryView(
                    gameManager: gameManager,
                    playerName: $gameManager.gameState.playerName,
                    onStartGame: {
                        gameManager.startGame()
                    }
                )
                .navigationDestination(for: AppView.self) { view in
                    switch view {
                    case .game:
                        MainGameView(gameState: gameManager.gameState, gameManager: gameManager)
                    case .settings:
                        SettingsView(gameSettings: gameSettings, onBack: {
                            gameManager.goBack()
                        })
                    case .highScores:
                        HighScoresView(
                            leaderboardManager: gameManager.leaderboardManager,
                            onBack: { gameManager.goBack() }
                        )
                    case .nameEntry:
                        EmptyView() // This case shouldn't be reached through navigation
                    }
                }
            }
        }
    }
}
