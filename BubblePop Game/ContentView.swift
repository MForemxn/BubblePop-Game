//
//  ContentView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var settings = GameSettings.shared
    @State private var showSettings = false
    @State private var currentView: AppView = .nameEntry
    
    enum AppView {
        case nameEntry
        case game
        case highScores
        case settings
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Main content based on current view
                if currentView == .nameEntry {
                    NameEntryView(playerName: $gameState.playerName, onStartGame: {
                        currentView = .game
                    })
                    .transition(.opacity)
                } else if currentView == .game {
                    MainGameView(gameState: gameState)
                        .environmentObject(settings)
                        .onDisappear {
                            gameState.resetGame()
                        }
                        .transition(.opacity)
                } else if currentView == .highScores {
                    HighScoreView(onBack: {
                        currentView = .nameEntry
                    })
                    .transition(.opacity)
                } else if currentView == .settings {
                    SettingsView(onBack: {
                        currentView = .nameEntry
                    })
                    .environmentObject(settings)
                    .transition(.opacity)
                }
            }
            .navigationBarTitle(navigationTitle, displayMode: .inline)
            .navigationBarItems(
                leading: leadingBarItems,
                trailing: trailingBarItems
            )
            .navigationBarBackButtonHidden(true)
            .animation(.easeInOut, value: currentView)
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var navigationTitle: String {
        switch currentView {
        case .nameEntry:
            return "BubblePop"
        case .game:
            return "Game in Progress"
        case .highScores:
            return "High Scores"
        case .settings:
            return "Settings"
        }
    }
    
    private var leadingBarItems: some View {
        Group {
            if currentView != .nameEntry {
                Button(action: {
                    if currentView == .game {
                        gameState.resetGame()
                    }
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
    
    private var trailingBarItems: some View {
        Group {
            if currentView == .nameEntry {
                HStack {
                    Button(action: {
                        currentView = .highScores
                    }) {
                        Image(systemName: "trophy")
                    }
                    
                    Button(action: {
                        currentView = .settings
                    }) {
                        Image(systemName: "gear")
                    }
                }
            } else if currentView == .game {
                Text("Score: \(gameState.currentScore)")
                    .bold()
                    .padding(.horizontal)
                    .background(Capsule().fill(Color.white.opacity(0.3)))
            }
        }
    }
}

#Preview {
    ContentView()
}
