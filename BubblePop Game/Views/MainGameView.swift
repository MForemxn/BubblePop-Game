//
//  MainGameView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI
import Combine

struct MainGameView: View {
    @ObservedObject var gameState: GameState
    @EnvironmentObject var settings: GameSettings
    @State private var displaySize: CGSize = .zero
    @State private var showCountdown = true
    @State private var countdownValue = 3
    @State private var displayedPopScore: (id: UUID, score: Int, position: CGPoint)? = nil
    @State private var lastUpdateTime: Date? = nil
    @State private var displayTimer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    let bubbleSize: CGFloat = 60
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game area
                Color.clear
                
                // Bubbles
                ForEach(Array(gameState.bubbles.enumerated()), id: \.element.id) { index, bubble in
                    BubbleView(bubble: bubble, size: bubbleSize) {
                        // Play sound
                        SoundManager.shared.playSoundForBubble(bubble.color)
                        
                        // Show score animation
                        let points = gameState.consecutiveSameColorPops > 0 && gameState.lastPoppedColor == bubble.color ?
                            Int(Double(bubble.pointValue) * gameState.comboMultiplier) :
                            bubble.pointValue
                        displayedPopScore = (id: UUID(), score: points, position: bubble.position)
                        
                        // Pop the bubble
                        gameState.popBubble(at: index)
                    }
                }
                
                // Score animation overlay
                if let popScore = displayedPopScore {
                    Text("+\(popScore.score)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 1)
                        .position(popScore.position)
                        .transition(.scale)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                if displayedPopScore?.id == popScore.id {
                                    displayedPopScore = nil
                                }
                            }
                        }
                        .animation(.easeOut(duration: 0.7), value: displayedPopScore != nil)
                }
                
                // Game info overlay
                VStack {
                    HStack {
                        // Time
                        HStack {
                            Image(systemName: "clock")
                            Text("\(gameState.timeRemaining)")
                                .fontWeight(.bold)
                        }
                        .padding(8)
                        .background(Capsule().fill(Color.black.opacity(0.7)))
