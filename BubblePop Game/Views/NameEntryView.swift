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
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Two-column layout for landscape
                landscapeLayout(geometry: geometry)
            } else {
                // Regular layout for portrait
                portraitLayout
            }
        }
    }
    
    // MARK: - Layout Views
    
    // Portrait layout - stacked vertically
    private var portraitLayout: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // Game title
                Text("BubblePop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)
                
                // Name input section - different based on Game Center authentication
                if gameKitManager.isAuthenticated {
                    gameCenterUserView
                } else {
                    regularUserView
                }
                
                // Start game button
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: min(280, geometry.size.width - 40))
                        .padding(.vertical, 14)
                        .background(playerName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(playerName.isEmpty)
                .padding(.top, 8)
                
                // Navigation buttons
                VStack(spacing: 16) {
                    NavigationLink(value: "settings") {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: min(280, geometry.size.width - 40))
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink(value: "highScores") {
                        Text("High Scores")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: min(280, geometry.size.width - 40))
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
        }
    }
    
    // Landscape layout - side-by-side columns
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left column - title and name input
            VStack(spacing: 20) {
                Spacer()
                
                // Game title
                Text("BubblePop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                // Name input section
                if gameKitManager.isAuthenticated {
                    // Game Center banner
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.green)
                        Text("Game Center: \(gameKitManager.playerName)")
                            .font(.headline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
                    
                    // Nickname input
                    TextField("Nickname", text: $nickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: min(300, geometry.size.width * 0.35))
                        .onChange(of: nickname) { oldValue, newValue in
                            playerName = newValue
                        }
                } else {
                    // Regular name input
                    Text("Enter Your Name")
                        .font(.headline)
                    
                    TextField("Player Name", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: min(300, geometry.size.width * 0.35))
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width * 0.5)
            .padding(.horizontal)
            
            // Right column - buttons
            VStack(spacing: 20) {
                Spacer()
                
                // Start game button
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .frame(width: min(200, geometry.size.width * 0.25))
                        .background(playerName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(playerName.isEmpty)
                
                // Settings button
                NavigationLink(value: "settings") {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .frame(width: min(200, geometry.size.width * 0.25))
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                // High scores button
                NavigationLink(value: "highScores") {
                    Text("High Scores")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .frame(width: min(200, geometry.size.width * 0.25))
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width * 0.5)
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .leading) { Color.clear }
        .safeAreaInset(edge: .trailing) { Color.clear }
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
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Game Center status banner
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.green)
                    Text("Game Center: \(gameKitManager.playerName)")
                        .font(.headline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.1))
                )
                .padding(.bottom, 8)
                
                // Nickname input
                Text("Enter Your Nickname")
                    .font(.headline)
                    .padding(.top, 8)
                
                TextField("Nickname", text: $nickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: min(280, geometry.size.width - 40))
                    .onChange(of: nickname) { oldValue, newValue in
                        playerName = newValue
                    }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    /// View for regular users without Game Center
    private var regularUserView: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Game Center status banner
                Text("Game Center: Not Signed In")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.vertical, 8)
                
                // Name input
                Text("Enter Your Name")
                    .font(.headline)
                    .padding(.top, 8)
                
                TextField("Player Name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: min(280, geometry.size.width - 40))
            }
            .frame(maxWidth: .infinity)
        }
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
