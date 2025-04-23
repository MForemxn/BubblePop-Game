# BubblePop Game

A colorful and engaging bubble-popping game developed as a university project for iOS, built with SwiftUI.

## Game Description

BubblePop is an arcade-style game where players tap colorful bubbles as they float across the screen. The game features different bubble colors with varying point values, combo bonuses for consecutive same-color pops, and increasing difficulty as time progresses.

## Features

- **Colorful Bubbles**: Five different bubble colors (red, pink, green, blue, black) with different point values and rarity
- **Dynamic Gameplay**: Bubbles move at various speeds and bounce off screen edges
- **Combo System**: Earn bonus points for popping consecutive bubbles of the same color
- **Increasing Difficulty**: Bubble speed increases as the game timer counts down
- **Game Settings**: Customize game duration, maximum bubble count, and bubble speed
- **Leaderboards**: Track high scores locally and integrate with Game Center
- **Sound Effects**: Optional sound effects and background music
- **Animations**: Visual feedback for popped bubbles and score updates

## How to Play

1. Enter your name on the start screen
2. Tap the "Start Game" button
3. After a brief countdown, bubbles will appear on screen
4. Tap bubbles to pop them and earn points
5. Try to pop same-colored bubbles consecutively for combo bonuses
6. Game ends when the timer reaches zero
7. View your score and see if you made it to the leaderboard

## Scoring System

- **Red Bubbles**: 1 point (40% chance of appearing)
- **Pink Bubbles**: 2 points (30% chance of appearing)
- **Green Bubbles**: 5 points (15% chance of appearing)
- **Blue Bubbles**: 8 points (10% chance of appearing)
- **Black Bubbles**: 10 points (5% chance of appearing)
- **Combo Bonus**: 1.5x multiplier for consecutive same-color pops

## Game Settings

- **Game Duration**: Time limit for each game
- **Maximum Bubbles**: Controls how many bubbles can appear on screen at once
- **Bubble Speed**: Choose between slow, medium, and fast bubble movement
- **Sound Effects**: Toggle on/off
- **Background Music**: Toggle on/off

## Technology

- Built with SwiftUI for iOS
- Uses GameKit for Game Center integration
- Local score persistence using UserDefaults
- Animation framework for visual effects
- Sound manager for audio feedback

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone or download the repository
2. Open `BubblePop Game.xcodeproj` in Xcode
3. Build and run on your device or simulator

## Future Improvements

- Additional bubble types with special effects
- Power-ups and gameplay modifiers
- Multiplayer mode
- More advanced physics and bubble interactions
- Additional visual themes

## Author

Created by Mason Foreman as a university project for Application Development in the iOS Environment. 