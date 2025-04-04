//
//  SaveRoutineView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/20/25.
//

import SwiftUI

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

    func saveRoutine() {
        guard let userId = UserDefaults.standard.integer(forKey: "user_id") as? Int else {
            print("No user ID found.")
            return
        }

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
        } catch {
            print("Error encoding JSON:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving routine:", error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Server Response Code:", httpResponse.statusCode)
            }

            if let data = data {
                do {
                    let savedRoutine = try JSONDecoder().decode(Routine.self, from: data)
                    DispatchQueue.main.async {
                        print("Routine saved successfully:", savedRoutine)
                        presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    print("Error decoding response:", error)
                }
            }
        }.resume()
    }
}
