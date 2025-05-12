//
//  WorkoutEntry.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 4/20/25.
//

import SwiftUI
import Foundation

// holds a single set during a live workout session
struct LiveSetEntry: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var weight: String
    var reps: String
    var isCompleted: Bool = false
}


// holds one full exercise with its list of sets during a workout
struct LiveWorkoutEntry: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var sets: [LiveSetEntry] = []
}

// shows a card for a single live workout exercise

struct LiveExerciseCardView: View {
    @Binding var exercise: LiveWorkoutEntry
    var onDelete: () -> Void
    @State private var showingDeleteOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Menu {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(.trailing, 4)
                }
        }
        .padding(.horizontal, 8)
        // column headers for set info
        HStack(spacing: 10) {
            Text("Set")
                .frame(width: 30, alignment: .center)
                .padding(.leading, 10)
            
            Text("Previous")
                .frame(width: 100, alignment: .center)
            
            Text("lbs")
                .frame(width: 80, alignment: .center)
            
            Text("Reps")
                .frame(width: 50, alignment: .center)
            
            Image(systemName: "checkmark")
                .frame(width: 30, alignment: .center)
                .padding(.leading, 8)
                .padding(.trailing, 5)
        }
        .font(.caption)
        .foregroundColor(.gray)
        .padding(.horizontal, 8)
        
        List {
            ForEach(Array($exercise.sets.enumerated()), id: \.element.id) { index, $set in
                HStack(spacing: 4) {
                    Text("\(index + 1)")
                        .frame(width: 30)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                        .padding(.trailing, 10)
                    //Text("\(set.weight) lb × \(set.reps)")
                    TextField("Coming Soon", text: .constant(""))
                        .frame(width: 100)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    TextField("lbs", text: $set.weight)
                        .frame(width: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 25)
                    
                    TextField("reps", text: $set.reps)
                        .frame(width: 40)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 20)
                    
                    
                    
                    Button(action: {
                        set.isCompleted.toggle()
                    }) {
                        Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(set.isCompleted ? .green : .gray)
                        
                    }
                    .frame(width: 20)
                    .padding(.leading, 25)
                }
                .padding(.vertical, 6)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteSet(at: index)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
        .frame(height: CGFloat(exercise.sets.count) * 55)
        
        // button to add a new set to the exercise
        Button(action: {
            exercise.sets.append(LiveSetEntry(id: UUID().uuidString, weight: "", reps: "", isCompleted: false))
        }) {
            Text("+ Add Set")
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }
        .padding(10)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.15), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 10)
}
// removes a set from the list
private func deleteSet(at index: Int) {
    exercise.sets.remove(at: index)
}
}

#Preview {
    LiveExerciseCardView(
        exercise: .constant(
            LiveWorkoutEntry(
                id: UUID().uuidString,
                name: "Dumbbell Bench Press",
                sets: [
                    LiveSetEntry(id: UUID().uuidString, weight: "500", reps: "10", isCompleted: false),
                    LiveSetEntry(id: UUID().uuidString, weight: "55", reps: "8", isCompleted: true)
                ]
            )
        ),
        onDelete: {}
    )
}


