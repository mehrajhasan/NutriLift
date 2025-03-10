//
//  WorkoutView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/9/25.
//
import SwiftUI

struct Routine: Identifiable {
    let id = UUID()
    let title: String
    let exercises: [String]
}

struct RoutinesView: View {
    let routines = [
        Routine(title: "Chest Day (Light Day)", exercises: [
            "Barbell Bench Press",
            "Dumbbell Bench Press",
            "Incline Dumbbell Bench Press",
            "Suspended Chest Fly",
            "Cable Rope Overhead Tricep Extensions"
        ]),
        Routine(title: "Leg Day", exercises: [
            "Squats",
            "Romanian Deadlifts",
            "Leg Press",
            "Bulgarian Split Squats",
            "Lying Hamstring Curls"
        ]),
        Routine(title: "Back Day", exercises: [
            "Deadlifts",
            "Pull-ups",
            "Bent-Over Barbell Rows",
            "Single-Arm Dumbbell Rows",
            "Seated Cable Rows"
        ])
    ]
    
    var body: some View {
        VStack {
            // Header with Title and Menu Button
            HStack {
                Spacer()
                Text("Routines")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: { /* Open menu */ }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.black)
                        .font(.title)
                }
            }
            .padding()
            
            // Create New Routine Button
            Button(action: { /* Create new routine action */ }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                    Text("Create New Routine")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)

            // Scrollable Routine Cards
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(routines) { routine in
                        RoutineCard(routine: routine)
                    }
                }
                .padding()
            }

            Spacer()

            // Bottom Navigation Bar
            HStack {
                Spacer()
                Image(systemName: "chart.pie.fill")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "dumbbell.fill")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
        }
        .navigationTitle("Workout Routines")
    }
}

// Routine Card View with Equal Width
struct RoutineCard: View {
    let routine: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(routine.title) - Preview")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
            
            ForEach(routine.exercises, id: \.self) { exercise in
                Text(exercise)
                    .foregroundColor(.black.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Ensures equal width
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    RoutinesView()
}


