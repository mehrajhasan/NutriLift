import SwiftUI

struct loginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var loginSuccess: Bool = false
    @State private var navigateToHome: Bool = false
    
    // for signoutvtaskbar login
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    
    var onLoginSuccess: () -> Void
    
    func login() {
        guard let url = URL(string: "http://localhost:3000/login") else {
            print("Invalid URL.")
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
            print("Error encoding JSON.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Login request failed:", error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print(" Server Response Code:", httpResponse.statusCode)
            }

            if let data = data {
                var rawResponse = String(data: data, encoding: .utf8) ?? "No response"
                print(" Raw Server Response:", rawResponse) // Log the response before decoding
                
                if(rawResponse == "{\"error\":\"Incorrect password\"}"){
                    rawResponse = "Incorrect password"
                }
                else if(rawResponse == "{\"error\":\"User not found\"}"){
                    rawResponse = "User not found"
                }

                do {
                     let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                     if let token = json?["token"] as? String {

                         UserDefaults.standard.set(token, forKey: "userToken")

                         if let userId = json?["user_id"] as? Int {
                             UserDefaults.standard.set(userId, forKey: "userId")
                         }
                         
                         self.isLoggedIn = true
                         print("Login successful.")
                         self.onLoginSuccess()
                    } else {
                        self.message = rawResponse
                    }
                } catch {
                    print("Error decoding login response:", error)
                }
            }
        }.resume()
    }

        
        func fetchProtected(){
            guard let url = URL(string: "http://localhost:3000/protected") else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            if let token = UserDefaults.standard.string(forKey: "userToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
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
                    if(!message.isEmpty){
                        Text(message)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 50)
                    }
                    Button(action: {
                        login()
                        //check user in database
                        //just checking if flows correctly
                        print("Username: \(username)")
                        print("Password: \(password)")
                        print("\(message)")
                        
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
                    //if login was successful, send to macros page aka homepage
                    .navigationDestination(isPresented: $loginSuccess) {
                        MacrosView()
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
            }
        }
    }

    #Preview {
        loginView(onLoginSuccess: {})
    }
