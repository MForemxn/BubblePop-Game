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
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(player.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(player.score)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            // Show game settings if available
                            if player.gameSettings != GameSettingsData.default {
                                HStack {
                                    Label("Settings", systemImage: "gear")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Time: \(player.gameSettings.gameTime)s")
                                        .font(.caption)
                                    
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Speed: \(player.gameSettings.bubbleSpeed.capitalized)")
                                        .font(.caption)
                                    
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Max: \(player.gameSettings.maxBubbles)")
                                        .font(.caption)
                                }
                                .padding(.top, 2)
                            }
                            
                            Text(player.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
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
    HighScoresView(leaderboardManager: LeaderboardManager(), onBack: {})
}
