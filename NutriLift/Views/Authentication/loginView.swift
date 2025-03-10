//
//  loginView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/2/25.
//

import SwiftUI

struct loginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var navigateToHome = false // State to navigate to home (TaskBarView)

    var body: some View {
        NavigationStack {
            VStack {
                // App Title
                Text("NutriLift")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 80)

                Spacer()

                // Username Field
                TextField("Username", text: $username)
                    .padding()
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
                    .padding(.horizontal, 50)

                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
                    .padding(.horizontal, 50)
                    .padding(.top, 10)

                // Forgot Password Link
                HStack {
                    Spacer()
                    NavigationLink {
                        forgotpasswordView()
                    } label: {
                        Text("Forgot password?").underline()
                    }
                    .foregroundColor(.blue)
                    .padding(.trailing, 50)
                }
                .padding(.top, 10)

                Spacer()

                // Sign-in Button
                Button(action: {
                    print("Username: \(username)")
                    print("Password: \(password)")

                    // Navigate to home page (TaskBarView)
                    navigateToHome = true
                }) {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
                        .padding(.horizontal, 50)
                }
                .padding(.top, 30)

                // Sign-up Section
                VStack {
                    Text("New to NutriLift?")
                        .foregroundColor(.gray)

                    NavigationLink {
                        signupView()
                    } label: {
                        Text("Sign up!").underline()
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top, 15)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                TaskBarView() // Navigate to home page
            }
        }
    }
}


// Reusable InputField Component (Handles both TextField and SecureField)
struct InputField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 20)
            }
            if isSecure {
                SecureField("", text: $text)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
            } else {
                TextField("", text: $text)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
            }
        }
    }
}

#Preview {
    loginView()
}
