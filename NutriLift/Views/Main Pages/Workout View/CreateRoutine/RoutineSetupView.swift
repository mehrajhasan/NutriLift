//
//  RoutineSetupView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/20/25.
//

import SwiftUI

struct RoutineSetupView: View {
    @State private var routineName: String = ""
    @State private var selectedExercises: [ExerciseEntry] = []
    @State private var showExercisePicker = false

    var body: some View {
        VStack {
            Text("Create a Routine")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)

            TextField("Enter Routine Name", text: $routineName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Text("Exercises in Routine:")
                .font(.headline)
                .padding(.top)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach($selectedExercises) { $entry in
                        ExerciseCardView(exercise: $entry)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 300)


            Spacer()

            Button(action: {
                showExercisePicker = true
            }) {
                Text("Add Exercises")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            NavigationLink(destination: SaveRoutineView(routineName: routineName, exercises: selectedExercises)) {
                Text("Save Routine")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(routineName.isEmpty || selectedExercises.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(routineName.isEmpty || selectedExercises.isEmpty) // Prevent saving if no data

        }
        .padding()
        .navigationDestination(isPresented: $showExercisePicker) {
            ExerciseSelectionView(selectedExercises: $selectedExercises)
        }
    }
}

