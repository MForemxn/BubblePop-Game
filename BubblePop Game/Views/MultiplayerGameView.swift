//
//  MultiplayerGameView.swift
//  BubblePop Game
//
//  Created by Assistant on 20/7/2025.
//

import SwiftUI

struct MultiplayerGameView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var gameManager: GameManager
    @ObservedObject var multiplayerManager: MultiplayerManager
    
    @State private var showingConnectionStatus = false
    @State private var connectionStatusMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Score Bar
                    multiplayerScoreBar
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Game Area
                    ZStack {
                        // Bubbles
                        ForEach(gameState.bubbles) { bubble in
                            BubbleView(bubble: bubble) {
                                gameManager.popBubble(bubble)
                                // Update opponent with new score
                                multiplayerManager.updateOpponentScore(gameState.currentScore)
                            }
                        }
                        
                        // Connection Status Overlay
                        if showingConnectionStatus {
                            connectionStatusOverlay
                        }
                        
                        // Game Over Overlay
                        if gameState.gameOver {
                            gameOverOverlay
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        gameState.updateScreenSize(geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        gameState.updateScreenSize(newSize)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupMultiplayerGame()
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameTimeExpired)) { _ in
            handleGameEnd()
        }
        .onChange(of: multiplayerManager.multiplayerState) { _, newState in
            handleMultiplayerStateChange(newState)
        }
        .sheet(isPresented: $multiplayerManager.showingBattleResults) {
            if let battleResult = multiplayerManager.battleResult {
                BattleResultsView(
                    battleResult: battleResult,
                    playerName: gameState.playerName,
                    opponentName: multiplayerManager.opponentName,
                    gameSettings: gameState.gameSettings,
                    onPlayAgain: {
                        startNewBattle()
                    },
                    onShareResults: {
                        shareResults()
                    },
                    onBackToMenu: {
                        endMultiplayerSession()
                    }
                )
            }
        }
    }
    
    // MARK: - Views
    
    private var multiplayerScoreBar: some View {
        HStack {
            // Player Score
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(gameState.playerName)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("(You)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("\(gameState.currentScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Timer
            VStack(spacing: 4) {
                Text("TIME")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(timeString)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(gameState.timeRemaining <= 10 ? .red : .primary)
            }
            
            // Opponent Score
            VStack(alignment: .trailing, spacing: 4) {
                Text(multiplayerManager.opponentName.isEmpty ? "Opponent" : multiplayerManager.opponentName)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("\(multiplayerManager.opponentScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 3)
        )
    }
    
    private var connectionStatusOverlay: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(connectionStatusMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
        )
    }
    
    private var gameOverOverlay: some View {
        VStack(spacing: 20) {
            Text("Time's Up!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Calculating results...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ProgressView()
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
        )
    }
    
    // MARK: - Computed Properties
    
    private var timeString: String {
        let minutes = gameState.timeRemaining / 60
        let seconds = gameState.timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Methods
    
    private func setupMultiplayerGame() {
        // Wait for both players to be ready
        if multiplayerManager.multiplayerState == .connected {
            // Start the game countdown
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                gameManager.beginActualGame()
                multiplayerManager.startGame()
            }
        }
    }
    
    private func handleMultiplayerStateChange(_ state: MultiplayerState) {
        switch state {
        case .connecting:
            showingConnectionStatus = true
            connectionStatusMessage = "Connecting to opponent..."
            
        case .connected:
            connectionStatusMessage = "Opponent found! Starting game..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingConnectionStatus = false
                setupMultiplayerGame()
            }
            
        case .playing:
            showingConnectionStatus = false
            
        case .disconnected:
            showingConnectionStatus = true
            connectionStatusMessage = "Opponent disconnected"
            
        case .finished:
            // Results will be shown via sheet
            break
            
        default:
            break
        }
    }
    
    private func handleGameEnd() {
        // Notify opponent of final score
        multiplayerManager.notifyGameEnd(finalScore: gameState.currentScore)
        
        // Calculate battle result
        multiplayerManager.handleGameCompletion(myScore: gameState.currentScore)
        
        // End the local game
        gameManager.endGame()
    }
    
    private func startNewBattle() {
        multiplayerManager.showingBattleResults = false
        
        // Reset game state
        gameManager.resetGame()
        
        // Start new multiplayer match
        multiplayerManager.startMultiplayerMatch(
            inviteRecipients: multiplayerManager.getResultsRecipients()
        )
    }
    
    private func shareResults() {
        guard let battleResult = multiplayerManager.battleResult else { return }
        
        let messageManager = MessageManager.shared
        let recipients = multiplayerManager.getResultsRecipients()
        
        let (winner, winnerScore, loser, loserScore) = getResultDetails(battleResult)
        
        messageManager.shareResults(
            to: recipients,
            winner: winner,
            winnerScore: winnerScore,
            loser: loser,
            loserScore: loserScore,
            gameSettings: gameState.gameSettings
        ) { success in
            if success {
                print("Results shared successfully!")
            } else {
                print("Failed to share results")
            }
        }
    }
    
    private func getResultDetails(_ battleResult: BattleResult) -> (winner: String, winnerScore: Int, loser: String, loserScore: Int) {
        switch battleResult {
        case .won(let myScore, let opponentScore):
            return (gameState.playerName, myScore, multiplayerManager.opponentName, opponentScore)
        case .lost(let myScore, let opponentScore):
            return (multiplayerManager.opponentName, opponentScore, gameState.playerName, myScore)
        case .tie(let score):
            return (gameState.playerName, score, multiplayerManager.opponentName, score)
        }
    }
    
    private func endMultiplayerSession() {
        multiplayerManager.disconnect()
        multiplayerManager.showingBattleResults = false
        gameManager.goBack() // Return to main menu
    }
}

// MARK: - BubbleView
struct BubbleView: View {
    let bubble: Bubble
    let onTap: () -> Void
    
    var body: some View {
        Circle()
            .fill(bubble.color.color)
            .frame(width: bubble.size, height: bubble.size)
            .position(bubble.position)
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    MultiplayerGameView(
        gameState: GameState(
            gameSettings: GameSettings(),
            animationManager: AnimationManager(),
            soundManager: SoundManager(gameSettings: GameSettings())
        ),
        gameManager: GameManager(gameSettings: GameSettings()),
        multiplayerManager: MultiplayerManager.shared
    )
}