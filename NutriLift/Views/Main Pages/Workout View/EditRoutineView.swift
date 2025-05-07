//
//  EditRoutineView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 4/24/25.
//

import SwiftUI
import Foundation


// screen that lets the user edit an existing workout routine
struct EditRoutineView: View {
    @State var routineName: String
    @State var selectedExercises: [ExerciseEntry]
    let routineId: Int
    let onFinish: () -> Void
    
    @State private var showExercisePicker = false
    
    var body: some View {
        
            VStack {
                
                Text("Edit Routine")//title
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                TextField("Edit Routine Name", text: $routineName)
                    .frame(height: 40)
                    .frame(width: 300)
                    .padding(.leading, 20)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
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
                .frame(height: 400)
                
                
                
                
                Button(action: {
                    showExercisePicker = true
                }) {
                    Text("Add Exercises")
                        .frame(width: 300)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                
                
                Button("Save Routine") {
                    saveEditedRoutine(routineId: routineId, title: routineName, exercises: selectedExercises) { success in
                        if success {
                            onFinish()
                        }
                    }
                    
                }
                .frame(width: 300)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(routineName.isEmpty || selectedExercises.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(routineName.isEmpty || selectedExercises.isEmpty) // Prevent saving if no data
                
            }
            
            
            .navigationDestination(isPresented: $showExercisePicker) {
                ExerciseSelectionView(selectedExercises: $selectedExercises)
            }
        }
    }


// sends updated routine data to the backend
func saveEditedRoutine(routineId: Int, title: String, exercises: [ExerciseEntry], completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/routines/\(routineId)") else {
        completion(false)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Attach auth token
    if let token = UserDefaults.standard.string(forKey: "userToken") {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    // prepare the request body with updated title and exercises
    let body: [String: Any] = [
        "title": title,
        "exercises": exercises.map { $0.ExFormat() }
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    URLSession.shared.dataTask(with: request) { data, response, _ in
        if let httpResponse = response as? HTTPURLResponse {
            completion(httpResponse.statusCode == 200)
        } else {
            completion(false)
        }
    }.resume()
}


/*
#Preview {
    RoutineCard(
        routine: Routine(
            id: 1,
            title: "Leg Day",
            exercises: [
                ExerciseEntry(
                    id: UUID().uuidString,
                    name: "Squat",
                    sets: [
                        SetEntry(id: UUID().uuidString, weight: "225", reps: "10"),
                        SetEntry(id: UUID().uuidString, weight: "245", reps: "8")
                    ]
                ),
                ExerciseEntry(
                    id: UUID().uuidString,
                    name: "Leg Press",
                    sets: [
                        SetEntry(id: UUID().uuidString, weight: "400", reps: "12")
                    ]
                ),
                ExerciseEntry(
                    id: UUID().uuidString,
                    name: "Lunges",
                    sets: [
                        SetEntry(id: UUID().uuidString, weight: "50", reps: "10"),
                        SetEntry(id: UUID().uuidString, weight: "50", reps: "10")
                    ]
                )
            ],
            created_at: nil,
            user_id: 1
        ),
        onDelete: {},
        onEdit: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
*/

#Preview {
    EditRoutineView(
        routineName: "User J Test",
        selectedExercises: [
            ExerciseEntry(
                id: UUID().uuidString,
                name: "FYR Banded Plank Jack",
                sets: [
                    SetEntry(id: UUID().uuidString, weight: "10", reps: "8"),
                    SetEntry(id: UUID().uuidString, weight: "20", reps: "2"),
                    SetEntry(id: UUID().uuidString, weight: "", reps: "")
                ]
            )
        ],
        routineId: 1,
        onFinish: {}
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
