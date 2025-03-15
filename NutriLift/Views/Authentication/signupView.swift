//
//  signupView.swift
//  NutriLift
//
//  Created by Mohammad Hossain on 3/2/25.
//

import SwiftUI

struct SignupTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.gray))
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(25)
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))
            .frame(height: 50)
            .padding(.horizontal, 5)
    }
}

struct signupView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Spacer()
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            VStack(spacing: 15) {
                SignupTextField(placeholder: "First Name", text: $firstName)
                SignupTextField(placeholder: "Last Name", text: $lastName)
                SignupTextField(placeholder: "Email", text: $email)
                SignupTextField(placeholder: "Create a Username", text: $username)
                SignupTextField(placeholder: "Create a Password", text: $password)
                SignupTextField(placeholder: "Confirm Password", text: $confirmPassword)
            }
            .padding(.horizontal, 25)

            Button(action: {
                signUpUser()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    func signUpUser() {
        guard let url = URL(string: "http://localhost:3000/signup") else { return }

        let user = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "username": username,
            "password": password
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: user)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            DispatchQueue.main.async {
                self.errorMessage = "Signup Successful!"
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        signupView()
    }
}
