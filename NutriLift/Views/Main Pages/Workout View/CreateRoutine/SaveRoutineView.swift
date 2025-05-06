//
//  SaveRoutineView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/20/25.
//

import SwiftUI

// screen to review and save the workout routine
struct SaveRoutineView: View {
    let routineName: String
    let exercises: [ExerciseEntry]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Review Your Routine")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Routine Name: \(routineName)")
                .font(.headline)
                .padding()
            
            Text("Exercises:")
                .font(.headline)
            
            List(exercises, id: \.id) { exercise in
                Text(exercise.name)
            }
            
            Spacer()
            
            Button(action: saveRoutine) {
                Text("Confirm & Save")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    
    // sends routine data to the backend
    func saveRoutine() {
        guard let userId = UserDefaults.standard.integer(forKey: "userId") as? Int else {
            print("No user ID found.")
            return
        }
        
        
        // builds the routine payload to send
        let routineData: [String: Any] = [
            "title": routineName,
            "user_id": userId,
            "exercises": exercises.map { exercise in
                return [
                    "id": exercise.id, // include exercise id from dataset
                    "name": exercise.name,
                    "sets": exercise.sets.map { set in
                        return [
                            "id": set.id,  // include id for each set
                            "weight": set.weight,
                            "reps": set.reps
                        ]
                    }
                ]
            }
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/routines") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: routineData)
        }
        catch {
            print("Error encoding JSON:", error)
            return
        }
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("network error:", error)
                return
            }

            guard let data = data else {
                print("no data returned from server")
                return
            }

            do {
                let savedRoutine = try JSONDecoder().decode(Routine.self, from: data)
                DispatchQueue.main.async {
                    print("routine saved successfully:", savedRoutine)
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } catch {
                print("decoding error:", error)
                print("raw response:", String(data: data, encoding: .utf8) ?? "n/a")
            }
        }.resume()

        
        
    }
        
}
