//
//  HighScoreView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct HighScoreView: View {
    @ObservedObject var gameKitManager = GameKitManager.shared
    let leaderboardID = "your_leaderboard_id" // Change this to your actual Game Center leaderboard ID

    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .padding()
            
            Button("Show Game Center Leaderboard") {
                gameKitManager.showLeaderboard(leaderboardID: leaderboardID)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .onAppear {
            _ = gameKitManager // Ensures Game Center authentication is attempted
        }
    }
}

struct HighScoreView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoreView()
    }
}
