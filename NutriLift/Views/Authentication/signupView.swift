import SwiftUI

struct SignupTextField: View {
    var placeholder: String
    @Binding var text: String
    var isError: Bool
    var onCommit: (() -> Void)? = nil

    var body: some View {
        TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.gray))
            .padding()
            .background(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
            .foregroundColor(.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                
                    .stroke(isError ? Color.red : Color(hue: 0.0, saturation: 0.0, brightness: 0.1686), lineWidth: 2)
                    
            )
            .frame(height: 50)
            .padding(.horizontal, 5)
            .onChange(of: text) { _ in
                onCommit?()
                
            }
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
    
    // Field errors
    @State private var firstNameError = false
    @State private var lastNameError = false
    @State private var emailError = false
    @State private var usernameError = false
    @State private var passwordError = false
    @State private var confirmPasswordError = false
    
    // Real-time validation state
    @State private var emailAvailable = true
    @State private var usernameAvailable = true
    @State private var passwordsMatch = true
    @State private var usernameDebounceTimer: Timer?


    var isFormValid: Bool {
        return !anyFieldEmpty() && emailAvailable && usernameAvailable && passwordsMatch
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            VStack(spacing: 15) {
                SignupTextField(placeholder: "First Name", text: $firstName, isError: firstNameError)
                SignupTextField(placeholder: "Last Name", text: $lastName, isError: lastNameError)
                
                SignupTextField(placeholder: "Create a Username", text: $username, isError: !usernameAvailable) {
                    checkFieldAvailability(field: "username", value: username)
                }
                if !usernameAvailable {
                    Text("Username is already taken").foregroundColor(.red).font(.caption)
                }

                SignupTextField(placeholder: "Email", text: $email, isError: !emailAvailable) {
                    checkFieldAvailability(field: "email", value: email)
                }
                if !emailAvailable {
                    Text("Email is already taken").foregroundColor(.red).font(.caption)
                }


                VStack(alignment: .leading) {
                    SignupTextField(placeholder: "Create a Password", text: $password, isError: passwordError) {
                        validatePasswords()
                    }
                }

                VStack(alignment: .leading) {
                    SignupTextField(placeholder: "Confirm Password", text: $confirmPassword, isError: !passwordsMatch) {
                        validatePasswords()
                    }
                    if !passwordsMatch {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .center)

                    }
                }
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
                    .background(isFormValid ? Color.blue : Color.gray) // Change color based on validity
                    .cornerRadius(15)
                    .opacity(isFormValid ? 1.0 : 0.5) // Fade button if invalid
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .disabled(!isFormValid) // Disable button if form is invalid

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
            "password": password,
            "confirmPassword": confirmPassword
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: user) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode JSON."
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server."
                }
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                    DispatchQueue.main.async {
                        if httpResponse.statusCode == 201 {
                            self.errorMessage = "Signup Successful!"
                            self.resetFieldErrors()
                        } else if let errorMsg = json?["error"] as? String, let field = json?["field"] as? String {
                            self.errorMessage = errorMsg
                            self.updateFieldErrors(for: field)
                        } else {
                            self.errorMessage = "Unexpected error occurred."
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse server response."
                    }
                }
            }
        }.resume()
    }

    func checkFieldAvailability(field: String, value: String) {
        guard !value.isEmpty else { return }

        let urlString = "http://localhost:3000/check-\(field)?value=\(value)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                return
            }

            guard let data = data else { return }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool] {
                DispatchQueue.main.async {
                    if field == "email" {
                        self.emailAvailable = jsonResponse["available"] ?? false
                    } else if field == "username" {
                        self.usernameAvailable = jsonResponse["available"] ?? false
                    }
                }
            }
        }.resume()
    }


    func validatePasswords() {
        passwordsMatch = password == confirmPassword && !password.isEmpty
    }

    func updateFieldErrors(for field: String) {
        self.resetFieldErrors()
        switch field {
        case "firstName": self.firstNameError = true
        case "lastName": self.lastNameError = true
        case "email": self.emailError = true
        case "username": self.usernameError = true
        case "password": self.passwordError = true
        case "confirmPassword": self.confirmPasswordError = true
        default: break
        }
    }

    func resetFieldErrors() {
        firstNameError = false
        lastNameError = false
        emailError = false
        usernameError = false
        passwordError = false
        confirmPasswordError = false
    }

    func anyFieldEmpty() -> Bool {
        return firstName.isEmpty || lastName.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty
    }
    
    func checkUsernameAvailability() {
        //Link to website: https://tarkalabs.com/blogs/debounce-in-swift/
        // Cancel any previous timer to debounce the requests
        usernameDebounceTimer?.invalidate()
        
        // Set a new timer to delay the API call
        usernameDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            guard !username.isEmpty else {
                self.usernameAvailable = true
                return
            }

            let urlString = "http://localhost:3000/check-username?value=\(username)"
            guard let url = URL(string: urlString) else { return }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let _ = error {
                    return
                }

                guard let data = data else { return }

                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool] {
                    DispatchQueue.main.async {
                        self.usernameAvailable = jsonResponse["available"] ?? false
                    }
                }
            }.resume()
        }
    }

}

#Preview {
    NavigationStack {
        signupView()
    }
}
