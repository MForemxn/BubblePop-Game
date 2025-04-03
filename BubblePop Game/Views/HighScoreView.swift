//
//  HighScoreView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct HighScoreView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var leaderboardManager: LeaderboardManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if leaderboardManager.highScores.isEmpty {
                Text("No scores yet!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(0..<leaderboardManager.highScores.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(width: 40, alignment: .leading)
                            
                            Text(leaderboardManager.highScores[index].name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(leaderboardManager.highScores[index].score)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(index % 2 == 0 ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                        )
                    }
                }
            }
            
            Button(action: {
                startNewGame()
            }) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Main Menu")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .frame(width: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .padding(.bottom)
        }
        .onAppear {
            // Refresh the high scores
            leaderboardManager.loadHighScores()
        }
    }
    
    func startNewGame() {
        gameState.resetGame()
        presentationMode.wrappedValue.dismiss()
    }
}
