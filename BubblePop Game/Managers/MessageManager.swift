//
//  MessageManager.swift
//  BubblePop Game
//
//  Created by Assistant on 20/7/2025.
//

import Foundation
import MessageUI
import SwiftUI
import GameKit

class MessageManager: NSObject, ObservableObject {
    static let shared = MessageManager()
    
    @Published var canSendMessages: Bool = false
    @Published var isShowingMessageComposer: Bool = false
    
    private override init() {
        super.init()
        canSendMessages = MFMessageComposeViewController.canSendText()
    }
    
    /// Generate an invitation link for multiplayer battle
    func generateInvitationLink(playerName: String, gameSettings: GameSettings) -> String {
        let baseURL = "bubblepop://battle"
        let encodedPlayerName = playerName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? playerName
        let difficulty = gameSettings.difficulty.rawValue
        let gameTime = gameSettings.gameTime
        
        return "\(baseURL)?player=\(encodedPlayerName)&difficulty=\(difficulty)&time=\(gameTime)"
    }
    
    /// Create invitation message for iMessage
    func createInvitationMessage(from playerName: String, gameSettings: GameSettings) -> String {
        let inviteLink = generateInvitationLink(playerName: playerName, gameSettings: gameSettings)
        
        return """
        🫧 BubblePop Battle Challenge! 🫧
        
        \(playerName) has challenged you to a bubble popping battle!
        
        Game Settings:
        • Difficulty: \(gameSettings.difficulty.rawValue.capitalized)
        • Duration: \(gameSettings.gameTime) seconds
        
        Tap this link to accept the challenge:
        \(inviteLink)
        
        Let's see who can pop more bubbles! 🎯
        """
    }
    
    /// Create results sharing message for iMessage
    func createResultsMessage(winner: String, winnerScore: Int, loser: String, loserScore: Int, gameSettings: GameSettings) -> String {
        let scoreDifference = abs(winnerScore - loserScore)
        let emoji = scoreDifference > 500 ? "🔥" : scoreDifference > 200 ? "💪" : "👏"
        
        return """
        🫧 BubblePop Battle Results! \(emoji)
        
        🏆 Winner: \(winner) - \(winnerScore) points
        🥈 Runner-up: \(loser) - \(loserScore) points
        
        Game Settings:
        • Difficulty: \(gameSettings.difficulty.rawValue.capitalized)
        • Duration: \(gameSettings.gameTime) seconds
        
        Great game! Ready for another round? 🎮
        """
    }
    
    /// Send invitation via iMessage
    func sendInvitation(to recipients: [String], from playerName: String, gameSettings: GameSettings, completion: @escaping (Bool) -> Void) {
        guard canSendMessages else {
            completion(false)
            return
        }
        
        let message = createInvitationMessage(from: playerName, gameSettings: gameSettings)
        presentMessageComposer(recipients: recipients, message: message, completion: completion)
    }
    
    /// Share battle results via iMessage
    func shareResults(to recipients: [String], winner: String, winnerScore: Int, loser: String, loserScore: Int, gameSettings: GameSettings, completion: @escaping (Bool) -> Void) {
        guard canSendMessages else {
            completion(false)
            return
        }
        
        let message = createResultsMessage(winner: winner, winnerScore: winnerScore, loser: loser, loserScore: loserScore, gameSettings: gameSettings)
        presentMessageComposer(recipients: recipients, message: message, completion: completion)
    }
    
    private func presentMessageComposer(recipients: [String], message: String, completion: @escaping (Bool) -> Void) {
        let messageComposer = MFMessageComposeViewController()
        messageComposer.recipients = recipients
        messageComposer.body = message
        messageComposer.messageComposeDelegate = MessageComposeDelegate(completion: completion)
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                
                topController.present(messageComposer, animated: true)
            }
        }
    }
    
    /// Parse invitation link to extract battle parameters
    func parseInvitationLink(_ url: URL) -> (playerName: String, difficulty: String, gameTime: Int)? {
        guard url.scheme == "bubblepop", url.host == "battle" else { return nil }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.queryItems else { return nil }
        
        var playerName = ""
        var difficulty = "easy"
        var gameTime = 60
        
        for item in queryItems {
            switch item.name {
            case "player":
                playerName = item.value?.removingPercentEncoding ?? ""
            case "difficulty":
                difficulty = item.value ?? "easy"
            case "time":
                gameTime = Int(item.value ?? "60") ?? 60
            default:
                break
            }
        }
        
        return (playerName: playerName, difficulty: difficulty, gameTime: gameTime)
    }
}

// MARK: - Message Compose Delegate
class MessageComposeDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    private let completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            self.completion(result == .sent)
        }
    }
}