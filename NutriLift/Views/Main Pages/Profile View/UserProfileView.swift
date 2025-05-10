//
//  UserProfileView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/24/25.
//

import SwiftUI

struct FriendStatus: Codable {
    let isFriend: Bool
    let isPending: Bool
}

struct UserProfileView: View {
    let user: UserProfile

    @State private var macroProgress: Double = 0.0 // from 0 to 1
    @State private var caloriesConsumed: Double = 0
    @State private var caloriesGoal: Double = 0
    @State private var proteinConsumed: Double = 0
    @State private var proteinGoal: Double = 0
    @State private var carbsConsumed: Double = 0
    @State private var carbsGoal: Double = 0
    @State private var fatConsumed: Double = 0
    @State private var fatGoal: Double = 0
    
    //from db
    @State private var first_name: String = "John"
    @State private var last_name: String = "Doe"
    @State private var points: Int = 0
    @State private var friendRequest: Bool = false
    @State private var isFriend: Bool = false
    @State private var isPending: Bool = false
    
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
        guard let url = URL(string: "http://localhost:3000/user/\(user.user_id)") else {
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
    
    //send friend req
    func sendFriendReq(){
        guard let url = URL(string: "http://localhost:3000/friend-req") else {
            print("Invalid URL")
            return
        }
        
        //get logged in user id from UserDefaults
        let sender_id = UserDefaults.standard.integer(forKey: "userId")
        
        //need to send body since post request
        //just holds the logged in user id and id of the person ur sending friend req to
        let body = [
            "sender_id": sender_id,
            "receiver_id": user.user_id
        ]
        
//        //check to see if working WORKS FINE!
//        print(sender_id)
//        print(user.user_id)
        
        //decode, if we dont server gets undefined
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        //set headers n stuff
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
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
            
            //if server processes the friend req, set to true so we can change ui status
            //else send issue (need to update ui for that)
            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 {
                    print("Friend request sent.")
                    friendRequest = true;
                } else {
                    print("Server returned status code: \(httpResponse.statusCode)")
                }
            }
                
            
        }.resume()
    }
    
    //get friends status (needed to update UI accordingly)
    func fetchFriendStatus(){
        //from logged in user
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        //endpoint and user.user_id since it depedns on prof
        guard let url = URL(string: "http://localhost:3000/\(userId)/friend-status/\(user.user_id)") else {
            print("Invalid URL")
            return
        }
        
        //setting up GET req headers
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
            
            //if good, decode the JSON res holding the isFriend/isPending data and udpate accordingly
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(FriendStatus.self, from: data)
                        
                        DispatchQueue.main.async{
                            self.isFriend = result.isFriend
                            self.isPending = result.isFriend
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

    
    var body: some View {
        NavigationStack {
            ZStack{
                //header
                HStack{

                    
                    Spacer()
                    
                    //profile
                    Text("@\(user.username)")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    
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
                    if(isFriend){
                        HStack{
                            Text("\(user.first_name) \(user.last_name)")
                                .font(.title)
                                .bold()
                
                            //need to add unfollow functionality as well
                            Button{
                            } label:{
                                Image(systemName: "person.fill.checkmark")
                            }
                        }
                        
                    }
                    else{
                        Text("\(user.first_name) \(user.last_name)")
                            .font(.title)
                            .bold()
                    }
                    if(!isFriend && !isPending){
                        Button{
                            //send a friend req wehn clikced
                            sendFriendReq()
                        } label:{
                            //toggles based on bool value
                            Text(friendRequest ? "Pending" : "Friend Request")
                                .foregroundColor(.white)
                                .font(.callout)
                                .frame(height:30)
                                .padding(.horizontal, 35)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(friendRequest ? Color(hue: 0.11, saturation: 0.93, brightness: 0.95) : Color(hue: 0.55033,saturation: 0.9608,brightness: 1))
                                    
                                )
                        }
                        .padding(.top, -12.5)
                    }
                    else if(isPending && !isFriend){
                        Button{
                            //add undo btn
                        } label:{
                            //toggles based on bool value
                            Text("Pending")
                                .foregroundColor(.white)
                                .font(.callout)
                                .frame(height:30)
                                .padding(.horizontal, 35)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hue: 0.11, saturation: 0.93, brightness: 0.95))
                                    
                                )
                        }
                        .padding(.top, -12.5)
                    }
                    //make dynamic for level and leaderboard score
                    HStack{
                        Text("0")
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        
                        
                        //need to make dynamic for up down
                        Text("\(user.points)")
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
                .padding(.top, 225)
                //update, no blur if friends
                .blur(radius: isFriend ? 0 : 5)
            }
            .onAppear {
                if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                    print("Retrieved userID: \(userId)")
                    fetchUserProfile(userId: userId)
                    fetchDailyMacros(userId: user.user_id)
                    fetchMacroGoal(userId: user.user_id)
                    fetchFriendStatus() //update all vars accordingly when it loads aka isFriend and isPending
                }
                else{
                    print("error fetching userid")
                }
            }
        }
    }
}

#Preview {
    UserProfileView(user: UserProfile(
            user_id: 1,
            username: "cbum",
            first_name: "Chris",
            last_name: "B.",
            email: "chris@example.com",
            profile_pic: nil,
            points: 99
        ))
}
