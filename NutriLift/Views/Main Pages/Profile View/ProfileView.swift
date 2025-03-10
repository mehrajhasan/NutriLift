//
//  ProfileView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/9/25.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Profile Page Coming Soon")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
            
            Text("We're working on your profile page. Stay tuned for updates!")
                .font(.title3)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    TaskBarView()
}
