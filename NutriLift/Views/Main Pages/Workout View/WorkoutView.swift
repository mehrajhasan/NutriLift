//
//  WorkoutRoutine.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/9/25.
//

import SwiftUI

struct RoutinesView: View {
    @State private var routines: [Routine] = []
    @State private var selectedRoutine: Routine?
    @State private var isWorkoutActive = false
    @State private var editingRoutine: Routine?
    
    
    
    var body: some View {
        ZStack {
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
                                RoutineCard(
                                    routine: routine,
                                    onDelete: { fetchRoutines() }, //refresh after delete
                                    onEdit: { editingRoutine = routine }
                                )
                                .onTapGesture {
                                    selectedRoutine = routine
                                    isWorkoutActive = false
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                }
                .onAppear {
                    fetchRoutines()
                }
            }
            if let routine = selectedRoutine, !isWorkoutActive {
                
                ZStack {
                    // dimmed background that dismisses on tap
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            selectedRoutine = nil
                        }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Button {
                                selectedRoutine = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primary)
                                    .padding(8)
                            }
                            Spacer()
                        }
                        
                        Text(routine.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(routine.exercises) { exercise in
                                HStack {
                                    Text("\(exercise.sets.count)  x")
                                        .frame(width: 30, alignment: .leading)
                                    Text(exercise.name)
                                    Spacer()
                                }
                            }
                        }
                        
                        Button("Start Workout") {
                            isWorkoutActive = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    .padding(.horizontal, 24)
                }
                
            }
        }
        .sheet(isPresented: $isWorkoutActive) {
            if let routine = selectedRoutine {
                WorkoutSessionView(routine: routine) {
                    isWorkoutActive = false
                    selectedRoutine = nil
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)
            }
        }
        
        .sheet(item: $editingRoutine) { routine in
            EditRoutineView(
                routineName: routine.title,
                selectedExercises: routine.exercises,
                routineId: routine.id
            ) {
                editingRoutine = nil
                fetchRoutines()
            }
        }
        
    }
    
    
    
    
    func fetchRoutines() {
        /*
         Upadted a bug used the old token variable while handing the FK userToken
         Works and checked the FK  - Jairo
         */
        
        
        // Since the endpoint now derives the user from the token, we use that.
        guard let url = URL(string: "http://localhost:3000/api/routines") else {
            print("Invalid API URL.")
            return
        }
        
        // Create a URLRequest so we can add custom headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add Authorization header if token is available
        if let token = UserDefaults.standard.string(forKey: "userToken") {
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
                        routines = decodedData
                    }
                } catch {
                    print("Error decoding JSON:", error)
                }
            }
        }.resume()
        
    }
}


/*
 struct WorkoutView_Previews: PreviewProvider {
 static var previews: some View {
 RoutinesView()
 }
 }
 */









struct RoutineCard: View {
    let routine: Routine
    var onDelete: () -> Void
    var onEdit: () -> Void
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with title and three dots menu
            HStack {
                Text(routine.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Menu {
                    Button(action: {
                        onEdit()
                    }) {
                        Label("Edit Routine", systemImage: "pencil")
                    }
                    
                    
                    Button(action: {
                        if let token = UserDefaults.standard.string(forKey: "userToken") {
                            deleteRoutine(routineId: routine.id, token: token) { success in
                                if success {
                                    DispatchQueue.main.async {
                                        onDelete()
                                    }
                                }
                            }
                        }
                    }) {
                        Label("Delete Routine", systemImage: "trash")
                    }
                    
                    
                    
                    Button(action: {
                        // Toggle collapse
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
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
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
                }
            }
            .frame(maxHeight: isExpanded ? .infinity : 120)
            
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
        // Fixed height when collapsed is automatic when expanded
        .frame(height: isExpanded ? nil : 220)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }
}


/*
 
 
 Delete Routine
 
 
 */

func deleteRoutine(routineId: Int, token: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/routines/\(routineId)") else {
        completion(false)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            completion(httpResponse.statusCode == 200)
        } else {
            completion(false)
        }
    }.resume()
}


struct RoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesView()
    }
}
