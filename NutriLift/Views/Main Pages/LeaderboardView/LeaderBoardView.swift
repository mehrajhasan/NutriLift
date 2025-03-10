//
//  LeaderBoardView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/9/25.
//

import SwiftUI

struct LeaderBoardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Leaderboard Coming Soon")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
            
            Text("We're working on the leaderboard feature. Stay tuned for updates!")
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
