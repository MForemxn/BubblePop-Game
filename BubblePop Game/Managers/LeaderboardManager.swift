//
//  LeaderboardManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import Combine

struct PlayerScore: Codable, Identifiable, Comparable {
    var id = UUID()
    let name: String
    let score: Int
    let date: Date
    
    static func < (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        return lhs.score > rhs.score // Sort in descending order
    }
}

class LeaderboardManager: ObservableObject {
    @Published var highScores: [PlayerScore] = []
    
    private let maxScores = 10
    private let userDefaults = UserDefaults.standard
    private let highScoresKey = "BubblePopHighScores"
    
    init() {
        loadHighScores()
    }
    
    func loadHighScores() {
        if let data = userDefaults.data(forKey: highScoresKey) {
            let decoder = JSONDecoder()
            if let savedScores = try? decoder.decode([PlayerScore].self, from: data) {
                highScores = savedScores.sorted()
            }
        }
    }
    
    func saveHighScores() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(highScores) {
            userDefaults.set(encodedData, forKey: highScoresKey)
        }
    }
    
    func addScore(player: String, score: Int) {
        let newScore = PlayerScore(name: player, score: score, date: Date())
        highScores.append(newScore)
        highScores.sort()
        
        // Keep only the top scores
        if highScores.count > maxScores {
            highScores = Array(highScores.prefix(maxScores))
        }
        
        saveHighScores()
    }
    
    func isHighScore(score: Int) -> Bool {
        if highScores.count < maxScores {
            return true
        }
        
        if let lowestScore = highScores.last?.score {
            return score > lowestScore
        }
        
        return false
    }
    
    func getHighestScore() -> Int {
        return highScores.first?.score ?? 0
    }
    
    func clearScores() {
        highScores = []
        saveHighScores()
    }
}
