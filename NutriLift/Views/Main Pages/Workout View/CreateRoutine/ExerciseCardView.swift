//
//  ExerciseCardView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/20/25.
//

import SwiftUI
import Foundation

/*
 UUID Link: https://developer.apple.com/documentation/foundation/uuid
 */

struct WorkoutRoutineView: View {
    @State private var selectedExercises: [ExerciseEntry] = []

    var body: some View {
        VStack {
            ScrollView {
                ForEach($selectedExercises) { $exercise in
                    ExerciseCardView(exercise: $exercise)
                }
            }

            Button(action: {
                // Navigate to add exercises screen
            }) {
                Text("Add Exercises")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct ExerciseCardView: View {
    @Binding var exercise: ExerciseEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal)
                

            // Header Row
            HStack {
                Text("Set")
                    .frame(width: 40, alignment: .center)

                Spacer()

                Text("Prev.")
                    .frame(width: 75, alignment: .center)

                Text("lbs")
                    .frame(width: 75, alignment: .center)

                Text("Reps")
                    .frame(width: 75, alignment: .center)

                Spacer()
                
                Text("") // for delete icon alignment
                    .frame(width: 20)
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)

            // Input Rows
            ForEach(Array($exercise.sets.enumerated()), id: \.element.id) { index, $set in
                HStack {
                    Text("\(index + 1)")
                        .frame(width: 40)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .multilineTextAlignment(.center)

                    Spacer()

                    Text("-")
                        .frame(width: 75)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                        .multilineTextAlignment(.center)

                    TextField("", text: $set.weight)
                        .frame(width: 75)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)

                    TextField("", text: $set.reps)
                        .frame(width: 75)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button(action: {
                        exercise.sets.remove(at: index)
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
            }

            // Add Set Button
            Button(action: {
                exercise.sets.append(SetEntry(id: UUID().uuidString, weight: "", reps: "")
)
            }) {
                Text("+ Add Set")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        
    }

}
#Preview {
    ExerciseCardView(exercise: .constant(
        ExerciseEntry(
            id: UUID().uuidString,
            name: "Bench Press (Smith Machine)",
            sets: [
                SetEntry(id: UUID().uuidString, weight: "135", reps: "10"),
                SetEntry(id: UUID().uuidString, weight: "145", reps: "8")
            ]
        )
    ))
}

#Preview {
    WorkoutRoutineView()
}
