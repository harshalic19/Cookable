//
//  SplashView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI

struct SplashView: View {
    @StateObject private var store = RecipeStore()
    @State private var isReady = false

    // Animation states
    @State private var appear = false
    @State private var subtitleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        Group {
            if isReady && !store.isLoading {
                ContentView()
                    .environmentObject(store)
            } else {
                ZStack {
                    // Dark background to match app theme
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 16) {
                        // splash logo image above the title
                        Image("splashLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300) // Adjust as needed
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .scaleEffect(appear ? 1.0 : 0.92)

                        // App name with simple scale/opacity animation
                        Text("Cookable")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .kerning(1.0)
                            .foregroundStyle(.white)
                            .scaleEffect(appear ? 1.0 : 0.92)
                            .opacity(appear ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.3), value: appear)

                        // Informational subtitle that slides in
                        Text("Discover delicious recipes, save favorites, and cook with confidence.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .offset(y: subtitleOffset)
                            .opacity(subtitleOpacity)
                            .animation(.easeOut(duration: 0.6).delay(0.25), value: subtitleOffset)
                            .animation(.easeOut(duration: 0.6).delay(0.25), value: subtitleOpacity)
                    }
                }
                .task {
                    // Trigger staged animations
                    appear = true
                    subtitleOffset = 0
                    subtitleOpacity = 1

                    // Keep splash visible briefly and allow initial fetch to start
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    isReady = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SplashView()
}
