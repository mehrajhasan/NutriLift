//
//  WorkoutView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/9/25.
//
import SwiftUI

struct RoutinesView: View {
    @State private var routines: [Routine] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Workout Routines")
                    .font(.largeTitle)
                    .bold()
                
                NavigationLink(destination: RoutineSetupView()) {
                    Text("Create New Routine")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(routines) { routine in
                            RoutineCard(routine: routine)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .onAppear {
                fetchRoutines()
            }
        }
    }
    
    func fetchRoutines() {
        
        guard let userId = UserDefaults.standard.integer(forKey: "user_id") as? Int else {
            print("No user ID found.")
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/api/routines/\(userId)") else {
            print("Invalid API URL.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network request failed:", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Server Response Code:", httpResponse.statusCode) // Debug HTTP status
            }
            
            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8) ?? "No response"
                print("Raw Server Response:", rawResponse) // Log raw response
                
                do {
                    let decodedData = try JSONDecoder().decode([Routine].self, from: data)
                    DispatchQueue.main.async {
                        self.routines = decodedData
                    }
                } catch {
                    print("Error decoding JSON:", error)
                }
            }
        }.resume()
    }
}

struct RoutineCard: View {
    let routine: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(routine.title)
                .font(.title2)
                .bold()
                .foregroundColor(.black)

            ForEach(routine.exercises, id: \.id) { exercise in
                VStack(alignment: .leading, spacing: 2) {
                    // Display only the exercise name
                    Text("• \(exercise.name)")
                        .foregroundColor(.gray)
                    
                    // For each set, show weight (lbs) and reps
                    ForEach(exercise.sets, id: \.id) { set in
                        HStack {
                            Text("lbs: \(set.weight)")
                            Text("Reps: \(set.reps)")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 220) // Keep the same height if desired
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }
}


struct RoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesView()
    }
}

