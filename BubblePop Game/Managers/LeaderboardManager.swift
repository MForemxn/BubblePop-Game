//
//  LeaderboardManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation

class LeaderboardManager: ObservableObject {
    @Published var highScores: [Player] = []
    
    init() {
        loadHighScores()
    }
    
    func addScore(player: String, score: Int) {
        let newPlayer = Player(name: player, score: score, date: Date())
        highScores.append(newPlayer)
        highScores.sort { $0.score > $1.score }
        if highScores.count > 10 { // Keep only top 10 scores
            highScores = Array(highScores.prefix(10))
        }
        saveHighScores()
    }
    
    func getHighestScore() -> Int {
        return highScores.first?.score ?? 0
    }
    
    private func loadHighScores() {
        highScores = Player.loadPlayers()
        highScores.sort { $0.score > $1.score }
    }
    
    private func saveHighScores() {
        if let data = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(data, forKey: "players")
        }
    }
}
