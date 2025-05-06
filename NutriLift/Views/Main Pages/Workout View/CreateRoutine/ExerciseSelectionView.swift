//
//  ExerciseSelectionView.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/20/25.
//


import SwiftUI
import Foundation


// view for picking exercises from a list
struct ExerciseSelectionView: View {
    @State private var searchText: String = "" // holds what user types in the search bar
    @State private var exercises: [Exercise] = [] // stores all available exercises
    @Binding var selectedExercises: [ExerciseEntry]// tracks exercises the user has picked
    @Environment(\.presentationMode) var presentationMode
    
    
    // filters exercises based on search input
    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            searchText.isEmpty || exercise.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack {
            // search bar
            TextField("Search Exercises", text: $searchText)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            
            // shows list of filtered exercises
            List(filteredExercises, id: \.id) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Button(action: {
                        toggleExerciseSelection(for: exercise)
                    }) {
                        Image(systemName: selectedExercises.contains(where: { $0.name == exercise.name }) ? "checkmark.square.fill" : "square")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            
            // button to close the view when done
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .onAppear {
            fetchExercises() // load exercises from the backend when view shows up
        }
    }
    
    
    // handles selecting or unselecting an exercise
    func toggleExerciseSelection(for exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.name == exercise.name }) {
            selectedExercises.remove(at: index)
        } else {
            let newEntry = ExerciseEntry(
                id: UUID().uuidString,
                name: exercise.name,
                sets: []
            )
            selectedExercises.append(newEntry)
        }
    }
    
    
    // pulls exercise data from the backend
    func fetchExercises() {
        guard let url = URL(string: "http://localhost:3000/api/exercises") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let decodedData = try! JSONDecoder().decode([Exercise].self, from: data)
                DispatchQueue.main.async {
                    self.exercises = decodedData
                }
            }
        }.resume()
    }

}
