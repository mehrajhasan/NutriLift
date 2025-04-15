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
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0){
                //for each notif, print xyz (this isnt the styling jsut testing stuff rn)
                //i wanna add the profile pic as well and let users click their prof too
                ForEach(notifications, id: \.notif_id){ notification in
                    VStack(alignment: .leading){
                        Text(notification.message)
                            .font(.headline)
                        Text(notification.created_at)
                            .font(.title3)
                    }
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
