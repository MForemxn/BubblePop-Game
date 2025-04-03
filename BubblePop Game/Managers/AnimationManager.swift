//
//  AnimationManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct BubblePopAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.5 : 1.0)
            .opacity(isAnimating ? 0 : 1)
            .animation(.easeOut(duration: 0.2), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct ScoreAnimation: ViewModifier {
    let score: Int
    @State private var offset: CGFloat = -50
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Text("+\(score)")
                .font(.title)
                .bold()
                .foregroundColor(.yellow)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
                .offset(y: offset)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.7)) {
                        offset = -100
                        opacity = 0
                    }
                }
        }
    }
}

struct CountdownAnimation: ViewModifier {
    @State private var scale: CGFloat = 2.0
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    scale = 1.0
                    opacity = 0.0
                }
            }
    }
}

extension View {
    func bubblePopEffect() -> some View {
        self.modifier(BubblePopAnimation())
    }
    
    func scorePopEffect(score: Int) -> some View {
        self.modifier(ScoreAnimation(score: score))
    }
    
    func countdownEffect() -> some View {
        self.modifier(CountdownAnimation())
    }
}
