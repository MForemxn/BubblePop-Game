//
//  CountdownView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct CountdownView: View {
    @Binding var timeRemaining: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack {
                Text("Get Ready!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
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
