//
//  SoundManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    private var isEnabled: Bool = true
    
    private init() {
        // Set up audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func toggleSound(enabled: Bool) {
        isEnabled = enabled
    }
    
    func playSound(named filename: String, fileExtension: String = "wav") {
        guard isEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Sound file \(filename).\(fileExtension) not found")
            return
        }
        
        if let player = audioPlayers[url] {
            player.currentTime = 0
            player.play()
        } else {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                audioPlayers[url] = player
                player.play()
            } catch {
                print("Failed to play sound: \(error)")
            }
        }
    }
    
    func playSoundForBubble(_ color: BubbleColor) {
        switch color {
        case .red:
            playSound(named: "pop_red")
        case .pink:
            playSound(named: "pop_pink")
        case .green:
            playSound(named: "pop_green")
        case .blue:
            playSound(named: "pop_blue")
        case .black:
            playSound(named: "pop_black")
        }
    }
}
