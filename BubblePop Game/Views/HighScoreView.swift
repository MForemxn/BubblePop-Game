//
//  HighScoresView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI
import GameKit

struct HighScoresView: View {
    @ObservedObject var leaderboardManager: LeaderboardManager
    let onBack: () -> Void  // Closure to handle navigation
    @State private var showGameKitLeaderboard = false
    
    var body: some View {
        VStack {
            if leaderboardManager.highScores.isEmpty {
                Text("No scores yet")
                    .font(.headline)
                    .padding()
            } else {
                List {
                    ForEach(leaderboardManager.highScores) { player in
                        NavigationLink(destination: DetailedScoreView(player: player, onBack: {})) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.name)
                                        .font(.headline)
                                    
                                    Text(player.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("\(player.score)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            if GameKitManager.shared.isAuthenticated {
                Button("Show Game Center Leaderboard") {
                    leaderboardManager.showGameKitLeaderboard()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
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
    NavigationStack {
        HighScoresView(leaderboardManager: LeaderboardManager(), onBack: {})
    }
}
