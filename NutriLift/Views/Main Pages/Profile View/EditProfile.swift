//
//  EditProfile.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/13/25.
//

import SwiftUI


struct EditProfile: View {
    @State private var username: String = "johndoe"
    @State private var first_name: String = "John"
    @State private var last_name: String = "Doe"
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 30) {
                    HStack {
                        Spacer()
                        
                        Text("Edit Profile")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Circle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 1.0))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(25)
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.6))
                        )
                    
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextField("Username", text: $username)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                                )
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("First Name")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextField("First Name", text: $first_name)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                                )
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Last Name")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextField("Last Name", text: $last_name)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hue: 0.0, saturation: 0.0, brightness: 0.1686))
                                )
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                    }) {
                        Text("Update Profile")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(hue: 0.55033,saturation: 0.9608,brightness: 1))
                            )
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .padding(.top,-20)
        }
    }
}

#Preview {
    EditProfile()
}
