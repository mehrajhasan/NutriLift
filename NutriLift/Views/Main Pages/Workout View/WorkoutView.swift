//
//  WorkoutRoutine.swift
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
        // If you need to check for a stored token (and/or user ID), do so here.
        // Since the endpoint now derives the user from the token, we use that.
        guard let url = URL(string: "http://localhost:3000/api/routines") else {
            print("Invalid API URL.")
            return
        }
        
        // Create a URLRequest so we can add custom headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add Authorization header if token is available
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No token found in UserDefaults.")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request failed:", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Server Response Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8) ?? "No response"
                print("Raw Server Response:", rawResponse)
                
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
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with title and three-dots menu
            HStack {
                Text(routine.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Menu {
                    Button(action: {
                        // Delete routine action
                        print("Delete routine: \(routine.title)")
                    }) {
                        Label("Delete Routine", systemImage: "trash")
                    }
                    Button(action: {
                        // Toggle expand/collapse
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Label(isExpanded ? "Collapse" : "View Full Routine",
                              systemImage: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(.horizontal)
                        .foregroundColor(.black)
                }
            }
            
            // Routine view styling - show only first three exercises if not expanded
            ForEach(
                isExpanded
                    ? Array(routine.exercises)
                    : Array(routine.exercises.prefix(3)),
                id: \.id
            ) { exercise in
                VStack(alignment: .leading, spacing: 2) {
                    Text("• \(exercise.name)")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
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
            
            // "Viewmore" button if more than 3 exercises and not expanded
            if !isExpanded && routine.exercises.count > 3 {
                Button("Viewmore") {
                    withAnimation {
                        isExpanded = true
                    }
                }
                .font(.caption)
                .padding(.top, 5)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        // Fixed height when collapsed; automatic when expanded
        .frame(height: isExpanded ? nil : 220)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }
}

struct RoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesView()
    }
}
