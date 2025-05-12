//
//  RoutineSetupView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/20/25.
//

import SwiftUI
import Foundation

// screen for setting up a new workout routine
struct RoutineSetupView: View {
    @State private var routineName: String = ""
    @State private var selectedExercises: [ExerciseEntry] = []
    @State private var showExercisePicker = false
    
    var body: some View {
        VStack {
            //title
            Text("Create a Routine")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            //input for the routine name
            TextField("Enter Routine Name", text: $routineName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            //Label aboce the list
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
            
            // navigation link to save the routine, only enabled if name and exercises are filled
            Button(action: {
                saveRoutine()
            }) {
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
        // triggers the exercise selection screen when user taps "add exercises"
        .navigationDestination(isPresented: $showExercisePicker) {
            ExerciseSelectionView(selectedExercises: $selectedExercises)
        }
    }
    
    
    // saveRoutine() function from old review page
    
    @Environment(\.presentationMode) var presentationMode
    
    func saveRoutine() {
        guard let userId = UserDefaults.standard.value(forKey: "userId") as? Int else {
            print("no user ID found.")
            return
        }
        
        let routineData: [String: Any] = [
            "title": routineName,
            "user_id": userId,
            "exercises": selectedExercises.map { exercise in
                return [
                    "id": exercise.id,
                    "name": exercise.name,
                    "sets": exercise.sets.map { set in
                        return [
                            "id": set.id,
                            "weight": set.weight,
                            "reps": set.reps
                        ]
                    }
                ]
            }
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/routines") else {
            print("invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: routineData)
        } catch {
            print("error encoding JSON:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("network error:", error)
                return
            }
            
            guard let data = data else {
                print("no data received")
                return
            }
            
            do {
                let _ = try JSONDecoder().decode(Routine.self, from: data)
                DispatchQueue.main.async {
                    print("routine saved successfully")
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("decoding error:", error)
                print("raw response:", String(data: data, encoding: .utf8) ?? "n/a")
            }
        }.resume()
    }
    
}
