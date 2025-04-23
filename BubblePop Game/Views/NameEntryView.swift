//
//  NameEntryView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI
import GameKit

/// Main menu view where players enter their name and start the game
struct NameEntryView: View {
    // MARK: - Properties
    
    /// Game manager that controls game flow
    @ObservedObject var gameManager: GameManager
    
    /// Manager that handles Game Center integration
    @ObservedObject var gameKitManager = GameKitManager.shared
    
    /// Player name binding that updates the game state
    @Binding var playerName: String
    
    /// Local nickname state for text field
    @State private var nickname: String = ""
    
    /// Callback for when the start game button is pressed
    let onStartGame: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Game title
            Text("BubblePop")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // Name input section - different based on Game Center authentication
            if gameKitManager.isAuthenticated {
                gameCenterUserView
            } else {
                regularUserView
            }
            
            // Start game button
            startGameButton
            
            // Navigation buttons
            NavigationLink(value: "settings") {
                buttonLabel(text: "Settings", color: .green)
            }
            
            NavigationLink(value: "highScores") {
                buttonLabel(text: "High Scores", color: .orange)
            }
        }
        .padding()
        .onAppear {
            // When authenticated with GameKit, set nickname initially to GameKit name
            if gameKitManager.isAuthenticated && nickname.isEmpty {
                nickname = gameKitManager.playerName
                playerName = nickname
            }
        }
    }
    
    // MARK: - View Components
    
    /// View for Game Center authenticated users
    private var gameCenterUserView: some View {
        VStack(spacing: 10) {
            // Game Center status banner
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(.green)
                Text("Game Center: \(gameKitManager.playerName)")
                    .font(.headline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green.opacity(0.1))
            )
            .padding(.bottom, 10)
            
            // Nickname input
            Text("Enter Your Nickname")
                .font(.headline)
            
            TextField("Nickname", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .frame(maxWidth: 300)
                .onChange(of: nickname) { newValue in
                    playerName = newValue
                }
        }
    }
    
    /// View for regular users without Game Center
    private var regularUserView: some View {
        VStack(spacing: 10) {
            // Game Center status banner
            Text("Game Center: Not Signed In")
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.bottom, 10)
            
            // Name input
            Text("Enter Your Name")
                .font(.headline)
            
            TextField("Player Name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .frame(maxWidth: 300)
        }
    }
    
    /// Start game button
    private var startGameButton: some View {
        Button(action: startGame) {
            buttonLabel(
                text: "Start Game",
                color: playerName.isEmpty ? .gray : .blue
            )
        }
        .disabled(playerName.isEmpty)
    }
    
    /// Reusable button label style
    private func buttonLabel(text: String, color: Color) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 200)
            .background(color)
            .cornerRadius(10)
    }
    
    // MARK: - Methods
    
    /// Handle start game button press
    private func startGame() {
        // If using Game Center, ensure we have a nickname or default to GameKit name
        if gameKitManager.isAuthenticated && nickname.isEmpty {
            // Default to Game Center name if no nickname is provided
            nickname = gameKitManager.playerName
            playerName = nickname
        }
        
        if !playerName.isEmpty {
            // Update the player in gameState
            gameManager.gameState.player = Player(
                name: playerName,
                score: 0,
                date: Date()
            )
            onStartGame()
        }
    }
}
