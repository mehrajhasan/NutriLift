//
//  NotificationView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/24/25.
//

import SwiftUI

struct Notification: Codable {
    let notif_id: Int
    let user_id: Int
    let message: String
    let type: String
    let created_at: String
}
struct NotificationView: View {
    //holds notifications in an array, should be easier for display
    @State private var notifications: [Notification] = []
    @State private var notifs: Bool = false
    
    //get from the /:userId/notifications nedpoint
    func getNotifications(userId: Int){
        //standard setitng up req
        guard let url = URL(string: "http://localhost:3000/\(userId)/notifications") else {
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
                let results = try decoder.decode([Notification].self, from: data)
                self.notifications = results
            }
            catch{
                print("Failed to decode: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    //calculate time since received notif, timestamp is ugly
    func timeSinceNoti(){
        
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0){
                //replacing with friend requests view
                NavigationLink(destination: FriendRequestView()){
                    HStack(spacing: 15){
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                        
                        VStack{
                            Text("Friend requests")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 12.5)
                    .padding(.horizontal)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                
                
                //normal notifs from us (not friend requests)
                ForEach(notifications, id: \.notif_id){ notification in
                    HStack{
                        if(notification.type == "social"){
                            Image(systemName: "person.2")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))
                        }
                        else if(notification.type == "reminder"){
                            Image(systemName: "alarm")
                                .foregroundColor(.red)
                                .font(.system(size: 24))
                        }
                        else if(notification.type == "system"){
                            Image(systemName: "bolt.shield")
                                .foregroundColor(.purple)
                                .font(.system(size: 24))
                        }
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text(notification.message)
                                .font(.body)
                        }
                        Spacer()
                        
                        Text("1hr ago")
                            .font(.footnote)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    Divider()
                        .frame(width: 350, height: 1)
                }
            }
        }
        .onAppear {
            if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                print("Retrieved userID: \(userId)")
                getNotifications(userId: userId)
            }
            else{
                print("error fetching userid")
            }
        }
        .navigationTitle("Notifications")

    }
}

#Preview {
    NavigationStack{
        NotificationView()
    }
}
