import SwiftUI

struct loginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var loginSuccess: Bool = false
    
    var onLoginSuccess: () -> Void // Callback function to update login state in ContentView
    
    func login() {
        guard let url = URL(string: "http://localhost:3000/login") else {
            print("An error occurred.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let input: [String: String] = [
            "username": username,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: input)
        } catch {
            print("An error occurred.")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.message = "Failed to connect to the server: \(error.localizedDescription)"
                return
            }
             
            guard let httpResponse = response as? HTTPURLResponse else {
                self.message = "An error occured."
                return
            }
            
            if httpResponse.statusCode == 200 {
                self.loginSuccess = true
                self.message = "Login successful."
                self.onLoginSuccess() // Notify ContentView to switch to TaskBarView
            } else if httpResponse.statusCode == 400 {
                self.message = "Incorrect password."
            } else if httpResponse.statusCode == 404 {
                self.message = "User not found."
            } else {
                self.message = "An error occurred. Please try again later."
            }
        }.resume()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("NutriLift")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 80)

                Spacer()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 50)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 50)
                    .padding(.top, 10)

                // Error Message Display
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                Spacer()

                // Sign-in Button
                Button(action: {
                    login()
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
        }
    }
}

#Preview {
    loginView(onLoginSuccess: {})
}
