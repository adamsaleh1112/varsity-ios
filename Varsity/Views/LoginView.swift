import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false
    @State private var showErrorAlert = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                // Subtle pink/blue gradient at top (matching home screen)
                VStack {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.blue.opacity(0.2), location: 0.0),
                            .init(color: Color.pink.opacity(0.2), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 180)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Spacer()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo
                    Image("VarsityLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(.bottom, 40)
                    
                    // Login Fields
                    VStack(spacing: 16) {
                        // Username Field
                        TextField("", text: $username, prompt: Text("Username").foregroundColor(.gray.opacity(0.6)))
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "28282B"), lineWidth: 1)
                            )
                            .frame(height: 50)
                        
                        // Email Field (only for sign up) - with smooth animation
                        if isSignUpMode {
                            TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray.opacity(0.6)))
                                .padding()
                                .background(Color.clear)
                                .foregroundColor(.white)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "28282B"), lineWidth: 1)
                                )
                                .frame(height: 50)
                                .opacity(isSignUpMode ? 1 : 0)
                                .scaleEffect(isSignUpMode ? 1 : 0.8)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.3)),
                                    removal: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.2))
                                ))
                        }
                        
                        // Password Field with Toggle
                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("", text: $password, prompt: Text("Password").foregroundColor(.gray.opacity(0.6)))
                                    .padding()
                                    .padding(.trailing, 30)
                            } else {
                                SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray.opacity(0.6)))
                                    .padding()
                                    .padding(.trailing, 30)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 12)
                        }
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "28282B"), lineWidth: 1)
                        )
                        .frame(height: 50)
                        
                        // Forgot Password Button (only in sign in mode)
                        if !isSignUpMode {
                            Button(action: {
                                // Handle forgot password
                            }) {
                                Text("Forgot Password?")
                                    .foregroundColor(Color(hex: "6e27e8"))
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        // Sign In/Sign Up Button
                        Button(action: {
                            Task {
                                if isSignUpMode {
                                    await authManager.signUpWithUsername(username: username, email: email, password: password)
                                } else {
                                    await authManager.signInWithUsername(username: username, password: password)
                                }
                            }
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isSignUpMode ? "Sign Up" : "Sign In")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "6e27e8"))
                            .cornerRadius(20)
                        }
                        .disabled(authManager.isLoading)
                        
                        // Toggle Sign In/Sign Up Mode
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSignUpMode.toggle()
                            }
                            authManager.errorMessage = nil
                            // Clear fields when switching modes
                            username = ""
                            email = ""
                            password = ""
                        }) {
                            Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 40)
                    .animation(.easeInOut(duration: 0.3), value: isSignUpMode)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("or")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 40)
                    
                    // Sign In Buttons
                    VStack(spacing: 12) {
                        // Sign in with Apple
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                Task {
                                    await authManager.signInWithApple()
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(20)
                        
                        // Coming Soon: Google Sign In
                        Button(action: {
                            // Google sign in coming soon
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.gray)
                                Text("Google Sign-In Coming Soon")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "28282B"))
                            .cornerRadius(20)
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By signing in, you agree to our")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") {
                                // Handle terms
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            
                            Button("Privacy Policy") {
                                // Handle privacy
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Authentication Error", isPresented: $showErrorAlert) {
            Button("OK") {
                authManager.errorMessage = nil
                showErrorAlert = false
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
        .onChange(of: authManager.errorMessage) {
            if authManager.errorMessage != nil {
                showErrorAlert = true
            }
        }
    }
}


#Preview {
    LoginView()
}
