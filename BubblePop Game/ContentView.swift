//
//  ContentView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

/// The main container view for the BubblePop game application
struct ContentView: View {
    // MARK: - Properties
    
    /// Game settings object that stores user preferences
    @StateObject private var settings = GameSettings()
    
    /// Manager that handles the game flow and navigation
    @StateObject private var gameManager: GameManager
    
    /// State object that holds the game data
    @StateObject private var gameState: GameState
    
    /// Current view to display in the app
    @State private var currentView: AppView = .nameEntry
    
    /// Controls whether to show the settings sheet
    @State private var showSettings = false
    
    // MARK: - Initialization
    
    /// Initialize the game components
    init() {
        // Create settings instance
        let settingsInstance = GameSettings()
        _settings = StateObject(wrappedValue: settingsInstance)
        
        // Create managers for animation and sound
        let animationManager = AnimationManager()
        let soundManager = SoundManager(gameSettings: settingsInstance)
        
        // Create game state with dependencies
        let gameStateInstance = GameState(
            gameSettings: settingsInstance,
            animationManager: animationManager,
            soundManager: soundManager
        )
        _gameState = StateObject(wrappedValue: gameStateInstance)
        
        // Create game manager
        _gameManager = StateObject(wrappedValue: GameManager(gameSettings: settingsInstance))
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                        startPoint: .top, endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    // Display the current view
                    currentViewContent(geometry: geometry)
                }
                .navigationTitle(navigationTitle)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    // Settings button in the top right
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                    
                    // Back button in the top left
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
                // Modal sheets
                .sheet(isPresented: $showSettings) {
                    settingsSheet
                }
                .sheet(isPresented: $gameState.gameOver) {
                    gameOverSheet
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// The current view to display based on navigation state
    private func currentViewContent(geometry: GeometryProxy) -> some View {
        Group {
            switch currentView {
            case .nameEntry:
                NameEntryView(
                    gameManager: gameManager,
                    playerName: $gameState.playerName,
                    onStartGame: { currentView = .game }
                )
                .environmentObject(gameManager)
            case .game:
                MainGameView(gameState: gameState, gameManager: gameManager)
                    .environmentObject(settings)
                    .environmentObject(gameManager)
                    .onDisappear { gameState.resetGame() }
            case .highScores:
                HighScoresView(
                    leaderboardManager: gameManager.leaderboardManager,
                    onBack: { currentView = .nameEntry }
                )
                .environmentObject(gameManager)
            case .settings:
                SettingsView(
                    gameSettings: settings, 
                    onBack: { currentView = .nameEntry },
                    onSettingsChanged: {
                        // Update game components if game is running
                        if gameManager.gameState.gameRunning {
                            gameManager.bubbleManager.updateBubbleSpeed()
                        }
                    }
                )
                .environmentObject(gameManager)
            }
        }
    }
    
    /// Navigation title based on current view
    private var navigationTitle: String {
        switch currentView {
        case .nameEntry: return "BubblePop"
        case .game: return "Game in Progress"
        case .highScores: return "High Scores"
        case .settings: return "Settings"
        }
    }
    
    /// Settings sheet content
    private var settingsSheet: some View {
        NavigationStack {
            SettingsView(
                gameSettings: settings, 
                onBack: { showSettings = false },
                onSettingsChanged: {
                    // Update game components if game is running
                    if gameManager.gameState.gameRunning {
                        gameManager.bubbleManager.updateBubbleSpeed()
                    }
                }
            )
        }
    }
    
    /// Game over sheet content
    private var gameOverSheet: some View {
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

/// View navigation options
enum AppView {
    case nameEntry, game, highScores, settings
}

#Preview {
    ContentView()
}
