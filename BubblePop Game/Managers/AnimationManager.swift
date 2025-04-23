//
//  AnimationManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

// MARK: - Animation Data Models
struct ScorePopup: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let position: CGPoint
    var opacity: Double // Made mutable for animation
    var scale: Double   // Made mutable for animation
}

struct BubblePopAnimation: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let position: CGPoint
    var opacity: Double // Made mutable for animation
    var scale: Double   // Made mutable for animation
}

// MARK: - Animation Manager
class AnimationManager: ObservableObject {
    @Published var scorePopups: [ScorePopup] = []
    @Published var bubblePopAnimations: [BubblePopAnimation] = []

    func showScorePopup(text: String, position: CGPoint, color: Color) {
        // Create a new score popup
        let popup = ScorePopup(
            text: text,
            color: color,
            position: position,
            opacity: 1.0,
            scale: 1.0
        )
        scorePopups.append(popup)

        // Animate the popup (fade out and scale up)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = self.scorePopups.firstIndex(where: { $0.id == popup.id }) {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.scorePopups[index].opacity = 0.0
                    self.scorePopups[index].scale = 1.5
                }
            }
        }

        // Remove the popup after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.scorePopups.removeAll { $0.id == popup.id }
        }
    }

    func animateBubblePop(at position: CGPoint, color: Color, size: CGFloat) {
        // Create a new bubble pop animation
        let anim = BubblePopAnimation(
            color: color,
            size: size,
            position: position,
            opacity: 1.0,
            scale: 1.0
        )
        bubblePopAnimations.append(anim)

        // Animate the pop effect (fade out and scale up slightly)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = self.bubblePopAnimations.firstIndex(where: { $0.id == anim.id }) {
                withAnimation(.easeOut(duration: 0.5)) {
                    self.bubblePopAnimations[index].opacity = 0.0
                    self.bubblePopAnimations[index].scale = 1.2
                }
            }
        }

        // Remove the animation after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.bubblePopAnimations.removeAll { $0.id == anim.id }
        }
    }

    func updateAnimations() {
        // Optional: Add any additional cleanup or updates if needed
    }
}

// MARK: - Optional View Modifiers (Retained for Future Use)
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
    func scorePopEffect(score: Int) -> some View {
        self.modifier(ScoreAnimation(score: score))
    }
    
    func countdownEffect() -> some View {
        self.modifier(CountdownAnimation())
    }
}
