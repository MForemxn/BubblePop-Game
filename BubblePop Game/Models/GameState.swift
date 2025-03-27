//
//  GameState.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import Foundation
import SwiftUI

struct GameState {
    let totalTime: Int         // Total game duration (e.g., 60 seconds); immutable constant for a game run
    var currentTime: Int       // Countdown timer that updates every second
    var currentScore: Int      // Player's current score; updated as bubbles are popped
    var bubbles: [Bubble]      // Current active bubbles on the screen
}
