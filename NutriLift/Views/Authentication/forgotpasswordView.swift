//
//  forgotpasswordView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/2/25.
//

import SwiftUI

struct forgotpasswordView: View {
    @State private var email: String = ""
    @State private var isEmailSent = false
    @Environment(\.dismiss) private var dismiss // Allows dismissing the screen

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Back button at the top left
                HStack {
                    Button(action: {
                        dismiss() // Go back to the previous screen
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 10)

                Text("NutriLift")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("Forgot Password")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("Enter your email address and we’ll send you a link to reset your password.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 30)

                Button(action: {
                    sendResetLink()
                }) {
                    Text("Send Reset Link")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
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

                // Navigation Link to LoginView
                NavigationLink(destination: loginView()) {
                    Text("Back to Login")
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                }
            }
            .padding(.top, 50)
        }
    }

    func sendResetLink() {
        isEmailSent = true
    }
}


// Custom text field
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

// did this so we can use the hex codes directly from figma
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
