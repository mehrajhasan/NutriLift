//
//  LeaderBoardView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/9/25.
//

import SwiftUI

struct LeaderBoardView: View {
    @State private var friendsData: [UserProfile] = []
    @State private var currentUser: UserProfile? = nil
//    @State private var friendsData: [UserProfile] =
//    [
//        UserProfile(user_id: 28, username: "Jakeharris", first_name: "Jake", last_name: "Harris", email: nil, profile_pic: nil, points: 52),
//        UserProfile(user_id: 27, username: "Jackblues", first_name: "Justin", last_name: "Bieber", email: nil, profile_pic: nil, points: 25),
//        UserProfile(user_id: 25, username: "fs", first_name: "Harry", last_name: "Potter", email: nil, profile_pic: nil, points: 20),
//        UserProfile(user_id: 2, username: "fs", first_name: "Hermione", last_name: "Granger", email: nil, profile_pic: nil, points: 24),
//        UserProfile(user_id: 23, username: "fs", first_name: "Ronald", last_name: "Weasley", email: nil, profile_pic: nil, points: 23),
//        UserProfile(user_id: 21, username: "fs", first_name: "Santa", last_name: "Claus", email: nil, profile_pic: nil, points: 12),
//        UserProfile(user_id: 221, username: "fs", first_name: "Jack", last_name: "Blues", email: nil, profile_pic: nil, points: 122)
//    ]
    let rank: Int = 1
    
    func getLeaderboard(userId: Int){
        guard let url = URL(string: "http://localhost:3000/\(userId)/leaderboard") else{
            print("Invalid URL")
            return
        }
        
        //setting up for a GET request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //authentication stuff
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        //handling data
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                print("Failed to connect to the server: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else{
                print("No data")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid server response")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Server error: \(httpResponse.statusCode)")
                return
            }
            
            //decode data from friendsdata
            do{
                let decoder = JSONDecoder()
                let results = try decoder.decode([UserProfile].self, from: data)
                self.friendsData = results
            }
            catch{
                print("Failed to decode: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    //https://developer.apple.com/documentation/swift/array/firstindex(of:) for header
    func calcuateRank(userId: Int, from friendsData: [UserProfile]) -> Int {
        //finding the index where the userId falls within list +1 cus its index
        if let index = friendsData.firstIndex(where: { $0.user_id == userId }){
            return index + 1
        }
        
        return 0
    }
        
    //ranking for logged in user
    func rankColor(rank: Int) -> Color {
        if(rank == 1){
            return Color(red: 0.9686, green: 0.7765, blue: 0.2902)
        }
        else if(rank == 2){
            return Color(red: 0.8502, green: 0.8502, blue: 0.8502)
        }
        else if(rank == 3){
            return Color(red: 0.851, green: 0.627, blue: 0.4)
        }
        else{
            return Color(red: 0.4, green: 0.698, blue: 0.941)
        }
    }

    var body: some View {
        NavigationStack{
            ScrollView{
                //put your own card on top of leaderboard so yk where u stand
                if let userId = UserDefaults.standard.value(forKey: "userId") as? Int, let user = friendsData.first(where: { $0.user_id == userId}) {
                    let yourRank = calcuateRank(userId: userId, from: friendsData)
                    VStack(alignment: .leading){
                        Text("Your rank")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                            .bold()
                        HStack(){
                            Text("\(yourRank)")
                                .frame(width: 30)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(25)
                                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.6))
                                )
                            
                            Text("\(user.first_name) \(user.last_name)")
                                .bold()
                                .padding(.leading)
                            Spacer()
                            Text("\(user.points)")
                                .padding(.leading)
                            
                            Image(systemName:"star.circle.fill")
                                .padding(.trailing)
                        }
                    }
                    .padding()
                    .background(rankColor(rank: yourRank))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .padding(.horizontal,5)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                
                //need this so we dont repeat userId
                let userId = UserDefaults.standard.value(forKey: "userId") as? Int
                let filteredData = friendsData.filter { $0.user_id != userId }
                VStack{
                    //changed to use index to be able to rank within here
                    ForEach(filteredData.indices, id: \.self){ index in
                        let user = filteredData[index]
                        
                        let userRank = calcuateRank(userId: user.user_id, from: friendsData)
                        HStack(){
                            Text("\(userRank)")
                                .frame(width: 30)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(25)
                                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.6))
                                )
                            
                            Text("\(user.first_name) \(user.last_name)")
                                .bold()
                                .padding(.leading)
                            Spacer()
                            Text("\(user.points)")
                                .padding(.leading)
                            
                            Image(systemName:"star.circle.fill")
                                .padding(.trailing)
                        }
                        .padding()
                        //make sure the ranks have diff colors gold silv bronze
                        .background(
                            userRank == 1 ? Color(red: 0.9686, green: 0.7765, blue: 0.2902) :
                            userRank == 2 ? Color(red: 0.8502, green: 0.8502, blue: 0.8502) :
                            userRank == 3 ? Color(red: 0.851, green: 0.627, blue: 0.4) :
                                Color.white.opacity(0.75)
                        )
                        .cornerRadius(15)
                        .foregroundColor(.black)
                        .padding(.horizontal,5)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        
                    }
                    Spacer()
                }
                .navigationTitle("Leaderboard")
            }
        }
        .onAppear {
            if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                print("Retrieved userID: \(userId)")
                getLeaderboard(userId: userId)
            }
            else{
                print("error fetching userid")
            }
        }
    }
    
    

}

#Preview {
    LeaderBoardView()
}
