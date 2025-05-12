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
    let email: String?
    let profile_pic: String?
    let points: Int
}

struct DailyMacros: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
}

struct MacroGoal: Codable {
    let protein_goal: Double?
    let carbs_goal: Double?
    let fats_goal: Double?
    let calories_goal: Double?
}

struct ProfileView: View {
    @State private var macroProgress: Double = 0.0 // from 0 to 1
    @State private var caloriesConsumed: Double = 0
    @State private var caloriesGoal: Double = 0
    @State private var proteinConsumed: Double = 0
    @State private var proteinGoal: Double = 0
    @State private var carbsConsumed: Double = 0
    @State private var carbsGoal: Double = 0
    @State private var fatConsumed: Double = 0
    @State private var fatGoal: Double = 0
    @State private var showLogoutConfirmation: Bool = false
    @State private var isLoggedOut = false
    
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
    
    //for progress bar
    var carbProgress: Double {
        guard carbsGoal > 0 else { return 0.0 }
        let prog = Double(carbsConsumed) / Double(carbsGoal)
        return prog.isFinite ? prog : 0.0
    }
    
    //for progress bar
    var fatProgress: Double {
        guard fatGoal > 0 else { return 0.0 }
        let prog = Double(fatConsumed) / Double(fatGoal)
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
    
    //fetches the added up macros for the day for user
    func fetchDailyMacros(userId: Int) {
        guard let url = URL(string: "http://localhost:3000/macro-daily/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        //setting up get
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //auth stuff
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
                        let macros = try decoder.decode([DailyMacros].self, from: data)
                        
                        DispatchQueue.main.async{
                            self.caloriesConsumed = macros[0].calories
                            self.proteinConsumed = macros[0].protein
                            self.carbsConsumed = macros[0].carbs
                            self.fatConsumed = macros[0].fats
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
    
    //fetch the macrogoal, no annoying type conversion cus float8
    func fetchMacroGoal(userId: Int){
        guard let url = URL(string: "http://localhost:3000/macro-goal/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        //setting up get
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //auth stuff
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
                        let goal = try decoder.decode([MacroGoal].self, from: data)
                        
                        DispatchQueue.main.async{
                            if let hasGoal = goal.first {
                                self.proteinGoal = hasGoal.protein_goal ?? 0
                                self.carbsGoal = hasGoal.carbs_goal ?? 0
                                self.fatGoal = hasGoal.fats_goal ?? 0
                                self.caloriesGoal = hasGoal.calories_goal ?? 0
                            }
                            else{
                                self.proteinGoal = 0
                                self.carbsGoal = 0
                                self.fatGoal = 0
                                self.caloriesGoal = 0
                            }
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
    
    func signOut(){
        UserDefaults.standard.removeObject(forKey: "userId")
        isLoggedOut = true
    }

    
    var body: some View {
        NavigationStack {
            ZStack{
                //header
                
                HStack{
                    NavigationLink(destination: NotificationView()){
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    //profile
                    Text("Profile")
                        .font(.title)
                        .bold()
                        .padding(.trailing, -30)
                    
                    Spacer()
                    HStack{
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .alert("Sign out?", isPresented: $showLogoutConfirmation) {
                            Button("Log out", role: .destructive) {
                                signOut()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        
                        NavigationLink(destination: UserSearch()) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                    .navigationDestination(isPresented: $isLoggedOut) {
                            loginView(onLoginSuccess: {})
                                .navigationBarBackButtonHidden(true)
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
                        EditProfileView()
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
                    
                    VStack{
                        HStack{
                            Text("Carbohydrates")
                            Spacer()
                            Text("\(Int(carbProgress*100))%")
                        }
                        .foregroundColor(.black)
                        .bold()
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(Color.white)
                                .frame(height:30)
                                .padding(.horizontal, -7.5)
                            ProgressView(value: carbProgress)
                        }
                    }
                    
                    VStack{
                        HStack{
                            Text("Fats")
                            Spacer()
                            Text("\(Int(fatProgress*100))%")
                        }
                        .foregroundColor(.black)
                        .bold()
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(Color.white)
                                .frame(height:30)
                                .padding(.horizontal, -7.5)
                            ProgressView(value: fatProgress)
                        }
                    }
                    
                    
                    
                }
                .padding()
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.827, green: 0.827, blue: 0.827))
                )
                .padding(.horizontal)
                .padding(.top, 250)
            }
            .onAppear {
                if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                    print("Retrieved userID: \(userId)")
                    fetchUserProfile(userId: userId)
                    fetchDailyMacros(userId: userId)
                    fetchMacroGoal(userId: userId)
                }
                else{
                    print("error fetching userid")
                }
            }
            
        }
    }
}

#Preview {
    NavigationStack{
        ProfileView()
    }
}
