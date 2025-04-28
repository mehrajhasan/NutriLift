//
//  LeaderBoardView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/9/25.
//

import SwiftUI

struct LeaderBoardView: View {
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                HStack{
                    Spacer()
                    Text("18")
                    Spacer()
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
                    Spacer()
                    Text("John Doe").bold()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("192")
                    Spacer()
                    Image(systemName:"arrow.up.right.circle")
                    Spacer()
                }
                .padding()
                .background(Color(red: 0.4, green: 0.698, blue: 0.941))                .cornerRadius(15)
                .foregroundColor(.white)
                
                Spacer()
            }
            .navigationTitle("Leaderboard")
        }
    }
    

}

#Preview {
    LeaderBoardView()
}
