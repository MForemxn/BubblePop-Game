//
//  LeaderboardManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import GameKit

class LeaderboardManager: ObservableObject {
    @Published private(set) var highScores: [Player] = []
    private let leaderboardID = "bubblePop_leaderboard"
    private let maxHighScores: Int = 10  // Configurable limit for top scores
    
    init(loadFromPersistence: Bool = true) {
        if loadFromPersistence {
            loadHighScores()
        }
    }
    
    func addScore(player: String, score: Int, gameSettings: GameSettings) {
        // Check if user is authenticated with GameKit
        if GameKitManager.shared.isAuthenticated {
            // Use GameKit player ID and nickname instead of manually entered name
            let localPlayer = GKLocalPlayer.local
            let newPlayer = Player(
                name: player, // Use the provided nickname
                score: score,
                date: Date(),
                gameKitPlayerId: localPlayer.gamePlayerID,
                gameSettings: GameSettingsData(from: gameSettings)
            )
            
            // Report the score to GameKit
            GameKitManager.shared.reportScore(score, leaderboardID: leaderboardID)
            
            // Update local leaderboard
            addPlayerToLeaderboard(newPlayer)
        } else {
            // Legacy support for non-GameKit players
            let newPlayer = Player(name: player, score: score, date: Date())
            addPlayerToLeaderboard(newPlayer)
        }
    }
    
    private func addPlayerToLeaderboard(_ newPlayer: Player) {
        // If player exists (by ID for GameKit or by name for legacy), only keep their highest score
        var updatedScores = highScores.filter { player in
            if !newPlayer.gameKitPlayerId.isEmpty {
                // For GameKit players, filter by ID
                return player.gameKitPlayerId != newPlayer.gameKitPlayerId
            } else {
                // For legacy players, filter by name
                return player.name != newPlayer.name
            }
        }
        
        // Add the new score in the correct position to maintain sorted order
        if let index = updatedScores.firstIndex(where: { $0.score < newPlayer.score }) {
            updatedScores.insert(newPlayer, at: index)
        } else {
            updatedScores.append(newPlayer)
        }
        
        // Keep the list sorted
        updatedScores.sort { $0.score > $1.score }
        
        // Trim the list to the top N scores
        if updatedScores.count > maxHighScores {
            updatedScores = Array(updatedScores.prefix(maxHighScores))
        }
        
        // Update the published property
        highScores = updatedScores
        
        saveHighScores()
    }
    
    func getHighestScore() -> Int {
        return highScores.first?.score ?? 0
    }
    
    // Get highest score for the current GameKit player
    func getCurrentPlayerHighScore() -> Int {
        if GameKitManager.shared.isAuthenticated {
            let playerId = GKLocalPlayer.local.gamePlayerID
            return highScores
                .filter { $0.gameKitPlayerId == playerId }
                .map { $0.score }
                .max() ?? 0
        }
        return 0
    }
    
    func showGameKitLeaderboard() {
        if GameKitManager.shared.isAuthenticated {
            GameKitManager.shared.showLeaderboard(leaderboardID: leaderboardID)
        }
    }
    
    private func loadHighScores() {
        highScores = Player.loadPlayers().sorted { $0.score > $1.score }
        
        // Remove duplicates to ensure only one entry per player
        var uniquePlayers: [String: Player] = [:]
        
        // First process GameKit players (by ID)
        for player in highScores where !player.gameKitPlayerId.isEmpty {
            if let existingPlayer = uniquePlayers[player.gameKitPlayerId], existingPlayer.score >= player.score {
                // Skip this player because we already have a higher score
                continue
            }
            uniquePlayers[player.gameKitPlayerId] = player
        }
        
        // Then process legacy players (by name)
        for player in highScores where player.gameKitPlayerId.isEmpty {
            let key = "name_\(player.name)"
            if let existingPlayer = uniquePlayers[key], existingPlayer.score >= player.score {
                // Skip this player because we already have a higher score
                continue
            }
            uniquePlayers[key] = player
        }
        
        // Reassign the filtered list and sort by score
        highScores = Array(uniquePlayers.values).sorted(by: { $0.score > $1.score })
        
        // Ensure we only keep top scores
        if highScores.count > maxHighScores {
            highScores = Array(highScores.prefix(maxHighScores))
        }
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
