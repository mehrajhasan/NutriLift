//
//  ProfileView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/9/25.
//
import SwiftUI

//defining db structure for fetching
struct UserProfile: Codable {
    let user_id: Int
    let username: String
    let first_name: String
    let last_name: String
    let email: String
    let profile_pic: String?
    let points: Int
}

struct ProfileView: View {
    @State private var macroProgress: Double = 0.0 // from 0 to 1
    @State private var caloriesConsumed: Int = 0
    @State private var caloriesGoal: Int = 0
    @State private var proteinConsumed: Int = 0
    @State private var proteinGoal: Int = 0
    
    //from db
    @State private var first_name: String = "John"
    @State private var last_name: String = "Doe"
    @State private var points: Int = 0
    
    
    //need to make dynamic
    //for progress bar
    var caloriesProgress: Double {
        guard caloriesGoal > 0 else { return 0.0 }
        let prog = Double(caloriesConsumed) / Double(caloriesGoal)
        return prog.isFinite ? prog : 0.0
    }
    
    //for progress bar
    var proteinProgress: Double {
        guard proteinGoal > 0 else { return 0.0 }
        let prog = Double(proteinConsumed) / Double(proteinGoal)
        return prog.isFinite ? prog : 0.0
    }
    
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
                            self.points = profile.points
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
    
    var body: some View {
        NavigationStack {
            ZStack{
                //header
                
                //messaging (?)
                HStack{
                    Button(action: {}) {
                        Image(systemName: "bubble.left")
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    //profile
                    Text("Profile")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink(destination: UserSearch()) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top,-375)
                
                
                //user profile pic dynamic
                VStack{
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
                }
                .padding(.top,-300)
                
                //dynamic
                //name - edit profile - points
                VStack{
                    Text("\(first_name) \(last_name)")
                        .font(.title)
                        .bold()
                    
                    NavigationLink{
                        EditProfile()
                    } label:{
                        Text("Edit Profile")
                            .foregroundColor(.white)
                        //                                        .bold()
                            .font(.callout)
                            .frame(height:30)
                            .padding(.horizontal, 35)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(hue: 0.544, saturation: 0.11, brightness: 0.73))
                                
                            )
                    }
                    .padding(.top, -12.5)
                    //make dynamic for level and leaderboard score
                    HStack{
                        Text("0")
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        
                        
                        //need to make dynamic for up down
                        Text("\(points)")
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.green)
                    }
                    
                }
                .padding(.top, -175)
                
                
                VStack(alignment: .leading, spacing: 25){
                    VStack{
                        HStack{
                            Text("Macro Progress")
                            Spacer()
                            Text("\(Int(macroProgress * 100))%")
                        }
                        .foregroundColor(.black)
                        .bold()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(Color.white)
                                .frame(height:30)
                                .padding(.horizontal, -7.5)
                            ProgressView(value: macroProgress)
                        }
                    }
                    
                    
                    VStack{
                        HStack{
                            Text("Calories")
                            Spacer()
                            Text("\(Int((caloriesProgress * 100)))%")
                        }
                        .foregroundColor(.black)
                        .bold()
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(Color.white)
                                .frame(height:30)
                                .padding(.horizontal, -7.5)
                            ProgressView(value: caloriesProgress)
                        }
                    }
                    
                    
                    VStack{
                        HStack{
                            Text("Protein")
                            Spacer()
                            Text("\(Int(proteinProgress*100))%")
                        }
                        .foregroundColor(.black)
                        .bold()
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(Color.white)
                                .frame(height:30)
                                .padding(.horizontal, -7.5)
                            ProgressView(value: proteinProgress)
                        }
                    }
                    
                    
                    
                }
                .padding()
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.827, green: 0.827, blue: 0.827))
                )
                .padding(.horizontal)
                .padding(.top, 150)
            }
            .onAppear {
                fetchUserProfile(userId: 12)
            }
        }
    }
}

#Preview {
    NavigationStack{
        ProfileView()
    }
}
