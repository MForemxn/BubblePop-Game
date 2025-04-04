//
//  MainGameView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct MainGameView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var gameManager: GameManager
    @State private var showCountdown = true
    @State private var timeRemaining = 3
    @State private var gameOverPopup = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            // Game information at the top
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Player: \(gameState.player.name)")
                            .font(.headline)
                        Text("Highest Score: \(gameState.highestScore)")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Score: \(gameState.score)")
                            .font(.headline)
                        Text("Time: \(gameState.timeRemaining)")
                            .font(.subheadline)
                            .foregroundColor(gameState.timeRemaining <= 10 ? .red : .primary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding([.horizontal, .top])
                
                Spacer()
            }
            
            // Bubbles
            ForEach(gameState.bubbles) { bubble in
                BubbleView(bubble: bubble)
                    .position(bubble.position)
                    .onTapGesture {
                        gameManager.popBubble(bubble)
                        gameState.soundManager.playPopSound()
                        gameState.animationManager.animateBubblePop(
                            at: bubble.position,
                            color: bubble.color.color, // Pass the bubble's color
                            size: bubble.size          // Pass the bubble's size
                        )
                    }
            }
            
            // Score popup animations
            ForEach(gameState.animationManager.scorePopups) { popup in
                Text(popup.text)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(popup.color)
                    .position(popup.position)
                    .opacity(popup.opacity)
                    .scaleEffect(popup.scale)
            }
            
            // Bubble pop animations
            ForEach(gameState.animationManager.bubblePopAnimations) { anim in
                Circle()
                    .fill(anim.color)
                    .frame(width: anim.size, height: anim.size)
                    .position(anim.position)
                    .opacity(anim.opacity)
                    .scaleEffect(anim.scale)
            }
            
            // Countdown overlay
            if showCountdown {
                CountdownView(timeRemaining: $timeRemaining)
            }
            
            // Game over popup
            if gameOverPopup {
                VStack {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Your score: \(gameState.score)")
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
        }
        .onAppear {
            // Start countdown
            startCountdown()
        }
        .onReceive(timer) { _ in
            if !showCountdown && gameState.gameRunning {
                gameManager.updateGame()
            }
            
            if gameState.timeRemaining <= 0 && !gameOverPopup && !showCountdown {
                gameEnd()
            }
        }
    }
    
    func startCountdown() {
        showCountdown = true
        timeRemaining = 3
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { countdownTimer in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                countdownTimer.invalidate()
                showCountdown = false
                gameManager.startGame()
            }
        }
    }
    
    func gameEnd() {
        gameState.gameRunning = false
        gameManager.endGame()
        gameOverPopup = true
    }
}

struct BubbleView: View {
    let bubble: Bubble
    
    var body: some View {
        Circle()
            .fill(bubble.color.color)
            .frame(width: bubble.size, height: bubble.size)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
}
