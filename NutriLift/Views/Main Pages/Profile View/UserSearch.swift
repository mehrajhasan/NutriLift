//
//  UserSearch.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/16/25.
//

import SwiftUI

struct UserSearch: View {
    @State private var query: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $query)
                    
                
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

            Spacer()
        }
        
    }
}

#Preview {
    UserSearch()
}
