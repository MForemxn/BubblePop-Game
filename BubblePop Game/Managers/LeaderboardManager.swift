//
//  LeaderboardManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation

class LeaderboardManager: ObservableObject {
    @Published private(set) var highScores: [Player] = []
    
    private let maxHighScores: Int = 10  // Configurable limit for top scores
    
    init(loadFromPersistence: Bool = true) {
        if loadFromPersistence {
            loadHighScores()
        }
    }
    
    func addScore(player: String, score: Int) {
        let newPlayer = Player(name: player, score: score, date: Date())
        
        // Insert the new score in the correct position to maintain sorted order
        if let index = highScores.firstIndex(where: { $0.score < newPlayer.score }) {
            highScores.insert(newPlayer, at: index)
        } else {
            highScores.append(newPlayer)
        }
        
        // Trim the list to the top N scores
        if highScores.count > maxHighScores {
            highScores = Array(highScores.prefix(maxHighScores))
        }
        
        saveHighScores()
    }
    
    func getHighestScore() -> Int {
        return highScores.first?.score ?? 0
    }
    
    private func loadHighScores() {
        highScores = Player.loadPlayers().sorted { $0.score > $1.score }
    }
    
    private func saveHighScores() {
        do {
            let data = try JSONEncoder().encode(highScores)
            UserDefaults.standard.set(data, forKey: "players")
        } catch {
            print("Failed to save high scores: \(error.localizedDescription)")
        }
    }
}
