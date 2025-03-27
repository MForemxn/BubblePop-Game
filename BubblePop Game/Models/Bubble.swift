//
//  Bubble.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI

enum BubbleColor: String, CaseIterable {
    case red, pink, green, blue, black
}

struct Bubble: Identifiable {
    let id: UUID = UUID()          // Unique identifier for each bubble
    let color: BubbleColor         // Bubble color from our predefined list
    let pointValue: Int            // Points awarded when popped
    let position: CGPoint          // Position on the screen (immutable once generated)
    let comboState: Int            // Represents combo sequence state; consider using a new instance to update combo
}
