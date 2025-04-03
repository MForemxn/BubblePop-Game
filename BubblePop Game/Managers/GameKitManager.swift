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
        localPlayer.authenticateHandler = { vc, error in
            if let viewController = vc {
                DispatchQueue.main.async {
                    self.presentGameCenterViewController(viewController)
                }
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
        let gkScore = GKScore(leaderboardIdentifier: leaderboardID)
        gkScore.value = Int64(score)
        
        GKScore.report([gkScore]) { error in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Score reported successfully!")
            }
        }
    }
    
    func showLeaderboard(leaderboardID: String) {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            print("Error: No root view controller available")
            return
        }
        
        let gcViewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        gcViewController.gameCenterDelegate = self
        rootVC.present(gcViewController, animated: true)
    }
    
    private func presentGameCenterViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
                print("Error: No root view controller available")
                return
            }
            rootVC.present(viewController, animated: true)
        }
    }
}

extension GameKitManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
