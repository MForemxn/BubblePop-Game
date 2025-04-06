//
//  ContentView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = GameSettings()
    @StateObject private var gameManager: GameManager
    @StateObject private var gameState: GameState
    @State private var currentView: AppView = .nameEntry
    
    init() {
        let settingsInstance = GameSettings()
        _settings = StateObject(wrappedValue: settingsInstance)
        let animationManager = AnimationManager()
        let soundManager = SoundManager(gameSettings: settingsInstance)
        let gameStateInstance = GameState(
            gameSettings: settingsInstance,
            animationManager: animationManager,
            soundManager: soundManager
        )
        _gameState = StateObject(wrappedValue: gameStateInstance)
        _gameManager = StateObject(wrappedValue: GameManager(gameSettings: settingsInstance))
    }
    
    enum AppView {
        case nameEntry, game, highScores, settings
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top, endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                switch currentView {
                case .nameEntry:
                    NameEntryView(
                        gameManager: gameManager,
                        playerName: $gameState.playerName,
                        onStartGame: { currentView = .game }
                    )
                case .game:
                    MainGameView(gameState: gameState, gameManager: gameManager)
                        .environmentObject(settings)
                        .onDisappear { gameState.resetGame() }
                case .highScores:
                    HighScoresView(
                        leaderboardManager: gameManager.leaderboardManager,
                        onBack: { currentView = .nameEntry }
                    )
                case .settings:
                    SettingsView(gameSettings: settings)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(gameSettings: settings)) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentView != .nameEntry {
                        Button(action: {
                            if currentView == .game { gameState.resetGame() }
                            currentView = .nameEntry
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $gameState.gameOver) {
                GameOverView(
                    score: gameState.currentScore,
                    playerName: gameState.playerName,
                    onPlayAgain: {
                        gameState.gameOver = false
                        gameState.startGame()
                    },
                    onViewHighScores: {
                        gameState.gameOver = false
                        currentView = .highScores
                    },
                    onMainMenu: {
                        gameState.gameOver = false
                        currentView = .nameEntry
                    }
                )
            }
        }
    }
    
    private var navigationTitle: String {
        switch currentView {
        case .nameEntry: return "BubblePop"
        case .game: return "Game in Progress"
        case .highScores: return "High Scores"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    ContentView()
}
