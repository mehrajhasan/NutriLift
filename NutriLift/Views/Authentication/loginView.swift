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
            VStack{
                Text("NutriLift")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top,80)
                
                Spacer()
                
                TextField("Username", text: $username)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(height:50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                        
                    )
                    .padding(.horizontal, 50)
                    .padding(.bottom,-10)
                    .overlay(
                        Group{
                            if username.isEmpty {
                                Text("Username")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, -130)
                                    .padding(.bottom,-10)
                            }
                        }
                    )
                
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(height:50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                        
                    )
                    .padding(.horizontal, 50)
                    .overlay(
                        Group{
                            if password.isEmpty {
                                Text("Password")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, -130)
                                    .padding(.bottom,-3)
                            }
                        }
                    )
                    .padding(.top,30)
                    .padding(.bottom,-40)
                    .padding(.vertical,-10)
                
                
            }
            HStack{
                Spacer()
                NavigationLink{
                    forgotpasswordView()
                } label: {
                    Text("Forgot password?").underline()
                }
                .padding(.horizontal,50)
                .padding(.top,50)
                .foregroundColor(Color(hue: 0.6667, saturation: 1.0, brightness: 1.0))
                
            }
            VStack{
                Spacer()
                Button(action: {
                    login()
                    //check user in database
                    //just checking if flows correctly
                    print("Username: \(username)")
                    print("Password: \(password)")
                    print("\(message)")
                    
                    //navigateToHome = true //navigate to MacrosView after checking credentials
                }){
                    Text("Sign in")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                        .frame(height:40)
                        .padding(.horizontal, 110)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hue: 0.55033,saturation: 0.9608,brightness: 1))
                            
                        )
                        .padding(.vertical,75)
                }
                
                Text("New to NutriLift?")
                    .padding(.top,-65)
                    .foregroundColor(Color(hue: 0.6667, saturation: 1.0, brightness: 1.0))
                
                NavigationLink{
                    signupView()
                } label: {
                    Text("Sign up!")
                        .underline()
                }
                .padding(.top,-55)
                .foregroundColor(Color(hue: 0.6667, saturation: 1.0, brightness: 1.0))
            }
            
//                .navigationDestination(isPresented: $navigateToHome) {  //brings user to home page (macros page)
//                    MacrosView()
//                }
        }
    }
}

#Preview {
    loginView(onLoginSuccess: {})
}
