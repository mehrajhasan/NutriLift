//
//  LeaderBoardView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/9/25.
//

import SwiftUI

struct LeaderBoardView: View {
//    @State private var friendsData: [UserProfile] = []
    @State private var friendsData: [UserProfile] =
    [
        UserProfile(user_id: 28, username: "Jakeharris", first_name: "Jake", last_name: "Harris", email: nil, profile_pic: nil, points: 52),
        UserProfile(user_id: 27, username: "Jackblues", first_name: "Justin", last_name: "Bieber", email: nil, profile_pic: nil, points: 25),
        UserProfile(user_id: 25, username: "fs", first_name: "Harry", last_name: "Potter", email: nil, profile_pic: nil, points: 20),
        UserProfile(user_id: 2, username: "fs", first_name: "Hermione", last_name: "Granger", email: nil, profile_pic: nil, points: 24),
        UserProfile(user_id: 23, username: "fs", first_name: "Ronald", last_name: "Weasley", email: nil, profile_pic: nil, points: 23),
        UserProfile(user_id: 21, username: "fs", first_name: "Santa", last_name: "Claus", email: nil, profile_pic: nil, points: 12),
        UserProfile(user_id: 221, username: "fs", first_name: "Jack", last_name: "Blues", email: nil, profile_pic: nil, points: 122)
    ]
    let rank: Int = 1


    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    //changed to use index to be able to rank within here
                    ForEach(friendsData.indices, id: \.self){ index in
                        let user = friendsData[index]
                        HStack(){
                            Text("\(index+1)")
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
                            
                            Image(systemName:"arrow.up.right.circle")
                                .padding(.trailing)
                        }
                        .padding()
                        //make sure the ranks have diff colors gold silv bronze
                        .background(
                            index == 0 ? Color(red: 0.9686, green: 0.7765, blue: 0.2902) :
                            index == 1 ? Color(red: 0.8502, green: 0.8502, blue: 0.8502) :
                            index == 2 ? Color(red: 0.851, green: 0.627, blue: 0.4) :
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
    }
    

}

#Preview {
    LeaderBoardView()
}
