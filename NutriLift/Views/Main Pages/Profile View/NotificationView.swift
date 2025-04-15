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
    let is_read: Bool
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
    
    //fucn for accepting a friend req
    func acceptRequest(){
        
    }
    
    //func for rejecting  a friend req
    func declineRequest(){
        
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0){
                Text("Notifications")
                    .font(.title)
                    .bold()
                    .padding(.vertical, -5)
                Spacer()
                //for each notif, print xyz (this isnt the styling jsut testing stuff rn)
                //i wanna add the profile pic as well and let users click their prof too
                //likely need to add 'type' to table and add conditions for type of notif
                ForEach(notifications, id: \.notif_id){ notification in
                    HStack{
                        //just here till pfp complete
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
                        
                        Text(notification.message)
                            .font(.callout)
//                        Text(notification.created_at)
//                            .font(.title3)
                        Spacer()
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
                                        .fill(Color(.lightGray))
                                    
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
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
    }
    
}

#Preview {
    NotificationView()
}
//testing
//#Preview {
//    NotificationView(notifications: [
//        Notification(
//            notif_id: 1,
//            user_id: 123,
//            message: "Mehraj sent you a friend request.",
//            is_read: false,
//            created_at: "2025-04-14T10:00:00Z"
//        ),
//        Notification(
//            notif_id: 2,
//            user_id: 13,
//            message: "Jake sent you a friend request.",
//            is_read: false,
//            created_at: "2025-04-14T10:00:00Z"
//        )
//    ])
//}
