//
//  UserSearch.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/16/25.
//

import SwiftUI

struct UserSearch: View {
    @State private var query: String = ""
    @State private var queryResults: [UserProfile] = []
    
    func searchUsers(){
        guard !query.isEmpty else {
            print("no query placeholder")
            queryResults = []
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/search?query=\(query)") else {
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
            DispatchQueue.main.async {
                guard let data = data else {
                    return
                }
                
                if let error = error {
                    print("Failed to connect: \(error.localizedDescription)")
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
                
                
                do {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([UserProfile].self, from: data)
                    self.queryResults = results
                } catch {
                    print("JSON decoding failed: \(error)")
                }
            }
        }.resume()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $query)
                    .onSubmit {
                        searchUsers()
                    }
                    
                
                if !query.isEmpty {
                    Button(action: {
                        query = ""
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                
                
            }
            .padding(10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        
        //displays but no func to see prof yet, just lists rn. testing to see if api works
        ScrollView {
            VStack(spacing: 0) {
                ForEach(queryResults, id: \.user_id) { user in
                    HStack {
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
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                }
            }
        }
        Spacer()

    }
}

#Preview {
    UserSearch()
}
