//
//  NameEntryView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI

struct NameEntryView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var playerName: String
    let onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Your Name")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Player Name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: 300)
            
            Button(action: {
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
    }
}
