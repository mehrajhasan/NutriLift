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
    
    var body: some View {
        VStack{
            Text("NutriLift")
                .font(.largeTitle)
                .bold()
                .padding(.top,80)
            
            Spacer()
    
            
            TextField("Username", text: $username)
                .foregroundColor(.white)
                .frame(height:50)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                    .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                    
                )
                .padding(.horizontal, 50)

                
            SecureField("Password", text: $password)
                .foregroundColor(.white)
                .frame(height:50)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                    
                )
                .padding(.horizontal, 50)
                .padding(.top,30)
        }
        VStack{
            Spacer()
            Button(action: {
                //check user in database
            }){
                Text("Sign in")
                    .foregroundColor(.white)
                    .frame(height:40)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(hue: 0.55033,saturation: 0.9608,brightness: 1))
                        
                    )
            }
        }
        
        
        
    }
}

#Preview {
    loginView()
}
