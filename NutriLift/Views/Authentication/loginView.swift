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
    @State private var navigateToHome = false //state to control navigation for home page (macros page)
    
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
                    //check user in database
                    //just checking if flows correctly
                    print("Username: \(username)")
                    print("Password: \(password)")
                    
                    navigateToHome = true //navigate to MacrosView after checking credentials
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
            
            .navigationDestination(isPresented: $navigateToHome) {  //brings user to home page (macros page)
                MacrosView()
            }
        }
    }
}

#Preview {
    loginView()
}
