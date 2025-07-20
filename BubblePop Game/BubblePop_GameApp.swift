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
                    case "multiplayerGame":
                        // Multiplayer game screen
                        MultiplayerGameView(
                            gameState: gameManager.gameState,
                            gameManager: gameManager,
                            multiplayerManager: MultiplayerManager.shared
                        )
                    case "inviteFriends":
                        // Invite friends screen
                        InviteFriendsView(
                            gameSettings: gameSettings,
                            playerName: gameManager.gameState.playerName,
                            onStartBattle: { recipients in
                                gameManager.startMultiplayerGame(with: recipients)
                            },
                            onBack: { gameManager.goBack() }
                        )
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
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }
    
    /// Handle incoming URL for battle invitations
    private func handleIncomingURL(_ url: URL) {
        let messageManager = MessageManager.shared
        
        if let inviteData = messageManager.parseInvitationLink(url) {
            // Handle battle invitation
            DispatchQueue.main.async {
                // Show alert to user about incoming invitation
                let alert = UIAlertController(
                    title: "Battle Invitation!",
                    message: "\(inviteData.playerName) has challenged you to a bubble popping battle!\n\nDifficulty: \(inviteData.difficulty.capitalized)\nDuration: \(inviteData.gameTime) seconds",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Accept Challenge", style: .default) { _ in
                    // Accept the challenge and start multiplayer game
                    self.gameManager.startMultiplayerGame(with: [])
                })
                
                alert.addAction(UIAlertAction(title: "Decline", style: .cancel))
                
                // Present the alert
                if let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    var topController = rootViewController
                    while let presentedController = topController.presentedViewController {
                        topController = presentedController
                    }
                    
                    topController.present(alert, animated: true)
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
