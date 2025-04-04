//
//  HighScoresView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct HighScoresView: View {
    @ObservedObject var leaderboardManager: LeaderboardManager
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
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
                    gameManager.currentView = .nameEntry
                }) {
                    Text("Back to Menu")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("High Scores", displayMode: .inline)
        }
    }
}
