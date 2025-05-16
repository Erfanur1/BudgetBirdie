import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // For handling onboarding completion
    var onContinue: () -> Void
    
    // Main blue color matching the app icon
    private let budgetBirdieBlue = Color(red: 0.25, green: 0.65, blue: 0.95)
    private let budgetBirdieLight = Color(red: 0.88, green: 0.95, blue: 1.0)
    
    // Animation properties
    @State private var slideOffset: CGFloat = 1000
    
    var body: some View {
        if isActive {
            ContentView()
                .transition(.move(edge: .trailing))
                .zIndex(0)
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [budgetBirdieLight, .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App icon and name
                    VStack(spacing: 20) {
                        // Using your app icon from Assets.xcassets
                        // 1. Make sure to add your icon image to Assets.xcassets with name "AppLogo"
                        Image("BirdLogo")  // ← Change this name to match what you named your icon in Assets
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(budgetBirdieBlue, lineWidth: 4)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(budgetBirdieBlue)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.0
                        }
                    }
                    
                    // Welcome message
                    VStack(spacing: 20) {
                        Text("Welcome to your")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("BudgetBirdie")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(budgetBirdieBlue)
                        
                        Text("Take Flight With Your Finances!")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .foregroundColor(.secondary)
                    }
                    .opacity(opacity)
                    .offset(y: opacity == 1 ? 0 : 20)
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            isActive = true
                            onContinue() // Call the completion handler
                        }
                    }) {
                        Text("Let's Go!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(budgetBirdieBlue)
                            )
                            .padding(.horizontal, 50)
                    }
                    .padding(.bottom, 50)
                    .opacity(opacity)
                    .offset(y: opacity == 1 ? 0 : 20)
                }
                .zIndex(1)
                
                // The content view is positioned behind the main tab, ready to slide in
                ContentView()
                    .offset(x: slideOffset)
                    .zIndex(0)
                    .opacity(isActive ? 1 : 0)
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    // Simulate iPhone unlock-like animation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        slideOffset = 0
                    }
                }
            }
        }
    }
}

// Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(onContinue: {})
    }
}
