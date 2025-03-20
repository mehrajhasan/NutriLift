import SwiftUI
import Foundation

struct CreateRoutineView: View {
    @State private var routineName: String = "" // Allow user input for routine name
    @State private var searchText: String = ""
    @State private var selectedExercises: Set<String> = [] // Store exercises by name
    @State private var exercises: [Exercise] = []
    
    @Binding var routines: [Routine]
    @Environment(\.presentationMode) var presentationMode // Allows dismissing view
    
    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            searchText.isEmpty || exercise.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    
    var body: some View {
        VStack {
            Text("Create A Routine")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            TextField("Routine Name", text: $routineName)
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Search Exercises", text: $searchText)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: searchText) { newValue in
                    print("Search Text Changed: \(newValue)") // Debugging
                }
            
            
            Text("Total Selected: \(selectedExercises.count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            List(filteredExercises, id: \.id) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Button(action: {
                        if selectedExercises.contains(exercise.name) {
                            selectedExercises.remove(exercise.name)
                        } else {
                            selectedExercises.insert(exercise.name)
                        }
                    }) {
                        Image(systemName: selectedExercises.contains(exercise.name) ? "checkmark.square.fill" : "square")
                            .foregroundColor(.purple)
                    }
                }
                .padding(.vertical, 5)
            }
            
            .onAppear {
                fetchExercises()
            }
            
            Spacer()
            
            // Save Routine Button
            Button(action: saveRoutine) {
                Text("Save Routine")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(routineName.isEmpty || selectedExercises.isEmpty) // Disable if no name or exercises selected
        }
        .padding()
    }
    
    func fetchExercises() {
        guard let url = URL(string: "http://localhost:3000/api/exercises") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Exercise].self, from: data)
                    DispatchQueue.main.async {
                        self.exercises = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func saveRoutine() {
        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            print("No user ID found.")
            return
        }
        
        // Convert Set<String> to Array<String>
        let exercisesArray = Array(selectedExercises)
        
        let newRoutine: [String: Any] = [
            "title": routineName,
            "exercises": exercisesArray, //Ensure this is an array
            "user_id": userId
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/routines") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: newRoutine, options: [])
            print("Request body:", String(data: request.httpBody!, encoding: .utf8)!) // Log request body
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
                print("Server Response Code:", httpResponse.statusCode) // Log HTTP response code
            }
            
            if let data = data {
                do {
                    let savedRoutine = try JSONDecoder().decode(Routine.self, from: data)
                    DispatchQueue.main.async {
                        routines.append(savedRoutine)
                        print("Routine saved successfully:", savedRoutine) //Log success
                        presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    print("Error decoding response:", error) // Log decoding error
                }
            }
        }.resume()
    }
}

//FOR TESTING
struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoutineView(routines: .constant([
            Routine(title: "Sample Routine", exercises: ["Bench Press", "Squats"])
        ]))
    }
}
