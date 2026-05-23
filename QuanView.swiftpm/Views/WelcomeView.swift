import Foundation
import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var pulse = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.02), Color(red: 0.02, green: 0.09, blue: 0.1), Color(white: 0.025)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 36) {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                        .frame(width: pulse ? 250 : 100)
                        .opacity(pulse ? 0 : 1)
                    
                    Image(systemName: "atom")
                        .font(.system(size: 80, weight: .ultraLight))
                        .foregroundStyle(.cyan)
                        .shadow(color: .cyan.opacity(0.8), radius: 15)
                }
                
                VStack(spacing: 14) {
                    Text("QuanView")
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .tracking(8)
                        .foregroundStyle(.white)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                    
                    Text("A tactile AR lab for quantum mechanics")
                        .font(.system(.title3, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .foregroundStyle(.gray)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                    
                    HStack(spacing: 8) {
                        WelcomePill(title: "Scan")
                        WelcomePill(title: "Simulate")
                        WelcomePill(title: "Log")
                    }
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
                }
                
                Spacer()
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.8)) { isPresented = false }
                }) {
                    Text("INITIALIZE EXPERIMENT")
                        .font(.system(.headline, design: .monospaced).bold())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .cyan.opacity(0.5), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .opacity(showText ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 3).repeatForever(autoreverses: false)) { pulse = true }
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) { showText = true }
        }
    }
}

struct WelcomePill: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.76))
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
