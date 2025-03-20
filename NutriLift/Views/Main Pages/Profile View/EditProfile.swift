//
//  EditProfile.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/13/25.
//

import SwiftUI

struct EditProfile: Codable {
    var user_id: Int
    var username: String
    var first_name: String
    var last_name: String
}

struct EditProfileView: View {
    @State private var username: String = "johndoe"
    @State private var first_name: String = "John"
    @State private var last_name: String = "Doe"
    @State private var userId: Int? = nil
    
    //pull info from db to show current info
    func fetchUserProfile(userId: Int) {
        guard let url = URL(string: "http://localhost:3000/user/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to connect to the server: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid server response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let profile = try decoder.decode(UserProfile.self, from: data)
                        
                        DispatchQueue.main.async{
                            self.first_name = profile.first_name
                            self.last_name = profile.last_name
                            self.username = profile.username
                        }
                    } catch {
                        print("Failed to decode server response: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Server returned status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    func updateUserProfile(userId: Int) {
        guard let url = URL(string: "http://localhost:3000/user/\(userId)/update") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let updatedProfile = EditProfile(
            user_id: userId,
            username: username,
            first_name: first_name,
            last_name: last_name
        )
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(updatedProfile)
            request.httpBody = jsonData
            
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to update profile: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid server response")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("Profile updated successfully")
                } else {
                    print("Failed to update profile. Status code: \(httpResponse.statusCode)")
                }
            }.resume()
        } catch {
            print("Failed to encode profile data: \(error.localizedDescription)")
        }
    }
    
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
                        if let userId = userId {
                            updateUserProfile(userId: userId)
                        } else {
                            print("User ID is not available")
                        }
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
            .onAppear {
                if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                    print("Retrieved userID: \(userId)")
                    self.userId = userId
                    fetchUserProfile(userId: userId)
                }
                else{
                    print("error fetching userid")
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
