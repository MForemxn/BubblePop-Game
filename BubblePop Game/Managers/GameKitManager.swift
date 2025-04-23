//
//  GameKitManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import GameKit
import SwiftUI

class GameKitManager: NSObject, ObservableObject {
    static let shared = GameKitManager()
    @Published var isAuthenticated: Bool = false
    @Published var playerName: String = ""
    
    private override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // We need to present the authentication view controller
                self.presentViewController(viewController)
            } else if localPlayer.isAuthenticated {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.playerName = localPlayer.displayName
                    print("Game Center Authentication succeeded: \(localPlayer.displayName)")
                }
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    print("Game Center Authentication failed: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }
    
    func reportScore(_ score: Int, leaderboardID: String) {
        GKLeaderboard.submitScore(
            Int64(score),
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Score reported successfully!")
            }
        }
    }
    
    func showLeaderboard(leaderboardID: String) {
        let gcViewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        gcViewController.gameCenterDelegate = self
        presentViewController(gcViewController)
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            // Get the current active window scene
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                // Find the topmost presented view controller
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                
                topController.present(viewController, animated: true)
            } else {
                print("Error: No active window scene available")
            }
        }
    }
}

extension GameKitManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
