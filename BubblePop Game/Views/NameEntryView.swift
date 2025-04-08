//
//  NameEntryView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI
import GameKit

struct NameEntryView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var gameKitManager = GameKitManager.shared
    @Binding var playerName: String
    @State private var nickname: String = ""
    let onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("BubblePop")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            if gameKitManager.isAuthenticated {
                VStack(spacing: 10) {
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
            } else {
                VStack(spacing: 10) {
                    Text("Game Center: Not Signed In")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .padding(.bottom, 10)
                    
                    Text("Enter Your Name")
                        .font(.headline)
                    
                    TextField("Player Name", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .frame(maxWidth: 300)
                }
            }
            
            Button(action: {
                // If using Game Center, ensure we have a nickname or default to GameKit name
                if gameKitManager.isAuthenticated {
                    if nickname.isEmpty {
                        // Default to Game Center name if no nickname is provided
                        nickname = gameKitManager.playerName
                        playerName = nickname
                    }
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
            }) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(playerName.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(playerName.isEmpty)
            
            Button(action: {
                gameManager.currentView = .settings
            }) {
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Button(action: {
                gameManager.currentView = .highScores
            }) {
                Text("High Scores")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.orange)
                    .cornerRadius(10)
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
}
