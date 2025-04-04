//
//  HighScoresView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct HighScoresView: View {
    @ObservedObject var leaderboardManager: LeaderboardManager
    let onBack: () -> Void  // Closure to handle navigation
    
    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List(leaderboardManager.highScores) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Text("\(player.score)")
                        .font(.headline)
                    Text(player.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Button(action: {
                onBack()  // Trigger the closure instead of modifying gameManager
            }) {
                Text("Back to Menu")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)  // Adaptive width
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("High Scores")  // Set title for parent navigation context
    }
}
