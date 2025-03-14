//
//  ProfileView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/9/25.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack{
            //header
            
            //messaging (?)
            HStack{
                Button(action: {}) {
                    Image(systemName: "bubble.left")
                        .font(.title2)
                }
                
                Spacer()
                
                //profile
                Text("Profile")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                //search
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                }
                
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
                Text("John Doe")
                    .font(.title)
                    .bold()
                
                Button(action: {
                    
                }){
                    Text("Edit Profile")
                        .foregroundColor(.white)
                    //                    .bold()
                        .font(.callout)
                        .frame(height:30)
                        .padding(.horizontal, 35)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hue: 0.544, saturation: 0.11, brightness: 0.73))
                            
                        )
                }
                .padding(.top, -12.5)
                
                Text("18          393")
            }
            .padding(.top, -175)
            
            
            //pull from macro progress
            //            VStack{
            //                Rectangle()
            //                    .frame(height: 100)
            //                    .foregroundColor(.gray.opacity(0.2))
            //                    .cornerRadius(8)
            //            }
            //        }
        }
    }
}

#Preview {
    ProfileView()
}
