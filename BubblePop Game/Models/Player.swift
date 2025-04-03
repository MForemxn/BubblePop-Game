//
//  Player.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import Foundation

struct Player: Identifiable, Codable {
    let id = UUID()
    let name: String
    var score: Int
    let date: Date
    
    static func savePlayer(_ player: Player) {
        var players = loadPlayers()
        players.append(player)
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
}
