//
//  ProfileView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/9/25.
//
import SwiftUI

struct ProfileView: View {
    @State private var macroProgress: Double = 0.0 // from 0 to 1
    @State private var caloriesConsumed: Int = 0
    @State private var caloriesGoal: Int = 0
    @State private var proteinConsumed: Int = 0
    @State private var proteinGoal: Int = 0
    
    //need to make dynamic
    //for progress bar
    var caloriesProgress: Double {
        guard caloriesGoal > 0 else { return 0.0 }
        let prog = Double(caloriesConsumed) / Double(caloriesGoal)
        return prog.isFinite ? prog : 0.0
    }
    
    //for progress bar
    var proteinProgress: Double {
        guard proteinGoal > 0 else { return 0.0 }
        let prog = Double(proteinConsumed) / Double(proteinGoal)
        return prog.isFinite ? prog : 0.0
    }
    
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
                
                NavigationLink{
                    EditProfile()
                } label:{
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
                //make dynamic for level and leaderboard score
                Text("18          393")
            }
            .padding(.top, -175)
            
            
            VStack(alignment: .leading, spacing: 25){
                VStack{
                    HStack{
                        Text("Macro Progress")
                        Spacer()
                        Text("\(Int(macroProgress * 100))%")
                    }
                    .foregroundColor(.black)
                    .bold()
                        
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.5)
                            .fill(Color.white)
                            .frame(height:30)
                            .padding(.horizontal, -7.5)
                        ProgressView(value: macroProgress)
                    }
                }
                               
                
                VStack{
                    HStack{
                        Text("Calories")
                        Spacer()
                        Text("\(Int((caloriesProgress * 100)))%")
                    }
                    .foregroundColor(.black)
                    .bold()
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 12.5)
                            .fill(Color.white)
                            .frame(height:30)
                            .padding(.horizontal, -7.5)
                        ProgressView(value: caloriesProgress)
                    }
                }
                
                
                VStack{
                    HStack{
                        Text("Protein")
                        Spacer()
                        Text("\(Int(proteinProgress*100))%")
                    }
                    .foregroundColor(.black)
                    .bold()
                  
                    ZStack{
                        RoundedRectangle(cornerRadius: 12.5)
                            .fill(Color.white)
                            .frame(height:30)
                            .padding(.horizontal, -7.5)
                        ProgressView(value: proteinProgress)
                    }
                }
                

                
            }
            .padding()
            .padding(.vertical, 5)
            .background(RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.827, green: 0.827, blue: 0.827))
            )
            .padding(.horizontal)
            .padding(.top, 150)
            

        }
    }
}

#Preview {
    NavigationStack{
        ProfileView()
    }
}
