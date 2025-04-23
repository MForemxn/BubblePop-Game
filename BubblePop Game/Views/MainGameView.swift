//
//  MainGameView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

/// Main view that displays the game screen where bubbles appear and can be popped
struct MainGameView: View {
    // MARK: - Properties
    
    /// Game state containing all game data (score, bubbles, time, etc.)
    @ObservedObject var gameState: GameState
    
    /// Controls whether to show the countdown before game starts
    @State private var showCountdown = true
    
    /// Seconds remaining in the countdown (starts at 3)
    @State private var timeRemaining = 3
    
    /// Controls whether to show the game over popup
    @State private var gameOverPopup = false
    
    /// Timer used for the initial countdown
    @State private var countdownTimer: Timer?
    
    /// Manager that handles game logic and updates
    @ObservedObject var gameManager: GameManager
    
    /// Timer that fires every second to update the game state
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                // Background color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Game elements - only show when countdown is finished and game is running
                if !showCountdown && gameState.gameRunning {
                    // Adapt layout based on orientation
                    if isLandscape {
                        landscapeGameLayout(geometry: geometry)
                    } else {
                        portraitGameLayout(geometry: geometry)
                    }
                }
                
                // Countdown overlay - blocks all game interaction until countdown finishes
                if showCountdown {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                    
                    CountdownView(timeRemaining: $timeRemaining)
                }
                
                // Game over popup that appears when time runs out
                if gameOverPopup {
                    gameOverView
                }
            }
            .onAppear {
                // Update screen size in game state when view appears
                gameManager.gameState.updateScreenSize(geometry.size)
                
                // Start countdown if game is not already running
                if !gameState.gameRunning {
                    startCountdown()
                }
            }
            .onDisappear {
                // Clean up timers and end game when view disappears
                countdownTimer?.invalidate()
                countdownTimer = nil
                gameManager.endGame()
            }
            .onReceive(gameTimer) { _ in
                // Update game state every second when game is running
                if !showCountdown && gameState.gameRunning {
                    gameManager.updateGame()
                }
                
                // End game if time runs out
                if gameState.timeRemaining <= 0 && !gameOverPopup && !showCountdown {
                    gameEnd()
                }
            }
        }
    }
    
    // MARK: - Layout Components
    
    /// Portrait layout for the game
    private func portraitGameLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Game information header (player name, score, time)
            gameInfoHeader
                .padding([.horizontal, .top])
            
            // Main game area
            ZStack {
                gameBubbles
                scorePopups
                bubblePopAnimations
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// Landscape layout for the game
    private func landscapeGameLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Game information side panel
            VStack {
                gameInfoHeader
                    .padding()
                    .frame(width: geometry.size.width * 0.25)
            }
            .frame(width: geometry.size.width * 0.25)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground).opacity(0.8))
                    .padding(5)
            )
            
            // Main game area
            ZStack {
                gameBubbles
                scorePopups
                bubblePopAnimations
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// Header view showing player info, score and time
    private var gameInfoHeader: some View {
        VStack(spacing: 10) {
            // Player information
            HStack {
                VStack(alignment: .leading) {
                    Text("Player: \(gameState.playerName)")
                        .font(.headline)
                    Text("Highest Score: \(gameState.highestScore)")
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Score and time information
                VStack(alignment: .trailing) {
                    Text("Score: \(gameState.currentScore)")
                        .font(.headline)
                    Text("Time: \(gameState.timeRemaining)")
                        .font(.subheadline)
                        .foregroundColor(gameState.timeRemaining <= 10 ? .red : .primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    /// Displays all active bubbles
    private var gameBubbles: some View {
        ForEach(gameState.bubbles) { bubble in
            BubbleView(bubble: bubble)
                .position(bubble.position)
                .onTapGesture {
                    // Pop the bubble when tapped
                    gameManager.popBubble(bubble)
                }
        }
    }
    
    /// Displays score popup animations
    private var scorePopups: some View {
        ForEach(gameState.animationManager.scorePopups) { popup in
            Text(popup.text)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(popup.color)
                .position(popup.position)
                .opacity(popup.opacity)
                .scaleEffect(popup.scale)
        }
    }
    
    /// Displays bubble pop animations
    private var bubblePopAnimations: some View {
        ForEach(gameState.animationManager.bubblePopAnimations) { anim in
            Circle()
                .fill(anim.color)
                .frame(width: anim.size, height: anim.size)
                .position(anim.position)
                .opacity(anim.opacity)
                .scaleEffect(anim.scale)
        }
    }
    
    /// Game over popup view
    private var gameOverView: some View {
        VStack {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Your score: \(gameState.currentScore)")
                .font(.title2)
                .padding()
            
            Button(action: {
                gameOverPopup = false
                gameManager.showHighScores()
            }) {
                Text("View High Scores")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .frame(width: 300, height: 250)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    // MARK: - Methods
    
    /// Starts the countdown before the game begins
    func startCountdown() {
        showCountdown = true
        timeRemaining = 3
        
        // Invalidate any existing timer
        countdownTimer?.invalidate()
        
        // Create a new timer on the main thread
        DispatchQueue.main.async {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.timeRemaining > 1 {
                    self.timeRemaining -= 1
                } else {
                    timer.invalidate()
                    self.countdownTimer = nil
                    self.showCountdown = false
                    
                    // Start the actual game after countdown
                    DispatchQueue.main.async {
                        self.gameManager.beginActualGame()
                    }
                }
            }
            
            // Ensure timer fires by adding to main run loop
            RunLoop.main.add(self.countdownTimer!, forMode: .common)
        }
    }
    
    /// Handles end of game logic
    func gameEnd() {
        gameManager.endGame()
        gameState.gameRunning = false
        gameOverPopup = true
    }
}

/// View for an individual bubble
struct BubbleView: View {
    /// The bubble data to display
    let bubble: Bubble
    
    var body: some View {
        Circle()
            .fill(bubble.color.color)
            .frame(width: bubble.size, height: bubble.size)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
}
