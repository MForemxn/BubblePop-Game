//
//  Player.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import Foundation
import GameKit

struct Player: Identifiable, Codable {
    let id = UUID()
    let name: String
    var score: Int
    let date: Date
    let gameKitPlayerId: String
    let gameSettings: GameSettingsData
    
    // Default initialization for non-GameKit players (for backward compatibility)
    init(name: String, score: Int, date: Date) {
        self.name = name
        self.score = score
        self.date = date
        self.gameKitPlayerId = ""
        self.gameSettings = GameSettingsData.default
    }
    
    // Initialize with GameKit player and settings
    init(name: String, score: Int, date: Date, gameKitPlayerId: String, gameSettings: GameSettingsData) {
        self.name = name
        self.score = score
        self.date = date
        self.gameKitPlayerId = gameKitPlayerId
        self.gameSettings = gameSettings
    }
    
    static func savePlayer(_ player: Player) {
        var players = loadPlayers()
        
        // If this player already exists (by gameKitPlayerId), only keep their highest score
        if !player.gameKitPlayerId.isEmpty {
            // Remove any lower scores from the same player
            players.removeAll { existingPlayer in
                existingPlayer.gameKitPlayerId == player.gameKitPlayerId && existingPlayer.score <= player.score
            }
            
            // Only add if this is their best score or they don't have any scores yet
            if !players.contains(where: { $0.gameKitPlayerId == player.gameKitPlayerId && $0.score > player.score }) {
                players.append(player)
            }
        } else {
            // Legacy support for non-GameKit players
            players.append(player)
        }
        
        savePlayers(players)
    }
    
    static func loadPlayers() -> [Player] {
        guard let data = UserDefaults.standard.data(forKey: "players") else { return [] }
        
        do {
            return try JSONDecoder().decode([Player].self, from: data)
        } catch {
            print("Error decoding players: \(error)")
            return []
        }
    }
    
    static func savePlayers(_ players: [Player]) {
        do {
            let data = try JSONEncoder().encode(players)
            UserDefaults.standard.set(data, forKey: "players")
        } catch {
            print("Error encoding players: \(error)")
        }
    }
    
    static func topPlayers(limit: Int = 10) -> [Player] {
        return loadPlayers()
            .sorted(by: { $0.score > $1.score })
            .prefix(limit)
            .map { $0 }
    }
    
    // Get the top score for a specific GameKit player
    static func topScoreForPlayer(gameKitPlayerId: String) -> Int {
        return loadPlayers()
            .filter { $0.gameKitPlayerId == gameKitPlayerId }
            .map { $0.score }
            .max() ?? 0
    }
}

// Structure to store game settings with the player's score
struct GameSettingsData: Codable, Equatable {
    let gameTime: Int
    let maxBubbles: Int
    let bubbleSpeed: String
    
    static var `default`: GameSettingsData {
        return GameSettingsData(gameTime: 60, maxBubbles: 15, bubbleSpeed: "medium")
    }
    
    init(from gameSettings: GameSettings) {
        self.gameTime = gameSettings.gameTime
        self.maxBubbles = gameSettings.maxBubbles
        self.bubbleSpeed = gameSettings.bubbleSpeed.rawValue
    }
    
    init(gameTime: Int, maxBubbles: Int, bubbleSpeed: String) {
        self.gameTime = gameTime
        self.maxBubbles = maxBubbles
        self.bubbleSpeed = bubbleSpeed
    }
    
    // Implement Equatable manually
    static func == (lhs: GameSettingsData, rhs: GameSettingsData) -> Bool {
        return lhs.gameTime == rhs.gameTime &&
               lhs.maxBubbles == rhs.maxBubbles &&
               lhs.bubbleSpeed == rhs.bubbleSpeed
    }
}
