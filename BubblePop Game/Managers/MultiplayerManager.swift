//
//  MultiplayerManager.swift
//  BubblePop Game
//
//  Created by Assistant on 20/7/2025.
//

import Foundation
import GameKit
import SwiftUI

enum MultiplayerState {
    case idle
    case searching
    case connecting
    case connected
    case playing
    case finished
    case disconnected
}

enum BattleResult {
    case won(myScore: Int, opponentScore: Int)
    case lost(myScore: Int, opponentScore: Int)
    case tie(score: Int)
}

struct MultiplayerGameData: Codable {
    let messageType: MessageType
    let playerName: String
    let score: Int?
    let timeRemaining: Int?
    let gameFinished: Bool
    
    enum MessageType: String, Codable {
        case gameStart
        case scoreUpdate
        case gameEnd
        case playerReady
    }
}

@MainActor
class MultiplayerManager: NSObject, ObservableObject {
    static let shared = MultiplayerManager()
    
    @Published var multiplayerState: MultiplayerState = .idle
    @Published var opponentName: String = ""
    @Published var opponentScore: Int = 0
    @Published var isHost: Bool = false
    @Published var battleResult: BattleResult?
    @Published var showingBattleResults: Bool = false
    
    private var match: GKMatch?
    private var matchRequest: GKMatchRequest?
    private var inviteRecipients: [String] = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Start searching for a multiplayer match
    func startMultiplayerMatch(inviteRecipients: [String] = []) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player not authenticated with Game Center")
            return
        }
        
        self.inviteRecipients = inviteRecipients
        multiplayerState = .searching
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        
        // Set recipients if we have phone numbers/emails
        if !inviteRecipients.isEmpty {
            request.recipients = inviteRecipients
        }
        
        matchRequest = request
        
        let matchmakerVC = GKMatchmakerViewController(matchRequest: request)
        matchmakerVC?.matchmakerDelegate = self
        
        presentViewController(matchmakerVC!)
    }
    
    /// Send game data to opponent
    func sendGameData(_ data: MultiplayerGameData) {
        guard let match = match else { return }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            try match.sendData(toAllPlayers: encodedData, with: .reliable)
        } catch {
            print("Error sending game data: \(error)")
        }
    }
    
    /// Update opponent with current score
    func updateOpponentScore(_ score: Int) {
        let data = MultiplayerGameData(
            messageType: .scoreUpdate,
            playerName: GKLocalPlayer.local.displayName,
            score: score,
            timeRemaining: nil,
            gameFinished: false
        )
        sendGameData(data)
    }
    
    /// Notify opponent that game has ended
    func notifyGameEnd(finalScore: Int) {
        let data = MultiplayerGameData(
            messageType: .gameEnd,
            playerName: GKLocalPlayer.local.displayName,
            score: finalScore,
            timeRemaining: nil,
            gameFinished: true
        )
        sendGameData(data)
    }
    
    /// Start the multiplayer game
    func startGame() {
        multiplayerState = .playing
        let data = MultiplayerGameData(
            messageType: .gameStart,
            playerName: GKLocalPlayer.local.displayName,
            score: nil,
            timeRemaining: nil,
            gameFinished: false
        )
        sendGameData(data)
    }
    
    /// Handle game completion and determine winner
    func handleGameCompletion(myScore: Int) {
        if opponentScore > myScore {
            battleResult = .lost(myScore: myScore, opponentScore: opponentScore)
        } else if myScore > opponentScore {
            battleResult = .won(myScore: myScore, opponentScore: opponentScore)
        } else {
            battleResult = .tie(score: myScore)
        }
        
        multiplayerState = .finished
        showingBattleResults = true
    }
    
    /// Disconnect from current match
    func disconnect() {
        match?.disconnect()
        match = nil
        matchRequest = nil
        multiplayerState = .idle
        opponentName = ""
        opponentScore = 0
        battleResult = nil
        showingBattleResults = false
    }
    
    /// Get recipients for sharing results
    func getResultsRecipients() -> [String] {
        return inviteRecipients
    }
    
    // MARK: - Private Methods
    
    private func presentViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                
                topController.present(viewController, animated: true)
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let gameData = try JSONDecoder().decode(MultiplayerGameData.self, from: data)
            
            switch gameData.messageType {
            case .gameStart:
                if opponentName.isEmpty {
                    opponentName = gameData.playerName
                }
                multiplayerState = .playing
                
            case .scoreUpdate:
                if let score = gameData.score {
                    opponentScore = score
                }
                
            case .gameEnd:
                if let score = gameData.score {
                    opponentScore = score
                }
                multiplayerState = .finished
                
            case .playerReady:
                if opponentName.isEmpty {
                    opponentName = gameData.playerName
                }
                multiplayerState = .connected
            }
            
        } catch {
            print("Error decoding game data: \(error)")
        }
    }
}

// MARK: - GKMatchmakerViewControllerDelegate
extension MultiplayerManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
        multiplayerState = .idle
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        multiplayerState = .idle
        print("Matchmaker failed with error: \(error)")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        self.match = match
        match.delegate = self
        multiplayerState = .connecting
        
        // Determine if we're the host (player with lower player ID)
        if let localPlayerID = GKLocalPlayer.local.gamePlayerID,
           let opponentID = match.players.first?.gamePlayerID {
            isHost = localPlayerID < opponentID
        }
        
        // Send ready message
        let data = MultiplayerGameData(
            messageType: .playerReady,
            playerName: GKLocalPlayer.local.displayName,
            score: nil,
            timeRemaining: nil,
            gameFinished: false
        )
        sendGameData(data)
    }
}

// MARK: - GKMatchDelegate
extension MultiplayerManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        handleReceivedData(data)
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            if multiplayerState == .connecting {
                multiplayerState = .connected
            }
        case .disconnected:
            multiplayerState = .disconnected
            opponentName = ""
            opponentScore = 0
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        multiplayerState = .disconnected
        print("Match failed with error: \(error?.localizedDescription ?? "Unknown error")")
    }
}