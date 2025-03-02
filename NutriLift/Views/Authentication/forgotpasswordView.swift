//
//  ForgotPasswordView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/2/25.
//

import SwiftUI

struct forgotpasswordView: View {
    @State private var email: String = ""
    @State private var isEmailSent = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // Background color
            
            VStack(spacing: 20) {
                Text("NutriLift")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 50)
                
                Text("Forgot your password?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                
                Text("Enter your email address and we’ll send you a link to reset your password.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                CustomTextField(placeholder: "Email", text: $email)
                    .padding(.horizontal, 30)

                Button(action: {
                    sendResetLink()
                }) {
                    Text("Send Reset Link")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "0AB5FF"))
                        .cornerRadius(10)
                        .shadow(color: Color(hex: "0AB5FF").opacity(0.5), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 30)
                }
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.5 : 1.0)
                
                if isEmailSent {
                    Text("A reset link has been sent to your email.")
                        .foregroundColor(.green)
                        .font(.body)
                }
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Login")
                        .foregroundColor(Color(hex: "0AB5FF"))
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 50)
        }
    }
    
    func sendResetLink() {
        // Simulate email reset link action
        isEmailSent = true
    }
}

// Custom text field with a modern design
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.gray)
                .padding(.leading, 10)

            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "0AB5FF"), lineWidth: 1))
        .background(Color(hex: "2B2B2B"))
        .cornerRadius(10)
    }
}

// Color extension to support hex codes
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    forgotpasswordView()
}
