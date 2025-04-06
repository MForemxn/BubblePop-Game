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
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    print("Back button pressed in HighScoresView")
                    onBack()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    HighScoresView(leaderboardManager: LeaderboardManager(), onBack: {})
}
