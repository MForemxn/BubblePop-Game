//
//  MainGameView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

// Call this when the game ends
func gameOver(finalScore: Int) {
    let leaderboardID = "your_leaderboard_id" // Replace with your actual Game Center leaderboard ID
    GameKitManager.shared.reportScore(finalScore, leaderboardID: leaderboardID)
}
