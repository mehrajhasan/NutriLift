//
//  TaskBarView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/9/25.
//

import SwiftUI

struct TaskBarView: View {
    var body: some View {
        TabView {
            MacrosView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Macros")
                }

            RoutinesView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workout")
                }

            LeaderBoardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Leaderboard")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue) // Highlight color for the active tab
    }
}

#Preview {
    TaskBarView()
}
