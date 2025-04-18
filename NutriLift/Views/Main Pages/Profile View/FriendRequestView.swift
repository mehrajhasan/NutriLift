//
//  FriendRequestView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 4/17/25.
//

import SwiftUI

struct FriendRequestView: View {
    @State private var requests: [UserProfile] = []
    
    func getFriendRequests(userId: Int){
        //standard setitng up req
        guard let url = URL(string: "http://localhost:3000/\(userId)/friend-requests") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //ensure valid auth token
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
            
            //this decodes the data sent from server and sets notifs to it
            do{
                let decoder = JSONDecoder()
                let results = try decoder.decode([UserProfile].self, from: data)
                self.requests = results
            }
            catch{
                print("Failed to decode: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    //fucn for accepting a friend req
    func acceptRequest(){
        print("testing")
    }
    
    //func for rejecting  a friend req
    func declineRequest(){
        print("testing")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(requests, id: \.user_id) { user in
                        HStack {
                            NavigationLink(destination: UserProfileView(user: user)) {
                                //fix pfp later when figured out just using tihs for now
                                Circle()
                                    .fill(Color(red: 0.9, green: 0.9, blue: 1.0))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(25)
                                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.6))
                                    )
                                
                                //put name and first last under
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.username)
                                        .font(.headline)
                                    Text("\(user.first_name) \(user.last_name)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                                
                                Spacer()
                            }
                            
                            Button{
                                acceptRequest() //not working yet
                            } label: {
                                Text("Accept")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                    .frame(height:30)
                                    .padding(.horizontal, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color(.blue))
                                    )
                                    .buttonStyle(BorderlessButtonStyle())
                            }
                            Button{
                                declineRequest() //not working yet
                            } label: {
                                Text("Deny")
                                    .foregroundColor(.black)
                                    .font(.footnote)
                                    .frame(height:30)
                                    .padding(.horizontal, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color(.systemGray5))
                                    )
                                    .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                    print("Retrieved userID: \(userId)")
                    getFriendRequests(userId: userId)
                }
                else{
                    print("error fetching userid")
                }
            }
            .navigationTitle("Friend Requests")
    }
}

#Preview {
    FriendRequestView()
}
