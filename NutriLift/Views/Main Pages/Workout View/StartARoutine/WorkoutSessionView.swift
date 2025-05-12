//
//  WorkoutSessionView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 4/11/25.
//

import SwiftUI

struct WorkoutSessionView: View {
    
    //Stopwatch Int
    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var startTime: Date? = nil
    
    //Add exercise logic
    @State private var ShowExerciseSearch = false
    @State private var TempExerciseEntries: [ExerciseEntry] = []
    
    
    
    let routine: Routine
    @State private var exercises: [LiveWorkoutEntry]
    let onEnd: () -> Void
    
    init(routine: Routine, onEnd: @escaping () -> Void) {
        self.routine = routine
        self.onEnd = onEnd
        _exercises = State(initialValue:
                            routine.exercises.map { exercise in
            LiveWorkoutEntry(
                id: exercise.id,
                name: exercise.name,
                sets: exercise.sets.map { set in
                    LiveSetEntry(
                        id: set.id,
                        weight: String(set.weight),
                        reps: String(set.reps),
                        isCompleted: false // default all sets as not completed
                    )
                }
            )
        }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Spacer(minLength: 20)// pushes everything down
                // Title and Timer
                VStack(spacing: 4) {
                    Text(routine.title)
                        .font(.largeTitle.bold())
                        .padding(.top,50)
                        
                    
                    Text(formatElapsedTime())
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($exercises) { $exercise in
                            LiveExerciseCardView(exercise: $exercise, onDelete: {
                                deleteEx(exerciseID: exercise.id)
                            })
                        }
                        Button(action: {
                            onEnd()
                        }) {
                            Text("Cancel Workout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                    }
                }
                
                NavigationLink(destination: ExerciseSelectionView(selectedExercises: $TempExerciseEntries)
                    .onDisappear {
                        let newLiveEntries = TempExerciseEntries.map { entry in
                            LiveWorkoutEntry(
                                id: entry.id,
                                name: entry.name,
                                sets: entry.sets.map { set in
                                    LiveSetEntry(
                                        id: set.id,
                                        weight: set.weight,
                                        reps: set.reps,
                                        isCompleted: false
                                    )
                                }
                            )
                        }
                        for newExercise in newLiveEntries {
                            if !exercises.contains(where: { $0.name == newExercise.name }) {
                                exercises.append(newExercise)
                            }
                        }
                    },
                               isActive: $ShowExerciseSearch
                ) {
                    EmptyView()
                }
                
            }
            
            
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        ShowExerciseSearch = true
                        TempExerciseEntries = []
                    }) {
                        Text("Add")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.top, 50)
                            .padding(.bottom, 50)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addpoints(userId: routine.user_id)
                        onEnd()
                    }) {
                        Text("Finish")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.top, 50)
                            .padding(.bottom, 50)
                    }
                }
            }
            
        }
        
        .onAppear {
            Startworkouttime()
            
            
            
        }
        
    }
    
    
    
    
    
    /*
     
     
     Delete
     
     
     
     */
    
    private func deleteEx(exerciseID: String) {
        exercises.removeAll { $0.id == exerciseID }
    }
    
    
    
    
    /*
     
     
     
     
     Live Timer
     
     
     
     
     
     */
    
    private func Startworkouttime() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    private func StopWorkoutTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatElapsedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

/*
 
 
 Finish Button
 
 
 */

private func addpoints(userId: Int) {
    let url = URL(string: "http://localhost:3000/api/userprofiles/\(userId)/increment-points")!
    print("Sending 20 points for user \(userId)")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request).resume()
}




#Preview {
    WorkoutSessionView(
        routine: Routine(
            id: 1,
            title: "Push Day",
            exercises: [
                ExerciseEntry(
                    id: UUID().uuidString,
                    name: "Bench Press",
                    sets: [
                        SetEntry(id: UUID().uuidString, weight: "135", reps: "10"),
                        SetEntry(id: UUID().uuidString, weight: "145", reps: "8")
                    ]
                ),
                ExerciseEntry(
                    id: UUID().uuidString,
                    name: "Shoulder Press",
                    sets: [
                        SetEntry(id: UUID().uuidString, weight: "50", reps: "12"),
                        SetEntry(id: UUID().uuidString, weight: "55", reps: "10")
                    ]
                )
            ],
            created_at: nil,
            user_id: 1
        ),
        onEnd: {}
    )
}

