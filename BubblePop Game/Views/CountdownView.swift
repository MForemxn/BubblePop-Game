//
//  CountdownView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

/// View that displays a countdown animation before the game starts
struct CountdownView: View {
    /// Current time remaining in the countdown, bound to parent view
    @Binding var timeRemaining: Int
    
    var body: some View {
        ZStack {
            // Semi-transparent black background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack {
                // "Get Ready" text
                Text("Get Ready!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                // Countdown number with animation
                Text("\(timeRemaining)")
                    .font(.system(size: 100))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding()
                    .scaleEffect(timeRemaining == 3 ? 0.5 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5), value: timeRemaining)
            }
        }
    }
}
